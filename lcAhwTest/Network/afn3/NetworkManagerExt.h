//
//  NetworkManagerExt.h
//  Base
//
//  Created by licheng on 16/7/7.
//  Copyright © 2016年 billnie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkBaseExt.h"
#import "ApiConfig.h"

@interface NetworkManagerExt : NSObject

@property (nonatomic, assign) BOOL bNeedLoadingUI;            // 是否需要缓冲UI，默认YES
@property (nonatomic, assign) BOOL bNeedAlertErr;             // 是否需要弹出错误提示，默认YES
@property (nonatomic, assign) BOOL bPbParse;                  // 是否需要pb通讯协议解析数据，默认YES（如阿里悟空文件上传则是解析json）
@property (nonatomic, strong) NSDictionary *headersDic;       // 请求头，默认为空
@property (nonatomic, strong) NSString *cookiesStr;           // 自定义需要添加的cookies，默认添加token和uuid
@property (nonatomic, strong) void (^progressBlock)(NSProgress *progressObj);  // 进度

// 业务层网络请求 GET
- (void)httpGet:(NSString *)urlStr
         params:(NSDictionary *)paramsDic
       targetVC:(UIViewController *)targetVC
        success:(void (^)(id resultObj))success
        failure:(void (^)(id error))failure;

// 业务层网络请求 POST 提交数据
- (void)httpPost:(NSString *)urlStr
          params:(NSDictionary *)paramsDic
        targetVC:(UIViewController *)targetVC
         success:(void (^)(id resultObj))success
         failure:(void (^)(id error))failure;

// 业务层网络请求 POST 上传文件
- (void)httpPost:(NSString *)urlStr
        fileData:(NSData *)fileData
        targetVC:(UIViewController *)targetVC
         success:(void (^)(id resultObj))success
         failure:(void (^)(id error))failure;

// 业务层网络请求 PUT
- (void)httpPut:(NSString *)urlStr
       fileData:(NSData *)fileData
       targetVC:(UIViewController *)targetVC
        success:(void (^)(id resultObj))success
        failure:(void (^)(id error))failure;

// 业务层网络请求 DELETE
- (void)httpDelete:(NSString *)urlStr
            params:(NSDictionary *)paramsDic
          targetVC:(UIViewController *)targetVC
           success:(void (^)(id resultObj))success
           failure:(void (^)(id error))failure;

@end
