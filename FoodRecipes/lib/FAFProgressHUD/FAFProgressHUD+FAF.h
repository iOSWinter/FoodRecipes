//
//  MBProgressHUD+FAF.h
//  FAFFramework
//
//  Created by iecd on 15/12/17.
//  Copyright © 2015年 SnowWolfSoftware. All rights reserved.
//

#import "FAFProgressHUD.h"

@interface FAFProgressHUD (FAF)

/**
 *  自定义的原始方法，所有参数都自己传
 *
 *  @param text  展示的文本，可空
 *  @param icon  展示的图片，可空，默认为转圈
 *  @param view  显示到哪个view，可空，默认展示在window上
 *  @param color 展示的背景颜色，可空，默认为半透明的黑色
 */
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view color:(UIColor *)color;
#pragma mark - 成功的展示
/**
 *  展示成功的圈圈
 *
 *  @param success 成后的提示文本
 */
+ (void)showSuccess:(NSString *)success;

/**
 *  展示成功的提示到某个view
 *
 *  @param success 成功的提示文本
 *  @param view    需要展示在这个view中
 */
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

/**
 *  展示成功提示，自定义图片和背景颜色
 *
 *  @param success 提示文本
 *  @param icon    自定义图片名字
 *  @param color   自定义背景颜色
 */
+ (void)showSuccess:(NSString *)success icon:(NSString *)icon color:(UIColor *)color;

#pragma mark - 失败的展示
/**
 *  提示失败的圈圈
 *
 *  @param error 提示文本
 */
+ (void)showError:(NSString *)error;

/**
 *  提示失败到某个view
 *
 *  @param error 失败文本
 *  @param view  提示在哪个view里
 */
+ (void)showError:(NSString *)error toView:(UIView *)view;
/**
 *  提示错误信息，自定义颜色和图片
 *
 *  @param error 错误信息文本
 *  @param icon  自定义图片名
 *  @param color 自定义颜色
 */
+ (void)showError:(NSString *)error icon:(NSString *)icon color:(UIColor *)color;

#pragma mark - 展示消息
/**
 *  展示消息
 *
 *  @param message 消息文本
 *
 *  @return 返回展示的圈圈，用来自定义关闭的时间
 */
+ (FAFProgressHUD *)showMessage:(NSString *)message;
/**
 *  展示消息到哪个view
 *
 *  @param message 消息文本
 *  @param view    展示到哪个view
 *
 *  @return 返回展示的圈圈，用来自定义关闭的时间
 */
+ (FAFProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;
/**
 *  展示消息，自定义背景颜色
 *
 *  @param message 消息文本
 *  @param color   自定义的背景颜色
 *
 *  @return 返回展示的圈圈，用来自定义关闭的时间
 */
+ (FAFProgressHUD *)showMessage:(NSString *)message color:(UIColor *)color;
/**
 *  展示消息到view，自定义背景颜色
 *
 *  @param message 消息文本
 *  @param view    展示到哪个view
 *  @param color   自定义背景颜色
 *
 *  @return 返回展示的圈圈，用来自定义关闭的时间
 */
+ (FAFProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view color:(UIColor *)color;

#pragma mark - 关闭转圈
+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;

@end
