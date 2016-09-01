//
//  MobFoodListCell.m
//  Recorder
//
//  Created by WinterChen on 16/8/14.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "MobFoodListCell.h"
#import "UIImageView+WebCache.h"
#import "MobCarefulSelectionModel.h"

@interface MobFoodListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgWidthConstraints;

@end

@implementation MobFoodListCell

+ (instancetype)mobFoodListCell
{
    return [[NSBundle mainBundle] loadNibNamed:@"MobFoodListCell" owner:nil options:nil].lastObject;
}

- (void)setupData:(MobFoodClassItemModel *)model
{
    if ([model isKindOfClass:[MobFoodClassItemModel class]]) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        if (model.thumbnail) {
            [self.img sd_setImageWithURL:[NSURL URLWithString:model.thumbnail]];
            self.imgWidthConstraints.constant = 104;
        } else {
            self.imgWidthConstraints.constant = 0;
        }
        self.title.text = model.name;
        NSString *recipes = [[model.recipe.ingredients substringWithRange:NSMakeRange(1, model.recipe.ingredients.length - 2)] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        self.desc.text = recipes ?: @"详见制作步骤";
        CGFloat descHeight = [self.desc.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 15 - 104 - 5 - 5, 80) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.height;
        self.descHeightConstraints.constant = descHeight <= 57 ? descHeight : 57;
    } else {
        MobCarefulSelectionModel *model1 = (MobCarefulSelectionModel *)model;
        NSString *imgUrl = [model1.thumbnails componentsSeparatedByString:@"$"].lastObject;
        if ([imgUrl containsString:@"jpg"]) {
            [self.img sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
            self.imgWidthConstraints.constant = 104;
        } else {
            self.imgWidthConstraints.constant = 0;
        }
        self.title.text = model1.title;
        self.desc.text = [model1.pubTime componentsSeparatedByString:@" "].lastObject;
    }
}

@end
