//
//  RequestHandler.m
//  lcAhwTest
//
//  Created by licheng on 15/4/14.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "RequestHandler.h"

@implementation RequestHandler

// 发送请求
+ (void)startRequestWithData:(BaseData *)data
                    delegate:(id)delegate
                     success:(SuccessBlock)success
                      failed:(FailedBlock)failed
{
    NSString *url = [self getRequestUrl:data.reqType];
    
    // get/post
    HttpRequestMethod reqMethod = [self getRequestMethod:data.reqType];
    
    // 请求头信息
    NSDictionary *headerDic = [self getRequestHeaderDic:data.reqType];
    
    // 数据打包
    NSDictionary *dic = [data package];
    
    // 发送请求
    [[HttpClient sharedInstance] requestUrl:url
                                   delegate:delegate
                                    headers:headerDic
                                      param:dic
                                   fileData:nil
                          withRequestMethod:reqMethod
                                   progress:^(NSUInteger bytesWritten,
                                              long long totalBytes,
                                              long long totalBytesExpected){
                                       
                                   }
                                    success:^(id resultObj){
                                        
                                        /*if (resultObj &&
                                            ![resultObj isKindOfClass:[NSNull class]] &&
                                            ![resultObj respondsToSelector:@selector(objectForKey:)])
                                        {
                                            resultObj = [NSJSONSerialization JSONObjectWithStream:resultObj options:0 error:nil];
                                        }*/
                                        
                                        if ([KUtils isNullOrEmptyArr:resultObj])
                                        {
                                            NSString *msg = @"服务器返回数据异常";
                                            failed ? failed(msg) : nil;
                                            return ;
                                        }
                                        
                                        NSInteger responseStatus = -1;
                                        id temp = [resultObj objectForKey:ResponseStatusKey];
                                        if (temp && ![temp isKindOfClass:[NSNull class]])
                                        {
                                            responseStatus = [temp integerValue];
                                        }
                                        
                                        if (responseStatus == ResponseStatus_Success)
                                        {
                                            // http请求和服务器业务逻辑 都成功
                                            
                                            id responseObj = [resultObj objectForKey:ResponseDataKey];
                                            
                                            // 解析数据
                                            BaseData *responseData = nil;
                                            if ([responseObj isKindOfClass:[NSDictionary class]])
                                            {
                                                // 比如实名认证和投标，只返回字符串 "Data":"pnrUrl..."
                                                id tempData = [(NSDictionary *)responseObj objectForKey:StringDataKey];
                                                if ([tempData isKindOfClass:[NSString class]])
                                                {
                                                    responseData = [[BaseData alloc] initWithRequestType:data.reqType];
                                                    responseData.responseDetails = tempData;
                                                }
                                                else
                                                {
                                                    responseData = [data unpackJson:responseObj];
                                                }
                                            }
                                            
                                            success ? success(responseData) : nil;
                                        }
                                        else
                                        {
                                            // http请求成功，但服务器业务逻辑返回失败
                                            
                                            NSString *msg = [resultObj objectForKey:MsgKey];
                                            failed ? failed(msg) : nil;
                                        }
                                        
                                    }
                                    failure:^(id error){
                                        failed ? failed(error) : nil;
                                    }
                                    withTag:data.reqType];
}

+ (void)cancelRequest:(id)delegate
{
    [[HttpClient sharedInstance] cancelDelegateRequest:delegate];
}


// 根据请求类型获取所需请求头的认证信息
+ (NSDictionary *)getRequestHeaderDic:(REQUEST_TYPE)type
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    // 请求头Content-Type
    //[dic setObject:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    
    // app版本号
    [dic setObject:[KUtils appVersion] forKey:@"Version"];
    
    // 操作系统
    [dic setObject:@"iOS" forKey:@"Client"];
    
    // 消息推送DeviceToken
    NSString *deviceTokenStr = [[PushNotificationMannager sharedInstance] getDeviceTokenStr];
    [dic setObject:deviceTokenStr forKey:DeviceTokenKey];
    
    // 基础认证
    //[dic safeSetObject:[AHWIdentityAuthenticationLib getBaseAuthenticationValue] forKey:[AHWIdentityAuthenticationLib getBaseAuthenticationToken]];
    [dic setObject:@"fc85a7ce091aea86ef3463b9166e9b06" forKey:@"AhwApi-Access-Token"];
    
    switch (type) {
        case LOGIN_TYPE:
        case REGISTER_TYPE:
        case HOMELISTINFO_TYPE:
        case BIDINVESTLIST_TYPE:
        case BIDRECORDS_TYPE:
        case BIDREPAYPLAN_TYPE:
        {
            // 登录、注册等无需身份认证
            
            break;
        }
        case BIDDETAIL_TYPE:
        {
            // 散标详情（可用余额） 根据登陆与否添加身份认证
            
            break;
        }
            
        default:
        {
            //选择性添加身份认证
            //[dic setObject:@"identity.Id" forKey:@"AhwApi-Access-Key"];
            //[dic setObject:@"aes(guid:md5(identity))" forKey:@"AhwApi-Access-Value"];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *accessKey = [userDefaults objectForKey:ACCOUNTID_KEY];
            if ([accessKey length] > 0)
            {
                [dic setObject:accessKey forKey:@"AhwApi-Access-Key"];
            }
            NSString *identity = [SettingManager shareInstance].sIdentity;
            if (![KUtils isNullOrEmptyStr:identity])
            {
//                NSString *aesToken = [AHWIdentityAuthenticationLib getIdentifyAuthenticationTokenByAccountID:identity];
//                NSString *aesKey = [AHWIdentityAuthenticationLib getIdentifyAuthenticationValue];
//                [dic setObject:aesToken forKey:aesKey];
                
                NSString *md5_identity = [KUtils md5:identity];
                NSString *uuid = [KUtils createUUID];
                NSString *unAesStr = [NSString stringWithFormat:@"%@:%@",uuid,md5_identity];
                //NSString *accessValue = [KUtils aes:unAesStr];
                NSString *accessValue = [AESCrypt encrypt:unAesStr password:@"1234567891234567"];
                [dic setObject:accessValue forKey:@"AhwApi-Access-Value"];
            }
            break;
        }
    }
    
    return dic;
}


// 获取http请求方式 get/post
+ (HttpRequestMethod)getRequestMethod:(REQUEST_TYPE)type
{
    HttpRequestMethod reqMthod = HttpRequestMethodGet;
    switch (type) {
        case LOGIN_TYPE:
        case BIDINVESTACTION_TYPE:
        {
            reqMthod = HttpRequestMethodPost;
        }
            break;
            
        default:
            break;
    }
    
    return reqMthod;
}

// 获取对应的请求的url
+ (NSString *)getRequestUrl:(REQUEST_TYPE)type
{
    NSString *url = nil;
    switch (type)
    {
        case LOGIN_TYPE:
        {
            url = LOGIN_URL;
        }
            break;
            
        case LOGOUT_TYPE:
        {
            url = LOGOUT_URL;
        }
            break;
            
        case REGISTER_TYPE:
        {
            url = REGISTER_URL;
        }
            break;
            
        case HOMELISTINFO_TYPE:
        {
            url = HOMELISTINFO_URL;
        }
            break;
            
        case BIDINVESTLIST_TYPE:
        {
            NSInteger page = [SettingManager shareInstance].invest_page;
            NSString *sortitem = [SettingManager shareInstance].invest_sortItem;
            url = [BIDINVESTLIST_URL stringByAppendingFormat:@"?page=%lu&SortItem=%@", (unsigned long)page, sortitem];
        }
            break;
        case BIDDETAIL_TYPE:
        {
            NSString *bidID = [SettingManager shareInstance].bidID;
            url = [BIDDETAIL_URL stringByAppendingFormat:@"/%@", bidID];
        }
            break;
        case BIDRECORDS_TYPE:
        {
            NSString *bidID = [SettingManager shareInstance].bidID;
            NSInteger page = [SettingManager shareInstance].investDetail_recordPage;
            url = [BIDRECOND_URL stringByAppendingFormat:@"/%@?page=%lu", bidID, page];
        }
            break;
        case BIDREPAYPLAN_TYPE:
        {
            NSString *bidID = [SettingManager shareInstance].bidID;
            NSInteger page = [SettingManager shareInstance].investDetail_payPlanPage;
            url = [BIDREPAYPLAN_URL stringByAppendingFormat:@"/%@?page=%i", bidID, page];
        }
            break;
        case MYACCOUNT_TYPE:
        {
            url = MYACCOUNT_URL;
        }
            break;
            
        default:
            break;
    }
    
    return url;
}


@end
