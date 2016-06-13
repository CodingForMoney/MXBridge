//
//  ViewController.m
//  MXWebviewDemo
//
//  Created by 罗贤明 on 16/6/8.
//  Copyright © 2016年 罗贤明. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webview;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *localfilePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSString *urlPath = [@"file://" stringByAppendingPathComponent:localfilePath];
    
    [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
