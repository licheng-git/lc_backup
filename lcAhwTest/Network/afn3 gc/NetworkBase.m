//
//  NetworkBase.m
//  GuangCaiJiaoYi
//
//  Created by 李诚 on 16/12/8.
//  Copyright © 2016年 Steven. All rights reserved.
//

#import "NetworkBase.h"
#import "Reachability.h"


@interface NetworkModel : NSObject
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) NSString *url;
@end

@implementation NetworkModel
@end


@interface NetworkBase()
{
    AFHTTPSessionManager  *_afManager;
    Reachability          *_hostReach;    // 网络状态
    //NSRecursiveLock       *_rLock;      // 递归锁
    NSMutableDictionary   *_dictModels;   // 队列记录正在执行的请求 （k:v->task.hash:model）
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
        _afManager.requestSerializer.timeoutInterval = 30;
        _afManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _afManager.securityPolicy.allowInvalidCertificates = YES;
        _afManager.securityPolicy.validatesDomainName = NO;
        _hostReach = [Reachability reachabilityForInternetConnection];
        [_hostReach startNotifier];
        //_rLock = [[NSRecursiveLock alloc] init];
        _dictModels = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// 基本网络请求，与业务无关
- (void)requestUrl:(NSString *)urlStr
           headers:(NSDictionary *)headersDict
           cookies:(NSString *)cookiesStr
            params:(NSDictionary *)paramsDict
          fileData:(NSData *)fileData
            method:(HttpMethod)method
          delegate:(id)delegate
          progress:(void (^)(NSProgress *progressObj))progress
           success:(void (^)(id responseObject))success
           failure:(void (^)(id error))failure {
    
    // 检查网络
//    [[AFNetworkReachabilityManager sharedManager] startMonitoring];  // AppDelegate *_* 第一次err
//    NSLog(@"网络状态：%li", [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus);
//    if(![AFNetworkReachabilityManager sharedManager].isReachable) {
//        failure ? failure(NSLocalizedString(@"網絡異常，請檢查網絡連接", nil)) : nil;
//        return;
//    }
    NSLog(@"网络状态：%li", _hostReach.currentReachabilityStatus);
    if (!_hostReach.isReachable) {
        failure ? failure(NSLocalizedString(@"網絡異常，請檢查網絡連接", nil)) : nil;
        return;
    }
    
    //[_rLock lock];  // 加锁
    
    // 设置cookies
    if (cookiesStr) {
        [_afManager.requestSerializer setValue:cookiesStr forHTTPHeaderField:@"Cookie"];
    }
    
    // 添加请求头
    if (headersDict) {
        for (NSString *key in headersDict) {
            [_afManager.requestSerializer setValue:[headersDict objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    // 根据方法发送请求
    NSURLSessionDataTask *task;
    if (method == HttpMethodGet) {
        task =
        [_afManager GET:urlStr parameters:paramsDict progress:^(NSProgress * _Nonnull downloadProgress) {
            progress ? progress(downloadProgress) : nil;
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self handleRequest:task result:responseObject completionBlock:success];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequest:task result:error completionBlock:failure];
        }];
    }
    
    else if (method == HttpMethodPost && !fileData) {
        task =
         [_afManager POST:urlStr parameters:paramsDict progress:^(NSProgress * _Nonnull uploadProgress) {
            progress ? progress(uploadProgress) : nil;
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self handleRequest:task result:responseObject completionBlock:success];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequest:task result:error completionBlock:failure];
        }];
    }
    
    else if (method == HttpMethodPost && fileData) {
    }
    
    else if (method == HttpMethodPut) {
    }
    
    else if (method == HttpMethodDelete) {
    }
    
    // 队列记录下正在执行的请求
    if (task) {
        NetworkModel *model = [[NetworkModel alloc] init];
        model.task = task;
        model.delegate = delegate;
        model.url = urlStr;
        NSString *key = [NSString stringWithFormat:@"%lu", [task hash]];
        if (key) {
            [_dictModels setValue:model forKey:key];
        }
    }
    
    //[_rLock unlock];  // 解锁

}

// 初步处理请求结果，打印日志
- (void)handleRequest:(NSURLSessionDataTask *)task result:(id)respObj completionBlock:(void(^)(id))completionBlock {
    
    if (![respObj isKindOfClass:[NSError class]]) {
        NSLog(@"请求成功地址： %@", task.response.URL);
        NSLog(@"请求成功数据： %@", respObj);
        completionBlock ? completionBlock(respObj) : completionBlock;  // 成功block回调
    }
    else {
        NSError *error = (NSError *)respObj;
        NSLog(@"请求失败： %@", error);
        NSLog(@"请求失败地址： %@", error.userInfo[@"NSErrorFailingURLKey"]);
        //NSLog(@"请求失败状态码： %li", ((NSHTTPURLResponse *)error.userInfo[@"com.alamofire.serialization.response.error.response"]).statusCode);
        NSLog(@"请求失败错误代码： %li", (long)error.code);
        NSLog(@"请求失败提示： %@", error.localizedDescription);
        NSString *msg;
        switch (error.code) {
            case NSURLErrorCancelled: {
                msg =  NSLocalizedString(@"請求已取消", nil);  // *_*调用取消方法也会执行失败block导致弹框
                break;
            }
            case NSURLErrorCannotConnectToHost: {
                msg =  NSLocalizedString(@"服務器連結失敗，請稍後重識", nil);
                break;
            }
            case NSURLErrorTimedOut: {
                msg = NSLocalizedString(@"網絡繁忙，請稍後重識", nil);
                break;
            }
            default: {
                msg = NSLocalizedString(@"請求失敗", nil);
                break;
            }
        }
        completionBlock ? completionBlock(msg) : nil;  // 失败block回调
    }
    
    // 从队列中移除请求
    //[cancleLock lock];
    NSString *key = [NSString stringWithFormat:@"%lu", [task hash]];
    if (key) {
        [_dictModels removeObjectForKey:key];
    }
    //[cancelLock unlock];
    
}

// 取消指定页面的所有请求
- (void)cancelRequest:(id)obj {
    if (!obj) {
        return;
    }
    //[cancleLock lock];
    for (NSString *key in _dictModels.allKeys) {
        NetworkModel *model = _dictModels[key];
        if (model && model.task && [model.delegate isEqual:obj]) {
            [model.task cancel];
            [_dictModels removeObjectForKey:key];
            NSLog(@"请求取消对象： %@", model.delegate);
            NSLog(@"请求取消地址： %@", model.url);
        }
    }
    //[cancelLock unlock];
}

@end

