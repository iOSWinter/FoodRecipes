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

- (void)setupDataWithModel:(MobAdvertiseModel *)model
{
    [self.img sd_setImageWithURL:[NSURL URLWithString:model.imgUrl]];
    
    NSString *valid = model.valid ? @"推荐中" : model.valided ? @"推荐过" : @"从未推荐";
    NSString *textString = [model.title stringByAppendingFormat:@" %@ %@", valid, model.link];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:textString attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]}];
    [attrString setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} range:[textString rangeOfString:model.title]];
    [attrString setAttributes:@{NSForegroundColorAttributeName : model.valid ? [UIColor magentaColor] : model.valided ? [UIColor grayColor] : [UIColor brownColor]} range:[textString rangeOfString:valid]];
    [attrString setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} range:[textString rangeOfString:model.link]];
    self.url.attributedText = attrString;
}

@end
