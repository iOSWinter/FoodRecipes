//
//  MobMenuCollectionCell.m
//  FoodRecipes
//
//  Created by WinterChen on 16/8/16.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "MobMenuCollectionCell.h"

@interface MobMenuCollectionCell ()
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *title;

@end

@implementation MobMenuCollectionCell

+ (instancetype)mobMenuCollectionCell
{
    return [[NSBundle mainBundle] loadNibNamed:@"MobMenuCollectionCell" owner:nil options:nil].lastObject;
}

- (void)setupData:(NSDictionary *)dict
{
    self.img.layer.cornerRadius = 30;
    self.img.layer.masksToBounds = YES;
    self.img.image = [UIImage imageNamed:dict.allKeys.firstObject];
    self.title.text = dict.allValues.firstObject;
}

@end
