//
//  WinSocialShareTool.h
//  ShareDemo
//
//  Created by WinterChen on 16/7/6.
//  Copyright © 2016年 win. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/SSDKUser.h>
#import "WinSSDKUser.h"

@interface WinSocialShareTool : NSObject

/** 调用登录模块 */
+ (void)win_loginWithPlatformType:(WinLoginPlatformType)platformType resultBlock:(void(^)(WinSSDKUser *user))resultBlock;

/**
 *  调用分享模块
 *
 *  @param title                    分享的标题
 *  @param images                   分享的图片数组
 *  @param content                  分享主要内容
 *  @param urlString                分享的url
 *  @param recommendCid             需要加入推荐列表的id
 */
+ (void)win_shareTitle:(NSString *)title images:(NSArray *)images content:(NSString *)content urlString:(NSString *)urlString recommendCid:(NSString *)recommendCid;

@end
