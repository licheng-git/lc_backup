//
//  ESDIdentityAuthenticationLib.h
//  ESDIdentityAuthenticationLib
//
//  Created by hhx on 14/11/21.
//  Copyright (c) 2014年 hhx. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AHWIdentityAuthenticationLib : NSObject

// 获取基础认证的Token（key）
+ (NSString *)getBaseAuthenticationToken;

// 获取基础认证的value
+ (NSString *)getBaseAuthenticationValue;

// 获取身份认证key
+ (NSString *)getIdentifyAuthenticationKey;

// 获取身份认证value
+ (NSString *)getIdentifyAuthenticationValue;

// 获取身份认证的token
+ (NSString *)getIdentifyAuthenticationTokenByAccountID:(NSString *)accountID;

// 获取唯一标示码
+ (NSString *)createUUID;

// md5 32位 加密 （小写）
+ (NSString *)md5:(NSString *)str;

@end
