//
//  BaseData.h
//  lcAhwTest
//
//  Created by licheng on 15/4/13.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 服务器业务逻辑返回数据 key
#define ResponseStatusKey       @"ResponseStatus"
#define ResponseDataKey         @"ResponseData"
#define MsgKey                  @"Msg"
#define StringDataKey           @"Data"
#define ListDataKey             @"ListData"

// 服务器业务逻辑返回状态码
#define ResponseStatus_Success         0       // 成功
#define ResponseStatus_UnAuthorized    -100    // 身份认证过期，需重新登录
#define ResponseStatus_Upgrade         -101    // 版本更新
#define ResponseStatus_ForceUpgrade    -102    // 强制版本更新


// 登陆请求数据key
#define USERNAME_KEY            @"Acc"    // 账户名
#define USERPWD_KEY             @"Pass"   // 密码
// 登陆返回数据key
#define IDENTITY_KEY            @"Identity"
#define ACCOUNTID_KEY           @"Id"    // 账户Id
#define NICKNAME_KEY            @"Name"  // 昵称


// 请求类型
typedef enum
{
    LOGIN_TYPE = 800,                 // 登录
    LOGOUT_TYPE,                      // 退出
    REGISTER_TYPE,                    // 注册
    
    HOMELISTINFO_TYPE,                // 首页列表信息
    
    BIDINVESTLIST_TYPE,               // 散标投资列表
    BIDDETAIL_TYPE,                   // 散标详情
    BIDRECORDS_TYPE,                  // 投标记录
    BIDREPAYPLAN_TYPE,                // 还款计划
    BIDINVESTACTION_TYPE,             // 投标
    
    MYACCOUNT_TYPE,               // 我的账户
    
} REQUEST_TYPE;


@interface BaseData : NSObject

@property (nonatomic, assign) REQUEST_TYPE reqType;          // 请求类型
//@property (nonatomic, assign) NSInteger responseStatus;    // 是否成功
//@property (nonatomic, copy) NSString *responseDetails;     // 返回信息
@property (nonatomic, strong) NSString *responseDetails;     // 返回字符串

// 初始化
- (id)initWithRequestType:(REQUEST_TYPE)type;

// 打包数据，用于上传到服务器
- (NSDictionary *)package;

// 解析数据
- (BaseData *)unpackJson:(NSDictionary *)dic;

@end
