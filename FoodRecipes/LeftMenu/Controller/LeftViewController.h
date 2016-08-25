//
//  LeftViewController.h
//  SideViewController
//
//  Created by YouXianMing on 16/6/6.
//  Copyright © 2016年 YouXianMing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeftViewControllerDelegate <NSObject>

@optional
- (void)leftViewHidden:(NSInteger)index;

@end

@interface LeftViewController : UIViewController

@property (nonatomic, weak) id<LeftViewControllerDelegate> delegate;

- (void)updateCachesSize;

@end
