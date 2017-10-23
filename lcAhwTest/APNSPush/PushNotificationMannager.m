//
//  PushNotificationMannager.m
//  lcAhwTest
//
//  Created by licheng on 15/5/26.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "PushNotificationMannager.h"

#define BidIDKey  @"LoanApplyID"  // 推送过来的新标Id

@interface PushNotificationMannager()
@property (nonatomic, strong) NSString *bidID;
@end

@implementation PushNotificationMannager

// 单例模式实例化对象
static PushNotificationMannager *sharedInstance = nil;
+ (PushNotificationMannager *)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

// 注册远程消息，包含短消息、声音和应用程序图标
- (void)registerForRemoteNotification
{
    // 适配ios8系统，推送接口变更
    if ([KUtils isIOS8])
    {
        UIUserNotificationType types = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        UIRemoteNotificationType types = (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
}

// 保存设备令牌
- (void)saveDeviceToken:(NSData *)deviceToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:deviceToken forKey:DeviceTokenKey];
    [userDefaults synchronize];
}

// 获取设备令牌字符串
- (NSString *)getDeviceTokenStr
{
    NSString *deviceTokenStr = @"";
    NSData *deviceTokenData = [[NSUserDefaults standardUserDefaults] objectForKey:DeviceTokenKey];
    if (deviceTokenData && deviceTokenData.length > 0)
    {
        deviceTokenStr = [[[[deviceTokenData description]
                            stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                            stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return deviceTokenStr;
}

//// 应用程序关闭状态 接收到远程消息，从推送窗口启动程序
//- (void)applicationStartFromRemoteNotification:(NSDictionary *)launchOptions
//{
//    if (launchOptions != nil)
//    {
//        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//        if (userInfo != nil)
//        {
//            // 通过推送窗口启动的程序
//            NSDictionary *payloadDic = [userInfo objectForKey:@"aps"];
//            NSLog(@"负载字符串 *_*%@", payloadDic);
//            
//            self.bidID = [userInfo objectForKey:BidIDKey];
//            NSLog(@"标的ID *_*%@", self.bidID);
//            
//            // 打开标的详情
//            [self showInvestDetailVC];
//        }
//    }
//}

// 应用程序运行状态（包括在前台运行和在后台运行） 处理接收到的推送消息
- (void)handleRemoteNotification:(NSDictionary *)userInfo
{
    NSDictionary *payloadDic = [userInfo objectForKey:@"aps"];
    NSString *msg = [payloadDic objectForKey:@"alert"];
    NSLog(@"负载字符串 *_*%@", payloadDic);
    NSLog(@"消息内容 *_*%@", msg);
    
    self.bidID = [userInfo objectForKey:BidIDKey];
    NSLog(@"标的ID *_*%@", self.bidID);
    
    // 程序在前台，需要推送提示音、弹框；在后台时，系统默认。 （前台接收时没有“叮咚”，直接执行代码；后台接收时有“叮咚”，点击推送栏才执行代码）
    NSLog(@"*_* applicationState=%li", [UIApplication sharedApplication].applicationState);  // 0前台，1后台，（2未启动，？，推送程序中访问不到）
    UIApplicationState appState = [UIApplication sharedApplication].applicationState;
    if (appState == UIApplicationStateActive)
    {
        NSLog(@"----程序在前台----");
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);  //震动
        AudioServicesPlaySystemSound(1007);  // 系统默认声音
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"查看", nil];
        [alertView show];
    }
    else
    {
        NSLog(@"----程序在后台----");
        [self showInvestDetailVC];
    }
}

// UIAlertView 点击按钮
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // 取消
    }
    else if (buttonIndex == 1)
    {
        // 查看
        [self showInvestDetailVC];
    }
}

// 打开标的详情页面
- (void)showInvestDetailVC
{
//    HomeTabBarController *homeVC = [HomeTabBarController getInstance];
//    [SettingManager shareInstance].bidID = self.bidID;
//    InvestDetailViewController *investDetailVC = [[InvestDetailViewController alloc] init];
//    [homeVC.navigationController pushViewController:investDetailVC animated:YES];
    
    // 延迟1秒执行，否则会出现没有导航条的问题
    //[[HomeTabBarController getInstance] handlePushOfNewBid:self.bidID];
    [[HomeTabBarController getInstance] performSelector:@selector(handlePushOfNewBid:)
                                             withObject:self.bidID
                                             afterDelay:1.0];
    
}

// 获取应用程序“系统设置－>允许通知"是否开启
- (BOOL)getSysSettingNotificationIsOpened
{
    BOOL isSysOpened = YES;  // 默认返回开启
    if ([KUtils isIOS8])
    {
        isSysOpened = [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
    }
    else
    {
        UIRemoteNotificationType types = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
        if (types == UIRemoteNotificationTypeNone)
        {
            isSysOpened = NO;
        }
    }
    return isSysOpened;
}

@end
