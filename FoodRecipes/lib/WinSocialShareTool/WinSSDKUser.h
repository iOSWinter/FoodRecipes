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


@interface QQUser : NSObject

/** province，省份 */
@property(nonatomic, copy) NSString* province;
/** city，城市 */
@property(nonatomic, copy) NSString* city;
/** gender，性别 */
@property(nonatomic, copy) NSString* gender;

@end

@interface SinaUser : NSObject

/** location，省份城市 */
@property(nonatomic, copy) NSString* location;
/** gender，性别 */
@property(nonatomic, copy) NSString* gender;
/** description，简介 */
@property(nonatomic, copy) NSString* description1;
/** followers_count，粉丝数 */
@property(nonatomic, assign) NSInteger followers_count;
/** friends_count，关注数 */
@property(nonatomic, assign) NSInteger friends_count;
/** statuses_count，微博数 */
@property(nonatomic, assign) NSInteger statuses_count;
/** favourites_count，收藏数 */
@property(nonatomic, assign) NSInteger favourites_count;
/** bi_followers_count，互粉数 */
@property(nonatomic, assign) NSInteger bi_followers_count;
/** created_at，创建日期 */
@property(nonatomic, copy) NSString* created_at;
/** allow_all_act_msg，允许私信 */
@property(nonatomic, assign) BOOL allow_all_act_msg;

@end
