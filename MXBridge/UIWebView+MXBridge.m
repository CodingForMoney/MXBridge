//
//  UIWebView+MXBridge.m
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/9.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import "UIWebView+MXBridge.h"
#import <objc/runtime.h>

/**
 *  delegate的 proxy
 */
@interface MXWebviewDelegateProxy : NSObject<UIWebViewDelegate>

// 外部委托.
@property (nonatomic,weak) id<UIWebViewDelegate> realDelegate;

@property (nonatomic,strong) MXWebviewBridge *bridge;

@end

@implementation MXWebviewDelegateProxy


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([self.realDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.realDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if ([self.realDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        return [self.realDelegate webViewDidStartLoad:webView];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
     //  每次加载完成，需要更新一下JS环境.
    [_bridge setupJSContext];
    if ([self.realDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        return [self.realDelegate webViewDidFinishLoad:webView];
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    if ([self.realDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        return [self.realDelegate webView:webView didFailLoadWithError:error];
    }
}

- (void)dealloc {
    [_bridge cleanJSContext];
}

@end


@implementation UIWebView(MXBridge)

static void *UIWebView_MXWebviewDelegateProxy_Key = &UIWebView_MXWebviewDelegateProxy_Key;

// UIView init 会调用 initWithFrame
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

- (void)mx_setup {
    // 在初始化完成后，进行一些操作。
    MXWebviewDelegateProxy *proxy =[[MXWebviewDelegateProxy alloc] init];
    MXWebviewBridge *bridge = [[MXWebviewBridge alloc] initWithWebview:self];
    proxy.bridge = bridge;
    [self mx_setDelegate:proxy];
    objc_setAssociatedObject(self, UIWebView_MXWebviewDelegateProxy_Key, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MXWebviewBridge *)bridge {
    return ((MXWebviewDelegateProxy *)self.delegate).bridge;
}

- (void)mx_setDelegate:(id)delegate {
    //  设置上真正的代理。
    ((MXWebviewDelegateProxy *)self.delegate).realDelegate = delegate;
}

@end
