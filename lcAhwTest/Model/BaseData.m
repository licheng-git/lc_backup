//
//  BaseData.m
//  lcAhwTest
//
//  Created by licheng on 15/4/13.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "BaseData.h"

@implementation BaseData

- (id)initWithRequestType:(REQUEST_TYPE)type
{
    self = [super init];
    if (self)
    {
        self.reqType = type;
    }
    return self;
}

// 打包数据，用于提交数据到服务器
- (NSDictionary *)package
{
    return nil;
}

// 解析数据，用于将服务器返回数据转换为对应实体
- (BaseData *)unpackJson:(NSDictionary *)dic
{
    return nil;
}


@end
