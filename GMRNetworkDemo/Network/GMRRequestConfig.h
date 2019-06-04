//
//  GMRRequestConfig.h
//  GMRNetworkDemo
//
//  Created by LeeSen on 2019/6/2.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GMRResponseSerializerType)
{
    GMRResponseSerializerTypeHTTP,
    GMRResponseSerializerTypeJSON,
    GMRResponseSerializerTypeXMLParse
};

@interface GMRRequestConfig : NSObject

/// 是否从缓存读取数据, 默认是YES
@property (nonatomic, assign, getter=isIgnoreCache) BOOL ignoreCache;
/// 缓存时长
@property (nonatomic, assign) CGFloat cacheDuration;
/// 是否从缓存中加载
@property (nonatomic, assign) BOOL loadFromCache;
/// 是否开启分页
@property (nonatomic, assign) BOOL pageEnable;
/// 是否关闭日志打印
@property (nonatomic, assign) BOOL logEnable;
/// 是否显示菊花转
@property (nonatomic, assign) BOOL showLoading;
/// 是否开启错误提示
@property (nonatomic, assign) BOOL alertError;
/// 缓存的文件名
@property (nonatomic, copy) NSString *cacheFileName;

@end

NS_ASSUME_NONNULL_END
