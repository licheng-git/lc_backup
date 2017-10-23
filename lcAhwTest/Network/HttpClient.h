//
//  HttpClient.h
//  lcAhwTest
//
//  Created by licheng on 15/4/14.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "HttpBaseRequest.h"
#import "KUtils.h"

@interface HttpClient : NSObject

+ (HttpClient *)sharedInstance;

/**
 *  get、post、下载、上传请求
 *
 *  @pram   url             :请求的URL
 *  @pram   delegate        :请求的页面对象
 *  @pram   headerDic       :请求头
 *  @pram   param           :请求参数
 *  @pram   fileData        :上传的data
 *  @pram   requestMethod   :请求方法
 *  @pram   progress        :下载、上传进度的回调块
 *  @pram   success         :成功的回调块
 *  @pram   failure         :失败的回调块
 *  @pram   tag             :每个请求的标志，tag
 *
 **/
- (void)requestUrl:(NSString *)url
          delegate:(id)delegate
           headers:(NSDictionary *)headerDic
             param:(NSDictionary *)param
          fileData:(NSData *)fileData
 withRequestMethod:(HttpRequestMethod)method
          progress:(void(^)(NSUInteger bytesWritten,
                            long long totalBytes,
                            long long totalBytesExpected)
                    )progress
           success:(void(^)(id resultObj))success
           failure:(void(^)(id error))failure
           withTag:(NSInteger)tag
;

// 取消请求
//- (void)cancelRequest:(NSInteger)tag;
//- (void)cancelRequest:(AFHTTPRequestOperation *)operation;

// 取消指定页面的所有请求
- (void)cancelDelegateRequest:(id)obj;

// 取消所有请求
- (void)cancelAllRequest;

@end
