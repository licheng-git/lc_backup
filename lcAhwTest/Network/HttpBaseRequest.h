//
//  HttpBaseRequest.h
//  lcAhwTest
//
//  Created by licheng on 15/6/3.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef NS_ENUM(NSInteger, HttpRequestMethod)
{
    HttpRequestMethodGet = 0,
    HttpRequestMethodPost,
    HttpRequestMethodPostFileData
};

@interface HttpBaseRequest : NSObject

@property (nonatomic, strong) AFHTTPRequestOperation *afOperation;
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong) NSDictionary *param;
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, assign) HttpRequestMethod method;
@property (nonatomic, assign) NSInteger tag;

@end
