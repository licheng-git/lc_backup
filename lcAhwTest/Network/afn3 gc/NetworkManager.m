//
//  NetworkManager.m
//  GuangCaiJiaoYi
//
//  Created by 李诚 on 16/12/8.
//  Copyright © 2016年 Steven. All rights reserved.
//

#import "NetworkManager.h"
#import "SVProgressHUD.h"

@implementation NetworkManager

- (id)init {
    self = [super init];
    if (self) {
        _bNeedLoadingUI = YES;
        _bNeedAlertErr = YES;
    }
    return self;
}

// 业务层网络请求
- (void)requestUrl:(NSString *)urlStr
            params:(NSDictionary *)paramsDict
            method:(HttpMethod)method
          delegate:(id)delegate
           success:(void (^)(NSDictionary *respDict))success
           failure:(void (^)(id error))failure {
    
    // 缓冲UI
    UIView *viewMask;
    if (_bNeedLoadingUI && delegate && [delegate isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (UIViewController *)delegate;
        viewMask = [[UIView alloc] initWithFrame:vc.view.bounds];
        viewMask.backgroundColor = [UIColor orangeColor];
        viewMask.alpha = 0.5;
        [vc.view addSubview:viewMask];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // 若没有设置cookiesStr，则添加默认
    if (!_cookiesStr) {
    }
    
    // 若没有设置headersDict，则添加默认sign+token（安全性验证）
    if (!_headersDict) {
        NSArray *arrParamKeys = [paramsDict allKeys];
        NSArray *arrParamKeysSorted = [arrParamKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2 options:NSNumericSearch];
        }];
        NSMutableString *strParam = [NSMutableString string];
        for (NSString *strParamKey in arrParamKeysSorted) {
            [strParam appendString:[NSString stringWithFormat:@"%@%@", strParamKey, paramsDict[strParamKey]]];
        }
        NSString *strParam_vector = [NSString stringWithFormat:@"ty%@", strParam];
        NSString *strParam_vector_md5 = [KUtils md5:strParam_vector];
        NSString *strSign = [strParam_vector_md5 uppercaseString];
        NSString *strToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"Token"];
        _headersDict = @{ @"sign" : strSign, @"token" : strToken };
    }
    
    // 业务层网络请求
    [[NetworkBase sharedInstance] requestUrl:urlStr
                                     headers:_headersDict
                                     cookies:_cookiesStr
                                      params:paramsDict
                                    fileData:_fileData
                                      method:method
                                    delegate:delegate
                                    progress:^(NSProgress *progressObj) {
                                   _progressBlock ? _progressBlock(progressObj) : nil;
                           } success:^(id responseObject) {
                               
                               // 缓冲结束
                               if (_bNeedLoadingUI) {
                                   [viewMask removeFromSuperview];
                               }
                               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                               
                               // 初步解析json
                               //int intSuccessCode = [responseObject[@"Code"] intValue];
                               NSString *strSuccessCode = [NSString stringWithFormat:@"%@", responseObject[@"Code"]];
                               if (![strSuccessCode isEqualToString:@"1"]) {
                                   if (_bNeedAlertErr) {
                                       [SVProgressHUD showErrorWithStatus:NSLocalizedString(strCode, nil)];
                                   }
                                   failure ? failure(responseObject) : nil;
                                   return;
                               }
                               // 保存服务器下发的token
                               NSString *strToken = responseObject[@"Token"];
                               if (![strToken isEqual:[[NSNull alloc] init]]) {
                                   [[NSUserDefaults standardUserDefaults] setValue:strToken forKey:@"Token"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                               }
                               success ? success(responseObject) : nil;
                               
                           } failure:^(id error) {
                               
                               if (_bNeedLoadingUI) {
                                   [viewMask removeFromSuperview];
                               }
                               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                               if (_bNeedAlertErr && [error isKindOfClass:[NSString class]]) {
                                   [SVProgressHUD showErrorWithStatus:error];
                               }
                               failure ? failure(error) : nil;
                               
                           }];
}

// 取消指定页面的所有请求
- (void)cancelRequest:(id)obj {
    if (!obj) {
        return;
    }
    //_bNeedAlertErr = NO;
    [[NetworkBase sharedInstance] cancelRequest:obj];
}

@end




//@implementation mbViewMask : UIView
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//    NSLog(@"*_* viewMask layoutSubviews");
//    UIView *viewParent = self.superview;
//    if (viewParent) {
//        self.frame = viewParent.bounds;
//    }
//}
//
//@end
