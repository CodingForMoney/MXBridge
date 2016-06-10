//
//  MXWebviewContext.m
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/9.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import "MXWebviewContext.h"
#import <objc/runtime.h>
#import "MXURLProtocol.h"

NSNumber * MXBridge_ReturnCode_OK;
NSNumber * MXBridge_ReturnCode_FAILED;
NSNumber * MXBridge_ReturnCode_PLUGIN_NOT_FOUND;
NSNumber * MXBridge_ReturnCode_METHOD_NOT_FOUND_EXCEPTION;
NSNumber * MXBridge_ReturnCode_PLUGIN_INIT_FAILED;
NSNumber * MXBridge_ReturnCode_ARGUMENTS_ERROR;
NSNumber * MXBridge_ReturnCode_UNKNOWN_ERROR;


NSString *MXLoggerLevel[] = {@"VERBOSE",@"DEBUG",@"INFO",@"WARN",@"ERROR"};

@implementation MXWebviewContext


+ (instancetype)shareContext {
    static MXWebviewContext *context ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[MXWebviewContext alloc] init];
        MXBridge_ReturnCode_OK = @(0);
        MXBridge_ReturnCode_FAILED = @(-1);
        MXBridge_ReturnCode_PLUGIN_NOT_FOUND = @(-2);
        MXBridge_ReturnCode_METHOD_NOT_FOUND_EXCEPTION = @(-3);
        MXBridge_ReturnCode_PLUGIN_INIT_FAILED = @(-4);
        MXBridge_ReturnCode_ARGUMENTS_ERROR = @(-5);
        MXBridge_ReturnCode_UNKNOWN_ERROR = @(-6);
    });
    return context;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"bridgeJS" ofType:@"js"];
        NSError *error;
        _bridgeJS = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"加载本地 bridgeJS.js文件失败， 发生错误 : %@",error);
            _bridgeJS = @"";// 放一个空值，防止崩溃。
        }
        _loggerBlock = ^(NSString *log,NSInteger loggerLevel) {
            NSLog(@"MXBridgeLog : %@ : %@",MXLoggerLevel[loggerLevel],log);
        };
        [self initPlugins];
    }
    return self;
}

/**
 *  初始化plugins Map。
 */
- (void)initPlugins {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"plugins" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSMutableDictionary *plugins = [[NSMutableDictionary alloc] initWithCapacity:data.count];
    for (NSString *key in data.allKeys) {
        NSString *className = data[key];
        Class cls = NSClassFromString(className);
        if (cls != nil) {
            plugins[key] = cls;
        }else{
            NSLog(@"在plugins.plist中声明的插件 %@ : %@ , 类%@ 并不存在 ！！！",key,className,className);
        }
    }
    _plugins = plugins;
}

- (NSURL *)bridgeJSURL {
    if (!_bridgeJSURL) {
        _bridgeJSURL = [NSURL URLWithString:@"bridgeJS.js"];
    }
    return _bridgeJSURL;
}

- (void)setUp {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [UIWebView class];
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        int methodsCount = 3;
        SEL originalSelector[methodsCount];
        SEL swizzledSelector[methodsCount];
        originalSelector[0] = @selector(setDelegate:);
        swizzledSelector[0] = @selector(mx_setDelegate:);
        originalSelector[1] = @selector(initWithFrame:);
        swizzledSelector[1] = @selector(mx_initWithFrame:);
        originalSelector[2] = @selector(initWithCoder:);
        swizzledSelector[2] = @selector(mx_initWithCoder:);
        
        for (int i = 0; i < methodsCount; i++) {
            Method originalMethod = class_getInstanceMethod(class, originalSelector[i]);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector[i]);
            
            BOOL didAddMethod =
            class_addMethod(class,
                            originalSelector[i],
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
            
            if (didAddMethod) {
                class_replaceMethod(class,
                                    swizzledSelector[i],
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
//        [MXURLProtocol registerProtocol];
    });
}

@end
