## 概述

`MXBridge`,提供一个插件式的`JavaScript`与`Objective-C`交互的框架,通过`JavaScriptCore`实现,插件式扩展`Obejctive-C`接口以供`JavaScript`调用.


## 主要的类

大致画了一下类图:

![](http://resource.luoxianming.cn/MXBRIDGE.png)

结合上图,先介绍一下这里几个类的方法:

* UIWebView(MXBridge) : category,持有一个`MXWebViewDelegateProxy`以截获`UIWebView`的页面加载的回调,以触发JS注入和bridge环境初始化的操作.
* MXWebviewDelegateProxy : 委托的代理.持有一个真正的`UIWebViewDelegate`,并持有一个`MXWebViewBridge`,这样将bridge与`UIWebView`绑定在一起,一个`UIWebView`中只有一个bridge,并跟随`UIWebView`的释放一起释放代理和`bridge`.
* MXWebViewBridge : 与JS交互,主要通过这个桥来实现. 持有`JSContext`,也就是当前`WebView`的JS运行环境.通过`JSExport`暴露三个接口供JS直接调用,同时持有一个从js中获取的`jsBridge`对象,即对应了JS代码中的 `JSBridgeForOC`以供异步回调时调用JS代码. 除了一个`setupJSContext`的初始化Webview的JS环境的方法外,还有一个`cleanJSContext`,在`UIWebView`释放时,释放持有的JS对象指针,以使对象正常释放.
* MXWebViewConntext : 一个单例的全局上下文,放置一些全局的系统信息,以及加载`mxbridge.js`的代码以字符串的形式放在内存中. 还持有一个插件列表,插件列表的信息放在应用中的 `plugins.plist`文件中,以键值对形式储存插件名和插件对应的OC类名.还有一个`setUp`方法,用于初始化`MXBridge`的功能,调用这个方法后,会通过`Method Swizzling`来为应用中所有的UIWebView赋予该功能.
* MXWebViewPlugin : 插件,所有OC对JS所提供的方法,都是基于插件的形式,即用户实现一个插件,然后JS代码就可以根据插件名和插件方法名来调用这个插件的功能. 
* MXMethodInvocaton : 方法调用,JS对OC的一次方法调用中,将参数以及调用信息记录在这个Model中.

## 实现原理

结合上图,来介绍一下MXBridge的实现原理,在介绍实现原理之前,建议先去学习一下`JavaScriptCore`的使用方法,`MXBridge`是基于`JavaScriptCore`实现的,所以只支持`iOS7`以上的设备.

通过`Method swizzling`来替换了`UIWebView`的三个方法的实现:

	- (instancetype)mx_initWithFrame:(CGRect)frame {
	    [self mx_initWithFrame:frame];
	    if (self) {
	        [self mx_setup];
	    }
	    return self;
	}
	
	- (nullable instancetype)mx_initWithCoder:(NSCoder *)aDecoder {
	    [self mx_initWithCoder:aDecoder];
	    if (self) {
	        [self mx_setup];
	    }
	    return self;
	}
	
	- (void)mx_setDelegate:(id)delegate {
	    //  设置上真正的代理。
	    if ([self.delegate isKindOfClass:[MXWebviewDelegateProxy class]]) {
	        ((MXWebviewDelegateProxy *)self.delegate).realDelegate = delegate;
	    }else {
	        [self mx_setDelegate:delegate];
	    }
	}

在初始化`UIWebView`的时候,就会为`webview`添加一个 `MXWebviewDelegateProxy`对象作为`webviewDelegate`,而在使用者使用 `setDelegate`方法时,将要设置的`delegate`赋值给`MXWebviewDelegateProxy`对象的`realDelegate`属性,以让这个设置的`delegate`能够正常运行.

`method swizzling`的执行是放在`MXwebViewContext`的`setUp`方法中的,这个方法作为在整个应用中初始化`MXBridge`环境,初始化后才能在应用里的`UIWebView`中进行`JavaScript`和`Objective-C`之间的交互.

而设置代理的主要目的,是为了给`UIWebView`当前界面的`JSContext`注入我们的`MXBridge.js`,以获取交互功能. 在`JavaScriptCore`中JS代码都是执行在`JSContext`这个运行环境中的,`JSContext`表示JS代码在OC中的运行环境,我们可以通过这个环境以执行JS代码,或者让JS直接调用OC方法,具体关于`JavaScriptCore`的一些简介,可以看一下这篇[简陋的文章](http://luoxianming.cn/2016/05/12/javaScriptCore/).

我们要获取这个`JSContext`,可以通过KVC :

	JSContext *context = [_webview valueForKeyPath: @"documentView.webView.mainFrame.javaScriptContext"];
	
但是`UIWebView`中的这个`JSContext`是一直在变化的,我们通过观察,可以发现,在`UIWebViewDelegate`的三个状态中`shouldStartLoadWithRequest` , `webViewDidStartLoad` 和 `webViewDidFinishLoad`时,`UIWebView`的`JSContext`都是指向不同地址,对于这个问题,我们一开始是选取最后一个状态,即`webViewDidFinishLoad`中的`JSContext`来使用,因为这个`JSContext`也是`UIWebView`加载结束后一直使用的`JSContext`.所以我们设置一个`delegateproxy`对象,以获取`webViewDidFinishLoad`事件,在此时将所需的js注入到从`UIWebView`中获取的`JSContext`中,就可以赋予JS与OC交互的功能,而这个阶段的主要操作就是 :

	// 获取js执行环境
    JSContext *context = [_webview valueForKeyPath: @"documentView.webView.mainFrame.javaScriptContext"];
    // 注入bridge.JS
    [_context evaluateScript:[MXWebviewContext shareContext].bridgeJS];
    // 从js环境中获取 JSbridgeForOC, 在MXWebviewBridge中持有
    _jsBridge = [_context[@"mxbridge"] valueForProperty:@"JSbridgeForOC"];
    // 将MXWebviewBridge放入js的环境中,由mxbridge持有
    [_context[@"mxbridge"] setValue:self forProperty:@"OCBridgeForJS"];

但由于`webViewDidStartLoad`的限制,我们的`mxbridge`必须在页面加载完成后,才会初始化完成,而js有些代码会在页面加载过程中执行,为了处理这个时间差,我们有一个变量来表示`mxbridge`的加载状态,即`mxbridge.isReady`, 还有一个`bridgeReady`的Event会在初始化完成时发送出去.所以js调用插件时,首先需要检测`mxbridge.isReady`,如果`mxbridge`没有成功初始化,就需要等待`bridgeReady`事件发生了. 如:

	execSafely : function (pluginName, functionName, args,successCallback,failCallback) {
            if (window.mxbridge && window.mxbridge.isReady) {
                window.mxbridge.exec(pluginName, functionName, args,successCallback,failCallback);
            } else {
                document.addEventListener("bridgeReady",  function() {
                                          window.mxbridge.exec(pluginName, functionName, args,successCallback,failCallback);
                                          }, true);
            }
        },

继续讨论实现原理,刚才说到初始化js环境,OC端持有一个JS的桥,而JS端也持有了一个OC端的桥,这样我们就可以使用`JavaScriptCore`相关的知识进行两者之间的交互了.

`Objective-C`供`JavaScript`持有一个`MXWebviewBridge`对象,而这个对象实现了一个继承了`JSExport`协议的`MXNativeBridgeExport` ,继承`JSExport`后,可以将OC中的方法直接在JS中使用,所以提供了三个接口给JS使用:

	// 在Native端打日志,方便调试
	- (void)loggerWithLevel:(NSArray *)arguments;
	// 异步调用插件
	- (void)callAsyn:(NSDictionary *)arguments;
	// 同步调用插件
	- (JSValue *)callSync:(NSDictionary *)arguments;

`JavaScript`通过`callAsyn:`和`callSync:`调用OC提供的插件,这两个函数中的具体实现,也比较简单,以`callAsyn:`举例说明一下:

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

上段代码中,当JS调用OC的数据传到后,先将调用数据转换为一个`MXMethodInvocation`对象,然后检测参数合法性. 然后检测插件是否存在,不存在则去创建插件,但插件不在`plugins.plist`中或者类不存在,也会有相应地错误提示.拿到插件后,就可以根据方法名和js传递的参数调用插件相应地方法了.

对于异步调用的插件,js调用时,会传递调用成功和失败的回调 :

            var list = {
                "success":successCallback,
                "fail":failCallback
            };
	            mxbridge.JSbridgeForOC.callBackLists[jscall.invocationID] = list;

bridge将成功失败的回调以 一次调用的唯一标示记录在`JSbridgeForOC`, 而在异步回调`JavaScript`的处理函数时,也就是调用`JSbridgeForOC`的`callbackAsyn`方法时,就会从`callBackLists`中找到对应的回调函数,以执行相应的回调:

            callbackAsyn : function (callbackID,status,args) {
                // 执行异步调用，然后OC对JS的调用立即返回。
                window.setTimeout(function() {
                                    mxbridge.JSbridgeForOC._callbackAsyn(callbackID,status,args);
                                  },0);
            },
            // 真正的回调函数.
            _callbackAsyn : function(callbackID , status ,args) {
                var callbackfuns = mxbridge.JSbridgeForOC.callBackLists[callbackID];
                if (callbackfuns) {
                    if (status == mxbridge.OK) {
                        callbackfuns.success && callbackfuns.success(args);
                    } else {
                        callbackfuns.fail && callbackfuns.fail(args);
                    }
                    delete mxbridge.JSbridgeForOC.callBackLists[callbackID];
                };
            }

## 使用步骤


1. 导入代码.
2. 创建插件 ,插件的编写要注意以下几点 :

	* 继承 MUWebviewPlugin 类,这个类中提供了几个在插件中常用的属性,`bridge`,`containerVC`和`webView`,一些异步时的回调函数,如`- (void)callBackSuccess:(BOOL)success withDictionary:(NSDictionary *)dict toInvocation:(MUOCMethodInvocation *)invocation;` 和 `- (void)callBackSuccess:(BOOL)success withString:(NSString *)string toCallbackID:(NSString *)callbackID;` ,返回给JS的值,可以是一个字符串,也可以是以`NSDictionary`表示的
JSON对象.
	* `- (instancetype)initWithBridge:(MUWebviewBridge *)bridge`,可以在这个初始化函数中作一些初始化的操作.
	* 对于插件方法,形式是这样的 : `- (NSDictionary *)syncFunction（:(MUOCMethodInvocation *)invocation）;` ,同步方法返回值必须是 `NSDictionary *` ,而参数可以有也可以没有. 对于异步方法 `- (void)asynFunction（:(MUOCMethodInvocation *)invocation）`,返回值类型为void,参数也可以有,可以没有. 传递的参数放在`MUOCMethodInvocation`中.

3. 创建 `plugins.plist`文件,以 键值对的形式,插件名和插件类名的对应关系.
4. 在需要该功能时,调用 `MUWebviewContext`的`setUp`方法,激活功能,使项目中所有的webview都能进行交互.
5. 在`MUWebViewContext`中提供了几个接口,以供设置 :

	* appName,appVersion,osType,osVersion ,等应用系统信息.
	* `loggerBlock`,一个打日志的block,用于调试JS..

## 注意事项

* JS调用插件,传递的参数是json对象的形式.而调用参数传递到插件中时,是以`NSDictionary`的形式.同理,在回调`JS`时,OC传递的类型是`NSDictionary`,而到达`JS`的返回值是 json对象. 这与`JavaScriptCore`相关.
* 在`UIWebView`页面加载完成时,才会初始化`MXBridge`以支持插件调用功能,所以,调用插件前,要进行检测,以确保`mxbridge`已经初始化完成.


