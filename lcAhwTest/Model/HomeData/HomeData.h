//
//  HomeData.h
//  lcAhwTest
//
//  Created by licheng on 15/4/13.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "BaseData.h"


// 最新项目 key
#define IDKey                  @"ID"
#define ZAContractCodeKey      @"ZAContractCode"
#define ProductNameKey         @"ProductName"
#define TotalKey               @"Total"
#define RateKey                @"Rate"
#define DateLimitKey           @"DateLimit"
#define ScheduleKey            @"Schedule"

// 首页广告图 key
#define NameKey                @"Name"
#define ImageUrlKey            @"ImageUrl"
#define LinkUrlKey             @"LinkUrl"
#define SortNumKey             @"SortNum"

// 散标投资 key
#define MinRateKey              @"MinRate"
#define MaxRateKey              @"MaxRate"
#define MinInvestKey            @"MinInvest"
#define LatestVersionKey        @"LatestVersion"
#define ContractNumKey          @"ContractNum"
#define WorkTimeKey             @"WorkTime"

// 首页列表 key
#define BannerListKey          @"BannerList"
#define LoanApplyListKey       @"LoanApplyList"
#define TipDataKey             @"TipData"


// 首页广告图
@interface BannerData : BaseData

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imgUrl;
@property (nonatomic, strong) NSString *linkUrl;
@property (nonatomic, assign) NSInteger sortNum;

@end


// 最新项目
@interface BidData : BaseData

@property (nonatomic, strong) NSString *Id;              // 标的Id
@property (nonatomic, strong) NSString *ZAContractCode;  // 借款代码
@property (nonatomic, strong) NSString *productName;     // 01老板贷/02业主贷/03薪贷
@property (nonatomic, strong) NSString *total;           // 金额
@property (nonatomic, strong) NSString *rate;            // 年利率
@property (nonatomic, strong) NSString *dateLimit;       // 期限
@property (nonatomic, assign) CGFloat schedule;          // 借款进度

@end


// 其他信息
@interface TipData : BaseData

@property (nonatomic, strong) NSString *minRate;        // 最小利率
@property (nonatomic, strong) NSString *maxRate;        // 最大利率
@property (nonatomic, assign) NSInteger minInvest;      // 启投金额
@property (nonatomic, strong) NSString *latestVersion;  // 最新版本号
@property (nonatomic, strong) NSString *contractNum;    // 联系电话
@property (nonatomic, strong) NSString *workTime;       // 客服工作时间

@end


// 首页信息列表
@interface HomeDataList : BaseData

@property (nonatomic, strong) NSMutableArray *bannerDataList;
@property (nonatomic, strong) NSMutableArray *bidDataList;
@property (nonatomic, strong) TipData *tipData;

@end

