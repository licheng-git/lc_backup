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

@implementation NetworkManager

- (id)init {
    self = [super init];
    if (self) {
        _bAsync = YES;
        _bNeedLoadingUI = YES;
        _bNeedAlertErr = NO;
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
           failure:(void (^)(id error))failure
{
    // 检查网络
    
    // 缓冲UI
    if (_bNeedLoadingUI && targetVC) {
        [MBProgressHUD showHUDAddedTo:targetVC.view animated:YES];
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
                                       async:_bAsync
                                     headers:_headersDic
                                     cookies:_cookiesStr
                                      params:paramsDic
                                    fileData:_fileData
                                      method:method progress:^(NSUInteger bytesWritten,
                                                               long long totalBytes,
                                                               long long totalBytesExpected) {
                               if (_progressBlock) {
                                   _progressBlock(bytesWritten, totalBytes, totalBytesExpected);
                               }
                           } success:^(id responseObject) {
                               
                               // 缓冲结束
                               if (_bNeedLoadingUI && targetVC) {
                                   [MBProgressHUD hideHUDForView:targetVC.view animated:YES];
                               }
                               
                               // 是否解析通讯协议的数据
                               if (!_bPbParse) {
                                   success ? success(responseObject) : nil;
                                   return;
                               }
                               
                               // 通讯协议 初步数据解析
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
//                                   Class pbMsg_SuperClass = class_getSuperclass(pbMsg_Class);
//                                   if (pbMsg_SuperClass != [GPBMessage class]) {
//                                       NSLog(@"通讯协议 数据解析异常");
//                                       failure ? failure(pbMsg) : nil;
//                                       return;
//                                   }
                                   PResult *pbResult = [pbMsg_Class parseFromData:pbMsg.data_p error:nil];
                                   NSLog(@"pbResult.description = %@", [pbResult description]);
                                   
                                   if ([self hasErrorCode:pbResult]) {
                                       if (_bNeedAlertErr && targetVC) {
                                           UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:pbResult.errorMsg preferredStyle:UIAlertControllerStyleAlert];
                                           UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
                                           [alertC addAction:okAction];
                                           [targetVC presentViewController:alertC animated:YES completion:nil];
                                       }
                                       NSLog(@"业务层错误 %@", pbResult);
                                       failure ? failure(pbResult) : nil;
                                       return;
                                   }
                                   
                                   success ? success(pbResult) : nil;
                                   
                               } @catch (NSException *exception) {
                                   NSLog(@"通讯协议 数据解析异常 %@", exception);
                                   failure ? failure(exception) : nil;
                                   return;
                               }
                               
                           } failure:^(id error) {
                               
                               if (_bNeedLoadingUI && targetVC) {
                                   [MBProgressHUD hideHUDForView:targetVC.view animated:YES];
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

