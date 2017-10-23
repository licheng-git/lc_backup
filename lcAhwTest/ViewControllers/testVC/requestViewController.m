//
//  requestViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/10/22.
//  Copyright © 2015年 lc. All rights reserved.
//

#import "requestViewController.h"
#import "KUtils.h"

#import "AFNetworking.h"
/*
 https -> Info.Plist
 + App Transport Security Settings + Allow Arbitrary Loads + YES
 */

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
/*
 1、-fno-objc-arc
 2、libz.tbd
 3、Reachability 重名需删除
*/

@interface requestViewController()<ASIHTTPRequestDelegate>
{
    int _i;
    NSString *_password;
    NSString *_password_md5;
    NSMutableArray *_passwordLib;  // 排列组合生成密码库
    
    AFHTTPRequestOperationManager *_afManager;
    NSString *_urlStr;
    NSMutableDictionary *_dicParams;
}
@end

@implementation requestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"网络请求";
    //[self testHttps];
    [self sendRequest_sys_NSURLSession_get];
}


#pragma mark - 网络请求 afn2

- (void)sendRequest_afn2_get
{
    AFHTTPRequestOperationManager *afManager = [AFHTTPRequestOperationManager manager];
    
    afManager.requestSerializer = [AFJSONRequestSerializer serializer];
    afManager.responseSerializer = [AFJSONResponseSerializer serializer];
    [afManager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css", @"text/plain", nil]];  // 设置可接收数据类型
    
    [afManager.requestSerializer setValue:@"fc85a7ce091aea86ef3463b9166e9b06" forHTTPHeaderField:@"AhwApi-Access-Token"];  // 添加请求头 基础认证
    [afManager.requestSerializer setValue:@"" forHTTPHeaderField:@"Version"];  // app版本号
    [afManager.requestSerializer setValue:@"" forHTTPHeaderField:@"Client"];  // 客户端操作系统
    [afManager.requestSerializer setValue:@"" forHTTPHeaderField:@"DeviceToken"];  // 消息推送DeviceToken
    
    NSString *urlStr = @"http://119.147.82.70:7771/api/Invest/List?page=2";
    
    AFHTTPRequestOperation *afOperation =
    [afManager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"获取成功 %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"获取失败");
    }];
    
    //[afOperation waitUntilFinished];  // 同步
}

- (void)sendRequest_afn2_post
{
    AFHTTPRequestOperationManager *afManager = [[AFHTTPRequestOperationManager alloc] init];
    
    afManager.requestSerializer = [AFJSONRequestSerializer serializer];
    afManager.responseSerializer = [AFJSONResponseSerializer serializer];
    [afManager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css", @"text/plain", nil]];  // 设置可接收数据类型
    
    [afManager.requestSerializer setValue:@"fc85a7ce091aea86ef3463b9166e9b06" forHTTPHeaderField:@"AhwApi-Access-Token"];  // 添加请求头 基础认证
    [afManager.requestSerializer setValue:@"" forHTTPHeaderField:@"Version"];  // app版本号
    [afManager.requestSerializer setValue:@"" forHTTPHeaderField:@"Client"];  // 客户端操作系统
    [afManager.requestSerializer setValue:@"" forHTTPHeaderField:@"DeviceToken"];  // 消息推送DeviceToken
    
    NSString *urlStr = @"http://119.147.82.70:7771/api/account/login";
    
    NSMutableDictionary *dicParams = [[NSMutableDictionary alloc] init];
    [dicParams setObject:@"licheng0" forKey:@"Acc"];
    _password = @"123456";
    _password_md5 = [KUtils md5:_password];
    [dicParams setObject:_password_md5 forKey:@"Pass"];
    
    
    [afManager POST:urlStr parameters:dicParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode != 200)
        {
            NSLog(@"success 网络或服务器异常");
        }
        else
        {
            NSInteger responseStatus = [[responseObject objectForKey:@"ResponseStatus"] integerValue];
            if (responseStatus != 0)
            {
                NSLog(@"登陆失败");
            }
            else
            {
                NSLog(@"登陆成功");
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"failure 网络或服务器异常");
        
    }];
}


#pragma mark - 网络请求 afn3

- (void)sendRequest_afn3
{
    // 没有同步，只有异步
    //AFHTTPSessionManager *afManager = [AFHTTPSessionManager manager];
}


#pragma mark - 网络请求 系统NSURLConnection

- (void)sendRequest_sys_NSURLConnection_get
{
    NSString *urlStr = @"http://119.147.82.70:7771/api/Invest/List?page=2";
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"fc85a7ce091aea86ef3463b9166e9b06" forHTTPHeaderField:@"AhwApi-Access-Token"];
    [request setValue:@"" forHTTPHeaderField:@"Version"];
    [request setValue:@"" forHTTPHeaderField:@"Client"];
    [request setValue:@"" forHTTPHeaderField:@"DeviceToken"];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [request setTimeoutInterval:5.0];
    
//    NSError *connectionError = nil;
//    NSURLResponse *response = nil;
//    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
//    NSLog(@"response = %@ \n data = %@ \n err = %@", response, data, connectionError);
//    NSString *responseDataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"responseDataStr = %@", responseDataStr);
    
    //NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSLog(@"response = %@ \n data = %@ \n err = %@", response, data, connectionError);
        NSString *responseDataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"responseDataStr = %@", responseDataStr);
    }];
}

- (void)sendRequest_sys_NSURLConnection_post
{
    // post提交 （系统的是form格式；AFNetworking是json格式 *_* ?）
    NSString *urlStr = @"http://119.147.82.70:7771/api/account/login";
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setValue:@"fc85a7ce091aea86ef3463b9166e9b06" forHTTPHeaderField:@"AhwApi-Access-Token"];
    [request setValue:@"" forHTTPHeaderField:@"Version"];
    [request setValue:@"" forHTTPHeaderField:@"Client"];
    [request setValue:@"" forHTTPHeaderField:@"DeviceToken"];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];  // 设置缓存策略
    [request setTimeoutInterval:5.0];  // 设置超时
    
//    NSDictionary *properties1 = [[NSMutableDictionary alloc] init];
//    [properties1 setValue:@"" forKey:NSHTTPCookieValue];
//    [properties1 setValue:@"token" forKey:NSHTTPCookieName];
//    [properties1 setValue:@".allseeing-i.com" forKey:NSHTTPCookieDomain];
//    [properties1 setValue:@"/http-request/tests" forKey:NSHTTPCookiePath];
//    [properties1 setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
//    NSHTTPCookie *cookie1 = [[NSHTTPCookie alloc] initWithProperties:properties1];
//    NSDictionary *properties2 = @{
//                                  NSHTTPCookieValue : @"",
//                                  NSHTTPCookieName : @"uuid",
//                                  NSHTTPCookieDomain : @".allseeing-i.com",
//                                  NSHTTPCookiePort : @"/http-request/tests",
//                                  NSHTTPCookieExpires : [NSDate dateWithTimeIntervalSinceNow:60*60]
//                                };
//    NSHTTPCookie *cookie2 = [[NSHTTPCookie alloc] initWithProperties:properties2];
//    NSMutableArray *cookies = [NSMutableArray arrayWithObjects:cookie1,cookie2, nil];
//    //[asiRequest setRequestCookies:cookies];
//    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie1];
//    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie2];
//    //[request setHTTPShouldHandleCookies:YES];
//    //[request setValue:@"cName=cValue" forHTTPHeaderField:@"Cookie"];
    
    [request setHTTPMethod:@"POST"];
    //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  // 表单
    //[request setValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Accept"];  // json
    //[request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];  // 二进制流
    NSMutableData *requestData = [NSMutableData data];
    //[requestData appendData:[@"Acc=licheng0" dataUsingEncoding:NSUTF8StringEncoding]];
    //[requestData appendData:[@"&Pass=e10adc3949ba59abbe56e057f20f883e" dataUsingEncoding:NSUTF8StringEncoding]];
    [requestData appendData:[@"Acc=licheng0&Pass=e10adc3949ba59abbe56e057f20f883e" dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:requestData];
    
//    // 同步
//    NSError *connectionError = nil;
//    NSURLResponse *response = nil;
//    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
//    NSLog(@"response = %@ \n data = %@ \n err = %@", response, data, connectionError);
//    NSString *responseDataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"responseDataStr = %@", responseDataStr);
    
    // 异步
    //NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSLog(@"response = %@ \n data = %@ \n err = %@", response, data, connectionError);
        NSString *responseDataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"responseDataStr = %@", responseDataStr);
//        // 获取cookie
//        //NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:fields forURL:url];
//        //NSString *cookieString = [[HTTPResponse allHeaderFields] valueForKey:@"Set-Cookie"];
//        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//        for (NSHTTPCookie *cookie in cookieStorage.cookies) {
//            NSLog(@"cookie%@", cookie);
//        }
    }];

}


#pragma mark - 网络请求 系统NSURLSession

- (void)sendRequest_sys_NSURLSession_get
{
    NSString *urlStr = @"http://119.147.82.70:7771/api/Invest/List?page=2";
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"fc85a7ce091aea86ef3463b9166e9b06" forHTTPHeaderField:@"AhwApi-Access-Token"];
    [request setValue:@"" forHTTPHeaderField:@"Version"];
    [request setValue:@"" forHTTPHeaderField:@"Client"];
    [request setValue:@"" forHTTPHeaderField:@"DeviceToken"];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [request setTimeoutInterval:5.0];
    
//    // 异步
//    NSURLSessionDataTask *task =
//    [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSLog(@"response = %@ \n data = %@ \n err = %@", response, data, error);
//        NSString *responseDataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"responseDataStr = %@", responseDataStr);
//    }];
//    [task resume];
//    NSLog(@"task = %@", task);
    
    // 同步
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    NSCondition *condition = [[NSCondition alloc] init];
    __block NSString *responseDataStr__block;
    NSURLSessionDataTask *task =
    [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"block*_* response = %@ \n data = %@ \n err = %@", response, data, error);
        NSString *responseDataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"block*_* responseDataStr = %@", responseDataStr);
        
        dispatch_semaphore_signal(semaphore);  // 先执行wait之后的代码，在执行signal本身下面的代码
//        [condition lock];
//        [condition signal];
//        [condition unlock];
        responseDataStr__block = responseDataStr;  // *_*写在之后没用
        
        if (error) {
            NSLog(@"%@", error);
            //NSLog(@"请求失败： %@", error.userInfo[@"NSErrorFailingURLStringKey"]);
            NSLog(@"请求失败代码：%li", (long)error.code);
            NSLog(@"请求失败提示：%@", error.localizedDescription);
        }
        else {
            //NSLog(@"请求成功： %@", response.URL);
            NSLog(@"请求成功状态码： %li", ((NSHTTPURLResponse *)response).statusCode);
        }
        
    }];
    [task resume];
    NSLog(@"main*_* task = %@", task);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    [condition lock];
//    [condition wait];
//    [condition unlock];
    NSLog(@"main*_* responseDataStr = %@", responseDataStr__block);
    NSLog(@"请求地址： %@", task.currentRequest.URL);
}

- (void)sendRequest_sys_NSURLSession_post
{
    NSString *urlStr = @"http://119.147.82.70:7771/api/account/login";
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"fc85a7ce091aea86ef3463b9166e9b06" forHTTPHeaderField:@"AhwApi-Access-Token"];
    [request setValue:@"" forHTTPHeaderField:@"Version"];
    [request setValue:@"" forHTTPHeaderField:@"Client"];
    [request setValue:@"" forHTTPHeaderField:@"DeviceToken"];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [request setTimeoutInterval:5.0];
    
    [request setHTTPMethod:@"POST"];
    NSMutableData *requestData = [NSMutableData data];
    [requestData appendData:[@"Acc=licheng0&Pass=e10adc3949ba59abbe56e057f20f883e" dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:requestData];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"response = %@ \n data = %@ \n err = %@", response, data, error);
        NSString *responseDataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"responseDataStr = %@", responseDataStr);
    }];
    [task resume];
    NSLog(@"task = %@", task);
}

// 有空继续看 http ://www.jianshu.com/p/02a5a896c9ed


#pragma mark - 网络请求 asi

- (void)sendRequest_asi_get
{
    NSString *urlStr = @"http://119.147.82.70:7771/api/Invest/List?page=2";
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    //[request setRequestMethod:@"GET"];
    //[request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"AhwApi-Access-Token" value:@"fc85a7ce091aea86ef3463b9166e9b06"];
    [request addRequestHeader:@"Version" value:@""];
    [request addRequestHeader:@"Client" value:@""];
    [request addRequestHeader:@"DeviceToken" value:@""];
    
//    // 同步
//    [request startSynchronous];
//    NSError *err = [request error];
//    if (err)
//    {
//        NSLog(@"%@", err);
//        return;
//    }
//    NSString *respStr = [request responseString];
//    NSLog(@"%@", respStr);
    
    // 异步
    request.delegate = self;
    [request startAsynchronous];
//    //request.didFinishSelector = @selector();
//    //request.didFailSelector = @selector();
//    //__block request
//    [request setFailedBlock:^{
//        NSLog(@"block.requestFailed *_* %@", [request error]);
//    }];
//    [request setCompletionBlock:^{
//        NSLog(@"block.requestFinished *_* %@", [request responseString]);
//    }];
}

- (void)sendRequest_asi_post
{
    NSString *urlStr = @"http://119.147.82.70:7771/api/account/login";
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //request.requestMethod = @"POST";
    [request addRequestHeader:@"AhwApi-Access-Token" value:@"fc85a7ce091aea86ef3463b9166e9b06"];
    [request addRequestHeader:@"Version" value:@""];
    [request addRequestHeader:@"Client" value:@""];
    [request addRequestHeader:@"DeviceToken" value:@""];
    [request setPostValue:@"licheng0" forKey:@"Acc"];
    [request setPostValue:@"e10adc3949ba59abbe56e057f20f883e" forKey:@"Pass"];
//    // 同步
//    [request startSynchronous];
//    NSError *err = [request error];
//    if (err)
//    {
//        NSLog(@"err=%@", err);
//        return;
//    }
//    NSString *respStr = [request responseString];
//    NSLog(@"respStr=%@", respStr);
    // 异步
    request.delegate = self;
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
//    NSString *respStr = [request responseString];
//    NSData *respData = [request responseData];
//    NSDictionary *respHeaders = [request responseHeaders];
    NSLog(@"delegate.requestFinished *_* %@", [request responseString]);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"delegate.requestFailed *_* %@", [request error]);
}


#pragma mark - SSL/TSL https

- (void)testHttps
{
    // afn
    AFHTTPRequestOperationManager *afManager = [AFHTTPRequestOperationManager manager];
    //AFHTTPSessionManager *afManager = [AFHTTPSessionManager manager];
    afManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    afManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [afManager.requestSerializer setTimeoutInterval:20];
    
//    // 安合网
//    NSString *urlStr = @"https://api.anhewang.com/api/Invest/List?page=2";
//    [afManager.requestSerializer setValue:@"fc85a7ce091aea86ef3463b9166e9b06" forHTTPHeaderField:@"AhwApi-Access-Token"];
//    [afManager.requestSerializer setValue:@"" forHTTPHeaderField:@"Version"];
//    [afManager.requestSerializer setValue:@"" forHTTPHeaderField:@"Client"];
//    [afManager.requestSerializer setValue:@"" forHTTPHeaderField:@"DeviceToken"];
    
    // 迷雾电子竞技社交平台
    //NSString *urlStr = @"https://sep.miwutech.com/v1/news/guest/timeline?level=all&offset=0";
    NSString *urlStr = @"https://sep.miwutech.com/v1/login/account?account=licheng&password=cbc024507579094bedd1552548d1d5bb&appid=sep_mobile&channel=0&imei=770248A7-56C8-4471-A1D5-1F73E79EB187&model=iPod%20touch%206&ostp=2&osv=9.3.4";
    afManager.securityPolicy.allowInvalidCertificates = YES;
    afManager.securityPolicy.validatesDomainName = NO;
    
    [afManager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"成功 %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"请求返回状态码：%li", (long)operation.response.statusCode);
        NSLog(@"失败 %@", error);
    }];
}

@end

