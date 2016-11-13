//
//  LeftViewController.m
//  FoodRecipes
//
//  Created by WinterChen on 16/8/29.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "LeftViewController.h"
#import "UIView+SetRect.h"
#import "AppDelegate.h"
#import "WinSocialShareTool.h"
#import "UIImageView+WebCache.h"


@interface LeftViewController ()

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *loginTips;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;
@property (weak, nonatomic) IBOutlet UIButton *cleanCachesButton;
@property (weak, nonatomic) IBOutlet UIButton *manageAdButton;
@property (weak, nonatomic) IBOutlet UIButton *recommendButton;
@property (weak, nonatomic) IBOutlet UILabel *cachesSize;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftViewWidthConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginTipsWidthConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *manageAdHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *RecommendHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoutButtonSpaceToTopConstraitns;
@property (nonatomic, strong) NSString *cachesDir;

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0, 0, Width, Height);
    
    [self setupViewsStyle];
}

- (void)setupViewsStyle
{
    [self setupBackgroundView];
    self.leftViewWidthConstraints.constant = leftViewWidth;
    self.loginTipsWidthConstraints.constant = leftViewWidth * 0.75;
    [self setupRadius:30 view:self.img];
    [self setupRadius:5 view:self.loginTips];
    [self setupRadius:5 view:self.logoutButton];
    [self setupLoginStatus];
    [self setupButtonImage:self.collectButton];
    [self setupButtonImage:self.manageAdButton];
    [self setupButtonImage:self.recommendButton];
    _cachesDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
}

- (void)setupBackgroundView
{
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Width * 0.75, self.view.height)];
    background.width = leftViewWidth;
    background.image = [UIImage imageNamed:@"nav"];
    background.userInteractionEnabled = YES;
    [self.backgroundView insertSubview:background atIndex:0];
}

- (void)setupRadius:(CGFloat)radius view:(UIView *)view
{
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}

- (void)setupLoginStatus
{
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    if (user) {
        [self.img sd_setImageWithURL:[NSURL URLWithString:user[@"icon"]]];
        self.nickname.text = user[@"nickname"];
        ((AppDelegate *)[UIApplication sharedApplication].delegate).uid = user[@"uid"];
    }
    NSString *uid = ((AppDelegate *)[UIApplication sharedApplication].delegate).uid;
    self.manageAdHeightConstraints.constant = 0;
    self.RecommendHeightConstraints.constant = 0;
    self.manageAdButton.hidden = YES;
    self.recommendButton.hidden = YES;
    if (uid) {
        self.loginTips.hidden = YES;
        self.loginHeightConstraints.constant = 0;
        self.loginView.hidden = YES;
        self.logoutButton.hidden = NO;
        if (Manager(uid)) {
            
            self.manageAdHeightConstraints.constant = 55;
            self.RecommendHeightConstraints.constant = 55;
            self.manageAdButton.hidden = NO;
            self.recommendButton.hidden = NO;
        }
    } else {
        self.loginTips.hidden = NO;
        self.loginHeightConstraints.constant = 110;
        self.loginView.hidden = NO;
        self.logoutButton.hidden = YES;
    }
    self.logoutButtonSpaceToTopConstraitns.constant = Height - 44 - 50 - (self.recommendButton.hidden ?  230 : 340);
}

- (void)setupButtonImage:(UIButton *)button
{
    [button setImage:[[UIImage imageNamed:@"nextIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, leftViewWidth - 25, 0, 0);
    
}

#pragma mark 事件处理
- (void)loginWithType:(WinLoginPlatformType)type
{
    FAFProgressHUD *hud = [FAFProgressHUD showMessage:@"" toView:self.backgroundView];
    [WinSocialShareTool win_loginWithPlatformType:type resultBlock:^(WinSSDKUser *user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud removeFromSuperview];
            if (user) {
                [self.img sd_setImageWithURL:[NSURL URLWithString:user.icon]];
                self.nickname.text = user.nickname;
                ((AppDelegate *)[UIApplication sharedApplication].delegate).uid = user.uid;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:@{@"nickname" : user.nickname ?: @"", @"icon" : user.icon ?: @"", @"uid" : user.uid} forKey:@"user"];
                [defaults synchronize];
                self.logoutButton.tag = 1;
                [self setupLoginStatus];
            }
        });
    }];
}

- (IBAction)loginWithQQ:(id)sender
{
    [self loginWithType:WinLoginPlatformTypeQQ];
}

- (IBAction)loginWithWB:(id)sender
{
    [self loginWithType:WinLoginPlatformTypeSinaWeibo];
}

- (IBAction)collectClicked:(id)sender
{
    [self excuteDelegate:1];
}

- (IBAction)cleanCacheClicked:(id)sender
{
    NSArray *dirArray = @[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.center = self.cleanCachesButton.center;
    indicatorView.color = [UIColor orangeColor];
    [self.cleanCachesButton addSubview:indicatorView];
    [indicatorView startAnimating];
    for (NSString *dir in dirArray) {
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
        NSEnumerator *e = [contents objectEnumerator];
        NSString *filename;
        while ((filename = [e nextObject])) {
            NSError *error = nil;
            NSString *filePath = [dir stringByAppendingPathComponent:filename];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self updateCachesSize];
        [indicatorView stopAnimating];
    });
}

- (IBAction)manageAdClicked:(id)sender
{
    [self excuteDelegate:2];
}

- (IBAction)recommendClicked:(id)sender
{
    [self excuteDelegate:3];
}

- (IBAction)logoutButtonClicked:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"user"];
    [defaults synchronize];
    self.img.image = nil;
    self.nickname.text = nil;
    ((AppDelegate *)[UIApplication sharedApplication].delegate).uid = nil;
    [self setupLoginStatus];
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
    self.cachesSize.text = [NSString stringWithFormat:@"%0.2fM", [self folderSizeAtPath:[_cachesDir stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"]] + [self folderSizeAtPath:[_cachesDir stringByAppendingPathComponent:@"default"]]];
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
