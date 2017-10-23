//
//  HttpClient.m
//  lcAhwTest
//
//  Created by licheng on 15/4/14.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "HttpClient.h"

@interface HttpClient ()
{
    NSRecursiveLock *_fLock;  // 递归锁，多次调用不会阻塞已获取该锁的线程
    NSRecursiveLock *_cancelLock;
}
@end

@implementation HttpClient
{
    AFHTTPRequestOperationManager *_manager;
    NSMutableDictionary *_requestRecords;
}

+ (HttpClient *)sharedInstance
{
    // 单例
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
    if (self)
    {
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.operationQueue.maxConcurrentOperationCount = 4;
        _requestRecords = [NSMutableDictionary dictionary];
    }
    return self;
}

// 开始发送请求
-(void)requestUrl:(NSString *)url
         delegate:(id)delegate
          headers:(NSDictionary *)headerDic
            param:(NSDictionary *)param
         fileData:(NSData *)fileData
withRequestMethod:(HttpRequestMethod)method
         progress:(void (^)(NSUInteger bytesWritten,
                            long long totalBytes,
                            long long totalBytesExpected)
                   )progress
          success:(void (^)(id resultObj))success
          failure:(void (^)(id error))failure
          withTag:(NSInteger)tag
{
    
    HttpBaseRequest *request = [[HttpBaseRequest alloc] init];
    request.delegate = delegate;
    request.url = url;
    request.headers = headerDic;
    request.param = param;
    request.fileData = fileData;
    request.method = method;
    request.tag = tag;
    
//    //检查网络是否可用
//    if (![KUtils isConnectionAvailable])
//    {
//        failure ? failure(@"网络异常，请检查网络连接") : nil;
//        return;
//    }
    
    // 递归锁
    [_fLock lock];
    
    // 序列化request
//    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    // 默认，返回json（字典）
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // 设置可接收数据类型
    [_manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css", @"text/plain", nil]];
    // multipart/form-data  application/octet-stream  二进制流格式
    
    // 添加请求头
    if (headerDic && ![headerDic isKindOfClass:[NSNull class]])
    {
        for (NSString *key in headerDic)
        {
            [_manager.requestSerializer setValue:[headerDic objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    // 根据方法发送请求
    if (method == HttpRequestMethodGet)
    {
        request.afOperation = [_manager GET:url
                              parameters:param
                                 success:^(AFHTTPRequestOperation *operation, id resultObj){
                                     
                                     /*[self handleRequestResult:operation result:resultObj];
                                     if (success)
                                     {
                                         success(resultObj);
                                     }*/
                                     [self handleRequestResult:operation result:resultObj withCompletionBlock:success];
                                     
                                 }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                     
                                     /*[self handleRequestResult:operation result:error];
                                     if (failure)
                                     {
                                         failure(error);
                                     }*/
                                     [self handleRequestResult:operation result:error withCompletionBlock:failure];
                                     
                                 }];
        // 获取、下载 进度
        [request.afOperation setDownloadProgressBlock:^(NSUInteger bytesRead,
                                                     long long totalBytesRead,
                                                     long long totalBytesExpectedToRead){
            if (progress)
            {
                progress(bytesRead, totalBytesExpectedToRead, totalBytesExpectedToRead);
            }
        }];
    }
    else if (method == HttpRequestMethodPost)
    {
        request.afOperation = [_manager POST:url
                               parameters:param
                                  success:^(AFHTTPRequestOperation *operation, id resultObj){
                                      
                                      [self handleRequestResult:operation result:resultObj withCompletionBlock:success];
                                      
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                      
                                      [self handleRequestResult:operation result:error withCompletionBlock:failure];
                                      
                                  }];
        // 提交进度
        [request.afOperation setUploadProgressBlock:^(NSUInteger bytesWritten,
                                                   long long totalBytesWritten,
                                                   long long totalBytesExpectedToWrite){
            if (progress)
            {
                progress(bytesWritten, totalBytesExpectedToWrite, totalBytesExpectedToWrite);
            }
        }];
    }
    else if (method == HttpRequestMethodPostFileData)
    {
        request.afOperation = [_manager POST:url
                               parameters:param
                constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
                    
                    [formData appendPartWithFileData:fileData name:@"file" fileName:@"image" mimeType:@""];
                    
                }
                                  success:^(AFHTTPRequestOperation *operation, id resultObj){
                                      
                                      [self handleRequestResult:operation result:resultObj withCompletionBlock:success];
                                      
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                      
                                      [self handleRequestResult:operation result:error withCompletionBlock:failure];
                                      
                                  }];
        // 上传进度
        [request.afOperation setUploadProgressBlock:^(NSUInteger bytesWritten,
                                                   long long totalBytesWritten,
                                                   long long totalBytesExpectedToWrite){
            if (progress)
            {
                progress(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
            }
        }];
    }
    
    // 将请求加入操作队列
    [self addOperation:request];
    
    // 解锁
    [_fLock unlock];
    
}

// 初步处理请求结果
- (void)handleRequestResult:(AFHTTPRequestOperation *)operation
                     result:(id)resultObj
        withCompletionBlock:(void(^)(id))completionBlock
{
//    NSString *key = [self requestHashKey:operation];
//    AFHTTPRequestOperation *requestOperation = _requestRecords[key];
//    if (requestOperation)
    
    NSLog(@"请求地址：%@", operation.request.URL);
    NSLog(@"请求返回状态码：%li", (long)operation.response.statusCode);
    //NSLog(@"请求返回数据：%@", operation.responseString);
    
//    // 获取响应头
//    NSDictionary *respHeaderDic = operation.response.allHeaderFields;
    
    if(operation.response.statusCode == 200)
    {
        // 请求成功
        NSLog(@"成功返回结果：%@", resultObj);
        
        // 成功回调
        completionBlock ? completionBlock(resultObj) : nil;
    }
    else
    {
        // 请求失败
        NSError *error = (NSError *)resultObj;
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
    
    [self removeOperation:operation];
}

// 获取队列中的请求的key
- (NSString *)requestHashKey:(AFHTTPRequestOperation *)operation
{
    NSString *key = [NSString stringWithFormat:@"%lu",(unsigned long)[operation hash]];
    return key;
}

// 将请求加入队列
//- (void)addOperation:(AFHTTPRequestOperation *)operation
- (void)addOperation:(HttpBaseRequest *)request
{
    if (request.afOperation !=nil)
    {
        NSString *key = [self requestHashKey:request.afOperation];
        if (key)
        {
            _requestRecords[key] = request;
        }
    }
}

// 移除请求
- (void)removeOperation:(AFHTTPRequestOperation *)operation
{
    NSString *key = [self requestHashKey:operation];
    if (key)
    {
        [_requestRecords removeObjectForKey:key];
    }
}


// 取消请求
- (void)cancelRequest:(AFHTTPRequestOperation *)operation
{
    [_cancelLock lock];
    
    [operation cancel];
    [self removeOperation:operation];
    // clearCompletionBlock ?
    
    [_cancelLock unlock];
}

// 取消全部请求
- (void)cancelAllRequest
{
    [_cancelLock lock];
    NSDictionary *copyRecords = [_requestRecords copy];
    for (NSString *key in copyRecords.allKeys)
    {
        HttpBaseRequest *request = copyRecords[key];
        if (request)
        {
            [request.afOperation cancel];
            [self removeOperation:request.afOperation];
            // [request clearCompletionBlock];
        }
    }
    [_cancelLock unlock];
}


// 取消指定页面的所有请求
- (void)cancelDelegateRequest:(id)obj
{
    [_cancelLock lock];
    NSDictionary *copyRecords = [_requestRecords copy];
    for (NSString *key in copyRecords)
    {
        HttpBaseRequest *request = copyRecords[key];
        if (request && obj && [obj isEqual:request.delegate])
        {
            [request.afOperation cancel];
            [self removeOperation:request.afOperation];
            // [request clearCompletionBlock];
        }
    }
    [_cancelLock unlock];
}

@end
