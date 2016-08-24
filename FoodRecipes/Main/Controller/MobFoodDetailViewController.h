//
//  MobFoodDetailViewController.h
//  Recorder
//
//  Created by WinterChen on 16/8/14.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobFoodClassModel.h"

@interface MobFoodDetailViewController : UIViewController

@property (nonatomic, strong) MobFoodClassItemModel *model;
@property (nonatomic, strong) NSString *cid;

@end
