//
//  MobAdvertiseModel.h
//  FoodRecipes
//
//  Created by WinterChen on 16/11/8.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    AdvertisementType_MMJPG = 1,
    AdvertisementType_OtherWeb,
} AdvertisementType;

@interface MobAdvertiseModel : NSObject

/** 唯一标示，也可以表示添加时间字符串 */
@property (nonatomic, strong) NSString *key;
/** 缩略图urlString */
@property (nonatomic, strong) NSString *imgUrl;
/** 标题 */
@property (nonatomic, strong) NSString *title;
/** 网站link */
@property (nonatomic, strong) NSString *link;
/** 当前时间是否上线 */
@property (nonatomic, assign) BOOL valid;
/** 曾经是否上线过 */
@property (nonatomic, assign) BOOL valided;
/** 标示不同网站类型 */
@property (nonatomic, assign) AdvertisementType type;

@end
