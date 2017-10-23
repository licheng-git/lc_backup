//
//  DBOperator.h
//  lcAhwTest
//
//  Created by licheng on 15/6/12.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface DBOperator : NSObject

// 创建单例
+ (instancetype)shareInstance;

// 打开（创建）数据库，创建表
- (BOOL)createTable;

// 执行sql（非select的语句）
- (BOOL)excuteSql;

// 执行select读取数据
- (void)readData;

// sqlite3直接操作数据库
+ (void)sqlite3;

@end
