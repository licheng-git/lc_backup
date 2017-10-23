//
//  BidListData.m
//  lcAhwTest
//
//  Created by licheng on 15/4/28.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "BidDataList.h"

@implementation BidDataList

- (instancetype)initWithRequestType:(REQUEST_TYPE)type
{
    self = [super initWithRequestType:type];
    if (self)
    {
        self.bidDataList = [[NSMutableArray alloc] initWithCapacity:0];
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
    if (![KUtils isNullOrEmptyArr:dic])
    {
        NSArray *tempArr_unsort = [dic objectForKey:ListDataKey];
        if (![KUtils isNullOrEmptyArr:tempArr_unsort])
        {
            // 排序
            NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:ScheduleKey ascending:YES];  // yes升序，no降序
            NSArray *sdArr = [NSArray arrayWithObjects:sd, nil];
            NSArray *tempArr = [tempArr_unsort sortedArrayUsingDescriptors:sdArr];
            
            BidDataList *listdata = [[BidDataList alloc] initWithRequestType:BIDINVESTLIST_TYPE];
            for (int i=0; i<tempArr.count; i++)
            {
                BidData *bidData = [[BidData alloc] initWithRequestType:BIDINVESTLIST_TYPE];
                NSDictionary *tempDic = [tempArr objectAtIndex:i];
                
                bidData.Id = [tempDic objectForKey:IDKey];
                bidData.ZAContractCode = [tempDic objectForKey:ZAContractCodeKey];
                bidData.productName = [tempDic objectForKey:ProductNameKey];
                bidData.total = [tempDic objectForKey:TotalKey];
                bidData.rate = [tempDic objectForKey:RateKey];
                bidData.dateLimit = [tempDic objectForKey:DateLimitKey];
                id schedule = [tempDic objectForKey:ScheduleKey];
                if (schedule && ![schedule isKindOfClass:[NSNull class]])
                {
                    bidData.schedule = [schedule floatValue];
                }
                
                [listdata.bidDataList addObject:bidData];
            }
            data = listdata;
        }
    }
    return data;
}

@end
