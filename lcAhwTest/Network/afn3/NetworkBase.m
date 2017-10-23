//
//  NetworkBase.m
//  mobaxx
//
//  Created by licheng on 16/5/27.
//  Copyright © 2016年 billnie. All rights reserved.
//

#import "NetworkBase.h"
#import "Reachability.h"

@interface NetworkBase()
{
    AFHTTPSessionManager  *_afManager;
    //NSRecursiveLock       *_rLock;      // 递归锁
    Reachability          *_hostReach;  // 网络状态
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

- (id)init {
    self = [super init];
    if (self) {
        _afManager = [AFHTTPSessionManager manager];
        _afManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _afManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _afManager.requestSerializer.timeoutInterval = 30;
        _afManager.securityPolicy.allowInvalidCertificates = YES;
        _afManager.securityPolicy.validatesDomainName = NO;
        //_rLock = [[NSRecursiveLock alloc] init];
        _hostReach = [Reachability reachabilityForInternetConnection];
        [_hostReach startNotifier];
    }
    return self;
}

// 基本网络请求，与业务无关
- (void)requestUrl:(NSString *)urlStr
           headers:(NSDictionary *)headersDic
           cookies:(NSString *)cookiesStr
            params:(NSDictionary *)paramsDic
          fileData:(NSData *)fileData
            method:(HttpMethod)method
          progress:(void (^)(NSProgress *progressObj))progress
           success:(void (^)(id responseObject))success
           failure:(void (^)(id error))failure {
    
    // 检查网络
//    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        NSLog(@"网络状态：%li", status);
//    }];
//    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
//    NSLog(@"网络状态：%li", [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus);  // block导致第一次请求状态为-1(unknown)
//    if(![AFNetworkReachabilityManager sharedManager].isReachable) {
//        failure ? failure(@"网络异常，请检查网络连接") : nil;
//        return;
//    }
    NSLog(@"网络状态：%li", _hostReach.currentReachabilityStatus);
    if (!_hostReach.isReachable) {
        failure ? failure(@"网络异常，请检查网络连接") : nil;
        return;
    }
    
    //[_rLock lock];  // 加锁
    
    // 设置cookies
    if (cookiesStr) {
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
        [_afManager GET:urlStr parameters:paramsDic progress:^(NSProgress * _Nonnull downloadProgress) {
            progress ? progress(downloadProgress) : nil;
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self handleRequest:task.response result:responseObject completionBlock:success];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequest:task.response result:error completionBlock:failure];
        }];
    }
    
    else if (method == HttpMethodDelete) {
        [_afManager DELETE:urlStr parameters:paramsDic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self handleRequest:task.response result:responseObject completionBlock:success];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequest:task.response result:error completionBlock:failure];
        }];
    }
    
//    else if (method == HttpMethodPost) {
//        [_afManager POST:urlStr parameters:paramsDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//            if (fileData) {
//                //[formData appendPartWithFileData:fileData name:@"n" fileName:@"fn" mimeType:@"mt"];
//            }
//        } progress:^(NSProgress * _Nonnull uploadProgress) {
//            progress ? progress(uploadProgress) : nil;
//        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            [self handleRequest:task.response result:responseObject completionBlock:success];
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            [self handleRequest:task.response result:error completionBlock:failure];
//        }];
//    }
//    
//    else if (method == HttpMethodPut) {
//        [_afManager PUT:urlStr parameters:paramsDic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            [self handleRequest:task.response result:responseObject completionBlock:success];
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            [self handleRequest:task.response result:error completionBlock:failure];
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
                [request setValue:@"application/json;" forHTTPHeaderField:@"Content-Type"];
                //[request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
            }
            [requestData appendData:fileData];
        }
        if (paramsDic) {
            if (!bBusinessHeader) {
                [request setValue:@"application/x-www-form-urlencoded;" forHTTPHeaderField:@"Content-Type"];
            }
            NSMutableString *paramsStr = [[NSMutableString alloc] init];
            for (NSString *key in paramsDic) {
                [paramsStr appendFormat:@"%@=%@&", key, [paramsDic valueForKey:key]];
            }
            NSString *str = [paramsStr substringWithRange: NSMakeRange(0, paramsStr.length-1)];
            [requestData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [request setHTTPBody:requestData];
        
        NSURLSessionDataTask *task =
        [_afManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (!error) {
                [self handleRequest:response result:responseObject completionBlock:success];
            }
            else {
                [self handleRequest:response result:error completionBlock:failure];
            }
        }];
        [task resume];
    }
    
    //[_rLock unlock];  // 解锁

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

