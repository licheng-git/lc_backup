//
//  NetworkManager.h
//  GuangCaiJiaoYi
//
//  Created by 李诚 on 16/12/8.
//  Copyright © 2016年 Steven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkBase.h"
#import "ApiConfig.h"

@interface NetworkManager : NSObject

@property (nonatomic, assign) BOOL bNeedLoadingUI;            // 是否需要缓冲UI，默认YES
@property (nonatomic, assign) BOOL bNeedAlertErr;             // 是否需要弹出错误提示，默认YES
@property (nonatomic, strong) NSDictionary *headersDict;      // 请求头，默认为空
@property (nonatomic, strong) NSString *cookiesStr;           // 自定义需要添加的cookies
@property (nonatomic, strong) NSData *fileData;               // 上传文件数据
@property (nonatomic, strong) void (^progressBlock)(NSProgress *progressObj);  // 进度

// 业务层网络请求
- (void)requestUrl:(NSString *)urlStr
            params:(NSDictionary *)paramsDict
            method:(HttpMethod)method
          delegate:(id)delegate
           success:(void (^)(NSDictionary *respDict))success
           failure:(void (^)(id error))failure;

// 取消指定页面的所有请求
- (void)cancelRequest:(id)obj;

@end




//@interface mbViewMask : UIView
//
//@end
