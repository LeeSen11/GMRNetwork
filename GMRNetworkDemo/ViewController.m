//
//  ViewController.m
//  GMRNetworkDemo
//
//  Created by LeeSen on 2019/5/31.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "GMRNetworkManager.h"
#import "GMRNetworkConfig.h"
#import "GMRRequestConfig.h"

@interface ViewController ()

@property (nonatomic, strong) GMRRequestConfig *requestConfig;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [GMRNetworkManager setBaseURLString:@"http://192.168.1.232:8081"];
    
    [GMRNetworkConfig sharedConfig].baseUrl = @"http://192.168.1.232:8081";
    
//    [[GMRNetworkManager sharedInstance] GET:@"kobe" parameters:nil progress:nil completion:nil];
}

- (IBAction)eventButtonResponse:(UIButton *)sender {
    [[GMRNetworkManager sharedInstance] GET:@"cas-client/restlogin/getSysTemUrl"
                                 parameters:nil
                              requestConfig:self.requestConfig
                                   progress:nil
                         completionCallback:^(NSDictionary * _Nullable responseDic, NSError * _Nullable error) {
        if (error) {
            
        } else {
            
        }
    }];
}

- (GMRRequestConfig *)requestConfig
{
    if (!_requestConfig) {
        _requestConfig = [GMRRequestConfig new];
        _requestConfig.logEnable = YES;
        _requestConfig.ignoreCache = NO;
        _requestConfig.cacheDuration = 120;
    }
    return _requestConfig;
}

@end
