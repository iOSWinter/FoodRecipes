//
//  MobAdEditCell.m
//  FoodRecipes
//
//  Created by WinterChen on 16/8/22.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "MobAdEditCell.h"
#import "UIImageView+WebCache.h"

@interface MobAdEditCell ()
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *url;

@end

@implementation MobAdEditCell

- (void)setupDataWithDict:(NSDictionary *)dict
{
    [self.img sd_setImageWithURL:[NSURL URLWithString:dict[@"k"]]];
    self.url.text = dict[@"v"];
    [self.url setAdjustsFontSizeToFitWidth:YES];
}

@end
