//
//  graphicsView.m
//  lcAhwTest
//
//  Created by licheng on 15/12/8.
//  Copyright © 2015年 lc. All rights reserved.
//

#import "graphicsView.h"

@implementation graphicsView

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self)
//    {
//        self.backgroundColor = [UIColor greenColor];
//    }
//    return self;
//}

- (void)drawRect:(CGRect)rect
{
    // Quartz 2D
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // CGContextAdd... ; CGContextStroke... ; CGContextFill...
    
    
    // 圆环（整圆）
    //UIGraphicsPushContext(context);
    //CGContextBeginPath(context);
    CGPoint arcCenter = CGPointMake(10, 10);  // 圆心
    CGFloat arcRadius = 30;  // 半径
    CGFloat arcStartAngle = 0;  // 起始角度
    CGFloat arcEndAngle = M_PI * 2 * 0.25;  // 结束角度 （M_PI*2整圆）
    int arcClockwise = 0;  // 0顺时针，1逆时针
    CGContextAddArc(context, arcCenter.x, arcCenter.y, arcRadius, arcStartAngle, arcEndAngle, arcClockwise);
    CGContextStrokePath(context);
    //UIGraphicsEndImageContext();
    //UIGraphicsPopContext();
    
    // 圆弧  三个点形成两条线，再与半径为r的圆确定的一条弧线
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextSetLineWidth(context, 10);
    CGContextMoveToPoint(context, 50, 10);
    CGContextAddArcToPoint(context, 150, 10, 150, 150, 30);
    CGContextStrokePath(context);
    
    // 二次贝赛尔曲线 Bezier  起点＋终点＋控制点 起点和终点在曲线上，“逼近”一个控制点，导数、阶次、形式
    CGContextSetStrokeColorWithColor(context, [UIColor cyanColor].CGColor);
    CGContextMoveToPoint(context, 170, 10);
    CGContextAddQuadCurveToPoint(context, 180, 100, 260, 10);
    CGContextStrokePath(context);
    
    // 三次贝赛尔曲线  起点＋终点＋两个控制点
    CGContextSetStrokeColorWithColor(context, [UIColor magentaColor].CGColor);
    CGContextSetLineWidth(context, 3);
    CGContextMoveToPoint(context, 170, 10);
    CGContextAddCurveToPoint(context, 300, 100, 210, -30, 260, 10);
    CGContextStrokePath(context);
    
    // 椭圆（圆）
    CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextAddEllipseInRect(context, CGRectMake(10, 80, 30, 50));
    //CGContextStrokePath(context);
    //CGContextFillPath(context);  // 线条和填充色 二选一
    CGContextDrawPath(context, kCGPathEOFillStroke);  // 线条和填充色 组合
    
    // 长方形（正方形）
    CGContextAddRect(context, CGRectMake(50, 80, 50, 30));
    //CGContextStrokePath(context);
    CGContextFillPath(context);
//    const CGRect rects[2] = { CGRectMake(10, 350, 10, 20), CGRectMake(50, 350, 30, 40) };
//    CGContextAddRects(context, rects, 2);  // 一次加多个
    
    // 连线 （直线或多边形）
    CGContextMoveToPoint(context, 180, 80);
    CGContextAddLineToPoint(context, 240, 80);
    CGContextAddLineToPoint(context, 260, 100);
    CGContextAddLineToPoint(context, 200, 120);
    CGContextAddLineToPoint(context, 180, 80);
    //CGContextClosePath(context);
    CGContextStrokePath(context);
    
    // 连线 （直线或多边形）
    CGPoint pointsLines[5] = { CGPointMake(120, 80), CGPointMake(140, 120),CGPointMake(160, 80),CGPointMake(140, 100), CGPointMake(120, 80) };
    CGContextAddLines(context, pointsLines, 4);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    //CGContextAddPath(context, CGPathRef  _Nullable path)
    
    
    // stroke...
    CGContextStrokeEllipseInRect(context, CGRectMake(10, 150, 50, 30));  // 圆
    CGContextStrokeRect(context, CGRectMake(80, 150, 30, 50));  // 方
    CGPoint pointsLineSegments[4] = { CGPointMake(150, 150), CGPointMake(160, 160),CGPointMake(170, 170), CGPointMake(180, 180)};
    CGContextStrokeLineSegments(context, pointsLineSegments, 4);  // 分段画线
    //CGContextStrokePath(context);
    
    
    // fill...
    CGContextFillEllipseInRect(context, CGRectMake(10, 220, 50, 50));  // 实心圆
    CGContextFillRect(context, CGRectMake(80, 220, 30, 30));  // 实心方
    //CGContextFillPath(context);
    
    
    //CGContextDraw...
    
    
    // 文字
    NSString *str = @"CGContextRef *_* Quartz 2D 绘图 \n哈吼";
    [str drawInRect:CGRectMake(10, 280, 300, 30) withAttributes:nil];
    [str drawAtPoint:CGPointMake(10, 310) withAttributes:@{ NSForegroundColorAttributeName : [UIColor brownColor], NSFontAttributeName : [UIFont systemFontOfSize:18] }];
    
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(10, 350, 300, 30)];
    lb.text = @"label哈吼";
    [self addSubview:lb];
    
    
    // 渐变色
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 130, 220);
    CGPathAddLineToPoint(path, nil, 170, 220);
    CGPathAddLineToPoint(path, nil, 160, 260);
    CGPathCloseSubpath(path);
    
    UIColor *colorStart = [UIColor blueColor];
    UIColor *colorEnd = [UIColor redColor];
    NSArray *arrColors = @[ (__bridge id)colorStart.CGColor, (__bridge id)colorEnd.CGColor ];
    CGFloat locations[] = { 0.0, 1.0 };
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorspace, (__bridge CFArrayRef)arrColors, locations);
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    // 渐变色方向
    //CGPoint pointStart = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMinY(pathRect));
    //CGPoint pointEnd = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect));
    CGPoint pointStart = CGPointMake(CGRectGetMinX(pathRect), CGRectGetMidY(pathRect));
    CGPoint pointEnd = CGPointMake(CGRectGetMaxX(pathRect), CGRectGetMinY(pathRect));
    
    CGContextAddPath(context, path);
    CGContextSetAlpha(context, 0.8);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, pointStart, pointEnd, 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    CGPathRelease(path);
}

@end
