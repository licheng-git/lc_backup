//
//  GesturePasswordController.h
//  GesturePassword
//
//  Created by hb on 14-8-23.
//  Copyright (c) 2014年 黑と白の印记. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "TentacleView.h"
#import "GesturePasswordView.h"

@protocol GesturePasswordVCDelegate <NSObject>

@optional
//- (void)forgetGesturePassword;         // 忘记手势密码
//- (void)otherUserAccountLogin;         // 其他用户登录
- (void)verifyGesturePasswordSuccess;  // 验证手势密码成功
- (void)resetGesturePasswordSuccess;   // 重置手势密码成功

@end

@interface GesturePasswordController : UIViewController <VerificationDelegate,ResetDelegate,GesturePasswordDelegate>

@property (nonatomic, assign) id<GesturePasswordVCDelegate> delegate;
@property (nonatomic, assign) NSInteger errorCount;  // 输入错误次数

+ (GesturePasswordController *)shareInstance;

// 清空手势密码和记录
- (void)clear;

// 清空用户密码和手势密码
- (void)clearUserPwdAndGesturePwd;

- (BOOL)exist;

/**
 *	@brief	显示手势密码视图（重置或验证 手势密码）
 */
- (void)showGetPwdView;

@end


