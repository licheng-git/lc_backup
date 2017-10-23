//
//  NetworkManagerExt.m
//  Base
//
//  Created by licheng on 16/7/7.
//  Copyright © 2016年 billnie. All rights reserved.
//

#import "NetworkManagerExt.h"
#import "Result.pbobjc.h"
#import <objc/runtime.h>
#import "MBProgressHUD.h"
#import "UserCenterInfo.h"

@interface NetworkManagerExt()
{
    NSString *_urlStr;  // 测试需求，要方便动态改服务器地址
}
@end

@implementation NetworkManagerExt

- (id)init {
    self = [super init];
    if (self) {
        self.bNeedLoadingUI = YES;
        self.bNeedAlertErr = YES;
        self.bPbParse = YES;
    }
    return self;
}


#pragma mark - 公开方法

// 业务层网络请求 GET
- (void)httpGet:(NSString *)urlStr
         params:(NSDictionary *)paramsDic
       targetVC:(UIViewController *)targetVC
        success:(void (^)(id resultObj))success
        failure:(void (^)(id error))failure {
    _urlStr = urlStr;
    [self invokeBegin:targetVC];
    [[NetworkBaseExt sharedInstance] httpGet:_urlStr
                                     headers:self.headersDic
                                     cookies:self.cookiesStr
                                      params:paramsDic
                                    progress:^(NSProgress *progressObj) {
                                        self.progressBlock ? self.progressBlock(progressObj) : nil;
                                    } success:^(id responseObject) {
                                        [self invokeSuccess:responseObject targetVC:targetVC success:success failure:failure];
                                    } failure:^(id error) {
                                        [self invokeFaile:error targetVC:targetVC failure:failure];
                                    }];
}


// 业务层网络请求 POST 提交数据
- (void)httpPost:(NSString *)urlStr
          params:(NSDictionary *)paramsDic
        targetVC:(UIViewController *)targetVC
         success:(void (^)(id resultObj))success
         failure:(void (^)(id error))failure {
    _urlStr = urlStr;
    [self invokeBegin:targetVC];
    [[NetworkBaseExt sharedInstance] httpPost:_urlStr
                                      headers:self.headersDic
                                      cookies:self.cookiesStr
                                       params:paramsDic
                                     fileData:nil
                                     progress:^(NSProgress *progressObj) {
                                         self.progressBlock ? self.progressBlock(progressObj) : nil;
                                     } success:^(id responseObject) {
                                         [self invokeSuccess:responseObject targetVC:targetVC success:success failure:failure];
                                     } failure:^(id error) {
                                         [self invokeFaile:error targetVC:targetVC failure:failure];
                                     }];
}


// 业务层网络请求 POST 上传文件
- (void)httpPost:(NSString *)urlStr
        fileData:(NSData *)fileData
        targetVC:(UIViewController *)targetVC
         success:(void (^)(id resultObj))success
         failure:(void (^)(id error))failure {
    _urlStr = urlStr;
    [self invokeBegin:targetVC];
    [[NetworkBaseExt sharedInstance] httpPost:_urlStr
                                      headers:self.headersDic
                                      cookies:self.cookiesStr
                                       params:nil
                                     fileData:fileData
                                     progress:^(NSProgress *progressObj) {
                                         self.progressBlock ? self.progressBlock(progressObj) : nil;
                                     } success:^(id responseObject) {
                                         [self invokeSuccess:responseObject targetVC:targetVC success:success failure:failure];
                                     } failure:^(id error) {
                                         [self invokeFaile:error targetVC:targetVC failure:failure];
                                     }];
}


// 业务层网络请求 PUT
- (void)httpPut:(NSString *)urlStr
       fileData:(NSData *)fileData
       targetVC:(UIViewController *)targetVC
        success:(void (^)(id resultObj))success
        failure:(void (^)(id error))failure {
    _urlStr = urlStr;
    [self invokeBegin:targetVC];
    [[NetworkBaseExt sharedInstance] httpPut:_urlStr
                                     headers:self.headersDic
                                     cookies:self.cookiesStr
                                    fileData:fileData
                                     success:^(id responseObject) {
                                         [self invokeSuccess:responseObject targetVC:targetVC success:success failure:failure];
                                     } failure:^(id error) {
                                         [self invokeFaile:error targetVC:targetVC failure:failure];
                                     }];
}


// 业务层网络请求 DELETE
- (void)httpDelete:(NSString *)urlStr
            params:(NSDictionary *)paramsDic
          targetVC:(UIViewController *)targetVC
           success:(void (^)(id resultObj))success
           failure:(void (^)(id error))failure {
    _urlStr = urlStr;
    [self invokeBegin:targetVC];
    [[NetworkBaseExt sharedInstance] httpDelete:_urlStr
                                        headers:self.headersDic
                                        cookies:self.cookiesStr
                                         params:paramsDic
                                        success:^(id responseObject) {
                                            [self invokeSuccess:responseObject targetVC:targetVC success:success failure:failure];
                                        } failure:^(id error) {
                                            [self invokeFaile:error targetVC:targetVC failure:failure];
                                        }];
}


#pragma mark - 私有方法

// 网络请求之前
- (void)invokeBegin:(UIViewController *)targetVC {
    
#warning 开发测试用，替换ApiConfig.URL_BASE，生产环境要删除此代码
#if DEBUG
    if ([_urlStr containsString:@":8001"]) {
        NSRange range = [_urlStr rangeOfString:@":8001"];
        NSString *localBaseUrlStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"IpAddress"];
        if (localBaseUrlStr.length) {
            _urlStr = [_urlStr stringByReplacingCharactersInRange:NSMakeRange(0, range.location + range.length) withString:localBaseUrlStr];
        }
    }
#endif
    
    
    // 检查网络
    
    // 检查参数
    
    // 缓冲UI
    if (self.bNeedLoadingUI && targetVC) {
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD showHUDAddedTo:targetVC.view animated:YES];
        });
    }
    
    // 若没有设置cookiesStr，则添加默认token和uuid
    if (!self.cookiesStr) {
        NSString *token = [UserCenterInfo shareUserCenter].token;
        NSString *uuid = [UserCenterInfo shareUserCenter].userID;
        if (uuid && token) {
            self.cookiesStr = [NSString stringWithFormat:@"token=%@;uuid=%@;", token, uuid];
        }
    }
    
}


// 网络请求成功
- (void)invokeSuccess:(id)responseObject
             targetVC:(UIViewController *)targetVC
              success:(void (^)(id resultObj))success
              failure:(void (^)(id error))failure {
    
    // 缓冲结束
    if (self.bNeedLoadingUI && targetVC) {
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideAllHUDsForView:targetVC.view animated:YES];
        });
    }
    
    // 是否解析通讯协议的数据
    if (!self.bPbParse) {
        success ? success(responseObject) : nil;
        return;
    }
    
    // 通讯协议 初步数据解析
    NSError *err;
    PMessage *pbMsg = [PMessage parseFromData:responseObject error:&err];
    if (!pbMsg) {
        NSLog(@"通讯协议 数据解析异常 %@", err);
        failure ? failure(err) : nil;
        return;
    }
    NSLog(@"class = %@, type = %@", NSStringFromClass([pbMsg class]), pbMsg.type);
    Class pbMsg_Class = NSClassFromString(pbMsg.type);
    PResult *pbResult = [pbMsg_Class parseFromData:pbMsg.data_p error:&err];
    NSLog(@"pbResult.description = %@", [pbResult description]);
    
    if ([self hasErrorCode:pbResult]) {
        if (self.bNeedAlertErr && targetVC) {
            dispatch_async(dispatch_get_main_queue(),^{
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:pbResult.errorMsg preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
                [alertC addAction:okAction];
                [targetVC presentViewController:alertC animated:YES completion:nil];
            });
        }
        NSLog(@"业务层错误 %@", pbResult);
        failure ? failure(pbResult) : nil;
        return;
    }
    
    success ? success(pbResult) : nil;
}


// 网络请求失败
- (void)invokeFaile:(id)error
           targetVC:(UIViewController *)targetVC
            failure:(void (^)(id error))failure {
    
    // 缓冲结束
    if (self.bNeedLoadingUI && targetVC) {
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideAllHUDsForView:targetVC.view animated:YES];
        });
    }
    
    // 错误提示
    if (self.bNeedAlertErr && targetVC && [error isKindOfClass:[NSString class]]) {
        dispatch_async(dispatch_get_main_queue(),^{
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:error preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
            [alertC addAction:okAction];
            [targetVC presentViewController:alertC animated:YES completion:nil];
        });
    }
    
    failure ? failure(error) : nil;
    
}


// 业务层有错误
- (BOOL)hasErrorCode:(PResult *)pbResult {
    if (![pbResult respondsToSelector:@selector(errorCode)]) {
        return NO;
    }
    return (pbResult.errorCode != 0);
}

@end
