//
//  NetworkBaseExt.m
//  Base
//
//  Created by licheng on 16/7/7.
//  Copyright © 2016年 billnie. All rights reserved.
//

#import "NetworkBaseExt.h"
#import "Reachability.h"

@interface NetworkBaseExt()
{
    AFHTTPSessionManager  *_afManager;
    NSRecursiveLock       *_fLock;      // 递归锁
    Reachability          *_hostReach;  // 网络状态
}
@end

@implementation NetworkBaseExt

+ (NetworkBaseExt *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _fLock = [[NSRecursiveLock alloc] init];
        _afManager = [AFHTTPSessionManager manager];
        _afManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _afManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [_afManager.requestSerializer setTimeoutInterval:20];
        _hostReach = [Reachability reachabilityForInternetConnection];
        [_hostReach startNotifier];
    }
    return self;
}


// 基础网络请求 GET
- (void)httpGet:(NSString *)urlStr
        headers:(NSDictionary *)headersDic
        cookies:(NSString *)cookiesStr
         params:(NSDictionary *)paramsDic
       progress:(void (^)(NSProgress *progressObj))progress
        success:(void (^)(id responseObject))success
        failure:(void (^)(id error))failure {
    
    NSLog(@"网络状态：%li", _hostReach.currentReachabilityStatus);
    if (!_hostReach.isReachable) {
        failure ? failure(@"网络异常，请检查网络连接") : nil;
        return;
    }
    [_fLock lock];  // 加锁
    if (cookiesStr) {
        [_afManager.requestSerializer setValue:cookiesStr forHTTPHeaderField:@"Cookie"];  // 设置cookies
    }
    if (headersDic) {
        for (NSString *key in headersDic) {
            [_afManager.requestSerializer setValue:[headersDic objectForKey:key] forHTTPHeaderField:key];  // 添加请求头
        }
    }
    [_afManager GET:urlStr parameters:paramsDic progress:^(NSProgress * _Nonnull downloadProgress) {
        progress ? progress(downloadProgress) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleRequest:task.response result:responseObject completionBlock:success];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleRequest:task.response result:error completionBlock:failure];
    }];
    [_fLock unlock];  // 解锁
}


// 基础网络请求 POST
- (void)httpPost:(NSString *)urlStr
         headers:(NSDictionary *)headersDic
         cookies:(NSString *)cookiesStr
          params:(NSDictionary *)paramsDic
        fileData:(NSData *)fileData
        progress:(void (^)(NSProgress *progressObj))progress
         success:(void (^)(id responseObject))success
         failure:(void (^)(id error))failure {
    NSLog(@"网络状态：%li", _hostReach.currentReachabilityStatus);
    if (!_hostReach.isReachable) {
        failure ? failure(@"网络异常，请检查网络连接") : nil;
        return;
    }
    [_fLock lock];
    if (cookiesStr) {
        [_afManager.requestSerializer setValue:cookiesStr forHTTPHeaderField:@"Cookie"];
    }
    if (headersDic) {
        for (NSString *key in headersDic) {
            [_afManager.requestSerializer setValue:[headersDic objectForKey:key] forHTTPHeaderField:key];
        }
    }
    [_afManager POST:urlStr parameters:paramsDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //if (fileData) {
        //    //[formData appendPartWithFileData:fileData name:@"n" fileName:@"fn" mimeType:@"mt"];
        //}
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress ? progress(uploadProgress) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleRequest:task.response result:responseObject completionBlock:success];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleRequest:task.response result:error completionBlock:failure];
    }];
    [_fLock unlock];
}


// 基础网络请求 PUT
- (void)httpPut:(NSString *)urlStr
        headers:(NSDictionary *)headersDic
        cookies:(NSString *)cookiesStr
       fileData:(NSData *)fileData
        success:(void (^)(id responseObject))success
        failure:(void (^)(id error))failure {
    NSLog(@"网络状态：%li", _hostReach.currentReachabilityStatus);
    if (!_hostReach.isReachable) {
        failure ? failure(@"网络异常，请检查网络连接") : nil;
        return;
    }
    [_fLock lock];
    if (cookiesStr) {
        [_afManager.requestSerializer setValue:cookiesStr forHTTPHeaderField:@"Cookie"];
    }
    if (headersDic) {
        for (NSString *key in headersDic) {
            [_afManager.requestSerializer setValue:[headersDic objectForKey:key] forHTTPHeaderField:key];
        }
    }
    [_afManager PUT:urlStr parameters:fileData success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleRequest:task.response result:responseObject completionBlock:success];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleRequest:task.response result:error completionBlock:failure];
    }];
    [_fLock unlock];
}


// 基础网络请求 DELETE
- (void)httpDelete:(NSString *)urlStr
           headers:(NSDictionary *)headersDic
           cookies:(NSString *)cookiesStr
            params:(NSDictionary *)paramsDic
           success:(void (^)(id responseObject))success
           failure:(void (^)(id error))failure {
    NSLog(@"网络状态：%li", _hostReach.currentReachabilityStatus);
    if (!_hostReach.isReachable) {
        failure ? failure(@"网络异常，请检查网络连接") : nil;
        return;
    }
    [_fLock lock];
    if (cookiesStr) {
        [_afManager.requestSerializer setValue:cookiesStr forHTTPHeaderField:@"Cookie"];
    }
    if (headersDic) {
        for (NSString *key in headersDic) {
            [_afManager.requestSerializer setValue:[headersDic objectForKey:key] forHTTPHeaderField:key];
        }
    }
    [_afManager DELETE:urlStr parameters:paramsDic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleRequest:task.response result:responseObject completionBlock:success];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleRequest:task.response result:error completionBlock:failure];
    }];
    [_fLock unlock];
}


// 初步处理请求结果，打印日志
//- (void)handleRequest:(NSURLSessionDataTask *)task result:(id)respObj completionBlock:(void(^)(id))completionBlock {
- (void)handleRequest:(NSURLResponse *)response result:(id)respObj completionBlock:(void(^)(id))completionBlock {
    
//    NSLog(@"请求地址： %@", response.URL);
//    NSLog(@"请求状态码： %li", ((NSHTTPURLResponse *)response).statusCode);
//    //NSLog(@"请求返回数据：%@", respObj);
    if (![respObj isKindOfClass:[NSError class]]) {
        NSLog(@"请求成功地址： %@", response.URL);
        //NSLog(@"请求成功状态码： %li", ((NSHTTPURLResponse *)response).statusCode);
        NSLog(@"请求成功数据： %@", respObj);
        completionBlock ? completionBlock(respObj) : completionBlock;  // 成功回调
    }
    else {
        NSError *error = (NSError *)respObj;
        NSLog(@"请求失败： %@", error);
        NSLog(@"请求失败地址： %@", error.userInfo[@"NSErrorFailingURLKey"]);
        //NSLog(@"请求失败地址： %@", error.userInfo[NSURLErrorFailingURLErrorKey]);
        //NSLog(@"请求失败状态码 %li", ((NSHTTPURLResponse *)error.userInfo[@"com.alamofire.serialization.response.error.response"]).statusCode);
        NSLog(@"请求失败错误代码：%li", (long)error.code);
        NSLog(@"请求失败提示：%@", error.localizedDescription);
        NSString *msg;
        switch (error.code) {
            case NSURLErrorCannotConnectToHost: {
                msg = @"服务器连接失败，请稍后重试！";
                break;
            }
            case NSURLErrorTimedOut: {
                msg = @"网络繁忙，请稍后重试！";
                break;
            }
            default: {
                msg = @"请求失败";
                break;
            }
        }
        completionBlock ? completionBlock(msg) : nil;  // 失败回调
    }
    
}


@end
