//
//  MyAccountData.h
//  lcAhwTest
//
//  Created by licheng on 15/5/13.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "BaseData.h"

@interface MyAccountData : BaseData

@property (nonatomic, assign) BOOL isValid;             // 是否通过实名认证
@property (nonatomic, strong) NSString *avlBal;         // 可用金额
@property (nonatomic, strong) NSString *profitPlan;     // 累计收益
@property (nonatomic, strong) NSString *profitFact;     // 已收收益
@property (nonatomic, strong) NSString *unRecovered;    // 待收收益
@property (nonatomic, assign) int cardCount;            // 银行卡数量
@property (nonatomic, assign) int investCount;          // 我的投资数量
@property (nonatomic, assign) NSInteger unReadMsgCount; // 未读消息数量

@end
