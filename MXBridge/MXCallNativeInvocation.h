//
//  MXCallNativeInvocation.h
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/8.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  JS对OC的一次函数调用信息
 */
@interface MXCallNativeInvocation : NSObject

/**
 *  以一次JScall的调用进行初始化
 *
 *  @param jscall <#jscall description#>
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithJSCall:(NSDictionary *)jscall;

/**
 *  函数参数,可能为空. 参数是一个Dictionary对象的形式,也就是JS调用的参数应该是一个JS的对象,json
 对象的形式.
 */
@property (nonatomic,strong) NSDictionary *arguments;

/**
 *  每一次调用都会有一个唯一ID，异步回调会使用这个ID。
 */
@property (nonatomic,strong) NSString *invocationID;

/**
 *  插件名
 */
@property (nonatomic,strong) NSString *pluginName;

/**
 *  函数名
 */
@property (nonatomic,strong) NSString *functionName;

@end
