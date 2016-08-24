//
//  MobFoodListCell.h
//  Recorder
//
//  Created by WinterChen on 16/8/14.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobFoodClassModel.h"

@interface MobFoodListCell : UITableViewCell

+ (instancetype)mobFoodListCell;

- (void)setupData:(MobFoodClassItemModel *)model1;

@end
