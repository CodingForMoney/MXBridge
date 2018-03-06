//
//  MXWebviewPlugin.h
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/9.
//  Copyright © 2016年 罗贤明. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "MXWebviewBridge.h"
#import "MXNativeInvocation.h"


/**
 定义输出函数的宏
 
 @param js_name js中使用的函数名
 @param method native 的 selector
 
 */
#define MX_EXTERN_METHOD(js_name, method) \
+ (NSArray<NSString *> *)__mx_export__##js_name { \
return @[@#js_name , NSStringFromSelector(@selector( method ))] ; \
}


/**
 *  插件基类。
 */
@interface MXWebviewPlugin : NSObject {
    __weak MXWebviewPlugin *_weakSelf;
}

@property (nonatomic,weak,readonly) MXWebviewBridge *bridge;

/**
    VC可能不存在。 
 */
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

// 派生的插件中，同步调用的方法，返回值是一个Dictionary，可以返回空。
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
- (void)callBackSuccess:(BOOL)success withDictionary:(NSDictionary *)dict toInvocation:(MXNativeInvocation *)invocation;


- (void)successCallBackWithDictionary:(NSDictionary *)dict toInvocation:(MXNativeInvocation *)invocation;

- (void)failCallBackWithDictionary:(NSDictionary *)dict toInvocation:(MXNativeInvocation *)invocation;

// callback 返回一个字符串。
- (void)callBackSuccess:(BOOL)success withString:(NSString *)string toInvocation:(MXNativeInvocation *)invocation;

- (void)successCallBackWithString:(NSString *)string toInvocation:(MXNativeInvocation *)invocation;

- (void)failCallBackWithString:(NSString *)string toInvocation:(MXNativeInvocation *)invocation;

// callback 返回一个数组

- (void)callBackSuccess:(BOOL)success withArray:(NSArray *)array toInvocation:(MXNativeInvocation *)invocation;

- (void)successCallBackWithArray:(NSArray *)array toInvocation:(MXNativeInvocation *)invocation;

- (void)failCallBackWithArray:(NSArray *)array toInvocation:(MXNativeInvocation *)invocation;



@end
