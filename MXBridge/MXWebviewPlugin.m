//
//  MXWebviewPlugin.m
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/9.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import "MXWebviewPlugin.h"

@implementation MXWebviewPlugin

- (UIViewController *)containerVC {
    return _bridge.containerVC;
}

- (UIWebView *)webview {
    return _bridge.webview;
}

- (instancetype)initWithBridge:(MXWebviewBridge *)bridge {
    if (self = [super init]) {
        _bridge = bridge;
        _weakSelf = self;
    }
    return self;
}

- (void)callBackSuccess:(BOOL)success withDictionary:(NSDictionary *)dict toInvocation:(MXMethodInvocation *)invocation {
    [_bridge callBackSuccess:success withDictionary:dict toInvocation:invocation];
}


- (void)successCallBackWithDictionary:(NSDictionary *)dict toInvocation:(MXMethodInvocation *)invocation {
    [self callBackSuccess:YES withDictionary:dict toInvocation:invocation];
}


- (void)failCallBackWithDictionary:(NSDictionary *)dict toInvocation:(MXMethodInvocation *)invocation {
    [self callBackSuccess:NO withDictionary:dict toInvocation:invocation];
}



- (void)callBackSuccess:(BOOL)success withString:(NSString *)string toInvocation:(MXMethodInvocation *)invocation {
    [_bridge callBackSuccess:success withString:string toInvocation:invocation];
}

- (void)successCallBackWithString:(NSString *)string toInvocation:(MXMethodInvocation *)invocation {
    [self callBackSuccess:YES withString:string toInvocation:invocation];
}

- (void)failCallBackWithString:(NSString *)string toInvocation:(MXMethodInvocation *)invocation {
    [self callBackSuccess:NO withString:string toInvocation:invocation];
}

@end
