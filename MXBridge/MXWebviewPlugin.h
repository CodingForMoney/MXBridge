//
//  MXWebviewPlugin.h
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/9.
//  Copyright © 2016年 罗贤明. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "MXWebviewBridge.h"
#import "MXMethodInvocation.h"
/**
 *  插件基类。
 */
@interface MXWebviewPlugin : NSObject

@property (nonatomic,weak,readonly) MXWebviewBridge *bridge;

@property (nonatomic,weak,readonly) UIViewController *containerVC;

@property (nonatomic,weak,readonly) UIWebView *webview;

/**
 *  初始化
 *
 *  @param bridge <#bridge description#>
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithBridge:(MXWebviewBridge *)bridge;

// 注意，同步调用的执行，不在 主线程中， 而 异步调用 的执行 在主线程中进行的。

// 派生的插件中，同步调用的方法，返回值是一个Dictionary，可以返回空。 但是函数上的返回值，必须声明为NSDictionary * ， 否则会崩溃。
//- (NSDictionary *)syncFunction（:(MXMethodInvocation *)invocation）;，
// 异步调用。 可以带有后面的 invocation 参数，也可以不带。
//- (void)asynFunction（:(MXMethodInvocation *)invocation）;


// callback ,返回的是一个js对象
/**
 *  回调的基本方法
 *
 *  @param success    是否成功
 *  @param dict       一个dictionary，会被转换为json传给JS，响应的调用。
 *  @param invocation <#invocation description#>
 */
- (void)callBackSuccess:(BOOL)success withDictionary:(NSDictionary *)dict toInvocation:(MXMethodInvocation *)invocation;


- (void)successCallBackWithDictionary:(NSDictionary *)dict toInvocation:(MXMethodInvocation *)invocation;

- (void)failCallBackWithDictionary:(NSDictionary *)dict toInvocation:(MXMethodInvocation *)invocation;

// callback 返回一个字符串。
- (void)callBackSuccess:(BOOL)success withString:(NSString *)string toInvocation:(MXMethodInvocation *)invocation;

- (void)successCallBackWithString:(NSString *)string toInvocation:(MXMethodInvocation *)invocation;

- (void)failCallBackWithString:(NSString *)string toInvocation:(MXMethodInvocation *)invocation;


@end
