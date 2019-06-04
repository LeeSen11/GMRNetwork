//
//  GMRCacheManager.m
//  GMRNetworkDemo
//
//  Created by LeeSen on 2019/6/2.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import "GMRCacheManager.h"
#import "GMRRequestConfig.h"
#import "GMRNetworkManager.h"

NSString *const GMRRequestCacheErrorDomain = @"com.GMR.request.caching";

static dispatch_queue_t gmrrequest_cache_writing_queue() {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_attr_t attr = DISPATCH_QUEUE_SERIAL;
        attr = dispatch_queue_attr_make_with_qos_class(attr, QOS_CLASS_BACKGROUND, 0);
        queue = dispatch_queue_create("com.GMR.gmrrequest.caching", attr);
    });
    
    return queue;
}

@interface GMRCacheMetadata : NSObject <NSSecureCoding>

@property (nonatomic, assign) long long version;
@property (nonatomic, strong) NSString *sensitiveDataString;
@property (nonatomic, assign) NSStringEncoding stringEncoding;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSString *appVersionString;

@end

@implementation GMRCacheMetadata

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.version = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(version))] integerValue];
    self.sensitiveDataString = [[aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(sensitiveDataString))] stringValue];
    self.stringEncoding = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(stringEncoding))] integerValue];
    self.creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(creationDate))];
    self.appVersionString = [[aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(appVersionString))] stringValue];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(self.version) forKey:NSStringFromSelector(@selector(version))];
    [aCoder encodeObject:self.sensitiveDataString forKey:NSStringFromSelector(@selector(sensitiveDataString))];
    [aCoder encodeObject:@(self.stringEncoding) forKey:NSStringFromSelector(@selector(stringEncoding))];
    [aCoder encodeObject:self.creationDate forKey:NSStringFromSelector(@selector(creationDate))];
    [aCoder encodeObject:self.appVersionString forKey:NSStringFromSelector(@selector(appVersionString))];
}

@end


@interface GMRCacheManager ()

@property (nonatomic, strong) GMRRequestConfig *requestConfig;
@property (nonatomic, assign) BOOL isDataFromCache;
@property (nonatomic, strong) GMRCacheMetadata *cacheMetadata;

@end

@implementation GMRCacheManager


- (instancetype)initWithRequestConfig:(GMRRequestConfig *)config
{
    if (self = [super init]) {
        self.requestConfig = config;
    }
    return self;
}

#pragma mark - Public Methods
- (BOOL)loadFromCache:(GMRRequestConfig *)config
{
    _requestConfig = config;
    if (config.isIgnoreCache) {
        return NO;
    }
    /// 判断缓存文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[self cacheBasePath] stringByAppendingPathComponent:_requestConfig.cacheFileName] isDirectory:nil]) {
        return NO;
    }
    // 判断缓存是否过期
    NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self cacheBasePath] stringByAppendingPathComponent:_requestConfig.cacheFileName] error:nil];
    NSDate *modificationDate = fileAttr[NSFileModificationDate];
    NSTimeInterval modificationInterval = [modificationDate timeIntervalSince1970];
    NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
    if ((currentInterval - modificationInterval) > _requestConfig.cacheDuration) {
        return NO;
    }
    return YES;
}

/**
 *  fileName: 缓存文件名
 *  error: 读取文件过程中发生的错误
 */
- (NSDictionary *)cacheDataForFile: (NSString *)fileName {
//    NSData *cacheData = [NSData dataWithContentsOfFile:[[self cacheBasePath] stringByAppendingPathComponent:_requestConfig.cacheFileName]];
    NSDictionary *cacheData = [NSDictionary dictionaryWithContentsOfFile:[[self cacheBasePath] stringByAppendingPathComponent:_requestConfig.cacheFileName]];
    return cacheData;
}

- (void)cacheResponseObject:(id)response
{
    NSString *basePath = [self cacheBasePath];
    NSString *cacheFilePath = [basePath stringByAppendingPathComponent:_requestConfig.cacheFileName];
    [response writeToFile:cacheFilePath atomically:YES];
}












#pragma mark - Private Methods
- (BOOL)loadCacheWithError: (NSError * _Nullable __autoreleasing *)error
{
    if (_requestConfig.cacheDuration < 0) {
        if (error) {
            *error = [NSError errorWithDomain:GMRRequestCacheErrorDomain code:GMRRequestCacheErrorInvalidCacheDuration userInfo:@{NSLocalizedDescriptionKey: @"Invalid Cache Duration"}];
        }
        return NO;
    }
    if (![self loadCacheMetadata]) {
        if (error) {
            *error = [NSError errorWithDomain:GMRRequestCacheErrorDomain code:GMRRequestCacheErrorInvalidMetadata userInfo:@{NSLocalizedDescriptionKey: @"Invalid metadata. Cache may not exist"}];
        }
        return NO;
    }
    
    return YES;
}

#pragma mark - Private Methods
- (BOOL)loadCacheMetadata
{
    NSString *path = [self cacheMetadataFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        @try {
            _cacheMetadata = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            return YES;
        } @catch (NSException *exception) {
            GMRLog(@"Load cache metadata failed, reason = %@", exception.reason);
            return NO;
        }
    }
    return NO;
}

- (NSString *)cacheMetadataFilePath
{
    NSString *cacheMetadataFileName = [NSString stringWithFormat:@"%@.metadata", _requestConfig.cacheFileName];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheMetadataFileName];
    return path;
}

- (NSString *)cacheBasePath
{
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"LazyRequestCache"];
    [self createDirectoryIfNeed:path];
    return path;
}

- (void)createDirectoryIfNeed: (NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
        }
    }
}

- (void)createBaseDirectoryAtPath: (NSString *)path {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        GMRLog(@"create cache direcotry failed, error = %@", error);
    } else {
        NSURL *url = [NSURL fileURLWithPath:path];
        NSError *backupError = nil;
        [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&backupError];
        if (backupError) {
            GMRLog(@"error to set do not backup attribute, error = %@", backupError);
        }
    }
}

- (void)saveResponseDataToCacheFile: (NSData *)data
{
    
}

@end
