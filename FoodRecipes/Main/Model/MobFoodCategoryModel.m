//
//  MobFoodCategoryModel.m
//  Recorder
//
//  Created by WinterChen on 16/8/14.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "MobFoodCategoryModel.h"

@implementation MobFoodCategoryInfoModel

@end

@implementation MobFoodChildsModel

@end

@implementation MobFoodCategoryChildsModel

@end

@implementation MobFoodCategoryModel

- (void)print
{
    NSLog(@"\n%@", self.categoryInfo.name);
    for (MobFoodCategoryChildsModel *model in self.childs) {
        NSLog(@"\n%@", model.categoryInfo.name);
        for (MobFoodChildsModel *child in model.childs) {
            NSLog(@"\n%@", child.categoryInfo.name);
        }
    }
}

@end
