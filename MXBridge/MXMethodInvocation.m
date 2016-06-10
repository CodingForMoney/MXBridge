//
//  MXMethodInvocation.m
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/8.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import "MXMethodInvocation.h"

@implementation MXMethodInvocation

- (instancetype)initWithJSCall:(NSDictionary *)jscall {
    if (self = [super init]) {
        _functionName = jscall[@"functionName"] ;
        _pluginName = jscall[@"pluginName"];
        _arguments = jscall[@"arguments"];
        _invocationID = jscall[@"callID"];
        if (_functionName.length < 1 ) {
            NSLog(@"未传递调用函数functionName ，当前JSCall为 :%@",jscall);
            return nil;
        }
        if (_pluginName.length < 1 ) {
            NSLog(@"未传递调用函数pluginName ，当前JSCall为 :%@",jscall);
            return nil;
        }
    }
    return self;
}


@end
