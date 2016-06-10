//
//  MXURLProtocol.m
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/8.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import "MXURLProtocol.h"
@implementation MXURLProtocol
//
static NSString *const ReplaceJSProtocol        = @"https://mxjs-resource/";

static const NSInteger ProtocolLength           = 21;
static const NSInteger SuffixLengthDotJS        = 3;
/**
 *  本地对于JS文件也进行缓存。
 */
static NSCache *cachelist;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSURL* URL = request.URL;
    NSString* urlString = URL.absoluteString;
    if ([[urlString lowercaseString] hasPrefix:ReplaceJSProtocol]) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSURL* URL = self.request.URL;
    NSString* urlString = URL.absoluteString;
    NSInteger jsFileNameLength = urlString.length - ProtocolLength -SuffixLengthDotJS;
    
    NSString *jsFileName = [urlString substringWithRange:NSMakeRange(ProtocolLength, jsFileNameLength)];
    NSString *path = [[NSBundle mainBundle] pathForResource:jsFileName ofType:@"js"];
    // URL跳转
    if (path) {
        NSData *data = [cachelist objectForKey:jsFileName];
        if (!data) {
            data = [[NSData alloc] initWithContentsOfFile:path];
            [cachelist setObject:data forKey:jsFileName];
        }
        if (!data) {
            NSLog(@"未查找到指定的本地JS文件,需要加载JS文件为 %@",urlString);
            return;
        }
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[NSURL URLWithString:@""] MIMEType:@"text/html" expectedContentLength:data.length textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    } else {
        NSLog(@"未查找到指定的本地JS文件,需要加载JS文件为 %@",urlString);
        [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:@"org.lxm.mxbridge.error." code:10086 userInfo:nil]];
    }
}

- (void)stopLoading {
    
}

+ (void)registerProtocol {
    [NSURLProtocol registerClass:[MXURLProtocol class]];
    cachelist = [[NSCache alloc] init];
}

@end