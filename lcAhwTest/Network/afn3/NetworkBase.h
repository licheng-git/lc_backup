//
//  NetworkBase.h
//  mobaxx
//
//  Created by licheng on 16/5/27.
//  Copyright © 2016年 billnie. All rights reserved.
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
           headers:(NSDictionary *)headersDic
           cookies:(NSString *)cookiesStr
            params:(NSDictionary *)paramsDic
          fileData:(NSData *)fileData
            method:(HttpMethod)method
          progress:(void (^)(NSProgress *progressObj))progress
           success:(void (^)(id responseObject))success
           failure:(void (^)(id error))failure;

@end

