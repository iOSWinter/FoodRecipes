//
//  MBProgressHUD+FAF.m
//  FAFFramework
//
//  Created by iecd on 15/12/17.
//  Copyright © 2015年 SnowWolfSoftware. All rights reserved.
//

#import "FAFProgressHUD+FAF.h"

@implementation FAFProgressHUD (FAF)
#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view color:(UIColor *)color
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    if (![view isKindOfClass:[UIView class]]) {
        assert("view is Not a UIView class");
    }
    if (![icon isKindOfClass:[NSString class]]) {
        assert("icon is Not a NSString class");
    }
    if (![color isKindOfClass:[UIColor class]]) {
        assert("color is Not a UIColor class");
    }
    // 快速显示一个提示信息
    FAFProgressHUD *hud = [FAFProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    
    // 再设置模式为自定义的
    hud.mode = MBProgressHUDModeCustomView;
    
    //颜色
    hud.color = color;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:1.0];
}

#pragma mark 显示成功信息

+ (void)showSuccess:(NSString *)success icon:(NSString *)icon color:(UIColor *)color
{
    [self show:success icon:icon view:nil color:color];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"FAFProgressHUD.bundle/success"  view:view color:nil];
}

+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil ];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error icon:(NSString *)icon color:(UIColor *)color{
    [self show:error icon:icon view:nil color:color];
}

+ (void)showError:(NSString *)error toView:(UIView *)view
{
    [self show:error icon:@"FAFProgressHUD.bundle/error" view:view color:nil];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

// success.png
#pragma mark 显示一些信息
+ (FAFProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view color:(UIColor *)color{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    if (![message isKindOfClass:[NSString class]]) {
        assert("message is Not a NSString class");
    }
    if (![view isKindOfClass:[UIView class]]) {
        assert("view is Not a UIView class");
    }
    if (![color isKindOfClass:[UIColor class]]) {
        assert("color is Not a UIColor class");
    }
    // 快速显示一个提示信息
    FAFProgressHUD *hud = [FAFProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    hud.color = color;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = YES;
    return hud;
}

+ (FAFProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view
{
    return [self showMessage:message toView:view color:nil];
}

+ (FAFProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:nil];
}

+ (FAFProgressHUD *)showMessage:(NSString *)message color:(UIColor *)color
{
    return [self showMessage:message toView:nil color:color];
}

#pragma mark - 关闭转圈圈
+ (void)hideHUDForView:(UIView *)view
{
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [self hideHUDForView:[[UIApplication sharedApplication].windows lastObject]];
}

@end
