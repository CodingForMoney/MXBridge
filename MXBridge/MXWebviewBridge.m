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
#import "MXWebviewPluginConfig.h"


@interface MXWebviewBridge ()

/**
 *  webview持有一个bridge， bridge持有插件。这里是持有插件队列的地方。每个插件在一个webview中只会存在一个。当webview释放的时候,bridge和插件也会跟随一起释放.但由于使用关联对象,释放会有一段延迟.
 */
@property (nonatomic,strong) NSMutableDictionary<NSString *,MXWebviewPlugin *> *pluginDictionarys;


/**
  由于ios11的检测主线程问题，在本地保存URL。
 */
@property (nonatomic,strong) NSURL *currentURL;

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
    JSContext *context = [_webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    if (!context) {
        MXError(@"setupJSContext : 无法获取Context ,初始化MXJSBridge失败!!!");
        return;
    }
    _currentURL = _webview.request.URL;
    JSValue *bridge = [context objectForKeyedSubscript:@"mxbridge"];
    if (bridge && ![bridge isUndefined]) {
        return;
    }
    [_webview stringByEvaluatingJavaScriptFromString:[MXWebviewContext shareContext].bridgeJS];
    
    bridge = [context objectForKeyedSubscript:@"mxbridge"];
    JSValue *ocBridge = [bridge objectForKeyedSubscript:@"OCBridgeForJS"];
    [self setJSFunction:ocBridge];
    if ([MXWebviewContext shareContext].appName) {
        [bridge setValue:[MXWebviewContext shareContext].appName forKey:@"appName"];
    }
    if ([MXWebviewContext shareContext].appVersion) {
        [bridge setValue:[MXWebviewContext shareContext].appVersion forKey:@"appVersion"];
    }
    if ([MXWebviewContext shareContext].osType) {
        [bridge setValue:[MXWebviewContext shareContext].osType forKey:@"osType"];
    }
    if ([MXWebviewContext shareContext].osVersion) {
        [bridge setValue:[MXWebviewContext shareContext].osVersion forKey:@"osVersion"];
    }
    [_webview stringByEvaluatingJavaScriptFromString:@"if (document.addEventListener) {var readyEvent = document.createEvent('UIEvents');readyEvent.initEvent('bridgeReady', false, false);document.dispatchEvent(readyEvent);window.mxbridge.isReady=true;}"];
    
}


- (UIViewController *)containerVC {
    if (!_containerVC) {
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
            MXError(@"未设置containerVC，且未将webview放置在Controller中，而想要使用ContainerVC,失败。");
        }
    }
    return _containerVC;
}


#pragma mark - callForJS

- (void)setJSFunction:(JSValue *)ocBridge {
    __weak MXWebviewBridge *wself = self;
    
    // log
    ocBridge[@"loggerWithLevel"] = ^() {
        if (!wself || !wself.webview) {
            return;
        }
        NSArray *args = [JSContext currentArguments];
        id log = args[0];
        NSInteger level = [args[1] toInt32];
        [MXWebviewContext shareContext].loggerBlock(log, level);
    };
    
    // 异步调用函数
    ocBridge[@"callAsyn"] = ^(NSDictionary *jsCall) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!wself || !wself.webview) {
                return;
            }
            MXNativeInvocation *invocation = [[MXNativeInvocation alloc] initWithJSCall:jsCall];
            if (!invocation) {
//                NSDictionary *error = @{@"errorCode":@(MXBridge_ReturnCode_PLUGIN_INIT_FAILED),@"errorMsg":@"参数传递错误,无法调用函数"};
                MXError(@"参数传递错误,无法调用函数");
                return;
            }
            MXWebviewPluginConfig *config = [MXWebviewContext shareContext].plugins[invocation.pluginName];
            if (!config) {
                NSDictionary *error = @{@"errorCode":@(MXBridge_ReturnCode_PLUGIN_NOT_FOUND),@"errorMsg":[NSString stringWithFormat:@"插件 %@ 并不存在 ",invocation.pluginName]};
                MXWarn(@"插件%@ 不存在",invocation.pluginName);
                [wself callBackSuccess:NO withDictionary:error toInvocation:invocation];
                return ;
            }
            // 创建插件实例
            MXWebviewPlugin *plugin = wself.pluginDictionarys[invocation.pluginName];
            if (!plugin) {
                Class pluginClass = config.pluginClass;
                plugin = [[pluginClass alloc] initWithBridge:wself];
                wself.pluginDictionarys[config.pluginName] = plugin;
            }
            // 找到方法
            MXNativeMethod *method = config.exportedMethods[invocation.functionName];
            if (!method) {
                NSDictionary *error = @{@"errorCode":@(MXBridge_ReturnCode_METHOD_NOT_FOUND_EXCEPTION),@"errorMsg":[NSString stringWithFormat:@"插件对应函数 %@ 并不存在 ",invocation.functionName]};
                MXWarn(@"插件对应函数 %@ 并不存在 ",invocation.functionName);
                [wself callBackSuccess:NO withDictionary:error toInvocation:invocation];
                return;
            }
            // 调用方法
            [method invokeWithObject:invocation onTarget:plugin];
        });
    };
    
    // 同步调用函数
    ocBridge[@"callSync"] = (JSValue *)^(NSDictionary *jsCall) {
        JSContext *context = [JSContext currentContext];
        if (!wself || !wself.webview) {
            return [JSValue valueWithNullInContext:context];
        }
        MXNativeInvocation *invocation = [[MXNativeInvocation alloc] initWithJSCall:jsCall];
        if (!invocation) {
            NSDictionary *error = @{@"errorCode":@(MXBridge_ReturnCode_PLUGIN_INIT_FAILED),@"errorMsg":@"传递参数错误，无法调用函数！"};
            MXError(@"传递参数错误，无法调用函数！");
            return [JSValue valueWithObject:error inContext:context];
        }
        MXWebviewPluginConfig *config = [MXWebviewContext shareContext].plugins[invocation.pluginName];
        if (!config) {
            NSDictionary *error = @{@"errorCode":@(MXBridge_ReturnCode_PLUGIN_NOT_FOUND),@"errorMsg":[NSString stringWithFormat:@"插件 %@ 并不存在 ",invocation.pluginName]};
            MXWarn(@"插件 %@ 并不存在 ",invocation.pluginName);
            return [JSValue valueWithObject:error inContext:context];
        }
        // 创建实例
        MXWebviewPlugin *plugin = wself.pluginDictionarys[invocation.pluginName];
        if (!plugin) {
            Class pluginClass = config.pluginClass;
            plugin = [[pluginClass alloc] initWithBridge:self];
            wself.pluginDictionarys[config.pluginName] = plugin;
        }
        // 找到方法
        MXNativeMethod *method = config.exportedMethods[invocation.functionName];
        if (!method) {
            NSDictionary *error = @{@"errorCode":@(MXBridge_ReturnCode_METHOD_NOT_FOUND_EXCEPTION),@"errorMsg":[NSString stringWithFormat:@"插件对应函数 %@ 并不存在 ",invocation.functionName]};
            MXWarn(@"插件对应函数 %@ 并不存在 ",invocation.functionName);
            return [JSValue valueWithObject:error inContext:context];
        }
        // 调用方法
        NSDictionary *returnValue = [method invokeWithObject:invocation onTarget:plugin];
        // 处理同步返回值
        if ([returnValue isKindOfClass:[NSDictionary class]]) {
            JSValue *retJSValue = [JSValue valueWithObject:returnValue inContext:context];
            return retJSValue;
        }
        return [JSValue valueWithNullInContext:context];
        
    };
}


#pragma mark - callForNative

- (void)internalCallbackSuccess:(BOOL)success withString:(NSString *)string toCallbackID:(NSString *)callbackID  {
    NSString *script = [NSString stringWithFormat:@"window.mxbridge.JSbridgeForOC.callbackAsyn(\"%@\",%@",callbackID,@(success ? MXBridge_ReturnCode_OK : MXBridge_ReturnCode_FAILED) ];
    if (string) {
        script = [script stringByAppendingFormat:@",%@)",string];
    }else {
        script = [script stringByAppendingString:@")"];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_webview stringByEvaluatingJavaScriptFromString:script];
    });
}


- (void)callBackSuccess:(BOOL)success withDictionary:(NSDictionary *)dict toInvocation:(MXNativeInvocation *)invocation {
    if (!_webview) {
        return;
    }
    if ([invocation isKindOfClass:[MXNativeInvocation class]]) {
        NSString *json =  nil;
        if ([dict isKindOfClass:[NSDictionary class]]) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
            if (error) {
                MXError(@"call传递的 NSDictionary格式不正确，无法编码为json 报错:%@",error);
                return;
            }else {
                json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
        [self internalCallbackSuccess:success withString:json toCallbackID:invocation.invocationID];
    }else {
        MXError(@"传递参数格式不正确，不是 MXNativeInvocation 类");
    }
}

- (void)callBackSuccess:(BOOL)success withString:(NSString *)string toInvocation:(MXNativeInvocation *)invocation {
    if (!_webview) {
        return;
    }
    if ([invocation isKindOfClass:[MXNativeInvocation class]]) {
        if ([string isKindOfClass:[NSString class]]) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:@[string] options:0 error:nil];
            string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            string = [string substringWithRange:NSMakeRange(1, string.length - 2)];
        }else {
            string = nil;
        }
        [self internalCallbackSuccess:success withString:string toCallbackID:invocation.invocationID];
    }else {
        MXError(@"传递参数格式不正确，不是 MXNativeInvocation 类");
    }
}

- (void)callBackSuccess:(BOOL)success withArray:(NSArray *)array toInvocation:(MXNativeInvocation *)invocation {
    if (!_webview) {
        return;
    }
    if ([invocation isKindOfClass:[MXNativeInvocation class]]) {
        NSString *json =  nil;
        if ([array isKindOfClass:[NSArray class]]) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
            if (error) {
                MXError(@"call传递的 NSArray格式不正确，无法编码为json 报错:%@",error);
                return;
            }else {
                json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
        [self internalCallbackSuccess:success withString:json toCallbackID:invocation.invocationID];
    }else {
        MXError(@"传递参数格式不正确，不是 MXNativeInvocation 类");
    }
}

@end
