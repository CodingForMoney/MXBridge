//
//  ViewController.m
//  TestIframe
//
//  Created by 罗贤明 on 2017/7/26.
//  Copyright © 2017年 罗贤明. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>




@interface WebViewController : UIViewController<UIWebViewDelegate>

- (instancetype)initWithURL:(NSString *)url;

@property (nonatomic,strong) NSURL *url;

@end

@implementation WebViewController


- (instancetype)initWithURL:(NSString *)url {
    if (self = [super init]) {
        _url = [NSURL URLWithString:url];
    }
    return  self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    UIWebView *webview = [[UIWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:webview];
    webview.delegate = self;
    [webview loadRequest:[NSURLRequest requestWithURL:_url]];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSArray *list = @[@"UIWebViewNavigationTypeLinkClicked",@"UIWebViewNavigationTypeFormSubmitted",@"UIWebViewNavigationTypeBackForward",@"UIWebViewNavigationTypeReload",@"UIWebViewNavigationTypeFormResubmitted",@"UIWebViewNavigationTypeOther"];
    NSLog(@"shouldStartLoadWithRequest  request: %@ ,navigationType : %@ MainDocumentRequest : %@ ", request.URL.absoluteString,list[navigationType],@([request.mainDocumentURL isEqual:request.URL]));
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad  currentRequest: %@",webView.request.URL);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad currentRequest: %@",webView.request.URL);
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"didFailLoadWithError currentRequest: %@ error : %@",webView.request.URL,error);
}

@end


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loadNormalPage:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"normalpage.html" ofType:nil];
    path = [@"file://" stringByAppendingString:path];
    WebViewController *vc = [[WebViewController alloc] initWithURL:path];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)loadIFrame:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"loadIFrame.html" ofType:nil];
    path = [@"file://" stringByAppendingString:path];
    WebViewController *vc = [[WebViewController alloc] initWithURL:path];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)loadRedirect:(id)sender {
    WebViewController *vc = [[WebViewController alloc] initWithURL:@"http://taobao.com"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)navigatonLoad:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"navigationLoad.html" ofType:nil];
    path = [@"file://" stringByAppendingString:path];
    WebViewController *vc = [[WebViewController alloc] initWithURL:path];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)loadWithIFrame:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"loadIWithFrame.html" ofType:nil];
    path = [@"file://" stringByAppendingString:path];
    WebViewController *vc = [[WebViewController alloc] initWithURL:path];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)loadWithIFrameFailed:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"loadIWithFrameFailed" ofType:@"html"];
    path = [@"file://" stringByAppendingString:path];
    WebViewController *vc = [[WebViewController alloc] initWithURL:path];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)loadFrameWithInvalidURL:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"loadIWithFrameInvalidURL" ofType:@"html"];
    path = [@"file://" stringByAppendingString:path];
    WebViewController *vc = [[WebViewController alloc] initWithURL:path];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)loadPageWithInvalidURL:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"loadIWithFrameFailed" ofType:@"html"];
    path = [@"fle://" stringByAppendingString:path];
    WebViewController *vc = [[WebViewController alloc] initWithURL:path];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
