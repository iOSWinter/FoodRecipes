//
//  MobViewCell.m
//  Recorder
//
//  Created by WinterChen on 16/8/14.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "MobViewCell.h"

@interface MobViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *text;

@end

@implementation MobViewCell

+ (instancetype)mobViewCell
{
    return [[NSBundle mainBundle] loadNibNamed:@"MobViewCell" owner:nil options:nil].firstObject;
}

- (void)setupDataWithModel:(MobFoodChildsModel *)model
{
    self.img.layer.cornerRadius = 20;
    self.img.layer.masksToBounds = YES;
    self.img.image = [UIImage imageNamed:[self fetchIconDataWithModel:model]];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.text.text = model.categoryInfo.name;
}

- (NSString *)fetchIconDataWithModel:(MobFoodChildsModel *)model
{
    NSString *foodMenuFilePath = [[NSBundle mainBundle] pathForResource:@"FoodMenu" ofType:@"plist"];
    NSDictionary *totalDict = [NSDictionary dictionaryWithContentsOfFile:foodMenuFilePath];
    NSDictionary *dict = ((NSArray *)totalDict[model.categoryInfo.parentId]).firstObject;
    return dict[model.categoryInfo.name][@"img"];
}

@end
