//
//  MXNativeMethod.h
//  MXWebviewDemo
//
//  Created by lxm on 2017/3/29.
//  Copyright © 2017年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXNativeInvocation.h"


/**
  提供给js的Native方法的记录。 新的苹果审核规则中，禁止了为runtime方法传入动态参数，所以我们要将对方法名的判断固定在代码中。
 */
@interface MXNativeMethod : NSObject


@property (nonatomic,assign) SEL selector;


/**
 js调用的函数名。
 */
@property (nonatomic,strong) NSString *name;


@property (nonatomic,assign) NSMethodSignature *signature;


/**
 初始化
 */
- (instancetype)initWithName:(NSString *)name selector:(SEL)seletor signature:(NSMethodSignature *)signature;

/**
 调用方法
 
 @param invocation 传递参数
 @param target 目标
 */
- (id)invokeWithObject:(MXNativeInvocation *)invocation onTarget:(id)target;




@end
