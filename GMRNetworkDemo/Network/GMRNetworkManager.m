//
//  GMRNetworkManager.m
//  GMRNetworkDemo
//
//  Created by LeeSen on 2019/5/31.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import "GMRNetworkManager.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "GMRNetworkConfig.h"
#import "GMRCacheManager.h"

#import <CommonCrypto/CommonDigest.h>

NSString *kBaseURLString;
AFHTTPRequestSerializer *kRequestSerializer;

NSString * const GMRNetworkManagerDidLogoutNotification = @"GMRNetworkManagerDidLogoutNotification";

@interface GMRNetworkManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation GMRNetworkManager

+ (GMRNetworkManager *)sharedInstance
{
    static GMRNetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    NSString *baseUrl = [GMRNetworkConfig sharedConfig].baseUrl;
    NSAssert(baseUrl, @"请先设置baseURLString");
    self = [super init];
    if (self) {
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    }
    return self;
}

#pragma mark - Public Methods
- (void)GET:(NSString *)URLString parameters:(id)params requestConfig:(GMRRequestConfig *)config progress:(ProgressBlock)progress completionCallback:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))callback
{
    if (config.showLoading) {
        
    }
    NSString *requestInfo = [NSString stringWithFormat:@"Method: GET url: %@", URLString];
    NSString *cacheFileName = [GMRNetworkManager md5StringFromString:requestInfo];
    config.cacheFileName = cacheFileName;
    GMRCacheManager *cacheManager = [[GMRCacheManager alloc] initWithRequestConfig:config];
    if ([cacheManager loadFromCache:config]) {
        NSError *error;
        NSDictionary *cacheData = [cacheManager cacheDataForFile:config.cacheFileName];
        NSLog(@" ===  rcache data == %@",cacheData);
        if (callback) {
            callback(cacheData, error);
        }
    } else {
        __weak typeof(self) weakSelf = self;
        [self.sessionManager GET:[self relativeAPI:URLString] parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(downloadProgress);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *respDictionary = responseObject;
            NSString *responseCode = [respDictionary[@"code"] stringValue];
            if ([responseCode isEqualToString:@"302"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:GMRNetworkManagerDidLogoutNotification object:nil];
            } else if ([responseCode isEqualToString:@"200"] && callback) {
                callback(respDictionary, nil);
            }
            if (config.logEnable) {
                GMRLog(@"{url=%@}, {method = GET}, {paramters=%@}, ", task.currentRequest.URL, params);
            }
            if (config.cacheDuration > 1) {
                [cacheManager cacheResponseObject:responseObject];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.hud hideAnimated:YES];
            });
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf.hud hideAnimated:YES];
            if (callback) {
                callback(@{}, error);
            }
        }];
    }
}

#pragma mark - Private Methods
- (NSString *)relativeAPI: (NSString *)urlString
{
    NSURL *baseURL = [NSURL URLWithString:kBaseURLString];
    return [[NSURL URLWithString:urlString relativeToURL:baseURL] absoluteString];
}

+ (NSString *)md5StringFromString: (NSString *)string
{
    NSParameterAssert(string != nil && [string length] > 0);
    const char *value = [string UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }
    
    return outputString;
}

#pragma mark - Setters and Getters
- (MBProgressHUD *)hud
{
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication].windows firstObject]];
        _hud.mode = MBProgressHUDModeIndeterminate;
    }
    return _hud;
}

- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _loadingView.tintColor = [UIColor redColor];
        [[[UIApplication sharedApplication].windows lastObject] addSubview:_loadingView];
    }
    return _loadingView;
}

@end
