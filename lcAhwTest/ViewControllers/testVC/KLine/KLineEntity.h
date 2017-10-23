//
//  YKLineEntity.h
//  YKLineChartView
//
//  Created by chenyk on 15/12/9.
//  Copyright © 2015年 chenyk. All rights reserved.
//  https://github.com/chenyk0317/YKLineChartView


#import <UIKit/UIKit.h>

@interface KLineEntity : NSObject
@property (nonatomic,assign) CGFloat open;    // 开盘价
@property (nonatomic,assign) CGFloat close;   // 收盘价
@property (nonatomic,assign) CGFloat high;    // 最高价
@property (nonatomic,assign) CGFloat low;     // 最低价
@property (nonatomic,strong) NSString *date;  // 日期
@property (nonatomic,assign) CGFloat volume;  // 成交量
@property (nonatomic,assign) CGFloat ma5;     // moving average 移动均线 （5天的平均值）
@property (nonatomic,assign) CGFloat ma10;
@property (nonatomic,assign) CGFloat ma20;
@end


@interface KTimeLineEntity : NSObject
@end
