//
//  APIConfig.h
//  lcAhwTest
//
//  Created by licheng on 15/4/14.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#ifndef lcAhwTest_APIConfig_h
#define lcAhwTest_APIConfig_h


/**
 *服务器连接的地址
 */

//#if DEBUG
#define SERVER_BASEURL @"http://119.147.82.70:7771/api" //调试模式
//#else
//#define SERVER_BASEURL @"https://api.anhewang.com/api" //发布模式
//#endif

/**
 *	@brief	各个API的地址
 */

// 投标成功 校验 url
#define INVESTBID_SUCCESS_URL     @"AhwInvestSuccess"
// 投标失败 校验 url
#define INVESTBID_FAIL_URL        @"AhwInvestFail"

#pragma mark - 账户管理

// 登录
#define LOGIN_URL                 [SERVER_BASEURL stringByAppendingString:@"/account/login"]

// 注册
#define REGISTER_URL              [SERVER_BASEURL stringByAppendingString:@"/account/register"]

// 用户退出
#define LOGOUT_URL                [SERVER_BASEURL stringByAppendingString:@"/Account/LoginOut"]

// 获取短信验证码
#define GETCHECKCODE_URL          [SERVER_BASEURL stringByAppendingString:@"/Account/GetValidateCode"]

// 找回密码
#define GETBACKPWD_URL            [SERVER_BASEURL stringByAppendingString:@"/Account/FindPass"]

// 找回密码里的修改密码
#define CHANGEPWD_URL             [SERVER_BASEURL stringByAppendingString:@"/Account/ChangePass"]

// 实名认证并开户
#define REALNAMEAUTHENTICATIO_URL [SERVER_BASEURL stringByAppendingString:@"/Account/PnrRegister"]

#pragma mark - 首页

// 首页列表信息：包含广告图，最新项目，散标投资 信息
#define HOMELISTINFO_URL     [SERVER_BASEURL stringByAppendingString:@"/Home/Index"]

// 消息中心 /Home/News?page=2 : page (int) 表获取第几页
#define MSGCENTER_URL        [SERVER_BASEURL stringByAppendingString:@"/Home/News"]

//意见反馈
#define FEEDBACK_URL         [SERVER_BASEURL stringByAppendingString:@"/Home/Advise"]

#pragma mark - 散标投资

// 散标投资列表
#define BIDINVESTLIST_URL    [SERVER_BASEURL stringByAppendingString:@"/Invest/List"]

// 散标详情
#define BIDDETAIL_URL        [SERVER_BASEURL stringByAppendingString:@"/Invest/Detail"]

// 投标记录
#define BIDRECOND_URL        [SERVER_BASEURL stringByAppendingString:@"/Invest/TenderList"]

// 还款记录
#define BIDREPAYPLAN_URL     [SERVER_BASEURL stringByAppendingString:@"/Invest/RepayPlanList"]

// 投标
#define BIDINVESTACTION_URL  [SERVER_BASEURL stringByAppendingString:@"/Invest/InvestAction"]

#pragma mark - 我的账户

// 我的账户
#define MYACCOUNT_URL        [SERVER_BASEURL stringByAppendingString:@"/My/Index"]

// 站内消息
#define NEWSSTATION_URL      [SERVER_BASEURL stringByAppendingString:@"/My/Msg"]

// 账户信息
#define MYACCOUNTINFO_URL    [SERVER_BASEURL stringByAppendingString:@"/My/Info"]

// 资金记录 金额
#define FOUNDDATA_URL        [SERVER_BASEURL stringByAppendingString:@"/My/FundData"]

// 资金记录 列表
#define FOUNDLIST_URL        [SERVER_BASEURL stringByAppendingString:@"/My/FundList"]

// 还款计划（月）
#define PAYPLAN_URL          [SERVER_BASEURL stringByAppendingString:@"/My/Plan"]

// 还款计划（天）
#define PAYPLANDETAIL_URL    [SERVER_BASEURL stringByAppendingString:@"/My/PlanDetail"]

// 我的投资
#define MYINVERST_URL        [SERVER_BASEURL stringByAppendingString:@"/My/InvestList"]

// 我的投资还款计划
#define MYINVERSTPAYPLAN_URL [SERVER_BASEURL stringByAppendingString:@"/My/ProfitPlan"]


#endif
