//
//  PareDetailViewController.m
//  ygxtClass
//
//  Created by kaili on 2018/9/10.
//  Copyright © 2018年 kaili. All rights reserved.
//

#import "PareDetailViewController.h"

@interface PareDetailViewController ()<UIWebViewDelegate>

@end

@implementation PareDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = self.pareUrl;
    UIWebView * webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    webView.delegate = self;
    webView.mediaPlaybackRequiresUserAction = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
}
@end
