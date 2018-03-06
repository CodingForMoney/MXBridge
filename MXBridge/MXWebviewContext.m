//
//  MXWebviewContext.m
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/9.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import "MXWebviewContext.h"
#import <objc/runtime.h>
#import "MXWebviewPluginConfig.h"

NSInteger const MXBridge_ReturnCode_OK = 0;
NSInteger const MXBridge_ReturnCode_FAILED = -1;
NSInteger const MXBridge_ReturnCode_PLUGIN_NOT_FOUND = -2;
NSInteger const MXBridge_ReturnCode_METHOD_NOT_FOUND_EXCEPTION = -3;
NSInteger const MXBridge_ReturnCode_PLUGIN_INIT_FAILED = -4;
NSInteger const MXBridge_ReturnCode_ARGUMENTS_ERROR = -5;
NSInteger const MXBridge_ReturnCode_UNKNOWN_ERROR = -6;


NSString *MXLoggerLevelLabels[] = {@"DEBUG",@"INFO",@"WARN",@"ERROR"};

@implementation MXWebviewContext


+ (instancetype)shareContext {
    static MXWebviewContext *context ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[MXWebviewContext alloc] init];
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
        // 默认的日志输出
        _loggerBlock = ^(NSString *log,MXLoggerLevel loggerLevel) {
            NSLog(@"MXBridgeLog : %@ : %@",MXLoggerLevelLabels[loggerLevel],log);
        };
        _plugins = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (NSURL *)bridgeJSURL {
    if (!_bridgeJSURL) {
        _bridgeJSURL = [NSURL URLWithString:@"bridgeJS.js"];
    }
    return _bridgeJSURL;
}

- (void)registerPlugin:(Class)plugin name:(NSString *)name {
    if (![plugin isSubclassOfClass:[MXWebviewPlugin class]]) {
        return;
    }
    MXWebviewPluginConfig *config = [[MXWebviewPluginConfig alloc] init];
    config.pluginClass = plugin;
    config.pluginName = name;
    NSMutableDictionary *methods = [[NSMutableDictionary alloc] init];
    unsigned int methodCount;
    Method *list = class_copyMethodList(object_getClass(plugin), &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = list[i];
        SEL selector = method_getName(method);
        NSString *selectorName = NSStringFromSelector(selector);
        if ([selectorName hasPrefix:@"__mx_export__"]) {
            IMP imp = method_getImplementation(method);
            NSArray<NSString *> *entries = ((NSArray<NSString *> *(*)(id, SEL))imp)(plugin, selector);
            NSString *exportedMethodName = entries[0];
            NSString *exportedSelectorName = entries[1];
            SEL exportedSelector = NSSelectorFromString(exportedSelectorName);
            NSMethodSignature *signature = [plugin instanceMethodSignatureForSelector:exportedSelector];
            MXNativeMethod *nativeMethod = [[MXNativeMethod alloc] initWithName:exportedMethodName selector:exportedSelector signature:signature];
            methods[exportedMethodName] = nativeMethod;
        }
    }
    free(list);
    config.exportedMethods = methods;
    _plugins[name] = config;
}
@end
