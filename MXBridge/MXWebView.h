//
//  MXWebView.h
//  MXWebviewDemo
//
//  Created by 罗贤明 on 2018/3/6.
//  Copyright © 2018年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - 初始化方式集成


/**
 使用者需要持有这个代理，负责接收webview的事件以注入mxbridge
 */
@interface MXWebViewBridgeWrapper : NSObject<UIWebViewDelegate>

/**
 使用这个delegate , 而默认的delegate被MXWebView占用了。
 */
@property (nonatomic,weak) id<UIWebViewDelegate> webviewDelegate;


/**
 以webview进行初始化， 会占据delegate ,要对该webview设置delegate ,需要使用webviewDelegate

 @param webview <#webview description#>
 @return <#return value description#>
 */
+ (instancetype)wrapperWithWebView:(UIWebView *)webview;

@end





#pragma mark - 继承方式集成

/**
  使用派生的UIWebView类
 */
@interface MXWebView : UIWebView


/**
 使用这个函数初始化，一开始必须传入webview所在的viewController
   DES
 @param vc webview所在的viewController
 */
- (instancetype)initWithViewController:(UIViewController *)vc;



//
//- (instancetype)initWithFrame:(CGRect)frame;
//- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@end





