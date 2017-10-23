//
//  BidDetailBottomView.h
//  lcAhwTest
//
//  Created by licheng on 15/5/5.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KUtils.h"
#import "BidDetailData.h"
#import "SettingManager.h"

typedef NS_ENUM(NSInteger, BidDetailBottomBtn_Tag)
{
    BidDetailBtnTag_Login = 1200,    // 登陆
    BidDetailBtnTag_Rigister,        // 注册
    
    BidDetailBtnTag_CheckAgreenment, // 协议 打勾
    BidDetailBtnTag_SeeAgreenment,   // 查看协议
    
    BidDetailBtnTag_Invest,          // 投标
    BidDetailBtnTag_Charge,          // 充值
    BidDetailBtnTag_PnrRigister,     // 实名认证
    BidDetailBtnTag_UnEnable,        // 其他情况按钮不可用
};

// 服务端返回按钮状态
#define kBtnStatus_1  @"-1"  // 没有实名认证 *_*
#define kBtnStatus_2  @"-2"  // 余额不足 *_*
#define kBtnStatus01  @"01"  // 审核中
#define kBtnStatus02  @"02"  // 审核拒绝
#define kBtnStatus03  @"03"  // 审核通过，即投标中 *_*
#define kBtnStatus04  @"04"  // 流标
#define kBtnStatus05  @"05"  // 已满标
#define kBtnStatus06  @"06"  // 打印放款通知书
#define kBtnStatus07  @"07"  // 已放款，即还款中
#define kBtnStatus10  @"10"  // 已结清

@interface BidDetailBottomView : UIView

@property (nonatomic, strong) UIButton *loginBtn;       // 登陆
@property (nonatomic, strong) UIButton *rigisterBtn;    // 注册

@property (nonatomic, strong) UIButton *checkBtn;       // 协议 勾选
@property (nonatomic, strong) UILabel *agreementLb;     // “我已阅读并同意”
@property (nonatomic, strong) UIButton *agreementBtn;   // 协议 点击查看
@property (nonatomic, strong) UITextField *inputTF;     // 输入框（投标金额 或 充值金额）
@property (nonatomic, strong) UIButton *actionBtn;      // 投标、充值、实名认证 登按钮


// 根据data.btnStatus状态创建视图
- (void)createViewWithData:(BidDetailData *)data delegate:(id)delegate;

@end
