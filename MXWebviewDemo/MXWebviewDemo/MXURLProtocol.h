//
//  MXURLProtocol.h
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/8.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  将js与oc交互的js代码至于APP中，通过NSURLProtocol进行截获替换。
 */
@interface MXURLProtocol : NSURLProtocol

/**
 *  初始化时调用该函数 注册 protocol
 */
+ (void)registerProtocol;

@end
