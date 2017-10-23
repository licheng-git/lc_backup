//
//  NetworkManager+Common.m
//  GuangCaiJiaoYi
//
//  Created by 李诚 on 16/12/8.
//  Copyright © 2016年 Steven. All rights reserved.
//

#import "NetworkManager.h"

@interface NetworkManager (Common)

- (void)httpGet:(NSString*)urlStr params:(NSDictionary *)paramsDict delegate:(id)delegate success:(void (^)(NSDictionary *respDict))success failure:(void (^)(id error))failure;

- (void)httpPost:(NSString *)urlStr params:(NSDictionary *)paramsDict delegate:(id)delegate success:(void (^)(NSDictionary *respDict))success failure:(void (^)(id error))failure;

- (void)httpPut:(NSString *)urlStr params:(NSDictionary *)paramsDict delegate:(id)delegate success:(void (^)(NSDictionary *respDict))success failure:(void (^)(id error))failure;

- (void)httpDelete:(NSString *)urlStr params:(NSDictionary *)paramsDict delegate:(id)delegate success:(void (^)(NSDictionary *respDict))success failure:(void (^)(id error))failure;

@end
