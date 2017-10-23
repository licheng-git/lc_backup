//
//  NetworkManager.h
//  mobaxx
//
//  Created by licheng on 16/5/27.
//  Copyright © 2016年 billnie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkBase.h"
#import "ApiConfig.h"

@interface NetworkManager : NSObject

@property (nonatomic, assign) BOOL bAsync;                    // 是否异步请求，默认YES （如发布多媒体帖子在队列中需要使用同步请求）
@property (nonatomic, assign) BOOL bNeedLoadingUI;            // 是否需要缓冲UI，默认YES
@property (nonatomic, assign) BOOL bNeedAlertErr;             // 是否需要弹出错误提示，默认NO
@property (nonatomic, assign) BOOL bPbParse;                  // 是否需要pb通讯协议解析数据，默认YES（如阿里悟空文件上传则是解析json）
@property (nonatomic, strong) NSDictionary *headersDic;       // 请求头，默认为空
@property (nonatomic, strong) NSString *cookiesStr;           // 自定义需要添加的cookies，默认添加token和uuid
@property (nonatomic, strong) NSData *fileData;               // 上传文件数据
@property (nonatomic, strong) void (^progressBlock)(NSUInteger bytesWritten, long long totalBytes, long long totalBytesExpected);  // 进度

// 业务层网络请求
- (void)requestUrl:(NSString *)urlStr
            params:(NSDictionary *)paramsDic
            method:(HttpMethod)method
          targetVC:(UIViewController *)targetVC
           success:(void (^)(id resultObj))success
           failure:(void (^)(id error))failure;

@end

