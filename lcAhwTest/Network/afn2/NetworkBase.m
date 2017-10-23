//
//  NetworkBase.m
//  mobaxx
//
//  Created by licheng on 16/5/27.
//  Copyright © 2016年 billnie. All rights reserved.
//

#import "NetworkBase.h"

@interface NetworkBase()
{
    AFHTTPRequestOperationManager *_afManager;
    //NSRecursiveLock *_rLock;  // 递归锁
}
@end

@implementation NetworkBase

+ (NetworkBase *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _afManager = [AFHTTPRequestOperationManager manager];
        _afManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _afManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _afManager.operationQueue.maxConcurrentOperationCount = 5;
        //_rLock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

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
           failure:(void (^)(id error))failure
{
//    // 检查网络是否可用
//    if () {
//        failure ? failure(@"网络异常，请检查网络连接") : nil;
//        return;
//    }
    
    //[_rLock lock];  // 加锁
    
    // 设置cookies
    if (cookiesStr) {
        //[_afManager.requestSerializer setHTTPShouldHandleCookies:YES];
        [_afManager.requestSerializer setValue:cookiesStr forHTTPHeaderField:@"Cookie"];
    }
    
    // 添加请求头
    if (headersDic) {
        for (NSString *key in headersDic) {
            [_afManager.requestSerializer setValue:[headersDic objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    // 根据方法发送请求
    if (method == HttpMethodGet) {
        // 获取
        AFHTTPRequestOperation *afOperation =
        [_afManager GET:urlStr
           parameters:paramsDic
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if (bAsync) {  // 异步请求执行回调
                      [self handleRequestResult:operation result:responseObject withCompletionBlock:success];
                  }
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  if (bAsync) {
                      [self handleRequestResult:operation result:error withCompletionBlock:failure];
                  }
              }];
        // 下载进度
        if (progress) {
            [afOperation setDownloadProgressBlock:^(NSUInteger bytesRead,
                                                    long long totalBytesRead,
                                                    long long totalBytesExpectedToRead) {
                progress(bytesRead, totalBytesExpectedToRead, totalBytesExpectedToRead);
            }];
        }
        // 同步请求更改回调执行顺序
        if (!bAsync) {
            [afOperation waitUntilFinished];
            if (afOperation.response.statusCode == 200) {
                [self handleRequestResult:afOperation result:afOperation.responseObject withCompletionBlock:success];
            }
            else {
                [self handleRequestResult:afOperation result:afOperation.responseObject withCompletionBlock:failure];
            }
        }
    }
//    else if (method == HttpMethodPost) {
//        // 提交
//        AFHTTPRequestOperation *afOperation =
//        [_afManager POST:urlStr parameters:paramsDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//            if (fileData) {
//                [formData appendPartWithFileData:fileData name:@"n" fileName:@"fn" mimeType:@"application/json; encoding=utf-8"];
//            }
//        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            [self handleRequestResult:operation result:responseObject withCompletionBlock:success];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [self handleRequestResult:operation result:error withCompletionBlock:failure];
//        }];
//    }
//    else if (method == HttpMethodPut) {
//        AFHTTPRequestOperation *afOperation =
//        [_afManager PUT:urlStr parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            [self handleRequestResult:operation result:responseObject withCompletionBlock:success];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [self handleRequestResult:operation result:error withCompletionBlock:failure];
//        }];
//    }
    
    else if (method == HttpMethodPost || method == HttpMethodPut) {
        
        NSURL *url = [[NSURL alloc] initWithString:urlStr];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        
        if (method == HttpMethodPost) {
            [request setHTTPMethod:@"POST"];
        }
        else if (method == HttpMethodPut) {
            [request setHTTPMethod:@"PUT"];
        }
        
        if (cookiesStr) {
            [request setValue:cookiesStr forHTTPHeaderField:@"Cookie"];
        }
        
        BOOL bBusinessHeader = NO;  // 业务层如自定义了Content-Type要避免覆盖
        if (headersDic) {
            for (NSString *key in headersDic) {
                [request setValue:[headersDic objectForKey:key] forHTTPHeaderField:key];
                if ([key isEqualToString:@"Content-Type"]) {
                    bBusinessHeader = YES;
                }
            }
        }
        
        NSMutableData *requestData = [NSMutableData data];
        if (fileData) {
            if (!bBusinessHeader) {
                [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
                //[request setValue:@"application/json;" forHTTPHeaderField:@"Content-Type"];
            }
            [requestData appendData:fileData];
        }
        if (paramsDic) {
            if (!bBusinessHeader) {
                [request setValue:@"application/x-www-form-urlencoded;" forHTTPHeaderField:@"Content-Type"];
            }
            NSMutableString *paramsStr = [[NSMutableString alloc] init];
            for (NSString *key in paramsDic) {
                [paramsStr appendFormat:@"%@=%@&", key, [paramsDic objectForKey:key]];
            }
            NSString *str = [paramsStr substringWithRange: NSMakeRange(0, paramsStr.length-1)];
            [requestData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [request setHTTPBody:requestData];
        
        AFHTTPRequestOperation *afOperation =
        [_afManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (bAsync) {
                [self handleRequestResult:operation result:responseObject withCompletionBlock:success];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (bAsync) {
                [self handleRequestResult:operation result:error withCompletionBlock:failure];
            }
        }];
        [_afManager.operationQueue addOperation:afOperation];
        if (progress) {
            [afOperation setUploadProgressBlock:^(NSUInteger bytesWritten,
                                                  long long totalBytesWritten,
                                                  long long totalBytesExpectedToWrite) {
                progress(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
            }];
        }
        if (!bAsync) {
            [afOperation waitUntilFinished];
            if (afOperation.response.statusCode == 200) {
                [self handleRequestResult:afOperation result:afOperation.responseObject withCompletionBlock:success];
            }
            else {
                [self handleRequestResult:afOperation result:afOperation.error withCompletionBlock:failure];
            }
        }
    }
    
    //[_rLock unlock];  // 解锁

}

// 初步处理请求结果
- (void)handleRequestResult:(AFHTTPRequestOperation *)operation
                     result:(id)responseObject
        withCompletionBlock:(void(^)(id))completionBlock
{
    NSLog(@"请求地址：%@", operation.request.URL);
    NSLog(@"请求返回状态码：%li", (long)operation.response.statusCode);
    //NSLog(@"请求返回string数据：%@", operation.responseString);
    //NSLog(@"请求返回data数据：%@", operation.responseData);
    
    if (operation.response.statusCode == 200)
    {
        // 请求成功
        NSLog(@"成功返回结果：%@", responseObject);
        // 成功回调
        completionBlock ? completionBlock(responseObject) : nil;
    }
    else
    {
        // 请求失败
        NSError *error = (NSError *)responseObject;
        NSLog(@"请求错误原因：%@", error);
        NSLog(@"请求错误代码：%li", (long)error.code);
        NSLog(@"请求错误日志：%@", error.localizedDescription);
        NSString *msg = nil;
        switch (error.code)
        {
            case NSURLErrorCannotConnectToHost:
            {
                msg = @"服务器连接失败，请稍后重试！";
                break;
            }
            case NSURLErrorTimedOut:
            {
                msg = @"网络繁忙，请稍后重试！";
                break;
            }
            default:
            {
                msg = @"请求失败";
                break;
            }
        }
        // 失败回调
        completionBlock ? completionBlock(msg) : nil;
    }
}

@end
