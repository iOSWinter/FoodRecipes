//
//  MobFoodClassModel.h
//  Recorder
//
//  Created by WinterChen on 16/8/14.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobFoodClassItemMethodModel : NSObject

@property (nonatomic, strong) NSString *img;
@property (nonatomic, strong) NSString *step;

@end

@interface MobFoodClassItemRecipeModel : NSObject

@property (nonatomic, strong) NSString *img;
@property (nonatomic, strong) NSString *ingredients;
@property (nonatomic, strong) NSArray<MobFoodClassItemMethodModel *> *method;
@property (nonatomic, strong) NSString *sumary;
@property (nonatomic, strong) NSString *title;

@end

@interface MobFoodClassItemModel : NSObject

@property (nonatomic, strong) NSArray *ctgIds;
@property (nonatomic, strong) NSString *ctgTitles;
@property (nonatomic, strong) NSString *menuId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) MobFoodClassItemRecipeModel *recipe;
@property (nonatomic, strong) NSString *thumbnail;


@end

@interface MobFoodClassModel : NSObject

@property (nonatomic, strong) NSString *curPage;
@property (nonatomic, strong) NSArray<MobFoodClassItemModel *> *list;
@property (nonatomic, strong) NSString *total;

@end
