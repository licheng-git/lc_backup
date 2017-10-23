//
//  BidDetailData.h
//  lcAhwTest
//
//  Created by licheng on 15/5/4.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "BaseData.h"


// 标的详情
@interface BidDetailData : BaseData
/**************
 BtnStatus按钮状态：
 01表示申请
 02表示审核拒绝
 03表示审核通过，即投标中
 04表示流标
 05表示已满标
 06表示打印放款通知书
 07表示已放款，即还款中
 -1表示没有实名认证
 *****************/
@property (nonatomic, strong) NSString *Id;                // 标的Id
@property (nonatomic, strong) NSString *ZAContractCode;    // 借款代码
@property (nonatomic, strong) NSString *productName;       // 老板贷/业主贷/薪贷
@property (nonatomic, strong) NSString *total;             // 金额
@property (nonatomic, strong) NSString *rate;              // 年利率
@property (nonatomic, strong) NSString *dateLimit;         // 期限
@property (nonatomic, assign) CGFloat  schedule;           // 借款进度
@property (nonatomic, strong) NSString *payTypeName;       // 还款方式
@property (nonatomic, strong) NSString *needTotalText;     // 可投金额（显示）
@property (nonatomic, assign) CGFloat  needTotalValue;     // 可投金额（数值）
@property (nonatomic, strong) NSString *btnStatus;         // 按钮状态
@property (nonatomic, strong) NSString *btnDesc;           // 按钮文字描述
@property (nonatomic, strong) NSString *textTip;           // 文字提示信息
@property (nonatomic, assign) CGFloat  avlBal;             // 可用余额
@property (nonatomic, strong) NSString *contractUrl;       // 借款协议地址
@property (nonatomic, strong) NSArray  *loanInfoArr;       // 贷款信息列表
@end


// 投标记录
@interface RecordData : BaseData
@property (nonatomic, strong) NSString *nickName;    // 用户名
@property (nonatomic, strong) NSString *money;       // 金额
@property (nonatomic, strong) NSString *time;        // 时间
@end

// 投标记录列表
@interface RecordDataList : BaseData
@property (nonatomic, strong) NSMutableArray *datalist;
@end


// 还款计划
@interface RepayPlanData : BaseData
@property (nonatomic, strong) NSString *repayDate;    // 还款日期
@property (nonatomic, strong) NSString *principal;    // 本金
@property (nonatomic, strong) NSString *interest;     // 利息
@end

// 还款计划列表
@interface RepayPlanDataList : BaseData
@property (nonatomic, strong) NSMutableArray *datalist;
@end
