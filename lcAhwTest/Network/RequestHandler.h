//
//  RequestHandler.h
//  lcAhwTest
//
//  Created by licheng on 15/4/14.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseData.h"
#import "HttpClient.h"
#import "APIConfig.h"
#import "SettingManager.h"
#import "AHWIdentityAuthenticationLib.h"
#import "PushNotificationMannager.h"

// Handler处理完成后调用的Block
typedef void (^CompleteBlock)();

// Handler处理成功时调用的Block
typedef void (^SuccessBlock)(id responseData);

// Handler处理失败时调用的Block
typedef void (^FailedBlock)(id);

@interface RequestHandler : NSObject

// 发送请求
+ (void)startRequestWithData:(BaseData *)data
                    delegate:(id)delegate
                     success:(SuccessBlock)success
                      failed:(FailedBlock)failed;

// 取消指定页面所有请求
+ (void)cancelRequest:(id)delegate;

//// 根据请求类型获取所需请求头的认证信息
//+ (NSDictionary *)getRequestHeaderDic:(REQUEST_TYPE)type;
//
//// 获取http请求方式
//+ (HttpRequestMethod)getRequestMethod:(REQUEST_TYPE)type;
//
//// 获取对应的请求的url
//+ (NSString *)getRequestUrl:(REQUEST_TYPE)type;

@end
