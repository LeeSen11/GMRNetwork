//
//  GMRNetworkConfig.m
//  GMRNetworkDemo
//
//  Created by LeeSen on 2019/6/2.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import "GMRNetworkConfig.h"

@implementation GMRNetworkConfig

+ (GMRNetworkConfig *)sharedConfig
{
    static GMRNetworkConfig *util = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = [[self alloc] init];
    });
    return util;
}

- (void)setBaseUrl:(NSString *)baseUrl
{
    NSAssert(baseUrl.length != 0, @"baseURL不能为空");
    NSString *trimStr = [baseUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSAssert(trimStr.length != 0, @"baseURL不能为空格");
    _baseUrl = baseUrl;
}


@end
