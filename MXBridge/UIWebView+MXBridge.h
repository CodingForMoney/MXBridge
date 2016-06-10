//
//  UIWebView+MXBridge.h
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/9.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXWebviewBridge.h"

/**
 *  非注入式，赋予普通webview强大的js交互能力，以及调用插件的能力。
 */
@interface UIWebView(MXBridge)

/**
 *  关于暴露的内容，暴露多少才是合适？
 */
@property (nonatomic,readonly) MXWebviewBridge *bridge;


@end
