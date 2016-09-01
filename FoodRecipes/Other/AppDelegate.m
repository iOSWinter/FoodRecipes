//
//  AppDelegate.m
//  Recorder
//
//  Created by WinterChen on 16/8/14.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "AppDelegate.h"
#import "CangShuBundleAd.h"

#define PublisherId @"825254494-CE1CD3-72C8-099A-98400A5FE"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [MobAPI registerApp:APPKey];
    [CangShuBundleAd setPublisherID:PublisherId];
    UINavigationBar *navBar = [UINavigationBar appearance];
    [navBar setBackgroundImage:[UIImage imageNamed:@"nav"] forBarMetrics:UIBarMetricsDefault];
    [navBar setTintColor:[UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1]}];
    [navBar setTranslucent:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
            [application registerUserNotificationSettings:settings];
        }
    });
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
//     UIBackgroundTaskIdentifier taskID = [application beginBackgroundTaskWithExpirationHandler:^{
//        if (taskID != UIBackgroundTaskInvalid)
//        {
            [application cancelAllLocalNotifications];
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *today = [dateFormatter stringFromDate:[NSDate date]];
            [dateFormatter setDateFormat:@"HHmmss"];
            NSString *nowString = [dateFormatter stringFromDate:[NSDate date]];
            if (nowString.integerValue - 90000 > 0) {
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                today = [dateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:3600 * 24]];
            }
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            notification.fireDate = [dateFormatter dateFromString:[today stringByAppendingString:@" 09:00:00"]];
            notification.repeatInterval = kCFCalendarUnitDay;
            notification.soundName = UILocalNotificationDefaultSoundName;
            NSArray *preArray = @[@"忙碌的一天又开始了吧?", @"曾经让你流口水的那道美食你还记得吗?", @"这里有你熟悉的美食味道...", @"你属于需要特殊照顾的人群吗?我们也同样为你甄选美食..."];
            NSArray *subArray = @[@"我们为您准备了丰盛的美食,赶快戳进去查看吧!", @"只有身体是自己的,一定要好好犒劳自己!马上行动...", @"美食查收不用谢!"];
            NSInteger preI = arc4random() % preArray.count;
            NSInteger subI = arc4random() % subArray.count;
            notification.alertBody = [preArray[preI] stringByAppendingString:subArray[subI]];
            [application scheduleLocalNotification:notification];
//            [application endBackgroundTask:taskID];
//        }
//    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
