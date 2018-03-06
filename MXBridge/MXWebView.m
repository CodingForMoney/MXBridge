//
//  MXWebView.m
//  MXWebviewDemo
//
//  Created by 罗贤明 on 2018/3/6.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import "MXWebView.h"
#import "MXWebviewBridge.h"

@interface MXWebViewBridgeWrapper ()

@property (nonatomic,strong) MXWebviewBridge *bridge;

/**
 判断当前请求数量，只有为0时，才为请求完成。
 */
@property (nonatomic,assign) NSInteger currentRequestNumber;

@end

@implementation MXWebViewBridgeWrapper


+ (instancetype)wrapperWithWebView:(UIWebView *)webview {
    MXWebViewBridgeWrapper *wrapper = [[MXWebViewBridgeWrapper alloc] init];
    wrapper.bridge = [[MXWebviewBridge alloc] initWithWebview:webview];
    webview.delegate = wrapper;
    return wrapper;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.mainDocumentURL isEqual:request.URL]) {
        //  URL相同时，才表示是页面的请求，这个时候我们才进行次数判断。
        _currentRequestNumber = 1;
    }else if(_currentRequestNumber > 0) {
        // 当期在加载主页面时如果有其他请求，则是 IFrame的请求.
        _currentRequestNumber ++ ;
    }
    if ([_webviewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [_webviewDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if ([_webviewDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [_webviewDelegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (_currentRequestNumber) {
        _currentRequestNumber --;
        if (_currentRequestNumber == 0) {
            // 这里判断，才是真正的页面加载完成，且过滤iframe的情况。
            [_bridge setupJSContext];
        }
    }
    if ([_webviewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [_webviewDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // 对于iframe加载时，iframe加载出错，要减少次数。
    // 因为加载iframe时，页面已经加载完成了，所以这里不可能遇到 iframe加载成功，而html加载出错的情况。所以放心去减少数量.
    if (_currentRequestNumber) {
        _currentRequestNumber --;
    }
    if ([_webviewDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [_webviewDelegate webView:webView didFailLoadWithError:error];
    }
}


@end


@interface MXWebView ()

@property (nonatomic,strong) MXWebViewBridgeWrapper *wrapper;
@end


@implementation MXWebView

- (instancetype)initWithViewController:(UIViewController *)vc {
    if (self = [super initWithFrame:CGRectZero]) {
        _wrapper = [MXWebViewBridgeWrapper wrapperWithWebView:self];
        _wrapper.bridge.containerVC = vc;
    }
    return self;
}



@end
