# MXBridge

A easy way for javaScript to call Objective-C in iOS

## English




## 中文文档

一个简单的JS与OC的桥，通过`JavaScriptCore`来实现.

先介绍一下几个类：

* MXWebviewContext : 全局上下文，单例，负责储存一些全局共享的内容。
* MXWebviewBridge ： 与JavaScript进行通信的桥，一个webview持有一个这样的桥，跟随webview的生命周期。
* MXWebviewPlugin : 插件。MXBridge通过插件的方式与JS进行交互，JS能调用的方法都是插件的形式创建的。
* MXMethodInvocation : JS对插件的一次调用信息。

## 使用说明

初始化 ：

	[[MXWebviewContext shareContext] setUp];

创建一个插件 ：

	@interface TestPlugin : MXWebviewPlugin
	
	@end
	@implementation TestPlugin
	- (NSDictionary *)helloworld {
	    return @{@"data":@"Hello world , hello MXBridge!"};
	}
	@end

在项目中新建一个`plugins.plist`文件，以插件名为key，插件类名为值，声明项目中提供给`javascript`调用的插件 ：

        <key>testplugin</key>
        <string>TestPlugin</string>
       
然后，在html页面中，在收到`bridgeReady`后，就可以调用相关的插件了，如Demo中的：

	function clickSync() {
		var retString = mxbridge.execSync("testplugin","helloworld");
		if (retString.data) {
            mxbridge.log(retString.data);
			alert(retString.data);
		}
	}

## License

These specifications and CocoaPods are available under the [MIT license](http://www.opensource.org/licenses/mit-license.php).
