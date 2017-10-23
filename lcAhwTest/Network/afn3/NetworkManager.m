//
//  NetworkManager.m
//  mobaxx
//
//  Created by licheng on 16/5/27.
//  Copyright © 2016年 billnie. All rights reserved.
//

#import "NetworkManager.h"
#import "Result.pbobjc.h"
#import <objc/runtime.h>
#import "MBProgressHUD.h"
#import "UserCenterInfo.h"

@implementation NetworkManager

- (id)init {
    self = [super init];
    if (self) {
        _bNeedLoadingUI = YES;
        _bNeedAlertErr = YES;
        _bPbParse = YES;
    }
    return self;
}

// 业务层网络请求
- (void)requestUrl:(NSString *)urlStr
            params:(NSDictionary *)paramsDic
            method:(HttpMethod)method
          targetVC:(UIViewController *)targetVC
           success:(void (^)(id resultObj))success
           failure:(void (^)(id error))failure {
    
#warning 开发测试用，替换ApiConfig.URL_BASE，生产环境要删除此代码
#if DEBUG
    if ([urlStr containsString:@":8001"]) {
        NSRange range = [urlStr rangeOfString:@":8001"];
        NSString *localBaseUrlStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"IpAddress"];
        if (localBaseUrlStr.length) {
            urlStr = [urlStr stringByReplacingCharactersInRange:NSMakeRange(0, range.location + range.length) withString:localBaseUrlStr];
        }
    }
#endif
    
    
    // 检查网络
    
    //// 检查参数
    //if (method == HttpMethodPost || method == HttpMethodPut) {
    //    if (paramsDic && _fileData) {
    //        NSLog(@"错误，HTTPHeader和HTTPBody冲突，请使用url参数替代params");
    //        return;
    //    }
    //}
    
    // 缓冲UI
    if (_bNeedLoadingUI && targetVC) {
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD showHUDAddedTo:targetVC.view animated:YES];
        });
    }
    
    // 若没有设置cookiesStr，则添加默认token和uuid
    if (!_cookiesStr) {
        NSString *token = [UserCenterInfo shareUserCenter].token;
        NSString *uuid = [UserCenterInfo shareUserCenter].userID;
        if (uuid && token) {
            _cookiesStr = [NSString stringWithFormat:@"token=%@;uuid=%@;", token, uuid];
        }
    }
    
    // 业务层网络请求
    [[NetworkBase sharedInstance] requestUrl:urlStr
                                     headers:_headersDic
                                     cookies:_cookiesStr
                                      params:paramsDic
                                    fileData:_fileData
                                      method:method progress:^(NSProgress *progressObj) {
                                   _progressBlock ? _progressBlock(progressObj) : nil;
                           } success:^(id responseObject) {
                               
                               // 缓冲结束
                               if (_bNeedLoadingUI && targetVC) {
                                   dispatch_async(dispatch_get_main_queue(),^{
                                       [MBProgressHUD hideAllHUDsForView:targetVC.view animated:YES];
                                   });
                               }
                               
                               // 是否解析通讯协议的数据
                               if (!_bPbParse) {
                                   success ? success(responseObject) : nil;
                                   return;
                               }
                               
                               // 通讯协议 初步数据解析
                               //id resultObj = nil;
                               @try {
                                   NSError *err;
                                   PMessage *pbMsg = [PMessage parseFromData:responseObject error:&err];
                                   if (!pbMsg) {
                                       NSLog(@"通讯协议 数据解析异常 %@", err);
                                       failure ? failure(err) : nil;
                                       return;
                                   }
                                   NSLog(@"class = %@, type = %@", NSStringFromClass([pbMsg class]), pbMsg.type);
                                   Class pbMsg_Class = NSClassFromString(pbMsg.type);
                                   //Class pbMsg_SuperClass = class_getSuperclass(pbMsg_Class);
                                   //if (pbMsg_SuperClass != [GPBMessage class]) {
                                   //    NSLog(@"通讯协议 数据解析异常");
                                   //    failure ? failure(pbMsg) : nil;
                                   //    return;
                                   //}
                                   PResult *pbResult = [pbMsg_Class parseFromData:pbMsg.data_p error:&err];
                                   //if (!pbResult) {  // 有些操作成功返回的pbResult也为空
                                   //    NSLog(@"通讯协议 数据解析异常 %@", err);
                                   //    failure ? failure(err) : nil;
                                   //    return;
                                   //}
                                   NSLog(@"pbResult.description = %@", [pbResult description]);
                                   
                                   if ([self hasErrorCode:pbResult]) {
                                       if (_bNeedAlertErr && targetVC) {
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
                                   //resultObj = pbResult;
                                   
                               } @catch (NSException *exception) {
                                   NSLog(@"通讯协议 数据解析异常 %@", exception);
                                   failure ? failure(exception) : nil;
                                   return;
                               }
                               
                               //success ? success(resultObj) : nil;
                               
                           } failure:^(id error) {
                               
                               if (_bNeedLoadingUI && targetVC) {
                                   dispatch_async(dispatch_get_main_queue(),^{
                                       [MBProgressHUD hideAllHUDsForView:targetVC.view animated:YES];
                                   });
                               }
                               
                               if (_bNeedAlertErr && targetVC && [error isKindOfClass:[NSString class]]) {
                                   dispatch_async(dispatch_get_main_queue(),^{
                                       UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:error preferredStyle:UIAlertControllerStyleAlert];
                                       UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
                                       [alertC addAction:okAction];
                                       [targetVC presentViewController:alertC animated:YES completion:nil];
                                   });
                               }
                               
                               failure ? failure(error) : nil;
                               
                           }];
}

// 业务层有错误
- (BOOL)hasErrorCode:(PResult *)pbResult {
//    BOOL hasErr = NO;
//    unsigned int count;
//    objc_property_t *properties = class_copyPropertyList([pbResult class], &count);
//    for(int i = 0; i < count; i++) {
//        NSString *propertyName = [NSString stringWithUTF8String:property_getName(properties[i])];
//        if ([propertyName isEqualToString:@"errorCode"]) {
//            hasErr = YES;
//            break;
//        }
//    }
//    free(properties);
//    if (hasErr) {
//        hasErr = (pbResult.errorCode != 0);
//    }
//    return hasErr;
    if (![pbResult respondsToSelector:@selector(errorCode)]) {
        return NO;
    }
    return (pbResult.errorCode != 0);
}

@end

