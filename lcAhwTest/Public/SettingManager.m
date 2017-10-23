//
//  SettingManager.m
//  lcAhwTest
//
//  Created by licheng on 15/4/29.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "SettingManager.h"

@implementation SettingManager


static SettingManager *instance = nil;
+ (SettingManager *)shareInstance
{
    @synchronized(self)  // 独占锁（单例）
    {
        if (instance == nil)
        {
            instance = [[self alloc] init];
        }
    }
    return instance;
}
//+ (instancetype)shareInstance
//{
//    static SettingManager *instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[self alloc] init];
//    });
//    return instance;
//}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _bIsNetBreak = NO;
        
        _bIsLogined = NO;
        _sIdentity = nil;
//        _bidID = nil; ?
        
        _invest_page = kDefaultPageNum;
        _invest_sortItem = Invest_SortItem_AuditDateKey;
        
        _investDetail_recordPage = kDefaultPageNum;
        _investDetail_payPlanPage = kDefaultPageNum;
        
        
        // 初始化NSUserDefault
        [self initUserDefaultsDataFromPlist];
        
//        BOOL k;  // no
//        BOOL kk = [[NSUserDefaults standardUserDefaults] boolForKey:@"asdfdsfdsf"];  // no
//        BOOL kkk = [[NSUserDefaults standardUserDefaults] boolForKey:@"IsFirstStart"];  // yes
        
    }
    return self;
}

// 读取plist文件初始化NSUserDefault
- (void)initUserDefaultsDataFromPlist
{
    //NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    NSString *resourcesPath = [[NSBundle mainBundle] pathForResource:@"PropertyList" ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:resourcesPath];
    [userDefaults registerDefaults:dic];
    
    
//    // 读写文件
//    NSMutableArray *arrKey = [[NSMutableArray alloc] init];
//    NSMutableArray *arrValue = [[NSMutableArray alloc] init];
//    NSString *resourcesPath = [[NSBundle mainBundle] pathForResource:@"folder_references/kk.txt" ofType:@""];
//    //NSArray *arr = [[NSArray alloc] initWithContentsOfFile:resourcesPath];  // *_*?
////    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:resourcesPath];  // 顺序乱掉，key值去重
////    for (NSString *strKey in [dict allKeys]) {
////        [arrKey addObject:strKey];
////        [arrValue addObject:[dict objectForKey:strKey]];
////    }
//    NSString *str = [NSString stringWithContentsOfFile:resourcesPath encoding:NSUTF8StringEncoding error:nil];
//    NSArray *arrKV = [str componentsSeparatedByString:@"\r"];
//    for (NSString *strKV in arrKV) {
//        NSArray *arrTemp = [strKV componentsSeparatedByString:@"="];
//        if (arrTemp.count != 2) {
//            NSLog(@"*_* %@", strKV);
//        }
//        else {
//            [arrKey addObject:arrTemp[0]];
//            [arrValue addObject:arrTemp[1]];
//        }
//    }
//    NSString *strPath_key = [NSString stringWithFormat:@"%@/translated_key.txt", NSHomeDirectory()];
//    [arrKey writeToFile:strPath_key atomically:YES];
//    NSString *strPath_value = [NSString stringWithFormat:@"%@/translated_value.txt", NSHomeDirectory()];
//    [arrValue writeToFile:strPath_value atomically:YES];
}




- (NSString *)str_readonly {
    return @"str_readonly";
}


static NSString *tempStr = nil;

+ (NSString *)str_static {
    return tempStr;
}

+ (void)setStr_static:(NSString *)str {
    tempStr = str;
}

@end
