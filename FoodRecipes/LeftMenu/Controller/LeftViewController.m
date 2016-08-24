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
}

- (void)setupBackgroundImg
{
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    background.image = [UIImage imageNamed:@"nav"];
    background.userInteractionEnabled = YES;
    [self.view addSubview:background];
    _background = background;
}

- (void)setupImgView
{
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, 60, 60)];
    img.layer.cornerRadius = img.frame.size.width * 0.5;
    img.layer.masksToBounds = YES;
    img.center = CGPointMake(Width * 3 / 4 * 0.5, 40);
    [self.background addSubview:img];
    _img = img;
    UILabel *nickname = [[UILabel alloc] initWithFrame:CGRectMake(0, img.centerY + 35, Width * 0.75, 15)];
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
        UILabel *loginTips = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Width * 0.5, 40)];
        loginTips.center = CGPointMake(Width * 0.75 * 0.5, 55);
        loginTips.backgroundColor = [UIColor blackColor];
        loginTips.textColor = [UIColor whiteColor];
        loginTips.text = @"您还没有登录账号";
        loginTips.textAlignment = NSTextAlignmentCenter;
        loginTips.layer.cornerRadius = 5;
        loginTips.layer.masksToBounds = YES;
        [self.background addSubview:loginTips];
        _loginTips = loginTips;
    }
}

- (void)setupLoginView
{
    UIButton *loginWay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginWay.frame = CGRectMake(0, 100, Width * 0.75, 40);
    [loginWay setTitle:@"登录方式" forState:UIControlStateNormal];
    loginWay.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [loginWay setTintColor:[UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1]];
    loginWay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
    loginWay.userInteractionEnabled = NO;
    loginWay.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    loginWay.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [self.background addSubview:loginWay];

    UIButton *qq = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    qq.frame = CGRectMake((Width * 0.75 - 160) / 3, loginWay.centerY + 30, 60, 60);
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
    
    UILabel *cache = [[UILabel alloc] initWithFrame:CGRectMake(clearButton.width - 160, clearButton.y, 150, 40)];
    cache.font = [UIFont systemFontOfSize:13];
    cache.textAlignment = NSTextAlignmentRight;
    cache.textColor = [UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1];
    [self.background addSubview:cache];
    _cache = cache;
    
    _cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"];
    [self updateCachesSize];
}

- (void)setupAdvertisementView
{
    NSString *uid = ((AppDelegate *)[UIApplication sharedApplication].delegate).uid;
    if (!([uid isEqualToString:@"WB5977475514"] || [uid isEqualToString:@"QQ805F4B09B2E96E9EB65A6E08FB92B05D"])) {
        return;
    }
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
    [manageAdButton addTarget:self action:@selector(manageAdvertisement:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark 事件处理
- (void)loginButtonClick:(UIButton *)button
{
    [WinSocialShareTool win_loginWithPlatformType:button.tag == 1 ? WinLoginPlatformTypeQQ : WinLoginPlatformTypeSinaWeibo resultBlock:^(WinSSDKUser *user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (user) {
                [self.loginTips removeFromSuperview];
                [self.img sd_setImageWithURL:[NSURL URLWithString:user.icon]];
                self.nickname.text = user.nickname;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:@{@"nickname" : user.nickname ?: @"", @"icon" : user.icon ?: @"", @"uid" : user.uid} forKey:@"user"];
                [defaults synchronize];
            }
        });
    }];
}

- (void)cleanCaches
{
    NSError *error = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.cachesDir error:nil];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        NSString *filePath = [self.cachesDir stringByAppendingPathComponent:filename];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
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

#pragma mark 辅助方法
- (void)excuteDelegate:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(leftViewHidden:)]) {
        [self.delegate leftViewHidden:index];
    }
}

- (void)updateCachesSize
{
    self.cache.text = [NSString stringWithFormat:@"%0.2fM", [self folderSizeAtPath:_cachesDir]];
}

- (CGFloat)folderSizeAtPath:(NSString*)folderPath
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
