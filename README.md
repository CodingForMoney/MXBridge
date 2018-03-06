## 废弃 DEPRECATED

通过`JavaScriptCore`搞的js桥接，但是`WKWebView`中拿不到`JSC`， 只能废弃了。

## MXBridge

Bridge betweeen iOS and JavaScript.

## English

Bridge JavaScript and Objective-C using the `JavaScriptCore`.

Classes description:

* `MXWebviewContext` : A context for global setting.
* `MXWebviewBridge` : The bridge connected Objective-C and JavaScript. UIWebview will hold a `MXWebviewBridge` instance within the lifecycle.
* `MXWebviewPlugin` : Objective-C plugin which provide functions for JavaScript. A plugin has some functions. `js` will specify the plugin and function to call Native.
* `MXCallNativeInvocation` : Storing Information for one call from JavaScript to Objective-C.
* `MXNativeMethod` : Storing Native method info.
* `MXWebviewPluginConfig` : Store Native plugin info.

## Usage

Add `MXBridge` to your project by `Cocoapods`:

	pod 'MXBridge'
	
To setup `MXBridge` :

	[[MXWebviewContext shareContext] setUp];
	
Create a plugin for JavaScript:

	@interface TestPlugin : MXWebviewPlugin
	
	@end
	@implementation TestPlugin
	MX_EXTERN_METHOD(hello, helloworld)
	- (NSDictionary *)helloworld {
	    return @{@"data":@"Hello world , hello MXBridge!"};
	}
	
	MX_EXTERN_METHOD(loadPicture, loadPicture:)
	- (void)loadPicture:(MXCallNativeInvocation *)invocation {
	    NSString *url = invocation.arguments[@"url"];
	    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
	        if (error) {
	            [self callBackSuccess:NO withString:nil toInvocation:invocation];
	        }else {
	            NSString *str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
	            [self callBackSuccess:YES withString:str toInvocation:invocation];
	        }
	    }] resume];
	}

	@end
	
Use `MX_EXTERN_METHOD` to export functions of plugins. First argument is the function name in `js` . The second argument is the selector of the exported function.

Register plugin before using :

	[[MXWebviewContext shareContext] registerPlugin:[TestPlugin class] name:@"test"];


Then,you can call the plugin in your JavaScript Code :

	function clickSync() {
		var retString = mxbridge.execSync("test","hello");
		if (retString.data) {
            mxbridge.log(retString.data);
			alert(retString.data);
		}
	}
	function clickAysn() {
        mxbridge.execSafely("test","loadPicture",{"url":"http://resource.luoxianming.cn/steam.gif"},function successDownload(data){
        	document.getElementById("showImg").src = "data:image/png;base64," + data ;
        });
	}
	
## Notice

The JSContext inits every time after the finish of website loading in the UIWebview.So the `MXBridge` is unavailable  before the loading finished. MXBridge post a notification `bridgeReady` after the initializtion.You should call the Objective-C plugins after the `bridgeReady` notification recieved.

More documents in the plan.

## License

These specifications and CocoaPods are available under the [MIT license](http://www.opensource.org/licenses/mit-license.php).
