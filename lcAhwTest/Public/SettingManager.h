//
//  SettingManager.h
//  lcAhwTest
//
//  Created by licheng on 15/4/29.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDefaultPageNum    1

#define Invest_SortItem_RateKey       @"rate"       // 散标投资 排序方式 按利率
#define Invest_SortItem_DateLimitKey  @"datelimit"  // 散标投资 排序方式 按期限
#define Invest_SortItem_AuditDateKey  @"auditdate"  // 散标投资 排序方式 按时间

@interface SettingManager : NSObject

@property (nonatomic, assign) BOOL bIsNetBreak; // 网络状态

@property (nonatomic, assign) BOOL bIsLogined; // 登陆状态
@property (nonatomic, strong) NSString *sIdentity; // json字符串 登陆下发的身份认证

@property (nonatomic, assign) NSUInteger invest_page;         // 散标投资 列表页数
@property (nonatomic, strong) NSString   *invest_sortItem;    // 散标投资 排序方式

@property (nonatomic, strong) NSString   *bidID;              // 标的ID
@property (nonatomic, assign) NSUInteger investDetail_recordPage;    // 标的详情 投标记录 页数
@property (nonatomic, assign) NSUInteger investDetail_payPlanPage;   // 标的详情 还款计划 页数


+ (SettingManager *)shareInstance;




// 只读属性
@property (nonatomic, strong, readonly) NSString *str_readonly;

// 类属性
+ (NSString *)str_static;
+ (void)setStr_static:(NSString *)str;

@end
