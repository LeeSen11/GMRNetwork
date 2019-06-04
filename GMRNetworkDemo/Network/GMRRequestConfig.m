//
//  GMRRequestConfig.m
//  GMRNetworkDemo
//
//  Created by LeeSen on 2019/6/2.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import "GMRRequestConfig.h"

@implementation GMRRequestConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ignoreCache = NO;
    }
    return self;
}

@end
