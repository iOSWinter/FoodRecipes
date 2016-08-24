//
//  MobFoodMethodCell.m
//  FoodRecipes
//
//  Created by WinterChen on 16/8/15.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "MobFoodMethodCell.h"
#import "UIImageView+WebCache.h"

@interface MobFoodMethodCell ()

@property (weak, nonatomic) IBOutlet UILabel *step;
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *methodHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeightConstraints;

@end


@implementation MobFoodMethodCell

+ (instancetype)mobFoodMethodCell
{
    return [[NSBundle mainBundle] loadNibNamed:@"MobFoodMethodCell" owner:nil options:nil].lastObject;
}

- (void)setupData:(MobFoodClassItemMethodModel *)model
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.step.text = model.step;
    CGFloat methodHeight = [model.step boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 27, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.height;
    self.methodHeightConstraints.constant = methodHeight + 5;
    if (model.img) {
        self.imgHeightConstraints.constant = ([UIScreen mainScreen].bounds.size.width - 60) * 311 / 414.0;
        [self.img sd_setImageWithURL:[NSURL URLWithString:model.img]];
    } else {
        self.imgHeightConstraints.constant = 0;
    }
}

@end
