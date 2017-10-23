//
//  DBOperator.m
//  lcAhwTest
//
//  Created by licheng on 15/6/12.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "DBOperator.h"

@interface DBOperator()
{
    FMDatabase *_db;
}
@end

@implementation DBOperator

// 创建单例
+ (instancetype)shareInstance
{
    static DBOperator *dbOperator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbOperator = [[DBOperator alloc] init];
    });
    return dbOperator;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initDb];
    }
    return self;
}

- (void)dealloc
{
    [_db close];
}

// 打开（创建）数据库
- (void)initDb
{
    // 数据库所在的目录
    NSString *directory = [NSHomeDirectory() stringByAppendingString:@"/Documents/kk"];  // Documents|Library|tmp
    NSString *dbPath = [directory stringByAppendingFormat:@"/Ahw.db"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:directory isDirectory:&isDir])  // Documents下kk文件夹不存在
    {
        // 创建路径 .../Documents/kk
        [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }

    _db = [FMDatabase databaseWithPath:dbPath];  // 新建 或 获取.../Documents/kk/Ahw.db
}

// 创建数据库表
- (BOOL)createTable
{
    if(![_db open])  // 打开
    {
        return NO;
    }
    
//    [_db open];
//    NSString *sqlStr = @"drop table if exists t_user";
//    BOOL isSuccess = [_db executeUpdate:sqlStr];
//    [_db close];
//    return isSuccess;
    
    
//    NSString *sqlCreateTb = @"\
//    create table if not exists t_user\
//    (id integer primary key autoincrement, \
//    name text, \
//    nickname text, \
//    sortnum text, \
//    money text, \
//    isvip text, \
//    createtime text, \
//    photo text\
//    )";
    
    // NULL
    // INTEGER  整数 （bool）
    // REAL     浮点型
    // TEXT     文本 （datetime）
    // BLOB     二进制数据
    
    NSString *sqlCreateTb = @"\
    create table if not exists t_user\
    (id integer primary key autoincrement, \
    name nvarchar(10), \
    nickname text, \
    sortnum integer, \
    money real, \
    isvip integer, \
    createtime text, \
    photo blob\
    )";  // id char(36) primary key not null unique
    BOOL isSuccess = [_db executeUpdate:sqlCreateTb];  // 创建表
    [_db close];
    return isSuccess;
}

// 版本变动时可能会添加字段
- (BOOL)addColumn:(NSString *)colName toTable:(NSString *)tbName
{
    BOOL isSuccess = NO;
    [_db open];
    if (![_db columnExists:colName inTableWithName:tbName])
    {
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ char(36)", tbName, colName];
        isSuccess = [_db executeUpdate:sql];
    }
    [_db close];
    return isSuccess;
}


// 判断是否存在表
- (BOOL)existsTable:(NSString *)tbName
{
    [_db open];
    NSString *sqlStr = @"select count(*) as 'count' from sqlite_master where type='table' and name=?";
    FMResultSet *rs = [_db executeQuery:sqlStr, tbName];
    BOOL isExists = NO;
    while ([rs next])
    {
        NSInteger count = [rs intForColumnIndex:0];
        isExists = (count!=0);
    }
    [_db close];
    return isExists;
}

// 执行sql（非select的语句）
- (BOOL)excuteSql
{
    [_db open];
    NSString *sqlStr = @"insert into t_user(name,nickname,sortnum,money,isvip,createtime,photo) values(?,?,?,?,?,?,?)";  //id,name,nickname,sortnum,money,isvip,createtime,photo
    //[_db beginTransaction];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    UIImage *img = [UIImage imageNamed:@"user_head_image@2x.png"];
    NSData *imgdata = UIImagePNGRepresentation(img);
    //NSData *imgdata = UIImageJPEGRepresentation(img, 1.0);
    BOOL isSuccess = [_db executeUpdate:sqlStr,
                      @"licheng",
                      @"lc橙子",
                      [NSNumber numberWithInt:3],
                      [NSNumber numberWithFloat:7.5f],
                      [NSNumber numberWithBool:NO],
                      [df stringFromDate:[NSDate date]],
                      imgdata];
    //return [_db commit];
    [_db close];
    return isSuccess;
}

// 执行select读取数据
- (void)readData
{
    [_db open];
    NSString *sqlStr = @"select * from t_user where name=?";
    FMResultSet *rs = [_db executeQuery:sqlStr, @"licheng"];
    while ([rs next])
    {
//        NSInteger tId = [rs intForColumn:@"id"];
//        NSString *name = [rs stringForColumn:@"name"];
//        NSString *nickname = [rs stringForColumn:@"nickname"];
//        NSInteger sortnum = [rs intForColumn:@"sortnum"];
//        CGFloat money = [[rs objectForColumnName:@"money"] floatValue];
//        BOOL isvip = [rs boolForColumn:@"isvip"];
//        NSDate *createtime = [rs dateForColumn:@"createtime"];
//        NSData *photo = [rs dataForColumn:@"photo"];
    }
    [_db close];
}


// sqlite3直接操作数据库
+ (void)sqlite3
{
    NSString *dbPath = [NSString stringWithFormat:@"%@/Documents/lc.sqlite", NSHomeDirectory()];
    
    // openDB(/initDB)
    sqlite3 *db;
    if (sqlite3_open([dbPath UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"数据库打开（创建）失败");
        return;
    }
    
    // 创建表
    NSString *sqlStr = @"create table if not exists t_user (id integer primary key autoincrement, name nvarchar(10), sortnum integer, createtime text)";
    if (sqlite3_exec(db, [sqlStr UTF8String], nil, NULL, NULL) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"数据库表创建失败");
        return;
    }
    
//    // 增删改
//    sqlStr = [NSString stringWithFormat:@"insert into t_user(name, sortnum, createtime) values('%@', '%@', '%@')", @"哈哈", @(2), [NSDate date]];
//    if (sqlite3_exec(db, [sqlStr UTF8String], NULL, nil, NULL) != SQLITE_OK) {
//        sqlite3_close(db);
//        NSLog(@"数据库操作失败");
//        return;
//    }
    // 增删改（带参数）
    sqlStr = @"update t_user set name=?,sortnum=? where rowid=1";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(db, [sqlStr UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"sql语句绑定参数失败");
        return;
    }
    sqlite3_bind_text(stmt, 1, [@"嘿嘿" UTF8String], -1, nil);
    sqlite3_bind_text(stmt, 2, [@"10" UTF8String], -1, NULL);
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        NSLog(@"数据库操作失败");
        return;
    }
    sqlite3_finalize(stmt);
    
    // 查询
    sqlStr = @"select * from t_user";
    sqlite3_stmt *stmt1;
    if (sqlite3_prepare(db, [sqlStr UTF8String], -1, &stmt1, nil) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"prepare失败");
        return;
    }
    while (sqlite3_step(stmt1) == SQLITE_ROW) {
        char *rowid = (char *)sqlite3_column_text(stmt1, 0);
        char *name = (char *)sqlite3_column_text(stmt1, 1);
        NSString *nameStr = name ? [NSString stringWithUTF8String:name] : nil;
        int sortnum = sqlite3_column_int(stmt1, 2);
        char *columnname = (char *)sqlite3_column_name(stmt1, 3);
        NSLog(@"*_*sqlite3 %s, %@, %i, %s", rowid, nameStr, sortnum, columnname);
    }
    sqlite3_finalize(stmt1);
    
    sqlite3_close(db);
    
}

@end
