//
//  GMRNetworkManager.h
//  GMRNetworkDemo
//
//  Created by LeeSen on 2019/5/31.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMRRequestConfig.h"

#ifdef DEBUG
#define GMRLog(...) NSLog(@"%s Code Line:%d \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define GMRLog(...)
#endif


typedef void(^ProgressBlock)(NSProgress *_Nonnull);
typedef void(^SuccessBlock)(void);
typedef void(^FailureBlock)(void);


extern NSString * _Nonnull const GMRNetworkManagerDidLogoutNotification;



typedef NS_ENUM(NSInteger, GMRNetworkManagerError)
{
    GMRNetworkManagerLogoutError,
};




@interface GMRNetworkManager : NSObject

+ (GMRNetworkManager *_Nonnull)sharedInstance;

- (void)GET:(nonnull NSString *)URLString parameters:(nullable id)params requestConfig: (nullable GMRRequestConfig *)config progress:(nullable ProgressBlock)progress completionCallback:  (nonnull void (^)(NSDictionary * _Nullable, NSError * _Nullable))callback;


@end
