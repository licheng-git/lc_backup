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
};

@interface NetworkBase : NSObject

+ (NetworkBase *)sharedInstance;

// 基本网络请求，与业务无关
- (void)requestUrl:(NSString *)urlStr
             async:(BOOL)bAsync
           headers:(NSDictionary *)headersDic
           cookies:(NSString *)cookiesStr
            params:(NSDictionary *)paramsDic
          fileData:(NSData *)fileData
            method:(HttpMethod)method
          progress:(void (^)(NSUInteger bytesWritten,
                             long long totalBytes,
                             long long totalBytesExpected)
                    )progress
           success:(void (^)(id responseObject))success
           failure:(void (^)(id error))failure;

@end

