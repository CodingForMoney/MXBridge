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
    }
    return self;
}

- (void)callBackSuccess:(BOOL)success withDictionary:(NSDictionary *)dict toInvocation:(MXCallNativeInvocation *)invocation {
    [_bridge callBackSuccess:success withDictionary:dict toInvocation:invocation];
}


- (void)successCallBackWithDictionary:(NSDictionary *)dict toInvocation:(MXCallNativeInvocation *)invocation {
    [self callBackSuccess:YES withDictionary:dict toInvocation:invocation];
}


- (void)failCallBackWithDictionary:(NSDictionary *)dict toInvocation:(MXCallNativeInvocation *)invocation {
    [self callBackSuccess:NO withDictionary:dict toInvocation:invocation];
}



- (void)callBackSuccess:(BOOL)success withString:(NSString *)string toInvocation:(MXCallNativeInvocation *)invocation {
    [_bridge callBackSuccess:success withString:string toInvocation:invocation];
}

- (void)successCallBackWithString:(NSString *)string toInvocation:(MXCallNativeInvocation *)invocation {
    [self callBackSuccess:YES withString:string toInvocation:invocation];
}

- (void)failCallBackWithString:(NSString *)string toInvocation:(MXCallNativeInvocation *)invocation {
    [self callBackSuccess:NO withString:string toInvocation:invocation];
}

- (void)callBackSuccess:(BOOL)success withArray:(NSArray *)array toInvocation:(MXCallNativeInvocation *)invocation {
    [_bridge callBackSuccess:success withArray:array toInvocation:invocation];
}

- (void)successCallBackWithArray:(NSArray *)array toInvocation:(MXCallNativeInvocation *)invocation {
    [self callBackSuccess:YES withArray:array toInvocation:invocation];
}

- (void)failCallBackWithArray:(NSArray *)array toInvocation:(MXCallNativeInvocation *)invocation {
    [self callBackSuccess:NO withArray:array toInvocation:invocation];
}

@end
