//
//  PushNotificationMannager.h
//  lcAhwTest
//
//  Created by licheng on 15/5/26.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "KUtils.h"
#import "SettingManager.h"
#import "HomeTabBarController.h"


// 设备令牌（消息推送）
#define DeviceTokenKey  @"DeviceToken"


@interface PushNotificationMannager : NSObject

// 单例模式实例化对象
+ (PushNotificationMannager *)sharedInstance;

// 注册远程消息，包含短消息、声音和应用程序图标
- (void)registerForRemoteNotification;

// 保存设备令牌
- (void)saveDeviceToken:(NSData *)deviceToken;

// 获取设备令牌字符串
- (NSString *)getDeviceTokenStr;

//// 应用程序关闭状态 接收到远程消息，从推送窗口启动程序
//- (void)applicationStartFromRemoteNotification:(NSDictionary *)launchOptions;

// 应用程序运行状态（包括在前台运行和在后台运行） 处理接收到的远程消息
- (void)handleRemoteNotification:(NSDictionary *)userInfo;

// 获取应用程序“系统设置－>允许通知"是否开启
- (BOOL)getSysSettingNotificationIsOpened;

@end
