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
#import "SDWebImageManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "JLPhotoBrowser.h"
#import "MJPhotoBrowser.h"

@interface MobAdViewController () <WKUIDelegate, WKNavigationDelegate, UIWebViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) WKWebView *webview;
@property (nonatomic, strong) UIWebView *meituWeb;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) GADBannerView *banner;

@property (nonatomic, assign) BOOL meitu;
@property (nonatomic, strong) NSMutableArray *imgsArray;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *imgViewsArray;

@property (nonatomic, assign) NSInteger longPressIndex;

@end

@implementation MobAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.adModel.title;
    if (self.adModel.type == AdvertisementType_MMJPG) {
        self.view.backgroundColor = [UIColor grayColor];
        self.meitu = YES;
        self.meituWeb = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, Width, self.view.height - 50)];
        self.meituWeb.hidden = YES;
        self.meituWeb.delegate = self;
        NSURL *url = [NSURL URLWithString:self.adModel.link];
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.meituWeb loadData:data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:url];
        });
        [self.view addSubview:self.meituWeb];
    } else if (self.adModel.type == AdvertisementType_OtherWeb) {
        self.webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, Width, self.view.height - 50)];
        self.webview.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.webview];
        self.webview.UIDelegate = self;
        self.webview.navigationDelegate= self;
        [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.adModel.link]]];
    }
    [self.indicatorView startAnimating];
    [self setupBannerView];
    
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
    [WinSocialShareTool win_shareTitle:@"精选美图" images:shareImgs content:self.adModel.title > 0 ? self.adModel.title : @"美食菜谱" urlString:self.adModel.link recommendCid:self.model.currentId];
}

- (void)setupBannerView
{
//    CGFloat bannerViewY = self.meitu ? arc4random() % (NSInteger)((Height - 64 - 50) * 0.5) + ((Height - 64 - 50) * 0.5) : Height - 50;
    GADBannerView *banner = [[GADBannerView alloc] initWithFrame:CGRectMake(0, Height - 50, Height, 50)];
    banner.adUnitID = AdMobBannerID;
    banner.rootViewController = self;
    banner.delegate = self;
    GADRequest *request = [GADRequest request];
    [banner loadRequest:request];
    [self.view addSubview:banner];
    self.banner = banner;
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    if (bannerView.y == Height - 50) {
        
        __weak MobAdViewController *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.3 animations:^{
                bannerView.y -= 64;
                [weakSelf.view layoutIfNeeded];
            }];
        });
    }
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    if (bannerView.y == Height - 50 - 64) {
        
        __weak MobAdViewController *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                bannerView.y += 64;
                [weakSelf.view layoutIfNeeded];
            }];
        });
    }
}

- (void)dealloc
{
    [[NSFileManager defaultManager] removeItemAtPath:NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject error:nil];
}

- (void)addScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, Width, Height - 64 - 50)];
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    NSInteger cols = 3;
    CGFloat gap = 8;
    CGFloat itemWidth = (Width - gap * (cols + 1)) / cols;
    CGFloat itemHeight = itemWidth * 1.35;
    for (NSInteger i = 0; i < self.imgsArray.count; i++) {
        NSInteger col = i % cols;
        NSInteger row = i / cols;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(gap + col * (itemWidth + gap), gap + row * (itemHeight + gap), itemWidth, itemHeight)];
        imgView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05].CGColor;
        imgView.layer.borderWidth = 1;
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.userInteractionEnabled = YES;
        imgView.tag = i;
        [imgView sd_setImageWithURL:self.imgsArray[i] placeholderImage:[UIImage imageNamed:@"placeholderPicture"]];
        [self.scrollView addSubview:imgView];
        [self.imgViewsArray addObject:imgView];
        // 点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageWithPhotoBrowser:)];
        [imgView addGestureRecognizer:tap];
        if (Manager(((AppDelegate *)[UIApplication sharedApplication].delegate).uid)) {
            // 长按手势
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            [imgView addGestureRecognizer:longPress];
        }
    }
    self.scrollView.contentSize = CGSizeMake(Width, ((self.imgsArray.count - 1) / cols + 1) * (itemHeight + gap) + gap + 5);
    [self.view bringSubviewToFront:self.banner];
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(longPressFunction) userInfo:nil repeats:NO];
        self.longPressIndex = gesture.view.tag + 1;
    }
}

- (void)longPressFunction
{
    UIActionSheet *act = [[UIActionSheet alloc] initWithTitle:@"设置为显示图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
    [act showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSString *last = self.adModel.imgUrl.lastPathComponent;
        NSString *extension = last.pathExtension;
        NSString *newPic = [NSString stringWithFormat:@"%ld.%@", self.longPressIndex, extension];
        self.adModel.imgUrl = [self.adModel.imgUrl stringByReplacingOccurrencesOfString:last withString:newPic];
        NSDictionary *dict = [MobAdvertiseModel faf_keyValuesArrayWithObjectArray:@[self.adModel]].firstObject;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [MobAPI sendRequestWithInterface:@"/ucache/put" param:@{@"key" : APPKey, @"table" : @"advertisement", @"k" : [self codeStringWithOriginalString:self.adModel.key], @"v" : [self codeStringWithOriginalString:json]} onResult:^(MOBAResponse *response) {
            if (!response.error) {
                [FAFProgressHUD showSuccess:@"设置成功" toView:self.view];
            } else {
                [FAFProgressHUD showError:@"操作失败,请稍后重试" toView:self.view];
            }
        }];
    }
}

// Base64编码
- (NSString *)codeStringWithOriginalString:(NSString *)originalString
{
    originalString = [WinDataCode win_EncryptAESData:originalString app_key:Secret];
    return [[[[[originalString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"=" withString:@""] stringByReplacingOccurrencesOfString:@"+" withString:@"-"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
}

- (void)showImageWithPhotoBrowser:(UITapGestureRecognizer *)gesture
{
    NSMutableArray *photos = [NSMutableArray array];
    for (NSInteger i = 0; i < self.imgsArray.count; i++) {
        
        // 1.创建photo模型
        MJPhoto *photo = [[MJPhoto alloc] init];
        // 2.原始imageView
        photo.url = self.imgsArray[i];
        photo.srcImageView = self.imgViewsArray[i];
        
        [photos addObject:photo];
        
    }
    MJPhotoBrowser *photoBrowser = [[MJPhotoBrowser alloc] init];
    photoBrowser.photos = photos;
    photoBrowser.currentPhotoIndex = gesture.view.tag;
    [photoBrowser show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.imgsArray.count == 0) {
        NSString *js = @"var content = document.querySelector('#content');var img = content.querySelector('img');img.src;";
        NSString *jpgUrl = [webView stringByEvaluatingJavaScriptFromString:js];
        NSString *extension = jpgUrl.pathExtension;
        NSString *last = jpgUrl.lastPathComponent;
        NSString *baseUrlString = [jpgUrl stringByReplacingOccurrencesOfString:last withString:@""];
        js = @"var page = document.querySelector('#page');var as = page.children;var a = as[as.length - 3];a.innerText;";
        NSString *countString = [webView stringByEvaluatingJavaScriptFromString:js];
        NSInteger count = countString.integerValue;
        
        for (NSInteger i = 0; i < count; i++) {
            NSURL *imgUrl = [NSURL URLWithString:[baseUrlString stringByAppendingFormat:@"%ld.%@", i+1, extension]];
            [self.imgsArray addObject:imgUrl];
        }
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%ld张", self.imgsArray.count] style:UIBarButtonItemStyleDone target:nil action:nil];
        [self addScrollView];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.indicatorView stopAnimating];
    });
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.indicatorView stopAnimating];
    [FAFProgressHUD show:@"加载失败,请重试" icon:nil view:self.view color:nil];
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
        _indicatorView.color = [UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1];
        _indicatorView.center = CGPointMake(Width * 0.5, self.view.center.y - 32);
        [self.view addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (NSMutableArray *)imgsArray
{
    if (_imgsArray == nil) {
        _imgsArray = [NSMutableArray array];
    }
    return _imgsArray;
}

- (NSMutableArray *)imgViewsArray
{
    if (_imgViewsArray == nil) {
        _imgViewsArray = [NSMutableArray array];
    }
    return _imgViewsArray;
}

@end
