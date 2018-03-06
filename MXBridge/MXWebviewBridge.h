//
//  MXWebviewBridge.h
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/9.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>
#import "MXNativeInvocation.h"
/**
 *  与webview进行通讯的桥梁,可以调用JS,也可以被JS调用.
 */
@interface MXWebviewBridge : NSObject

/**
 *  以webview初始化.
 *
 *  @param webview <#webview description#>
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithWebview:(UIWebView *)webview;

/**
 *  每次在webViewDidFinishLoad 中，初始化JSContext。
 */
- (void)setupJSContext;


/**
 *  持有一份webview
 */
@property (nonatomic,weak,readonly) UIWebView *webview;

/**
 *  容器viewcontroller。外部可以设置这个值,没有设置,会通过 view的层级找到持有webview的ViewController
 */
@property (nonatomic,weak) UIViewController *containerVC;

/**
 *  异步回调，异步回传数据 给JS端。
 *
 *  @param success    是否成功
 *  @param dict       回传一个NSDictionary的对象,到JS端会是一个json对象
 *  @param invocation 根据调用ID进行回调.
 */
- (void)callBackSuccess:(BOOL)success withDictionary:(NSDictionary *)dict toInvocation:(MXNativeInvocation *)invocation ;

// 回调，传 String类型的数据 给js。
- (void)callBackSuccess:(BOOL)success withString:(NSString *)string toInvocation:(MXNativeInvocation *)invocation ;

// 回调，传递 array 类型数据
- (void)callBackSuccess:(BOOL)success withArray:(NSArray *)array toInvocation:(MXNativeInvocation *)invocation;

@end
