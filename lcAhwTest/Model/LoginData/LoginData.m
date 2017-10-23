//
//  LoginData.m
//  lcAhwTest
//
//  Created by licheng on 15/4/20.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "LoginData.h"
#import "KUtils.h"
#import "SettingManager.h"
//#import "JSONKit.h"  // iOS9有错误
#import "CJSONSerializer.h"

@implementation LoginData

- (NSDictionary *)package
{
    NSMutableDictionary *dic = nil;
    if (self)
    {
        dic = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dic setObject:self.userName forKey:USERNAME_KEY];
        [dic setObject:self.userPwd forKey:USERPWD_KEY]; // 密码已经md5加密过
    }
    return dic;
}

- (BaseData *)unpackJson:(NSDictionary *)dic
{
    BaseData *data = nil;
    
    NSDictionary *identityDic = [dic objectForKey:IDENTITY_KEY];
    dic = identityDic;
    
    if (![KUtils isNullOrEmptyArr:dic])
    {
        // 保存identity数据(JsonStr 字符串格式)
        
//        // 系统自带的json解析，会带换行符\n和空格
//        NSString *jsonstr;
//        if ([NSJSONSerialization isValidJSONObject:dic])
//        {
//            NSData *jsondata = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil]; //*_*
//            jsonstr = [[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
//        }
        
//        // JSONKit解析，iOS9出错
//        //NSString *jsonstr = [dic JSONString];
//        NSData *jsondata = [dic JSONData];
//        NSString *jsonstr = [[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
        
        // TouchJSON解析
        NSData *jsondata = [[CJSONSerializer serializer] serializeDictionary:dic error:nil];
        NSString *jsonstr = [[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
        
        [SettingManager shareInstance].sIdentity = jsonstr;
        
        
        // 保存账户ID
        NSString *accountID = [dic objectForKey:ACCOUNTID_KEY];
        if (![KUtils isNullOrEmptyStr:accountID])
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:accountID forKey:ACCOUNTID_KEY];
            [userDefaults synchronize]; // 建议同步到磁盘，但不是必需的
        }
        // 保存用户昵称
        NSString *nickName = [dic objectForKey:NICKNAME_KEY];
        if (![KUtils isNullOrEmptyStr:nickName])
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:nickName forKey:NICKNAME_KEY];
            [userDefaults synchronize];
        }
    }
    return data;
}

@end
