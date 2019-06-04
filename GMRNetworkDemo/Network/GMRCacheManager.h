//
//  GMRCacheManager.h
//  GMRNetworkDemo
//
//  Created by LeeSen on 2019/6/2.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_ENUM(NSUInteger) {
    GMRRequestCacheErrorExpired = -1,
    GMRRequestCacheErrorVersionDismatch = -2,
    GMRRequestCacheErrorSensitiveDataMismatch = -3,
    GMRRequestCacheErrorInvalidCacheDuration = -4,
    GMRRequestCacheErrorInvalidMetadata = -5,
    GMRRequestCacheErrorInvalidCacheData = -6
};

@class GMRRequestConfig;
@interface GMRCacheManager : NSObject

- (instancetype)initWithRequestConfig: (GMRRequestConfig *)config;
- (instancetype)initWithFileName: (NSString *)fileName;
- (BOOL)loadFromCache: (GMRRequestConfig *)config;
- (NSDictionary *)cacheDataForFile: (NSString *)fileName;
- (void)cacheResponseObject: (id)response;

@end

NS_ASSUME_NONNULL_END
