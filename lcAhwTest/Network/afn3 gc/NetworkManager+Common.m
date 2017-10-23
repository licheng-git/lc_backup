//
//  NetworkManager+Common.m
//  GuangCaiJiaoYi
//
//  Created by 李诚 on 16/12/8.
//  Copyright © 2016年 Steven. All rights reserved.
//

#import "NetworkManager+Common.h"


@implementation NetworkManager (Common)

- (void)httpGet:(NSString*)urlStr params:(NSDictionary *)paramsDict delegate:(id)delegate success:(void (^)(NSDictionary *respDict))success failure:(void (^)(id error))failure {
    [self requestUrl:urlStr params:paramsDict method:HttpMethodGet delegate:delegate success:^(NSDictionary *respDict) {
        success ? success(respDict) : nil;
    } failure:^(id error) {
        failure ? failure(error) : nil;
    }];
}

- (void)httpPost:(NSString*)urlStr params:(NSDictionary *)paramsDict delegate:(id)delegate success:(void (^)(NSDictionary *respDict))success failure:(void (^)(id error))failure {
    [self requestUrl:urlStr params:paramsDict method:HttpMethodPost delegate:delegate success:^(NSDictionary *respDict) {
        success ? success(respDict) : nil;
    } failure:^(id error) {
        failure ? failure(error) : nil;
    }];
}

- (void)httpPut:(NSString*)urlStr params:(NSDictionary *)paramsDict delegate:(id)delegate success:(void (^)(NSDictionary *respDict))success failure:(void (^)(id error))failure {
    [self requestUrl:urlStr params:paramsDict method:HttpMethodPut delegate:delegate success:^(NSDictionary *respDict) {
        success ? success(respDict) : nil;
    } failure:^(id error) {
        failure ? failure(error) : nil;
    }];
}

- (void)httpDelete:(NSString*)urlStr params:(NSDictionary *)paramsDict delegate:(id)delegate success:(void (^)(NSDictionary *respDict))success failure:(void (^)(id error))failure {
    [self requestUrl:urlStr params:paramsDict method:HttpMethodDelete delegate:delegate success:^(NSDictionary *respDict) {
        success ? success(respDict) : nil;
    } failure:^(id error) {
        failure ? failure(error) : nil;
    }];
}

@end
