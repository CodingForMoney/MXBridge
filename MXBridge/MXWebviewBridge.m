//
//  MXWebviewBridge.m
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/9.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import "MXWebviewBridge.h"
#import "MXWebviewContext.h"
#import "MXWebviewPlugin.h"
#import "UIWebView+MXBridge.h"
/**
 * JS可以直接调用的 Native的方法。
 */
@protocol MXNativeBridgeExport <JSExport>

/**
 *  打日志，带日志等级,第一个参数为日志内容,第二个参数为日志等级
 */
- (void)loggerWithLevel:(NSArray *)arguments;

/**
 *  异步调用插件
 */
- (void)callAsyn:(NSDictionary *)arguments;


/**
 *  同步调用插件
 */
- (JSValue *)callSync:(NSDictionary *)arguments;

@end


@interface MXWebviewBridge ()<MXNativeBridgeExport>

/**
 *  webview持有一个bridge， bridge持有插件。这里是持有插件队列的地方。每个插件在一个webview中只会存在一个。当webview释放的时候,bridge和插件也会跟随一起释放.但由于使用关联对象,释放会有一段延迟.
 */
@property (nonatomic,strong) NSMutableDictionary<NSString *,MXWebviewPlugin *> *pluginDictionarys;


@end


@implementation MXWebviewBridge

- (instancetype)initWithWebview:(UIWebView *)webview {
    if (self = [super init]) {
        _webview = webview;
        _pluginDictionarys = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/**
 *  初始化JS环境， 注入JS,并获取JS中对象.
 */
- (void)setupJSContext {
    JSContext *context = [_webview valueForKeyPath: @"documentView.webView.mainFrame.javaScriptContext"];
    if (_context[@"mxbridge"]) {
        // 这种情况存在于设置Webview有缓冲,在goBack的时候,虽然context指针的值变了,但是window上真实地对象还存在,即JS已经初始化了
        _jsBridge = [_context[@"mxbridge"] valueForProperty:@"JSbridgeForOC"];
        [_context[@"mxbridge"] setValue:self forProperty:@"OCBridgeForJS"];
        return;
    }
    _context = context;
    if ([_context respondsToSelector:@selector(evaluateScript:withSourceURL:)]) {
        [_context evaluateScript:[MXWebviewContext shareContext].bridgeJS withSourceURL:[MXWebviewContext shareContext].bridgeJSURL];
    } else {
        [_context evaluateScript:[MXWebviewContext shareContext].bridgeJS];
    }
    _jsBridge = [_context[@"mxbridge"] valueForProperty:@"JSbridgeForOC"];
    // 这里实际上有一个引用的环，暂时通过clean方法来清除这个环。
    [_context[@"mxbridge"] setValue:self forProperty:@"OCBridgeForJS"];
    if ([MXWebviewContext shareContext].appName) {
        [_context[@"mxbridge"] setValue:[MXWebviewContext shareContext].appName forProperty:@"appName"];
    }
    if ([MXWebviewContext shareContext].appVersion) {
        [_context[@"mxbridge"] setValue:[MXWebviewContext shareContext].appVersion forProperty:@"appVersion"];
    }
    if ([MXWebviewContext shareContext].osType) {
        [_context[@"mxbridge"] setValue:[MXWebviewContext shareContext].osType forProperty:@"osType"];
    }
    if ([MXWebviewContext shareContext].osVersion) {
        [_context[@"mxbridge"] setValue:[MXWebviewContext shareContext].osVersion forProperty:@"osVersion"];
    }
    // 加载完成，发送消息bridgeready。
    if ([_context respondsToSelector:@selector(evaluateScript:withSourceURL:)]) {
        [_context evaluateScript:@"if (document.addEventListener) {var readyEvent = document.createEvent('UIEvents');readyEvent.initEvent('bridgeReady', false, false);document.dispatchEvent(readyEvent);window.mxbridge.isReady=true;}" withSourceURL:[MXWebviewContext shareContext].bridgeJSURL];
    } else {
        [_context evaluateScript:@"if (document.addEventListener) {var readyEvent = document.createEvent('UIEvents');readyEvent.initEvent('bridgeReady', false, false);document.dispatchEvent(readyEvent);window.mxbridge.isReady=true;}"];
    }
}

- (void)cleanJSContext {
    // 断开 JS 与 OC的联系,以使两者能正常释放.
    [_context[@"mxbridge"] setValue:nil forProperty:@"OCBridgeForJS"];
    _jsBridge = nil;
}

- (UIViewController *)containerVC {
    if (!_containerVC) {
        // 如果没有设置 containerVC, 会根据nextResponder 找到持有webview的controlller
        UIResponder *next = _webview;
        while (next) {
            if([next isKindOfClass: [UIViewController class]] ){
                break;
            }
            next = next.nextResponder;
        }
        if (nil != next && [next isKindOfClass: [UIViewController class]]) {
            _containerVC = (UIViewController *)next;
        }else {
            NSLog(@"未设置containerVC");
        }
    }
    return _containerVC;
}

#pragma mark - call from JavaScript

- (void)loggerWithLevel:(NSArray *)arguments {
    if ([arguments isKindOfClass:[NSArray class]] && arguments.count == 2) {
        id log = arguments[0];
        NSInteger level = [arguments[1] integerValue];
        [MXWebviewContext shareContext].loggerBlock(log,level);
    }
}


- (void)callAsyn:(NSDictionary *)arguments {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 在主线程中执行。
        MXMethodInvocation *invocation = [[MXMethodInvocation alloc] initWithJSCall:arguments];
        if (invocation == nil) {
            NSDictionary *error = @{@"errorCode":MXBridge_ReturnCode_PLUGIN_INIT_FAILED,@"errorMsg":@"传递参数错误，无法调用函数！"};
            NSLog(@"异步调用 ，失败 %@",error);
        }
        MXWebviewPlugin *plugin = _pluginDictionarys[invocation.pluginName];
        if (!plugin) {
            Class cls = [MXWebviewContext shareContext].plugins[invocation.pluginName];
            if (cls == NULL) {
                NSDictionary *error = @{@"errorCode":MXBridge_ReturnCode_PLUGIN_NOT_FOUND,@"errorMsg":[NSString stringWithFormat:@"插件 %@ 并不存在 ",invocation.pluginName]};
                [self callBackSuccess:NO withDictionary:error toInvocation:invocation];
            }
            plugin = [[cls alloc] initWithBridge:self];
            _pluginDictionarys[invocation.pluginName] = plugin;
        }
        // 调用 插件中相应方法
        SEL selector = NSSelectorFromString(invocation.functionName);
        if (![plugin respondsToSelector:selector]) {
            selector = NSSelectorFromString([invocation.functionName stringByAppendingString:@":"]);
            if (![plugin respondsToSelector:selector]) {
                NSDictionary *error = @{@"errorCode":MXBridge_ReturnCode_METHOD_NOT_FOUND_EXCEPTION,@"errorMsg":[NSString stringWithFormat:@"插件对应函数 %@ 并不存在 ",invocation.functionName]};
                [self callBackSuccess:NO withDictionary:error toInvocation:invocation];
            }
        }
        // 调用插件
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [plugin performSelector:selector withObject:invocation];
#pragma clang diagnostic pop
    });
}


- (JSValue *)callSync:(NSDictionary *)arguments {
    MXMethodInvocation *invocation = [[MXMethodInvocation alloc] initWithJSCall:arguments];
    if (invocation == nil) {
        NSDictionary *error = @{@"errorCode":MXBridge_ReturnCode_PLUGIN_INIT_FAILED,@"errorMsg":@"传递参数错误，无法调用函数！"};
        return [JSValue valueWithObject:error inContext:_context];
    }
    MXWebviewPlugin *plugin = _pluginDictionarys[invocation.pluginName];
    if (!plugin) {
        Class cls = [MXWebviewContext shareContext].plugins[invocation.pluginName];
        if (cls == NULL) {
            NSDictionary *error = @{@"errorCode":MXBridge_ReturnCode_PLUGIN_NOT_FOUND,@"errorMsg":[NSString stringWithFormat:@"插件 %@ 并不存在 ",invocation.pluginName]};
            return [JSValue valueWithObject:error inContext:_context];
        }
        plugin = [[cls alloc] initWithBridge:self];
        _pluginDictionarys[invocation.pluginName] = plugin;
    }
    // 调用 插件中相应方法
    SEL selector = NSSelectorFromString(invocation.functionName);
    if (![plugin respondsToSelector:selector]) {
        selector = NSSelectorFromString([invocation.functionName stringByAppendingString:@":"]);
        if (![plugin respondsToSelector:selector]) {
            NSDictionary *error = @{@"errorCode":MXBridge_ReturnCode_METHOD_NOT_FOUND_EXCEPTION,@"errorMsg":[NSString stringWithFormat:@"插件对应函数 %@ 并不存在 ",invocation.functionName]};
            return [JSValue valueWithObject:error inContext:_context];
        }
    }
    // 调用插件
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSDictionary *retJson = [plugin performSelector:selector withObject:invocation];
#pragma clang diagnostic pop
    if ([retJson isKindOfClass:[NSDictionary class]]) {
        JSValue *retJSValue = [JSValue valueWithObject:retJson inContext:_context];
        return retJSValue;
    }
    return [JSValue valueWithNullInContext:_context];
}


#pragma mark - callback from Objective-C



- (void)callBackSuccess:(BOOL)success withDictionary:(NSDictionary *)dict toInvocation:(MXMethodInvocation *)invocation {
    UIWebView *webview = _webview;
    if (webview && invocation.invocationID) {
        // 只要检测webview是否还在，就可以了
        // 回调JS。
        NSNumber *status = success ? MXBridge_ReturnCode_OK : MXBridge_ReturnCode_FAILED;
        NSArray *callBackParams = dict ? @[invocation.invocationID,status,dict] : @[invocation.invocationID,status];
        dispatch_async(dispatch_get_main_queue(), ^{ // 要在主线程中执行
            [_jsBridge[@"callbackAsyn"] callWithArguments:callBackParams];
        });
    }
}

// 回调，传 String 给js。
- (void)callBackSuccess:(BOOL)success withString:(NSString *)string toInvocation:(MXMethodInvocation *)invocation {
    UIWebView *webview = _webview;
    if (webview && invocation.invocationID) {
        // 只要检测webview是否还在，就可以了
        // 回调JS。
        NSNumber *status = success ? MXBridge_ReturnCode_OK : MXBridge_ReturnCode_FAILED;
        NSArray *callBackParams = string ? @[invocation.invocationID,status,string] : @[invocation.invocationID,status];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_jsBridge[@"callbackAsyn"] callWithArguments:callBackParams];
        });
    }
}


@end
