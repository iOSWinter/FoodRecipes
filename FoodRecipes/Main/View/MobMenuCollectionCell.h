//
//  MobMenuCollectionCell.h
//  FoodRecipes
//
//  Created by WinterChen on 16/8/16.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MobMenuCollectionCell : UICollectionViewCell

+ (instancetype)mobMenuCollectionCell;

- (void)setupData:(NSDictionary *)dict;

@end
