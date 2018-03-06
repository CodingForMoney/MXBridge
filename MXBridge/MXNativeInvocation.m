//
//  MXNativeInvocation.m
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/8.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import "MXNativeInvocation.h"

@interface MXNativeInvocation()

/**
  调用时间.
 */
@property (nonatomic,strong) NSDate *callDate;

@end

@implementation MXNativeInvocation

- (instancetype)initWithJSCall:(NSDictionary *)jscall {
    if (self = [super init]) {
        _functionName = jscall[@"functionName"] ;
        _pluginName = jscall[@"pluginName"];
        _arguments = jscall[@"arguments"];
        _invocationID = jscall[@"invocationID"];
        _callDate = [NSDate date];
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

- (NSString *)description {
    return [NSString stringWithFormat:@"PluginName : %@ \n FunctionName : %@ \n callID : %@ \n Arguments : %@ ",_pluginName,_functionName,_invocationID,_arguments];
}


@end
