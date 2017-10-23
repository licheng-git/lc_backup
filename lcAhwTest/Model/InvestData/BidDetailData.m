//
//  BidDetailData.m
//  lcAhwTest
//
//  Created by licheng on 15/5/4.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "BidDetailData.h"
#import "KUtils.h"

// 标的详情
#define IDKey                  @"ID"
#define ZAContractCodeKey      @"ZAContractCode"
#define ProductNameKey         @"ProductName"
#define TotalKey               @"Total"
#define RateKey                @"Rate"
#define DateLimitKey           @"DateLimit"
#define ScheduleKey            @"Schedule"
#define PayTypeNameKey         @"PayTypeName"
#define NeedTotalTextKey       @"NeedTotalText"
#define NeedTotalValueKey      @"NeedTotalValue"
#define BtnStatusKey           @"BtnStatus"
#define BtnDescKey             @"BtnDesc"
#define TextTipKey             @"TextTip"
#define AvlBalKey              @"AvlBal"
#define ContractUrlKey         @"ContractUrl"
#define LoanApplyInfoKey       @"LoanApplyInfo"

// 投标记录
#define Records_NickNameKey           @"NickName"
#define Records_TenderMoneyKey        @"TenderMoney"
#define Records_TenderTimeKey         @"TenderTime"

// 还款计划
#define RepayPlan_PayDateKey             @"PayDate"
#define RepayPlan_PrincipalPayKey        @"PrincipalPay"
#define RepayPlan_IntPayKey              @"IntPay"



// 标的详情
@implementation BidDetailData

- (id)initWithRequestType:(REQUEST_TYPE)type
{
    self = [super initWithRequestType:type];
    if (self)
    {
    }
    return self;
}

- (NSDictionary *)package
{
    return nil;
}

- (BaseData *)unpackJson:(NSDictionary *)dic
{
    BaseData *data = nil;
    
    if ([KUtils isNullOrEmptyArr:dic])
    {
        return data;
    }
    
    BidDetailData *biddata = [[BidDetailData alloc] initWithRequestType:BIDDETAIL_TYPE];
    biddata.Id = [dic objectForKey:IDKey];
    biddata.ZAContractCode = [dic objectForKey:ZAContractCodeKey];
    biddata.productName = [dic objectForKey:ProductNameKey];
    biddata.total = [dic objectForKey:TotalKey];
    biddata.rate = [dic objectForKey:RateKey];
    biddata.dateLimit = [dic objectForKey:DateLimitKey];
    biddata.schedule = [[dic objectForKey:ScheduleKey] floatValue];
    biddata.payTypeName = [dic objectForKey:PayTypeNameKey];
    biddata.needTotalText = [dic objectForKey:NeedTotalTextKey];
    biddata.needTotalValue = [[dic objectForKey:NeedTotalValueKey] floatValue];
    biddata.btnStatus = [dic objectForKey:BtnStatusKey];
    biddata.btnDesc = [dic objectForKey:BtnDescKey];
    biddata.textTip = [dic objectForKey:TextTipKey];
    biddata.avlBal = [[dic objectForKey:AvlBalKey] floatValue];
    biddata.contractUrl = [dic objectForKey:ContractUrlKey];
    biddata.loanInfoArr = [dic objectForKey:LoanApplyInfoKey];
    
    data = biddata;
    return data;
}

@end



// 投标纪录
@implementation RecordData
@end

// 投标纪录列表
@implementation RecordDataList

- (id)initWithRequestType:(REQUEST_TYPE)type
{
    self = [super initWithRequestType:type];
    if (self)
    {
        self.datalist = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSDictionary *)package
{
    return nil;
}

- (BaseData *)unpackJson:(NSDictionary *)dic
{
    if ([KUtils isNullOrEmptyArr:dic])
    {
        return nil;
    }
    
    NSArray *tempArr = [dic objectForKey:ListDataKey];
    if ([KUtils isNullOrEmptyArr:tempArr])
    {
        return nil;
    }
    
    BaseData *data = nil;
    RecordDataList *recorddatalist = [[RecordDataList alloc] initWithRequestType:BIDRECORDS_TYPE];
    for (int i=0; i<tempArr.count; i++)
    {
        NSDictionary *tempDic = [tempArr objectAtIndex:i];
        RecordData *recorddata = [[RecordData alloc] initWithRequestType:BIDRECORDS_TYPE];
        recorddata.nickName = [tempDic objectForKey:Records_NickNameKey];
        recorddata.money = [tempDic objectForKey:Records_TenderMoneyKey];
        recorddata.time = [tempDic objectForKey:Records_TenderTimeKey];
        [recorddatalist.datalist addObject:recorddata];
    }
    data = recorddatalist;
    
    return data;
}

@end



// 还款计划
@implementation RepayPlanData
@end

// 还款计划列表
@implementation RepayPlanDataList

- (id)initWithRequestType:(REQUEST_TYPE)type
{
    self = [super initWithRequestType:type];
    if (self)
    {
        self.datalist = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSDictionary *)package
{
    return nil;
}

- (BaseData *)unpackJson:(NSDictionary *)dic
{
    if ([KUtils isNullOrEmptyArr:dic])
    {
        return nil;
    }
    
    NSArray *tempArr = [dic objectForKey:ListDataKey];
    if ([KUtils isNullOrEmptyArr:tempArr])
    {
        return nil;
    }
    
    BaseData *data = nil;
    RepayPlanDataList *repayplandatalist = [[RepayPlanDataList alloc] initWithRequestType:BIDREPAYPLAN_TYPE];
    for (int i=0; i<tempArr.count; i++)
    {
        NSDictionary *tempDic = [tempArr objectAtIndex:i];
        RepayPlanData *repayplandata = [[RepayPlanData alloc] initWithRequestType:BIDREPAYPLAN_TYPE];
        repayplandata.repayDate = [tempDic objectForKey:RepayPlan_PayDateKey];
        repayplandata.principal = [tempDic objectForKeyedSubscript:RepayPlan_PrincipalPayKey];
        repayplandata.interest = [tempDic objectForKey:RepayPlan_IntPayKey];
        [repayplandatalist.datalist addObject:repayplandata];
    }
    data = repayplandatalist;
    
    return data;
}

@end
