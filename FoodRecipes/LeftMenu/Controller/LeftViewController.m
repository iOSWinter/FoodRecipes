//
//  LeftViewController.m
//  SideViewController
//
//  Created by YouXianMing on 16/6/6.
//  Copyright © 2016年 YouXianMing. All rights reserved.
//

#import "LeftViewController.h"
#import "UIView+SetRect.h"
#import "UIImageView+WebCache.h"
#import "WinSocialShareTool.h"
#import "AppDelegate.h"

@interface LeftViewController ()

@property (nonatomic, strong) UIImageView *img;
@property (nonatomic, strong) UILabel *nickname;
@property (nonatomic, strong) UIImageView *background;
@property (nonatomic, strong) UILabel *cache;
@property (nonatomic, strong) NSString *cachesDir;
@property (nonatomic, strong) UILabel *loginTips;
@property (nonatomic, strong) UIButton *logoutButton;
@property (nonatomic, strong) UIButton *manageAdButton;
@property (nonatomic, strong) UIButton *recommendButton;

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBackgroundImg];
    [self setupImgView];
    [self setupLoginView];
    [self setupCollectView];
    [self setupClearCachesView];
    [self setupAdvertisementView];
    [self setupRecommendView];
    [self setupLogoutButtonView];
}

- (void)setupBackgroundImg
{
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    background.width = Width * 0.75;
    background.image = [UIImage imageNamed:@"nav"];
    background.userInteractionEnabled = YES;
    [self.view addSubview:background];
    _background = background;
}

- (void)setupImgView
{
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    img.layer.cornerRadius = img.frame.size.width * 0.5;
    img.layer.masksToBounds = YES;
    img.center = CGPointMake(Width * 3 / 4 * 0.5, 30);
    [self.background addSubview:img];
    _img = img;
    UILabel *nickname = [[UILabel alloc] initWithFrame:CGRectMake(0, img.y + img.height + 5, Width * 0.75, 15)];
    nickname.font = [UIFont systemFontOfSize:13];
    nickname.textAlignment = NSTextAlignmentCenter;
    nickname.textColor = [UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1];
    [self.background addSubview:nickname];
    _nickname = nickname;
    
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    if (user) {
        [self.img sd_setImageWithURL:[NSURL URLWithString:user[@"icon"]]];
        self.nickname.text = user[@"nickname"];
        ((AppDelegate *)[UIApplication sharedApplication].delegate).uid = user[@"uid"];
    } else {
        [self showLoginTipsView];
    }
}

- (void)showLoginTipsView
{
    UILabel *loginTips = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Width * 0.5, 40)];
    loginTips.center = CGPointMake(Width * 0.75 * 0.5, self.img.centerY + 10);
    loginTips.backgroundColor = [UIColor blackColor];
    loginTips.textColor = [UIColor whiteColor];
    loginTips.text = @"您还没有登录账号";
    loginTips.textAlignment = NSTextAlignmentCenter;
    loginTips.layer.cornerRadius = 5;
    loginTips.layer.masksToBounds = YES;
    [self.background addSubview:loginTips];
    _loginTips = loginTips;
}

- (void)setupLoginView
{
    UIButton *loginWay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginWay.frame = CGRectMake(0, self.nickname.y + self.nickname.height + 15, Width * 0.75, 40);
    [loginWay setTitle:@"登录方式" forState:UIControlStateNormal];
    loginWay.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [loginWay setTintColor:[UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1]];
    loginWay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
    loginWay.userInteractionEnabled = NO;
    loginWay.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    loginWay.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [self.background addSubview:loginWay];

    UIButton *qq = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    qq.frame = CGRectMake((Width * 0.75 - 160) / 3, loginWay.y + loginWay.height + 5, 60, 60);
    [qq setBackgroundImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
    qq.tag = 1;
    [self.background addSubview:qq];
    [qq addTarget:self action:@selector(loginButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [qq setTintColor:[UIColor clearColor]];
    UIButton *wb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    wb.frame = CGRectMake(Width * 0.75 - qq.x - 70, qq.y, 70, 70);
    [wb setBackgroundImage:[UIImage imageNamed:@"wb"] forState:UIControlStateNormal];
    wb.tag = 2;
    [self.background addSubview:wb];
    [wb addTarget:self action:@selector(loginButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupCollectView
{
    UIButton *collectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    collectButton.frame = CGRectMake(0, self.nickname.centerY + 140, Width * 0.75, 40);
    [collectButton setTitle:@"我的收藏" forState:UIControlStateNormal];
    collectButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [collectButton setTintColor:[UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1]];
    collectButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.06];
    [collectButton setImage:[UIImage imageNamed:@"nextIcon"] forState:UIControlStateNormal];
    collectButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    collectButton.imageEdgeInsets = UIEdgeInsetsMake(0, collectButton.width - 25, 0, 0);
    collectButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [self.background addSubview:collectButton];
    [collectButton addTarget:self action:@selector(collect:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupClearCachesView
{
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    clearButton.frame = CGRectMake(0, self.nickname.centerY + 195, Width * 0.75, 40);
    [clearButton setTitle:@"清理缓存" forState:UIControlStateNormal];
    clearButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [clearButton setTintColor:[UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1]];
    clearButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.06];
    clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    clearButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [self.background addSubview:clearButton];
    [clearButton addTarget:self action:@selector(cleanCaches) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *cache = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, clearButton.width - 15, 40)];
    cache.font = [UIFont systemFontOfSize:13];
    cache.textAlignment = NSTextAlignmentRight;
    cache.textColor = [UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1];
    [clearButton addSubview:cache];
    _cache = cache;
    
    _cachesDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    [self updateCachesSize];
}

- (void)setupAdvertisementView
{
    UIButton *manageAdButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    manageAdButton.frame = CGRectMake(0, self.nickname.centerY + 250, Width * 0.75, 40);
    [manageAdButton setTitle:@"广告管理" forState:UIControlStateNormal];
    manageAdButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [manageAdButton setTintColor:[UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1]];
    manageAdButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.06];
    manageAdButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    manageAdButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [manageAdButton setImage:[UIImage imageNamed:@"nextIcon"] forState:UIControlStateNormal];
    manageAdButton.imageEdgeInsets = UIEdgeInsetsMake(0, manageAdButton.width - 25, 0, 0);
    [self.background addSubview:manageAdButton];
    _manageAdButton = manageAdButton;
    [manageAdButton addTarget:self action:@selector(manageAdvertisement:) forControlEvents:UIControlEventTouchUpInside];
    [self setupManageAdButtonStatus];
}

- (void)setupManageAdButtonStatus
{
    self.manageAdButton.hidden = YES;
    self.manageAdButton.enabled = NO;
    self.recommendButton.hidden = YES;
    self.recommendButton.enabled = NO;
    NSString *uid = ((AppDelegate *)[UIApplication sharedApplication].delegate).uid;
    if (([uid isEqualToString:@"WB5977475514"] || [uid isEqualToString:@"QQ805F4B09B2E96E9EB65A6E08FB92B05D"] || [uid isEqualToString:@"WB3455461862"])) {
        self.manageAdButton.hidden = NO;
        self.manageAdButton.enabled = YES;
        self.recommendButton.hidden = NO;
        self.recommendButton.enabled = YES;
    }
}

- (void)setupRecommendView
{
    UIButton *recommendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    recommendButton.frame = CGRectMake(0, self.nickname.centerY + 305, Width * 0.75, 40);
    [recommendButton setTitle:@"推荐管理" forState:UIControlStateNormal];
    recommendButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [recommendButton setTintColor:[UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1]];
    recommendButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.06];
    recommendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    recommendButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [recommendButton setImage:[UIImage imageNamed:@"nextIcon"] forState:UIControlStateNormal];
    recommendButton.imageEdgeInsets = UIEdgeInsetsMake(0, recommendButton.width - 25, 0, 0);
    [self.background addSubview:recommendButton];
    _recommendButton = recommendButton;
    [recommendButton addTarget:self action:@selector(recommendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self setupManageAdButtonStatus];
}

- (void)setupLogoutButtonView
{
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    logoutButton.frame = CGRectMake(0, 0, Width * 0.5, 30);
    logoutButton.center = CGPointMake(self.img.centerX, self.background.height - 90);
    logoutButton.layer.cornerRadius = 5;
    logoutButton.layer.masksToBounds = YES;
    [logoutButton setTitle:@"退出登录" forState:UIControlStateNormal];
    logoutButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [logoutButton setTintColor:[UIColor whiteColor]];
    logoutButton.backgroundColor = [UIColor redColor];
    logoutButton.tag = ((AppDelegate *)[UIApplication sharedApplication].delegate).uid ? 1 : 0;
    [self.background addSubview:logoutButton];
    _logoutButton = logoutButton;
    [self setupLogoutButtonSatuas];
    [logoutButton addTarget:self action:@selector(logoutButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupLogoutButtonSatuas
{
    self.logoutButton.hidden = !self.logoutButton.tag;
    self.logoutButton.enabled = self.logoutButton.tag;
}

#pragma mark 事件处理
- (void)loginButtonClick:(UIButton *)button
{
    FAFProgressHUD *hud = [FAFProgressHUD showMessage:@"" toView:self.background];
    [WinSocialShareTool win_loginWithPlatformType:button.tag == 1 ? WinLoginPlatformTypeQQ : WinLoginPlatformTypeSinaWeibo resultBlock:^(WinSSDKUser *user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud removeFromSuperview];
            if (user) {
                [self.loginTips removeFromSuperview];
                [self.img sd_setImageWithURL:[NSURL URLWithString:user.icon]];
                self.nickname.text = user.nickname;
                ((AppDelegate *)[UIApplication sharedApplication].delegate).uid = user.uid;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:@{@"nickname" : user.nickname ?: @"", @"icon" : user.icon ?: @"", @"uid" : user.uid} forKey:@"user"];
                [defaults synchronize];
                self.logoutButton.tag = 1;
                [self setupLogoutButtonSatuas];
                [self setupManageAdButtonStatus];
            }
        });
    }];
}

- (void)cleanCaches
{
    NSError *error = nil;
    NSArray *dirArray = @[[self.cachesDir stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"], [self.cachesDir stringByAppendingPathComponent:@"default"]];
    for (NSString *dir in dirArray) {
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
        NSEnumerator *e = [contents objectEnumerator];
        NSString *filename;
        while ((filename = [e nextObject])) {
            NSString *filePath = [dir stringByAppendingPathComponent:filename];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        }
    }
    [self updateCachesSize];
}

- (void)collect:(UIButton *)button
{
    [self excuteDelegate:1];
}

- (void)manageAdvertisement:(UIButton *)button
{
    [self excuteDelegate:2];
}

- (void)recommendButton:(UIButton *)button
{
    [self excuteDelegate:3];
}

- (void)logoutButton:(UIButton *)button
{
    if (button.tag) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"user"];
        [defaults synchronize];
        self.img.image = nil;
        self.nickname.text = nil;
        ((AppDelegate *)[UIApplication sharedApplication].delegate).uid = nil;
        [self showLoginTipsView];
        button.tag = !button.tag;
        [self setupLogoutButtonSatuas];
        [self setupManageAdButtonStatus];
    }
}

#pragma mark 辅助方法
- (void)excuteDelegate:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(leftViewHidden:)]) {
        [self.delegate leftViewHidden:index];
    }
}

- (void)updateCachesSize
{
    self.cache.text = [NSString stringWithFormat:@"%0.2fM", [self folderSizeAtPath:[_cachesDir stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"]] + [self folderSizeAtPath:[_cachesDir stringByAppendingPathComponent:@"default"]]];
}

- (CGFloat)folderSizeAtPath:(NSString *)folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) {
        return 0;
    }
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    CGFloat folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize / (1024.0 * 1024.0);
}

- (CGFloat)fileSizeAtPath:(NSString*)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

@end
