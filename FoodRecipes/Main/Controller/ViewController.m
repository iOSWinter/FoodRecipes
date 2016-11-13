//
//  ViewController.m
//  Recorder
//
//  Created by WinterChen on 16/8/14.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "ViewController.h"
#import "LeftViewController.h"
#import "MainViewController.h"
#import "MobSearchViewController.h"
#import "MobAdEditViewController.h"
#import "MobMyCollectViewController.h"
#import "MobRecommendViewController.h"
#import "UIView+SetRect.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface ViewController () <LeftViewControllerDelegate, GADInterstitialDelegate, GADBannerViewDelegate>
// 右滑侧栏相关
{
    CGFloat _screenWidth;
}

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic)         CGPoint                 panBeginPoint;

@property (nonatomic, strong) LeftViewController     *leftViewController;
@property (nonatomic, strong) UIView                 *leftView;

@property (nonatomic, strong) MainViewController     *mainViewController;
@property (nonatomic, strong) UIView                 *mainView;

@property (nonatomic, strong) UINavigationBar *navBar;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) NSString *titleName;
@property (nonatomic, assign) BOOL special;
@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) UIView *launchView;
@property (nonatomic, strong) GADBannerView *rectBannerView;
@property (nonatomic, assign) BOOL adDidShow;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLeftView:) name:@"showLeftView" object:nil];
    
    _screenWidth = Width;
    // LeftViewController
    self.leftViewController = [[LeftViewController alloc] init];
    self.leftViewController.delegate = self;
    self.leftView = self.leftViewController.view;
    [self.view addSubview:self.leftView];
    // MainViewController
    self.mainViewController = [[MainViewController alloc] init];
    self.mainViewController.navController = self.navigationController;
    self.mainView = self.mainViewController.view;
    [self.view addSubview:self.mainView];
    // Pan gesture.
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureEvent:)];
    [self.mainView addGestureRecognizer:self.panGesture];
    
    [self showLaunchView];
}

- (void)showLaunchView
{
    UIView *launchView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    launchView.backgroundColor = [UIColor whiteColor];
    [self.navigationController.view addSubview:launchView];
    self.launchView = launchView;
    UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(0, Height, Width, 50)];
    [self.launchView addSubview:iconView];
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake((launchView.width - 80 - 50 - 10) * 0.5, 0, 50, 50)];
    icon.image = [UIImage imageNamed:@"appIcon"];
    icon.layer.cornerRadius = 10;
    icon.layer.masksToBounds = YES;
    [iconView addSubview:icon];
    UILabel *appName = [[UILabel alloc] initWithFrame:CGRectMake(icon.x + icon.width + 10, icon.y, 80, icon.height)];
    appName.text = @"美食菜谱";
    appName.textColor = [UIColor grayColor];
    [iconView addSubview:appName];
    [UIView animateWithDuration:0.5 animations:^{
        iconView.y -= 70;
    }];
    [self showRectangleBannerView];
}

- (void)showRectangleBannerView
{
    CGRect frame = CGRectMake((Width - 300) * 0.5, (Height - 70 - 250) * 0.5, 300, 250);
    _rectBannerView = [[GADBannerView alloc] initWithFrame:frame];
    [self.rectBannerView setAdSize:kGADAdSizeMediumRectangle];
    self.rectBannerView.adUnitID = AdMobBannerID;
    self.rectBannerView.rootViewController = self;
    self.rectBannerView.delegate = self;
    GADRequest *request = [GADRequest request];
    [self.rectBannerView loadRequest:request];
    [self.launchView addSubview:self.rectBannerView];
    UIView *barTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _rectBannerView.width, 15)];
    barTop.backgroundColor = [UIColor whiteColor];
    [_rectBannerView addSubview:barTop];
    UIView *barBottom = [[UIView alloc] initWithFrame:CGRectMake(0, _rectBannerView.height - barTop.height, _rectBannerView.width, barTop.height)];
    barBottom.backgroundColor = [UIColor whiteColor];
    [_rectBannerView addSubview:barBottom];
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(removeLaunchViewWhenNotShowAd) userInfo:nil repeats:NO];
}

- (void)showAdView
{
    CGRect frame = CGRectMake((Width - 300) * 0.5, (Height - 70 - 250) * 0.5, 300, 250);
    NSInteger sequence = arc4random() % 4 + 1;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"ad%ld.jpg", sequence]];
    imgView.layer.cornerRadius = 5;
    imgView.layer.masksToBounds = YES;
    imgView.alpha = 0.9;
    [self.launchView addSubview:imgView];
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    self.adDidShow = YES;
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(removeLaunchView) userInfo:nil repeats:NO];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    self.adDidShow = YES;
    [self showAdView];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(removeLaunchView) userInfo:nil repeats:NO];
}

- (void)removeLaunchViewWhenNotShowAd
{
    if (!self.adDidShow) {
        [self removeLaunchView];
    }
}

- (void)removeLaunchView
{
    self.mainViewController.refresh = YES;
    __weak ViewController *weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        
        weakSelf.launchView.y = Height;
    } completion:^(BOOL finished) {
        
        [weakSelf.launchView removeFromSuperview];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setupNavBar];
}

- (void)setupNavBar
{
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(self.special ? 0 : -0.75 * Width, 0, Width * 1.75, 44)];
    [navBar setBackgroundImage:[UIImage imageNamed:@"nav"] forBarMetrics:UIBarMetricsDefault];
    [navBar setTintColor:[UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1]];
    if (!self.special) {
        UINavigationItem *navItem = [[UINavigationItem alloc] init];
        [navItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"] style:UIBarButtonItemStyleDone target:self action:@selector(searchFood)]]];
        navBar.items = @[navItem];
    }
    UILabel *personal = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Width * 0.75, 44)];
    personal.font = [UIFont boldSystemFontOfSize:17];
    personal.textAlignment = NSTextAlignmentCenter;
    personal.text = @"个人中心";
    personal.textColor = [UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1];
    [navBar addSubview:personal];
    if (self.special) {
        UIImageView *back = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"backIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        back.frame = CGRectMake(Width * 0.75 + 4, 10.5, 18, 23);
        [back setTintColor:[UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1]];
        [navBar addSubview:back];
        UIImageView *share = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"shareIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        share.frame = CGRectMake(Width * 1.75 - 45, 6, 29, 30);
        [share setTintColor:[UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1]];
        [navBar addSubview:share];
    }
    UILabel *titleName = [[UILabel alloc] initWithFrame:CGRectMake(0.75 * Width, 0, Width, 44)];
    titleName.font = [UIFont boldSystemFontOfSize:17];
    titleName.textAlignment = NSTextAlignmentCenter;
    titleName.text = self.special ? self.titleName : @"美食秘方";
    titleName.textColor = [UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1];
    [navBar addSubview:titleName];
    [self.navigationController.navigationBar addSubview:navBar];
    _navBar = navBar;
    self.mainViewController.navBar = navBar;
    self.special = NO;
}

- (void)addTapGesture
{
    if (self.rightView == nil) {
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Width * 0.25, Height)];
        [self.mainView addSubview:rightView];
        _rightView = rightView;
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch:)];
    [self.rightView addGestureRecognizer:tap];
}

- (void)touch:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            _mainView.x = 0.0f;
            self.navBar.x = _mainView.x - 0.75 * Width;
        } completion:^(BOOL finished) {
            [self backToViewController];
        }];
    }
}

- (void)showLeftView:(NSNotification *)noti
{
    self.viewControllers = self.navigationController.viewControllers;
    [self.navigationController popToRootViewControllerAnimated:YES];
    UIImageView *imgView = noti.object;
    self.titleName = noti.userInfo.allValues.firstObject;
    [self.mainView addSubview:imgView];
    _imgView = imgView;
    self.special = YES;
    [self addTapGesture];
    self.mainView.x = _screenWidth * 0.75f;
    [self.leftViewController updateCachesSize];
}
         
- (void)backToViewController
 {
     [self.rightView removeFromSuperview];
     self.rightView = nil;
     if (self.viewControllers.count > 0) {
         self.navigationController.viewControllers = self.viewControllers;
         self.viewControllers = nil;
         [self.navBar removeFromSuperview];
         [self.imgView removeFromSuperview];
     }
 }

- (void)panGestureEvent:(UIPanGestureRecognizer *)gesture {
    
    CGPoint translation = [gesture translationInView:gesture.view];
    CGPoint velocity    = [gesture velocityInView:gesture.view];
    
    CGFloat gap               = _screenWidth * 0.75f;
    CGFloat sensitivePosition = _screenWidth * 0.3f;
    
    if (velocity.x < 0 && _mainView.x <= 0) {
        
        // 过滤掉向左侧滑过头的情形
        _mainView.x = 0.f;
        self.navBar.x = -0.75 * Width;
        
        [self backToViewController];
        
    } else {
        
        if (gesture.state == UIGestureRecognizerStateBegan) {
            
            // 开始
            _panBeginPoint = translation;
            
            if (_mainView.x >= sensitivePosition) {
                
                _panBeginPoint.x -= gap;
                self.navBar.x = gap - 0.75 * Width;
            }
            
        } else if (gesture.state == UIGestureRecognizerStateChanged) {
            
            // 值变化
            _mainView.x = translation.x - _panBeginPoint.x;
            _mainView.x = _mainView.x >= gap ? gap : _mainView.x;
            self.navBar.x = _mainView.x - 0.75 * Width;
            
            if (_mainView.x <= 0) {
                
                // 过滤掉向左侧滑过头的情形
                _mainView.x = 0.f;
                self.navBar.x = 0 - 0.75 * Width;
            }
            
        } else if (gesture.state == UIGestureRecognizerStateEnded) {
            
            // 结束
            [UIView animateWithDuration:0.20f animations:^{
                
                _mainView.x >= sensitivePosition ? (_mainView.x = gap) : (_mainView.x = 0);
                self.navBar.x = _mainView.x - 0.75 * Width;
                if (_mainView.x == gap) {
                    [self addTapGesture];
                    [self.leftViewController updateCachesSize];
                }
            } completion:^(BOOL finished) {
                if (_mainView.x == 0) {
                    [self backToViewController];
                }
            }];
        }
    }
}

#pragma mark 搜索食谱
- (void)searchFood
{
    [self.navBar removeFromSuperview];
    MobSearchViewController *vc = [[MobSearchViewController alloc] init];
    vc.title = @"美食搜索";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)leftViewHidden:(NSInteger)index
{
    self.mainView.x = 0;
    self.navBar.x = self.mainView.x - 0.75 * Width;
    [self.rightView removeFromSuperview];
    self.rightView = nil;
    [self.navBar removeFromSuperview];
    if (index == 1) {
        MobMyCollectViewController *vc = [[MobMyCollectViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (index == 2) {
        MobAdEditViewController *vc = [[MobAdEditViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (index == 3) {
        MobRecommendViewController *vc = [[MobRecommendViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end

