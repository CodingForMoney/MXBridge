//
//  MXWebviewContext.h
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/9.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXWebviewPlugin.h"

// 返回给js的返回码
extern NSInteger const MXBridge_ReturnCode_OK;
extern NSInteger const MXBridge_ReturnCode_FAILED;
extern NSInteger const MXBridge_ReturnCode_PLUGIN_NOT_FOUND;
extern NSInteger const MXBridge_ReturnCode_METHOD_NOT_FOUND_EXCEPTION;
extern NSInteger const MXBridge_ReturnCode_PLUGIN_INIT_FAILED;
extern NSInteger const MXBridge_ReturnCode_ARGUMENTS_ERROR;
extern NSInteger const MXBridge_ReturnCode_UNKNOWN_ERROR;

typedef NS_ENUM(NSUInteger, MXLoggerLevel) {
    MXLoggerLevelDebug = 0,
    MXLoggerLevelInfo,
    MXLoggerLevelWarn,
    MXLoggerLevelError
};


/**
 *  打印日志block，可以自己定义，也可以使用默认的，默认的格式为 :     MUBridgeLog : level : xxxx....
 *
 *  @param log   <#log description#>
 *  @param level 等级
 */
typedef void (^MXLoggerWithLevelBlock)(NSString *log , MXLoggerLevel level);

/**
 *  一个是全局的上下文，纪录一些全局数据信息
 */
@interface MXWebviewContext : NSObject



/**
 *  全局共享
 *
 *  @return <#return value description#>
 */
+ (instancetype)shareContext;


/**
 *  appName , 可以向mxbridge上添加一些基础的应用信息。默认为空，设置后，js中才能获取。
 */
@property (nonatomic,strong) NSString *appName;

@property (nonatomic,strong) NSString *appVersion;

@property (nonatomic,strong) NSString *osType;

@property (nonatomic,strong) NSString *osVersion;

/**
 *  全局打印js日志的block，默认提供，也可以使用自己的日志系统进行收集。
 */
@property (nonatomic,copy) MXLoggerWithLevelBlock loggerBlock;

/**
 全局注册插件
 
 @param plugin <#plugin description#>
 */
- (void)registerPlugin:(Class)plugin name:(NSString *)name;



#pragma mark - private

/**
 *  bridge的js代码
 */
@property (nonatomic,strong,readonly) NSString *bridgeJS;

/**
 *  js的URL
 */
@property (nonatomic,strong) NSURL *bridgeJSURL;

/**
 *  全部的plugin列表, 列表中为从文件plugins.plist中加载，key为插件名，value为插件的类
 */
@property (nonatomic,strong,readonly) NSMutableDictionary *plugins;


@end



#define MXDebug(...)      [MXWebviewContext shareContext].loggerBlock( [NSString stringWithFormat: __VA_ARGS__ ] ,MXLoggerLevelDebug)
#define MXInfo(...)       [MXWebviewContext shareContext].loggerBlock( [NSString stringWithFormat: __VA_ARGS__ ] ,MXLoggerLevelInfo)
#define MXWarn(...)       [MXWebviewContext shareContext].loggerBlock( [NSString stringWithFormat: __VA_ARGS__ ] ,MXLoggerLevelWarn)
#define MXError(...)      [MXWebviewContext shareContext].loggerBlock( [NSString stringWithFormat: __VA_ARGS__ ] ,MXLoggerLevelError)


