//
//  KUtils.h
//  lcAhwTest
//
//  Created by licheng on 15/4/9.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Constants.h"

// 检查网络连接
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

// md5
#import <CommonCrypto/CommonDigest.h>
// aes
#import "AESCrypt.h"

// 内存和cpu
#include <mach/mach.h>


@interface KUtils : NSObject

/************************************************************
 ** 创建UIButton
 ** titleColor：标题文本颜色，如果使用默认问题颜色，则传nil
 ** tag：按钮标识，如果不设置，则默认使用
 ************************************************************/
+ (UIButton *)createButtonWithFrame:(CGRect)frame
                              title:(NSString *)title
                         titleColor:(UIColor *)titleColor
                             target:(id)target
                                tag:(NSInteger)tag;

/************************************************************
 ** 创建label
 ** tag 按钮标识，如果不设置，则默认使用kDEFAULT_TAG
 ************************************************************/
+ (UILabel *)createLabelWithFrame:(CGRect)frame
                             text:(NSString *)text
                         fontSize:(CGFloat)fontSize
                    textAlignment:(NSInteger)align
                              tag:(NSInteger)tag;

/************************************************************
 ** 创建textField
 ** tag 按钮标识，如果不设置，则默认使用kDEFAULT_TAG
 ************************************************************/
+ (UITextField *)createTextFieldWithFrame:(CGRect)frame
                                 fontSize:(CGFloat)fontSize
                                   enable:(BOOL)enable
                                 delegate:(id)delegate
                                      tag:(NSInteger)tag;

/************************************************************
 动画 弹出页面
 从上往下：Animationtype:kCATransitionMoveIn andSubtype:kCATransitionFromBottom
 从左往右：Animationtype:kCATransitionMoveIn andSubtype:kCATransitionFromRight
 ************************************************************/
+ (void)showView:(UIView *)view withAnimationType:(NSString *)type andSubtype:(NSString *)subType;


// 判断是否为空字符串
+ (BOOL)isNullOrEmptyStr:(NSString *)str;

// 是否 空字典或空数组
+ (BOOL)isNullOrEmptyArr:(id)arr_or_dic;

// iPhone4/4s
+ (BOOL)isIPhone4;

// iPhone5/5s/5c
+ (BOOL)isIPhone5;

// iPhone6
+ (BOOL)isIPhone6;

// iPhone6+
+ (BOOL)isIPhone6Plus;

// App版本号
+ (NSString *)appVersion;

// ios系统版本号
+ (NSString *)sysVersion;

// 判断是否ios7以上
+ (BOOL)isIOS7;

// 判断是否ios8以上
+ (BOOL)isIOS8;

// 系统语言
+ (NSString *)sysLanguage;

// 检查网络是否可用
+ (BOOL)isConnectionAvailable;

// md5 32位 加密 （小写）
+ (NSString *)md5:(NSString *)str;

// aes加密
+ (NSString *)aes:(NSString *)str;

// 创建UUID
+ (NSString *)createUUID;

// 拨打电话
+ (void)openTelphone:(NSString *)telNum;


// newVersion是否最新版本 （是则需更新）
+ (BOOL)isLatestVersion:(NSString *)newVersion;

// 更新 根据应用AppID打开AppStore
+ (void)openAppDownLoadAddress;

// 强制退出程序 － 动画方式
+ (void)exitApplication;

// 视图生成图片
+ (UIImage *)imageFromView:(UIView *)view;

// 缩放图片
+ (UIImage *)image:(UIImage *)img scaleToSize:(CGSize)size;

// 裁剪图片
+ (UIImage *)image:(UIImage *)img clipToSize:(CGSize)size;


// 监测性能（内存值和cup占用率）
+ (void)monitor;

// 记录崩溃日志
+ (void)uncaughtExceptionLog;

@end
