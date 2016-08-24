//
//  MobViewCell.h
//  Recorder
//
//  Created by WinterChen on 16/8/14.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobFoodCategoryModel.h"

@interface MobViewCell : UITableViewCell

+ (instancetype)mobViewCell;

- (void)setupDataWithModel:(MobFoodChildsModel *)model;

@end
