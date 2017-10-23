//
//  LoginData.h
//  lcAhwTest
//
//  Created by licheng on 15/4/20.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "BaseData.h"

#define VERIFICATIONCODE_KEY    @"VerificationCode"

// 用户登录请求数据
@interface LoginData : BaseData

@property (nonatomic, strong) NSString *userName;       //用户名
@property (nonatomic, strong) NSString *userPwd;        //密码
@property (nonatomic, strong) NSString *validateCode;   //验证码
@property (nonatomic, strong) NSString *identify;

@end
