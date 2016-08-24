//
//  MobFoodMethodCell.h
//  FoodRecipes
//
//  Created by WinterChen on 16/8/15.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobFoodClassModel.h"

@interface MobFoodMethodCell : UITableViewCell

+ (instancetype)mobFoodMethodCell;

- (void)setupData:(MobFoodClassItemMethodModel *)model;

@end
