//
//  MobAdViewController.m
//  FoodRecipes
//
//  Created by WinterChen on 16/8/17.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "MobAdViewController.h"
#import <WebKit/WebKit.h>
#import "WinSocialShareTool.h"
#import "UIImageView+WebCache.h"

@interface MobAdViewController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webview;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation MobAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, Width, self.view.height - 50)];
    self.webview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webview];
    self.webview.UIDelegate = self;
    self.webview.navigationDelegate= self;
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.link]]];
    [self.indicatorView startAnimating];
    
    CSBBannerView *banner = [[CSBBannerView alloc] initWithFrame:CGRectMake(0, self.view.height - 114, Width, 50)];
    [banner loadAd];
    [self.view addSubview:banner];
}

- (void)shareItemClicked
{
    NSString *imgKey = nil;
    NSMutableArray *shareImgs = [NSMutableArray array];
    imgKey = [self.model.thumbnails componentsSeparatedByString:@"$"].lastObject ?: nil;
    if (imgKey) {
        UIImage *shareImg = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imgKey] ?: [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imgKey];
        if (shareImg) {
            [shareImgs addObject:shareImg];
        }
        imgKey = nil;
    }
    if (shareImgs.count == 0) {
        [shareImgs addObject:[UIImage imageNamed:@"shareDefault"]];
    }
    [WinSocialShareTool win_shareTitle:@"精选美食" images:shareImgs content:self.model.title > 0 ? self.model.title : @"美食菜谱" urlString:self.link recommendCid:self.model.currentId];
}

- (void)dealloc
{
    [[NSFileManager defaultManager] removeItemAtPath:NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject error:nil];
}

#pragma mark WKWebView的代理
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.indicatorView stopAnimating];
    if (self.model) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shareIcon"] style:UIBarButtonItemStyleDone target:self action:@selector(shareItemClicked)];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self.indicatorView stopAnimating];
}

- (UIActivityIndicatorView *)indicatorView
{
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.color = [UIColor grayColor];
        _indicatorView.center = self.view.center;
        [self.view addSubview:_indicatorView];
    }
    return _indicatorView;
}

@end
