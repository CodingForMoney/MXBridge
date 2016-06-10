//
//  MXWebviewBridge.h
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/9.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>
#import "MXMethodInvocation.h"
/**
 *  与webview进行通讯的桥。
 */
@interface MXWebviewBridge : NSObject

/**
 *  以webview初始化，两者互相持有。
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
 *  清空JS环境，释放环。
 */
- (void)cleanJSContext;

/**
 *  context是从webview中获取的，由webview自己管理，我们只管 webview是否存在的检测。
 */
@property (nonatomic,weak,readonly) JSContext *context;

/**
 *  Native端持有一份 JSbridge。来调用js中的方法， 即持有 window.mxbridge.JSbridgeForOC对象。
 *  调用js时，要先确认webview有没有被释放。
 */
@property (nonatomic,strong) JSValue *jsBridge;

/**
 *  持有一份webview
 */
@property (nonatomic,weak,readonly) UIWebView *webview;

/**
 *  容器viewcontroller。外部初始化时，一定要传递这个值。当然，如果自己不需要的话，可以不传，会通过某种方式获取。
 */
@property (nonatomic,weak) UIViewController *containerVC;

/**
 *  异步回调，传递数据给JS。
 *
 *  @param success    <#success description#>
 *  @param dict       <#dict description#>
 *  @param invocation <#invocation description#>
 */
- (void)callBackSuccess:(BOOL)success withDictionary:(NSDictionary *)dict toInvocation:(MXMethodInvocation *)invocation ;

// 回调，传 String 给js。
- (void)callBackSuccess:(BOOL)success withString:(NSString *)string toInvocation:(MXMethodInvocation *)invocation ;

@end