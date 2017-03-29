//
//  MXWebviewPluginConfig.h
//  MXWebviewDemo
//
//  Created by lxm on 2017/3/29.
//  Copyright © 2017年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXNativeMethod.h"

/**
  对于一个插件，生成一份配置。记录 方法调用关系。
 */
@interface MXWebviewPluginConfig : NSObject



/**
     module类
 */
@property (nonatomic) Class pluginClass;


/**
     提供给JS使用的module名
 */
@property (nonatomic) NSString *pluginName;


/**
     JS函数名和native函数名的对应。
 */
@property (nonatomic,strong) NSDictionary<NSString *,MXNativeMethod *> *exportedMethods;

@end
