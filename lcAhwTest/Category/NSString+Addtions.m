//
//  NSString+Addtions.m
//  lcAhwTest
//
//  Created by licheng on 15/6/25.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "NSString+Addtions.h"

@implementation NSString (kkString)

+ (NSString *)currentTimeStr
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *result = [df stringFromDate:[NSDate date]];
    return result;
}

- (NSURL *)toURL
{
    NSURL *result = [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return result;
}

@end
