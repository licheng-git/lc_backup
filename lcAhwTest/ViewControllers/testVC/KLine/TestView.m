//
//  TestView.m
//  KLine_lcTest
//
//  Created by apple on 17/2/10.
//  Copyright © 2017年 李诚. All rights reserved.
//

#import "TestView.h"

@interface TestView()
{
    UIView *_breathingPoint;
}
@end

@implementation TestView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.layer.borderColor = [UIColor yellowColor].CGColor;
        self.layer.borderWidth = 1;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(GestureAction_Tap:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    // 背景
//    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
//    CGContextFillRect(context, rect);
//    
//    // 边框
//    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
//    CGContextSetLineWidth(context, 1);
//    CGContextStrokeRect(context, rect);
    
    // 直线
    CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 10, 10);
    CGContextAddLineToPoint(context, 50, 20);
    CGContextStrokePath(context);
    
    // 文字
    int r = arc4random() % 50;  // 随机整数，范围在[from,to)，包括from，不包括to  ->  (int)(from + arc4random() % (to - from + 1))
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", r] attributes:@{ NSForegroundColorAttributeName : [UIColor greenColor], NSFontAttributeName : [UIFont systemFontOfSize:10] }];
    [attrStr drawInRect:CGRectMake(rect.size.width/2-10, rect.size.height/2-10, 20, 20)];
    
    
    // 渐变色
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 100, 20);
    CGPathAddLineToPoint(path, nil, 120, 60);
    CGPathAddLineToPoint(path, nil, 50, 100);
    CGPathCloseSubpath(path);
    
    UIColor *colorStart = [UIColor blueColor];
    UIColor *colorEnd = [UIColor whiteColor];
    NSArray *arrColors = @[ (__bridge id)colorStart.CGColor, (__bridge id)colorEnd.CGColor ];
    CGFloat locations[] = { 0.0, 1.0 };
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorspace, (__bridge CFArrayRef)arrColors, locations);
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    CGPoint pointStart = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMinY(pathRect));
    CGPoint pointEnd = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect));
    
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextSetAlpha(context, 0.5);
    CGContextDrawLinearGradient(context, gradient, pointStart, pointEnd, 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    CGPathRelease(path);
    
    
    // 闪光小圆圈
    _breathingPoint = [[UIView alloc] initWithFrame:CGRectMake(200, 10, 5, 5)];
    [self addSubview:_breathingPoint];
    _breathingPoint.layer.borderColor = [UIColor blueColor].CGColor;
    _breathingPoint.layer.borderWidth = 1;
    _breathingPoint.layer.cornerRadius = 2.5;
    _breathingPoint.clipsToBounds = YES;
    _breathingPoint.alpha = 1;
    [self keepBreathing];
}

- (void)keepBreathing {
    [UIView animateWithDuration:0.1 delay:0.1 options:0 animations:^{
        _breathingPoint.alpha -= 0.1;
        if (_breathingPoint.alpha < 0) {
            _breathingPoint.alpha = 1;
        }
    } completion:^(BOOL finished) {
        [self keepBreathing];
    }];
}


- (void)GestureAction_Tap:(UIPanGestureRecognizer *)gesture {
    [self setNeedsDisplay];
}

@end
