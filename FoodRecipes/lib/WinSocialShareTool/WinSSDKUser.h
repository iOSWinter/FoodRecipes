//
//  WinSSDKUser.h
//  ShareDemo
//
//  Created by WinterChen on 16/7/10.
//  Copyright © 2016年 win. All rights reserved.
//

#import <ShareSDK/ShareSDK.h>

typedef NS_ENUM(NSUInteger, WinLoginPlatformType)
{
    WinLoginPlatformTypeSinaWeibo = 1,
    WinLoginPlatformTypeQQ = 998,
};

@interface WinSSDKUser : SSDKUser

/**
 *  授权登录平台类型
 */
@property (nonatomic, assign) WinLoginPlatformType loginPlatformType;

@end
