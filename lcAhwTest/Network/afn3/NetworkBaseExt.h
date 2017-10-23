//
//  NetworkBaseExt.h
//  Base
//
//  Created by licheng on 16/7/7.
//  Copyright © 2016年 billnie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface NetworkBaseExt : NSObject

+ (NetworkBaseExt *)sharedInstance;

// 基础网络请求 GET
- (void)httpGet:(NSString *)urlStr
        headers:(NSDictionary *)headersDic
        cookies:(NSString *)cookiesStr
         params:(NSDictionary *)paramsDic
       progress:(void (^)(NSProgress *progressObj))progress
        success:(void (^)(id responseObject))success
        failure:(void (^)(id error))failure;

// 基础网络请求 POST
- (void)httpPost:(NSString *)urlStr
         headers:(NSDictionary *)headersDic
         cookies:(NSString *)cookiesStr
          params:(NSDictionary *)paramsDic
        fileData:(NSData *)fileData
        progress:(void (^)(NSProgress *progressObj))progress
         success:(void (^)(id responseObject))success
         failure:(void (^)(id error))failure;

// 基础网络请求 PUT
- (void)httpPut:(NSString *)urlStr
        headers:(NSDictionary *)headersDic
        cookies:(NSString *)cookiesStr
       fileData:(NSData *)fileData
        success:(void (^)(id responseObject))success
        failure:(void (^)(id error))failure;

// 基础网络请求 DELETE
- (void)httpDelete:(NSString *)urlStr
           headers:(NSDictionary *)headersDic
           cookies:(NSString *)cookiesStr
            params:(NSDictionary *)paramsDic
           success:(void (^)(id responseObject))success
           failure:(void (^)(id error))failure;

@end
