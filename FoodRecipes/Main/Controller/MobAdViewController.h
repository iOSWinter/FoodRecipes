//
//  MobAdViewController.h
//  FoodRecipes
//
//  Created by WinterChen on 16/8/17.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobCarefulSelectionModel.h"

@interface MobAdViewController : UIViewController

@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) MobCarefulSelectionModel *model;

@end