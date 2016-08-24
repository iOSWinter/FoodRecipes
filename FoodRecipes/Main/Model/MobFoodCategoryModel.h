//
//  MobFoodCategoryModel.h
//  Recorder
//
//  Created by WinterChen on 16/8/14.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobFoodCategoryInfoModel : NSObject

@property (nonatomic, strong) NSString *ctgId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *parentId;

@end

@interface MobFoodChildsModel : NSObject

@property (nonatomic, strong) MobFoodCategoryInfoModel *categoryInfo;

@end

@interface MobFoodCategoryChildsModel : NSObject

@property (nonatomic, strong) MobFoodCategoryInfoModel *categoryInfo;
@property (nonatomic, strong) NSArray<MobFoodChildsModel *> *childs;

@end

@interface MobFoodCategoryModel : NSObject

@property (nonatomic, strong) MobFoodCategoryInfoModel *categoryInfo;
@property (nonatomic, strong) NSArray<MobFoodCategoryChildsModel *> *childs;
- (void)print;
@end
