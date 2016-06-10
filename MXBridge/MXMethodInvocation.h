//
//  MXMethodInvocation.h
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/8.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  JS对OC的一次函数调用
 */
@interface MXMethodInvocation : NSObject

/**
 *  以一次JScall的调用进行初始化
 *
 *  @param jscall <#jscall description#>
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithJSCall:(NSDictionary *)jscall;

/**
 *  函数参数,可能为空，
 */
@property (nonatomic,strong) NSDictionary *arguments;

/**
 *  每一次调用都会有一个唯一ID，异步回调会使用这个ID。
 */
@property (nonatomic,strong) NSString *invocationID;


@property (nonatomic,strong) NSString *pluginName;

@property (nonatomic,strong) NSString *functionName;

@end
