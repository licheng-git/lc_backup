//
//  2dViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/12/8.
//  Copyright © 2015年 lc. All rights reserved.
//

#import "2dViewController.h"
#import "graphicsView.h"

@implementation _2dViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Quartz 2D";  // CGContextRef ; CGPath ; UIBezierPath
    
    // view实线
    UIView *realLine = [[UIView alloc] initWithFrame:CGRectMake(10, 80, kSCREEN_WIDTH - 20, 1)];
    realLine.backgroundColor = [UIColor greenColor];
    [self.view addSubview:realLine];
    
    
    // 虚线
    UIImageView *dottedLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, kSCREEN_WIDTH - 20, 5)];
    //dottedLine.backgroundColor = [UIColor orangeColor];
    [dottedLine.image drawInRect:CGRectMake(0, 0, dottedLine.frame.size.width, dottedLine.frame.size.height)];
    UIGraphicsBeginImageContext(dottedLine.frame.size);  // 开始画图
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor brownColor].CGColor);  // 颜色
    //[[UIColor brownColor] setStroke];
    //CGContextSetRGBStrokeColor(context, 0.6, 0.4, 0.2, 1);
    CGContextSetLineWidth(context, 1);  // 线宽（横线即为线高）
    CGContextSetLineCap(context, kCGLineCapRound);  // 边缘样式
    
    // 直线（实线或虚线）
    CGFloat phase = 0;  // 起始位置跳过的点
    CGFloat lengths[] = {10, 5};  // 画10个点，跳过5个点，循环
    CGFloat lengthsCount = 2;
    CGContextSetLineDash(context, phase, lengths, lengthsCount);  // 设置为虚线（注释掉即为实线）
    CGContextMoveToPoint(context, dottedLine.bounds.origin.x, 1);  // 起点
    CGContextAddLineToPoint(context, dottedLine.bounds.size.width, 1);  // 终点
    CGContextStrokePath(context);  // 画线
    
    dottedLine.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  // 结束画图
    [self.view addSubview:dottedLine];
    
    
//    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 140, kSCREEN_WIDTH - 20, 300)];
//    bgImgView.backgroundColor = [UIColor greenColor];
//    [bgImgView.image drawInRect:CGRectMake(10, 10, bgImgView.frame.size.width, bgImgView.frame.size.height)];
//    //CGContextRef context = UIGraphicsGetCurrentContext();
//    UIGraphicsBeginImageContext(bgImgView.bounds.size);
//    // ...
//    bgImgView.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    [self.view addSubview:bgImgView];
    
    
    // view边框虚线
    UIView *slView = [[UIView alloc] initWithFrame:CGRectMake(20, 120, kSCREEN_WIDTH - 40, 20)];
    slView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:slView];
    //slView.layer.borderWidth = 1;
    //slView.layer.borderColor = [UIColor grayColor].CGColor;
    CAShapeLayer *sl = [CAShapeLayer layer];
    sl.strokeColor = [UIColor grayColor].CGColor;
    sl.fillColor = nil;
    sl.path = [UIBezierPath bezierPathWithRect:slView.bounds].CGPath;
    sl.lineWidth = 2;
    sl.lineDashPattern = @[@2, @3];
    //sl.frame = slView.bounds;
    //sl.lineCap = @"square";
    [slView.layer addSublayer:sl];
    
    
    graphicsView *gView = [[graphicsView alloc] initWithFrame:CGRectMake(10, 160, kSCREEN_WIDTH - 20, 400)];
    gView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:gView];
}

@end
