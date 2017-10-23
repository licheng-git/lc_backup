//
//  AppDelegate.m
//  lcAhwTest
//
//  Created by licheng on 15/4/8.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeTabBarController.h"
#import "PushNotificationMannager.h"
#import "MainPageController.h"

#import "SettingViewController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    // 单独的页面测试用
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
//    UIViewController *vc = [[SettingViewController alloc] init];
//    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:vc];
//    self.window.rootViewController = navC;
//    [KUtils monitor];
//    [KUtils uncaughtExceptionLog];
//    return YES;
    
    
    // 友盟统计
    
    // 创建window和homeVC
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.homeVC = [HomeTabBarController getInstance];
    self.homeNav = [[UINavigationController alloc] initWithRootViewController:self.homeVC];
    self.homeNav.navigationBar.hidden = YES;
    self.window.rootViewController = self.homeNav;
    
    // 设置导航栏
    [UINavigationBar appearance].barTintColor = kNAV_BG_COLOR;
    [UINavigationBar appearance].titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    
    // 注册 消息推送
    [[PushNotificationMannager sharedInstance] registerForRemoteNotification];
    
//    // 应用程序关闭状态接收到推送消息，从推送窗口启动程序
//    [[PushNotificationMannager sharedInstance] applicationStartFromRemoteNotification:launchOptions];
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo != nil)  // 应用程序从推送栏启动（若从icon启动则userIno为nil）
    {
        // 处理接收到的推送消息
        [[PushNotificationMannager sharedInstance] handleRemoteNotification:userInfo];
    }
    
    
    return YES;
}

// 应用程序注册消息推送成功，取得设备令牌
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"应用程序注册消息推送成功 deviceToken *_*%@", deviceToken);
    // 保存设备令牌（————然后在网络请求时放到http请求头中发送到WebApi服务器）
    [[PushNotificationMannager sharedInstance] saveDeviceToken:deviceToken];
}

// 应用程序注册消息推送失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"应用程序注册消息推送失败 *_*%@", error);
}

// 应用程序处理接收到的推送消息 （前台接收时没有“叮咚”，直接执行代码；后台接收时有“叮咚”，点击推送栏才执行代码）
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"处理接收到的推送消息 *_*%@", userInfo);
    // 处理接收到的推送消息，包括前台和后台
    [[PushNotificationMannager sharedInstance] handleRemoteNotification:userInfo];
}

// 应用程序处理接受到的本地消息
- (void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification
{
    NSLog(@"本地推送 *_* %@", [notification.userInfo objectForKey:@"name"]);
}

// 应用程序从后台进入前台 （启动时也会调用，包括直接启动和推送栏启动）
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    [application cancelAllLocalNotifications];
}

// 应用程序从前台进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground %ld", application.applicationState);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"applicationWillResignActive %ld", application.applicationState);
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground %ld", application.applicationState);
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"applicationWillTerminate %ld", application.applicationState);
}
- (void)applicationSignificantTimeChange:(UIApplication *)application
{
    NSLog(@"applicationSignificantTimeChange %ld", application.applicationState);
}
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSLog(@"applicationDidFinishLaunching %ld", application.applicationState);
}


// 从网页打开或其他app打开，获取参数
- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation
{
    NSLog(@"sourceApplication *_* %@", sourceApplication);  // com.zac.lcHybridTest
    NSLog(@"openURL *_* %@", url);  // lc://ahw.test.app | lc://ahw.test.app/xxVC?param=detailID&custId=123
    NSLog(@"URL.absoluteString *_* %@", url.absoluteString);  // lc://ahw.test.app | lc://ahw.test.app/xxVC?param=detailID&custId=123
    NSLog(@"URL.scheme *_* %@", url.scheme);  // lc
    NSLog(@"URL.relativePath *_* %@", url.relativePath);  //  | /xxVC
    NSLog(@"URL.query *_* %@", url.query);  // null | param=detailID&custId=123
    NSLog(@"URL.parameterString *_* %@", url.parameterString);  // null
    
    if ([url.relativePath isEqualToString:@"/xxVC"])
    {
        [[HomeTabBarController getInstance] performSelector:@selector(handlePushOfNewBid:) withObject:@"0f937e21-8b28-4afd-9a16-b748514d6589" afterDelay:1.0];
    }
    
    return YES;
}




@end
