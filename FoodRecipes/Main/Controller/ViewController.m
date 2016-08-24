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
#import "UIView+SetRect.h"

@interface ViewController () <LeftViewControllerDelegate>
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
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLeftView) name:@"showLeftView" object:nil];
    
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setupNavBar];
}

- (void)setupNavBar
{
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(-0.75 * Width, 0, Width * 1.75, 44)];
    [navBar setBackgroundImage:[UIImage imageNamed:@"nav"] forBarMetrics:UIBarMetricsDefault];
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    [navItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"] style:UIBarButtonItemStyleDone target:self action:@selector(searchFood)]]];
    navBar.items = @[navItem];
    navBar.subviews[1].centerX = 0.75 * Width + Width * 0.5;
    UILabel *personal = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Width * 0.75, 44)];
    personal.font = [UIFont boldSystemFontOfSize:17];
    personal.textAlignment = NSTextAlignmentCenter;
    personal.text = @"个人中心";
    personal.textColor = [UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1];
    [navBar addSubview:personal];
    UILabel *titleName = [[UILabel alloc] initWithFrame:CGRectMake(0.75 * Width, 0, Width, 44)];
    titleName.font = [UIFont boldSystemFontOfSize:17];
    titleName.textAlignment = NSTextAlignmentCenter;
    titleName.text = @"美食秘方";
    titleName.textColor = [UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1];
    [navBar addSubview:titleName];
    [self.navigationController.navigationBar addSubview:navBar];
    _navBar = navBar;
    self.mainViewController.navBar = navBar;
}

- (void)addTapGesture
{
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Width * 0.25, Height)];
    rightView.backgroundColor = [UIColor redColor];
    [self.mainView addSubview:rightView];
    _rightView = rightView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch:)];
    [rightView addGestureRecognizer:tap];
}

- (void)touch:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            _mainView.x = 0.0f;
        } completion:^(BOOL finished) {
            [self backToViewController];
        }];
    }
}

- (void)showLeftView
{
    [self addTapGesture];
    self.mainView.x = _screenWidth / 4.f * 3;
    self.viewControllers = self.navigationController.viewControllers;
    [self.navigationController popToRootViewControllerAnimated:YES];
}
         
- (void)backToViewController
 {
     [self.rightView removeFromSuperview];
     if (self.viewControllers.count > 0) {
         self.navigationController.viewControllers = self.viewControllers;
         self.viewControllers = nil;
     }
 }

- (void)panGestureEvent:(UIPanGestureRecognizer *)gesture {
    
    CGPoint translation = [gesture translationInView:gesture.view];
    CGPoint velocity    = [gesture velocityInView:gesture.view];
    
    CGFloat gap               = _screenWidth / 4.f * 3;
    CGFloat sensitivePosition = _screenWidth / 2.f;
    
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
    [self.navBar removeFromSuperview];
    if (index == 1) {
        MobMyCollectViewController *vc = [[MobMyCollectViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        MobAdEditViewController *vc = [[MobAdEditViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end

