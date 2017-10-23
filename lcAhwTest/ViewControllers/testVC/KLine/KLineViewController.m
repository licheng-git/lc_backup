//
//  ViewController.m
//  KLine_lcTest
//
//  Created by 李诚 on 17/2/7.
//  Copyright © 2017年 李诚. All rights reserved.
//

#import "KLineViewController.h"
#import "TestView.h"
#import "KLineView_Image.h"
#import "KLineView.h"
#import "KLineView_ok.h"
#import "KLineEntity.h"


@implementation KLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"股票大盘 k线图";
    
//    TestView *testview = [[TestView alloc] initWithFrame:CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width - 40, 200)];
//    //testview.backgroundColor = [UIColor lightGrayColor];
//    //testview.layer.borderColor = [UIColor yellowColor].CGColor;
//    //testview.layer.borderWidth = 1;
//    [self.view addSubview:testview];
    
    
//    KLineView_Image *klineV = [[KLineView_Image alloc] initWithFrame:CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width - 40, 200)];
//    [self.view addSubview:klineV];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data.plist" ofType:nil];
    NSDictionary *dictSource = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *arrSource = [dictSource objectForKey:@"data"];
    //NSLog(@"%@", arrSource);
    NSMutableArray *arrEntity = [NSMutableArray array];
    for (NSDictionary *dictItem in arrSource) {
        KLineEntity *entity = [[KLineEntity alloc] init];
        entity.open = [dictItem[@"open_px"] doubleValue];
        entity.close = [dictItem[@"close_px"] doubleValue];
        entity.high = [dictItem[@"high_px"] doubleValue];
        entity.low = [dictItem[@"low_px"] doubleValue];
        entity.date = dictItem[@"date"];
        entity.volume = [dictItem[@"total_volume_trade"] doubleValue];
        entity.ma5 = [dictItem[@"avg5"] doubleValue];
        entity.ma10 = [dictItem[@"avg10"] doubleValue];
        entity.ma20 = [dictItem[@"avg20"] doubleValue];
        [arrEntity addObject:entity];
    }
    
//    KLineView *klineV = [[KLineView alloc] initWithFrame:CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width - 40, 200)];
//    [self.view addSubview:klineV];
//    klineV.arrEntity = arrEntity;  // 第一次绘图之前的设置
//    [klineV setNeedsDisplay];  // 第一次绘图
    
    KLineView_ok *klineV = [[KLineView_ok alloc] initWithFrame:CGRectMake(10, 100, [UIScreen mainScreen].bounds.size.width - 20, 400)];
    [self.view addSubview:klineV];
    klineV.arrEntity = arrEntity;
    klineV.uperChartHeightScale = 0.6;
    [klineV firstDraw];
}


- (void)dealloc {
    NSLog(@"KLineViewController dealloc");
}

@end
