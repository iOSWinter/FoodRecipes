//
//  MainViewController.h
//  SideViewController
//
//  Created by YouXianMing on 16/6/6.
//  Copyright © 2016年 YouXianMing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) UINavigationBar *navBar;
/** 刷新 */
@property (nonatomic, assign) BOOL refresh;

@end
