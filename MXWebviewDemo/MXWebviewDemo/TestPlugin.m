//
//  TestPlugin.m
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/10.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import "TestPlugin.h"


@interface TestPlugin ()


@end

@implementation TestPlugin

MX_EXTERN_METHOD(hello, helloworld)
- (NSDictionary *)helloworld {
    return @{@"data":@"Hello world , hello MXBridge!"};
}

MX_EXTERN_METHOD(loadPicture, loadPicture:)
- (void)loadPicture:(MXNativeInvocation *)invocation {
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
