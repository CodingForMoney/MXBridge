//
//  MXNativeMethod.m
//  MXWebviewDemo
//
//  Created by lxm on 2017/3/29.
//  Copyright © 2017年 罗贤明. All rights reserved.
//

#import "MXNativeMethod.h"


@interface MXNativeMethod ()

// 方法是否有返回值
@property (nonatomic) BOOL hasReturn;
// 方法是否有参数
@property (nonatomic) BOOL hasArguments;

@end

@implementation MXNativeMethod

- (instancetype)initWithName:(NSString *)name selector:(SEL)seletor signature:(NSMethodSignature *)signature {
    if (self = [super init]) {
        _name = name;
        _selector = seletor;
        _signature = signature;
        _hasReturn = strcmp([signature methodReturnType] , "v");
        _hasArguments = _signature.numberOfArguments > 2;
    }
    return  self;
}

- (id)invokeWithObject:(MXCallNativeInvocation *)invocation onTarget:(id)target {
    NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:_signature];
    __autoreleasing id returnValue;
    invoc.selector = _selector;
    invoc.target = target;
    if (_hasArguments) {
        [invoc setArgument:&invocation atIndex:2];
    }
    [invoc invoke];
    if (_hasReturn) {
        // 所以returnValue必须是 Object类型，否则崩溃。
        [invoc getReturnValue:&returnValue];
    }
    return returnValue;
}

@end
