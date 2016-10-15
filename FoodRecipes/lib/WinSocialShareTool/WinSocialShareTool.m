//
//  WinSocialShareTool.m
//  ShareDemo
//
//  Created by WinterChen on 16/7/6.
//  Copyright © 2016年 win. All rights reserved.
//

#import "WinSocialShareTool.h"
#import <UIKit/UIKit.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDKUI.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <ShareSDK/ShareSDK+Base.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import "MJExtension.h"
#import "WinDataCode.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

#define animation 0.35
#define Secret @"1234567890."

@interface WinSocialShareTool ()

// 视图相关
/**  用于暂存遮盖View */
@property (nonatomic, strong) UIControl *coverView;
/**  用于显示分享icon的View */
@property (nonatomic, strong) UIView *shareView;
/**  用于暂存shareView的显示状态的Frame */
@property (nonatomic, assign) CGRect showFrame;
/**  用于暂存shareView的隐藏状态的Frame */
@property (nonatomic, assign) CGRect hideFrame;
/**  用于分享的数据字典 */
@property (nonatomic, strong) NSMutableDictionary *shareParams;
/**  加入推荐列表的id */
@property (nonatomic, strong) NSString *cid;

@end

static WinSocialShareTool *_shareInstance = nil;

@implementation WinSocialShareTool

// 调用登录模块
+ (void)win_loginWithPlatformType:(WinLoginPlatformType)platformType resultBlock:(void (^)(WinSSDKUser *))resultBlock
{
    [self initializeClass];
    [self loginWithPlatformType:platformType resultBlock:resultBlock];
}

// 调用分享模块
+ (void)win_shareTitle:(NSString *)title images:(NSArray *)images content:(NSString *)content urlString:(NSString *)urlString recommendCid:(NSString *)recommendCid
{
    [self initializeClass];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:content images:images url:[NSURL URLWithString:urlString] title:title type:SSDKContentTypeAuto];
    [_shareInstance setupSharePageViewWithShareParams:shareParams cid:recommendCid];
}

#pragma mark -第三方登录模块
// 第三方登录执行方法(每次都需要进行授权)
+ (void)loginWithPlatformType:(WinLoginPlatformType)platformType resultBlock:(void(^)(WinSSDKUser *))resultBlock
{
    SSDKPlatformType sdkType = (SSDKPlatformType)platformType;
    [ShareSDK authorize:sdkType settings:nil onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess) {
            [ShareSDK getUserInfo:sdkType onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
                if (error == nil) {
                    WinSSDKUser *sdkUser = [[WinSSDKUser alloc] init];
                    sdkUser.uid = [platformType == WinLoginPlatformTypeQQ ? @"QQ" : @"WB" stringByAppendingString:user.uid];
                    sdkUser.nickname = user.nickname;
                    sdkUser.icon = user.icon;
                    sdkUser.loginPlatformType = platformType;
                    if (sdkType == SSDKPlatformTypeQQ) {
                        sdkUser.icon = [sdkUser.icon stringByReplacingOccurrencesOfString:@"http://qzapp.qlogo.cn/qzapp" withString:@"http://q.qlogo.cn/qqapp"];
                    } else if (sdkType == SSDKPlatformTypeSinaWeibo) {
                        sdkUser.icon = [sdkUser.icon stringByReplacingOccurrencesOfString:@"50/" withString:@"180/"];
                    }
                    // 拼接授权信息
                    NSString *authString = @"";
                    NSString *separateString = @"/\\c";
                    if (platformType == WinLoginPlatformTypeQQ) {
                        QQUser *otherUser = [QQUser faf_objectWithKeyValues:user.rawData];
                        authString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", sdkUser.icon?:@"", separateString, user.nickname?:@"", separateString, otherUser.gender?:@"", separateString, [otherUser.province?:@"" stringByAppendingFormat:@" %@", otherUser.city?:@""]];
                    } else if (platformType == WinLoginPlatformTypeSinaWeibo) {
                        [SinaUser faf_setupReplacedKeyFromPropertyName:^NSDictionary *{
                            return @{@"description1" : @"description"};
                        }];
                        SinaUser *otherUser = [SinaUser faf_objectWithKeyValues:user.rawData];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
                        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                        NSDate *date = [dateFormatter dateFromString:otherUser.created_at?:@""];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSString *createTime = [dateFormatter stringFromDate:date];
                        authString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%ld%@%ld%@%ld%@%ld%@%ld%@%@%@%ld", sdkUser.icon?:@"", separateString, user.nickname?:@"", separateString, [otherUser.gender?:@"f" isEqualToString:@"m"] ? @"男" : @"女", separateString, otherUser.location?:@"", separateString, otherUser.description1?:@"", separateString, otherUser.followers_count, separateString, otherUser.friends_count, separateString, otherUser.statuses_count, separateString, otherUser.favourites_count, separateString, otherUser.bi_followers_count, separateString, createTime?:@"", separateString, (long)otherUser.allow_all_act_msg];
                    }
                    if (sdkUser.uid && ![authString isEqualToString:@""]) {
                        NSString *k = [WinDataCode win_EncodeBase64String:[WinDataCode win_EncryptAESData:user.uid app_key:Secret]];
                        NSString *v = [WinDataCode win_EncodeBase64String:[WinDataCode win_EncryptAESData:authString app_key:Secret]];
                        NSLog(@"%@,%@", k, v);
                        [MobAPI sendRequestWithInterface:@"/ucache/put" param:@{@"key" : @"17134bad622aa", @"table" : @"userInfo", @"k" : k, @"v" : v} onResult:nil];
                    }
                    if (resultBlock) {
                        resultBlock(sdkUser);
                    }
                }
            }];
        } else {
            if (resultBlock) {
                resultBlock(nil);
            }
        }
    }];
}

#pragma mark -第三方分享模块
// 分享平台点击事件
- (void)touchPlatformShareButton:(UIButton *)button
{
    switch (button.tag) {
        case 1: {
            // 微信好友
            [self shareActionWithType:SSDKPlatformSubTypeWechatSession];
            break;
        }
        case 2: {
            // 微信朋友圈
            [self shareActionWithType:SSDKPlatformSubTypeWechatTimeline];
            break;
        }
        case 3: {
            // 新浪微博
            [self shareActionWithType:SSDKPlatformTypeSinaWeibo];
            break;
        }
        case 4: {
            // QQ好友
            [self shareActionWithType:SSDKPlatformSubTypeQQFriend];
            break;
        }
        case 5: {
            // QQ空间
            [self shareActionWithType:SSDKPlatformSubTypeQZone];
            break;
        }
        case 6: {
            // 加入推荐列表
            [self shareActionWithType:SSDKPlatformTypeUnknown];
            break;
        }
        default:
            break;
    }
}

// 调用对应的平台进行分享
- (void)shareActionWithType:(SSDKPlatformType)type
{
    [self cancleShareView];
    if (type != SSDKPlatformTypeUnknown) {
        // 其他第三方平台
        if (type == SSDKPlatformTypeSinaWeibo) {
            [self addUrlStringToText];
        }
        [self.shareParams SSDKEnableUseClientShare];
        [ShareSDK share:type parameters:self.shareParams onAuthorize:^(SSDKAuthorizeStateChangedHandler authorizeStateChangedHandler) {
            [ShareSDK authorize:type settings:nil onStateChanged:nil];
        } onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
            [self handleShareResult:state platformType:type];
        }];
    } else {
        // 加入推荐列表
        [MobAPI sendRequestWithInterface:@"/ucache/put" param:@{@"key" : APPKey, @"table" : @"recommend", @"k" : [self codeStringWithOriginalString:self.cid], @"v" : [self codeStringWithOriginalString:@"YES"]} onResult:^(MOBAResponse *response) {
            [self handleShareResult:response.error ? SSDKResponseStateFail : SSDKResponseStateSuccess platformType:SSDKPlatformTypeUnknown];
        }];
    }
}

// Base64编码和解码
- (NSString *)codeStringWithOriginalString:(NSString *)originalString
{
    return [[[[[originalString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"=" withString:@""] stringByReplacingOccurrencesOfString:@"+" withString:@"-"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
}

// 处理分享结果
- (void)handleShareResult:(SSDKResponseState)state platformType:(SSDKPlatformType)platformType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (state == SSDKResponseStateFail || state == SSDKResponseStateSuccess) {
            self.shareParams = nil;
            self.cid = nil;
            if (platformType == SSDKPlatformTypeSinaWeibo || platformType == SSDKPlatformTypeUnknown) {
                NSString *result = nil;
                switch (state) {
                    case SSDKResponseStateSuccess: {
                        result = @"成功";
                        break;
                    }
                    case SSDKResponseStateFail: {
                        result = @"失败";
                        break;
                    }
                    default: {
                        break;
                    }
                }
                NSString *platform = platformType == SSDKPlatformTypeSinaWeibo ? @"分享到新浪微博" : platformType == SSDKPlatformTypeUnknown ? @"加入推荐列表" : nil;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@%@", platform, result] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
            }
        }
    });
}

// 为Facebook和新浪微博中添加URL参数
- (void)addUrlStringToText
{
    NSString *newTextString = [self.shareParams[@"title"] stringByAppendingFormat:@" %@ %@", ((NSURL *)self.shareParams[@"url"]).absoluteString, self.shareParams[@"text"]];
    self.shareParams[@"text"] = newTextString.length > 130 ? [newTextString substringToIndex:130] : newTextString;
}

// 设置分享平台的配置信息
- (void)setupInitValue
{
    [ShareSDK registerApp:@"163cf66f80340" activePlatforms:@[@(SSDKPlatformTypeWechat), @(SSDKPlatformTypeSinaWeibo), @(SSDKPlatformTypeQQ)] onImport:^(SSDKPlatformType platformType) {
        switch (platformType) {
            case SSDKPlatformTypeWechat:
                [ShareSDKConnector connectWeChat:[WXApi class] delegate:self];
                break;
            case SSDKPlatformTypeQQ:
                [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                break;
            case SSDKPlatformTypeSinaWeibo:
                [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                break;
            default:
                break;
        }
    } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
        NSDictionary *dic = [self fetchApplicationKeyDictionary];
        switch (platformType) {
            case SSDKPlatformTypeWechat:
                //微信配置
                [appInfo SSDKSetupWeChatByAppId:dic[@"wx"][@"appKey"] appSecret:dic[@"wx"][@"appSecret"]];
                break;
            case SSDKPlatformTypeSinaWeibo:
                //微博配置
                [appInfo SSDKSetupSinaWeiboByAppKey:dic[@"wb"][@"appKey"] appSecret:dic[@"wb"][@"appSecret"] redirectUri:dic[@"wb"][@"redirectUri"] authType:SSDKAuthTypeBoth];
                break;
            case SSDKPlatformTypeQQ:
                //QQ配置
                [appInfo SSDKSetupQQByAppId:dic[@"qq"][@"appKey"] appKey:dic[@"qq"][@"appSecret"] authType:SSDKAuthTypeBoth];
                break;
            default:
                break;
        }
    }];
}

// 获取第三方平台key
- (NSDictionary *)fetchApplicationKeyDictionary
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WinSocialShareConfig" ofType:@"plist"];
    NSDictionary *fileDic = [NSDictionary dictionaryWithContentsOfFile:filePath][@"Application"];
    return fileDic;
}

// 创建分享页面(view)
- (void)setupSharePageViewWithShareParams:(NSMutableDictionary *)shareParams cid:(NSString *)cid
{
    self.shareParams = shareParams;
    self.cid = cid;
    CGRect screenRect = [UIScreen mainScreen].bounds;
    // 获取最上层的View
    UIView *topView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    // 创建遮盖View
    UIControl *coverView = [[UIControl alloc] initWithFrame:screenRect];
    coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    [topView addSubview:coverView];
    [coverView addTarget:self action:@selector(cancleShareView) forControlEvents:UIControlEventTouchUpInside];
    _coverView = coverView;
    // 创建share按钮区域的View
    UIView *shareView = [[UIView alloc] init];
    shareView.backgroundColor = [UIColor whiteColor];
    [coverView addSubview:shareView];
    _shareView = shareView;
    // 创建第三方应用icon
    [self setupOAuthorizeApplicationIconInView:shareView withConfig:[self fetchInstalledSocialPlatformConfig]];
    // 动画显示shareView
    [self showShareViewWithAnimation];
}

// 动画显示shareView
- (void)showShareViewWithAnimation
{
    [UIView animateWithDuration:animation animations:^{
        _shareView.frame = self.showFrame;
        [self.coverView layoutIfNeeded];
    }];
}

// 动画隐藏shareView
- (void)hideShareViewWithAnimation
{
    [UIView animateWithDuration:animation animations:^{
        _shareView.frame = self.hideFrame;
        [self.coverView layoutIfNeeded];
    }];
}

// 创建第三方应用icon按钮
- (void)setupOAuthorizeApplicationIconInView:(UIView *)shareView withConfig:(NSDictionary *)configDic
{
    CGFloat iconButtonW = 60;
    NSInteger maxCols = 3;
    CGFloat outsideMargin = 20;
    CGFloat betweenMargin = ([UIScreen mainScreen].bounds.size.width - maxCols * iconButtonW - outsideMargin * 2) / (maxCols - 1);
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat viewHeight = outsideMargin * 2 + ((configDic.count - 1) / maxCols + 1) * (iconButtonW + 20);
    _showFrame = CGRectMake(0, size.height - viewHeight, size.width, viewHeight);
    _hideFrame = CGRectMake(0, size.height, _showFrame.size.width, _showFrame.size.height);
    self.shareView.frame = _hideFrame;
    
    NSArray *keysArray = [configDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        if (obj1.integerValue > obj2.integerValue) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    // 管理人员新增1个按钮
    for (NSInteger i = 0; i < keysArray.count; i++) {
        NSString *key = keysArray[i];
        NSDictionary *dic = configDic[key];
        NSString *iconStr = dic[@"imgName"];
        UIImage *iconImg = [UIImage imageNamed:iconStr];
        // 图标
        UIButton *iconButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        iconButton.frame = CGRectMake(outsideMargin + (i % maxCols) * (betweenMargin + iconButtonW), outsideMargin + (i / maxCols) * (outsideMargin + iconButtonW + 10), iconButtonW, iconButtonW);
        [iconButton setBackgroundImage:iconImg forState:UIControlStateNormal];
        iconButton.tag = ((NSString *)dic[@"sequence"]).integerValue;
        [shareView addSubview:iconButton];
        [iconButton addTarget:self action:@selector(touchPlatformShareButton:) forControlEvents:UIControlEventTouchUpInside];
        // 文字
        CGFloat textH = 15;
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(iconButton.frame.origin.x - 5, iconButton.frame.origin.y + iconButton.frame.size.height, iconButtonW + 10, textH)];
        text.text = dic[@"language"][@"chinese"];
        text.textAlignment = NSTextAlignmentCenter;
        text.font = [UIFont systemFontOfSize:11];
        text.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [shareView addSubview:text];
    }
}

// 取消按钮点击事件
- (void)cancleShareView
{
    [self hideShareViewWithAnimation];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animation * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.coverView removeFromSuperview];
        self.coverView = nil;
        self.shareView = nil;
    });
}

// 获得需要显示的分享平台
- (NSDictionary *)fetchInstalledSocialPlatformConfig
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WinSocialShareConfig" ofType:@"plist"];
    NSDictionary *fileDic = [NSDictionary dictionaryWithContentsOfFile:filePath][@"UI"];
    NSMutableDictionary *configDic = [NSMutableDictionary dictionary];
    if ([WXApi isWXAppInstalled]) {
        [self addConfigDicWithFileDic:fileDic configDic:&configDic key:@"wechat"];
        [self addConfigDicWithFileDic:fileDic configDic:&configDic key:@"wechattimeline"];
        [self addConfigDicWithFileDic:fileDic configDic:&configDic key:@"wechatfav"];
    }
    if ([WeiboSDK isWeiboAppInstalled]) {
        [self addConfigDicWithFileDic:fileDic configDic:&configDic key:@"wb"];
    }
    if ([QQApiInterface isQQInstalled]) {
        [self addConfigDicWithFileDic:fileDic configDic:&configDic key:@"qq"];
        [self addConfigDicWithFileDic:fileDic configDic:&configDic key:@"zone"];
    }
    // 管理人员按钮
    if (![self.shareParams[@"title"] isEqualToString:@"精选美食"]) {
        [self addConfigDicWithFileDic:fileDic configDic:&configDic key:@"recommend"];
    }
    return configDic;
}

// 判断是否新增需要显示的分享平台
- (void)addConfigDicWithFileDic:(NSDictionary *)fileDic configDic:(NSMutableDictionary **)configDic key:(NSString *)key
{
    NSDictionary *dic = fileDic[key];
    NSString *sequenceKey = dic[@"sequence"];
    if (sequenceKey.integerValue != 0) {
        (*configDic)[sequenceKey] = fileDic[key];
    }
}

// 判断系统是否安装有app
- (BOOL)isInstalledWithPlatformUrlString:(NSString *)urlString
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", urlString]]];
}

// 实例化类
+ (void)initializeClass
{
    if (_shareInstance == nil) {
        _shareInstance = [[self alloc] init];
    }
}

// 重写父类方法
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [super allocWithZone:nil];
        [_shareInstance setupInitValue];
    });
    return _shareInstance;
}

@end
