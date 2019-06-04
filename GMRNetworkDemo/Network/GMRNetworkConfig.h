//
//  GMRNetworkConfig.h
//  GMRNetworkDemo
//
//  Created by LeeSen on 2019/6/2.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMRNetworkConfig : NSObject

@property (nonatomic, copy) NSString *baseUrl;
@property (nonatomic, assign) BOOL debugEnable;

+ (GMRNetworkConfig *)sharedConfig;

@end

NS_ASSUME_NONNULL_END
