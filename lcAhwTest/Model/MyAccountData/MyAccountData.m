//
//  MyAccountData.m
//  lcAhwTest
//
//  Created by licheng on 15/5/13.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "MyAccountData.h"
#import "KUtils.h"
//#import "MJExtension.h"
//#import <objc/runtime.h>

#define IsValidKey              @"IsValid"
#define AvlBalKey               @"AvlBal"
#define ProfitPlanKey           @"ProfitPlan"
#define ProfitFactKey           @"ProfitFact"
#define UnRecoveredKey          @"UnRecovered"
#define CardCountKey            @"CardCount"
#define InvestCountKey          @"InvestCount"
#define UnReadMsgCountKey       @"UnReadMsgCount"

@implementation MyAccountData

- (BaseData *)unpackJson:(NSDictionary *)dic
{
    if ([KUtils isNullOrEmptyArr:dic])
    {
        return nil;
    }
    
    MyAccountData *myAccountData = [[MyAccountData alloc] initWithRequestType:MYACCOUNT_TYPE];
    myAccountData.isValid = [[dic objectForKey:IsValidKey] boolValue];
    myAccountData.avlBal = [dic objectForKey:AvlBalKey];
    myAccountData.profitPlan = [dic objectForKey:ProfitPlanKey];
    myAccountData.profitFact = [dic objectForKey:ProfitFactKey];
    myAccountData.unRecovered = [dic objectForKey:UnRecoveredKey];
    myAccountData.cardCount = [[dic objectForKey:CardCountKey] intValue];
    myAccountData.investCount = [[dic objectForKey:InvestCountKey] intValue];
    myAccountData.unReadMsgCount = [[dic objectForKey:UnReadMsgCountKey] integerValue];
    
    return myAccountData;
}


/*
// 属性的大小写要严格一致
- (id)unpackJson:(NSDictionary *)dic
{
    MyAccountData *myAccountData = [[MyAccountData alloc] initWithRequestType:MYACCOUNT_TYPE];
    
//    //#import "MJExtension.h"
//    myAccountData = [MyAccountData objectWithKeyValues:dic];
    
    //#import <objc/runtime.h>
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([myAccountData class], &outCount);
    for (i=0; i<outCount; i++ )
    {
        objc_property_t property = properties[i];
        NSString *key = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding]; // 属性名
        //NSString *attr = [[NSString alloc] initWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding]; // 属性类型
        id dicValue = [dic objectForKey:key];
        if (dicValue != nil)
        {
            [myAccountData setValue:dicValue forKey:key]; // 给属性赋值
        }
    }
    
    return myAccountData;
}


- (NSDictionary *)package:(id)myData
{
    NSDictionary *dic = [[NSDictionary alloc] init];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([myData class], &outCount);
    for (i=0; i<outCount; i++ )
    {
        objc_property_t property = properties[i];
        NSString *key = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding]; // 属性名
        id value = [myData valueForKey:key]; // 属性值
        if (value != nil)
        {
            [dic setValue:value forKey:key]; // 打包
        }
    }
    return dic;
}
*/


/*
+ (void)unpackTest {
    MyAccountData *myAccountData = [[MyAccountData alloc] init];
    NSDictionary *dict = @{
                           //@"IsValid" : @(YES),
                           //@"AvlBal" : @"可用金额",
                           @"ProfitPlan" : @"累计收益",
                           @"ProfitFact" : @"已收收益",
                           @"UnRecovered_err" : @"待收收益",
                           //@"CardCount" : @(1),
                           @"InvestCount" : @(2),
                           @"UnReadMsgCount" : @(-1)
                           };
    [myAccountData setValuesForKeysWithDictionary:dict];
    NSLog(@"*_* %@", myAccountData);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"value=%@, key=%@", value, key);
}
*/

@end
