//
//  LeftViewController.h
//  FoodRecipes
//
//  Created by WinterChen on 16/8/29.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define leftViewWidth Width * 0.75

@protocol LeftViewControllerDelegate <NSObject>

@optional
- (void)leftViewHidden:(NSInteger)index;

@end

@interface LeftViewController : UIViewController

@property (nonatomic, weak) id<LeftViewControllerDelegate> delegate;

- (void)updateCachesSize;
@end
