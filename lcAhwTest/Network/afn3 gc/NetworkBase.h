//
//  NetworkBase.h
//  GuangCaiJiaoYi
//
//  Created by 李诚 on 16/12/8.
//  Copyright © 2016年 Steven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef NS_ENUM(NSInteger, HttpMethod)
{
    HttpMethodGet = 0,
    HttpMethodPost,
    HttpMethodPut,
    HttpMethodDelete,
};

@interface NetworkBase : NSObject

+ (NetworkBase *)sharedInstance;

// 基础网络请求，与业务无关
- (void)requestUrl:(NSString *)urlStr
           headers:(NSDictionary *)headersDict
           cookies:(NSString *)cookiesStr
            params:(NSDictionary *)paramsDict
          fileData:(NSData *)fileData
            method:(HttpMethod)method
          delegate:(id)delegate
          progress:(void (^)(NSProgress *progressObj))progress
           success:(void (^)(id responseObject))success
           failure:(void (^)(id error))failure;

// 取消指定页面的所有请求
- (void)cancelRequest:(id)obj;

@end

