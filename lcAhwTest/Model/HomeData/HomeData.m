//
//  HomeData.m
//  lcAhwTest
//
//  Created by licheng on 15/4/13.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "HomeData.h"
#import "KUtils.h"

// 首页广告图
@implementation BannerData
@end

// 最新项目
@implementation BidData
@end

// 散标投资
@implementation TipData
@end

// 首页信息列表
@implementation HomeDataList

- (id)initWithRequestType:(REQUEST_TYPE)type
{
    self = [super initWithRequestType:type];
    if (self)
    {
        self.bannerDataList = [[NSMutableArray alloc] init];
        self.bidDataList = [[NSMutableArray alloc] initWithCapacity:0];
        self.tipData = [[TipData alloc] initWithRequestType:type];
    }
    return self;
}

- (BaseData *)unpackJson:(NSDictionary *)dic
{
    BaseData *data = nil;
    
    //if (!dic || dic==nil || [dic isKindOfClass:[NSNull class]] || [dic count]<=0)
    if ([KUtils isNullOrEmptyArr:dic])
    {
        return data;
    }
    
    HomeDataList *listdata = [[HomeDataList alloc] initWithRequestType:HOMELISTINFO_TYPE];
        
    // banner图
    NSArray *tempArr = [dic objectForKey:BannerListKey];
    if (![KUtils isNullOrEmptyArr:tempArr])
    {
        for (int i=0; i<tempArr.count; i++)
        {
            BannerData *bannerData = [[BannerData alloc] initWithRequestType:HOMELISTINFO_TYPE];
            NSDictionary *tempDic = [tempArr objectAtIndex:i];
            
            NSString *name = [tempDic objectForKey:NameKey];
            if (![KUtils isNullOrEmptyStr:name])
            {
                bannerData.name = name;
            }
                
            NSString *imgUrl = [tempDic objectForKey:ImageUrlKey];
            if (![KUtils isNullOrEmptyStr:imgUrl])
            {
                bannerData.imgUrl = imgUrl;
            }
                
            NSString *linkUrl = [tempDic objectForKey:LinkUrlKey];
            if(![KUtils isNullOrEmptyStr:linkUrl])
            {
                bannerData.linkUrl = linkUrl;
            }
                
            id sortNum = [tempDic objectForKey:SortNumKey];
            if (sortNum && ![sortNum isKindOfClass:[NSNull class]])
            {
                bannerData.sortNum = [sortNum integerValue];
            }
                
            [listdata.bannerDataList addObject:bannerData];
        }
    }
    
    // 最新项目
    tempArr = [dic objectForKey:LoanApplyListKey];
    if (![KUtils isNullOrEmptyArr:tempArr])
    {
        for (int i=0; i<tempArr.count; i++) {
            
            BidData *bidData = [[BidData alloc] initWithRequestType:HOMELISTINFO_TYPE];
            NSDictionary *tempDic = [tempArr objectAtIndex:i];
            
            bidData.Id = [tempDic objectForKey:IDKey];
            
            bidData.ZAContractCode = [tempDic objectForKey:ZAContractCodeKey];
            
            bidData.productName = [tempDic objectForKey:ProductNameKey];
            
            bidData.total = [tempDic objectForKey:TotalKey];
            
            bidData.rate = [tempDic objectForKey:RateKey];
            
            bidData.dateLimit = [tempDic objectForKey:DateLimitKey];
            
            //bidData.schedule = [[tempDic objectForKey:ScheduleKey] floatValue];
            id schedule = [tempDic objectForKey:ScheduleKey];
            if (schedule && ![schedule isKindOfClass:[NSNull class]])
            {
                bidData.schedule = [schedule floatValue];
            }
            
            [listdata.bidDataList addObject:bidData];
        }
    }
    
    // 散标投资
    NSDictionary *tempDic = [dic objectForKey:TipDataKey];
    if (![KUtils isNullOrEmptyArr:tempDic])
    {
        listdata.tipData.minRate = [tempDic objectForKey:MinRateKey];
        listdata.tipData.maxRate = [tempDic objectForKey:MaxRateKey];
        //listdata.tipData.minInvest = [[tempDic objectForKey:MinInvestKey] integerValue];
        id minInvest = [tempDic objectForKey:MinInvestKey];
        if (minInvest && ![minInvest isKindOfClass:[NSNull class]])
        {
            listdata.tipData.minInvest = [minInvest integerValue];
        }
        listdata.tipData.latestVersion = [tempDic objectForKey:LatestVersionKey];
        listdata.tipData.contractNum = [tempDic objectForKey:ContractNumKey];
        listdata.tipData.workTime = [tempDic objectForKey:WorkTimeKey];
    }
    
    data = listdata;
    
    return data;
}

@end