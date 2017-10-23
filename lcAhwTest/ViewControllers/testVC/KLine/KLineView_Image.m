//
//  KLineView_Image.m
//  KLine_lcTest
//
//  Created by 李诚 on 17/2/8.
//  Copyright © 2017年 李诚. All rights reserved.
//


// 一次全部画完整个k线图

#import "KLineView_Image.h"

@interface KLineView_Image()
{
    CGFloat _lastPinchScale;
    UIView *_tempLine;
}
@end

@implementation KLineView_Image

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    int w = 10;
    int total = 100;
    int space = 3;
    
    CGFloat bgview_W = (w + space) * total + space;
    UIImageView *bgview = [[UIImageView alloc] initWithFrame:CGRectMake(rect.size.width-bgview_W, 0, bgview_W, rect.size.height)];
    [self addSubview:bgview];
    self.layer.masksToBounds = YES;
    bgview.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(GestureAction_Pan:)];
    [bgview addGestureRecognizer:panGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(GestureAction_Pinch:)];
    [bgview addGestureRecognizer:pinchGesture];
    _lastPinchScale = 1;
    
    UILongPressGestureRecognizer *lpGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(GestureAction_LongPress:)];
    [bgview addGestureRecognizer:lpGesture];
    _tempLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bgview_W, 1)];
    _tempLine.backgroundColor = [UIColor grayColor];
    [bgview addSubview:_tempLine];
    _tempLine.hidden = YES;
    
    
    // self.context
    CGContextRef context0 = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context0, [UIColor cyanColor].CGColor);
    CGContextFillRect(context0, rect);
    
    
    // bgview.context
    [bgview.image drawInRect:CGRectMake(0, 0, bgview_W, rect.size.height)];
    UIGraphicsBeginImageContext(bgview.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextFillRect(context, bgview.bounds);
    
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextStrokeRect(context, bgview.bounds);
    
    CGPoint prePoint = CGPointZero;
    for (int i=total; i>0; i--) {
        int h = 20 + arc4random() % 50;  // 随机整数，范围在[from,to)，包括from，不包括to  ->  (int)(from + arc4random() % (to - from + 1))
        CGFloat x = bgview.bounds.size.width - (total-i+1)*(w+space);
        CGFloat y = 20 + arc4random() % 50;
        UIColor *c = (arc4random() %2 == 0) ? [UIColor redColor] : [UIColor blueColor];
        CGContextSetFillColorWithColor(context, c.CGColor);
        CGContextFillRect(context, CGRectMake(x, y, w, h));
        
        CGFloat pointX = x + w/2;
        CGContextSetStrokeColorWithColor(context, c.CGColor);
        CGContextSetLineWidth(context, 1);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, pointX, y-10);
        CGContextAddLineToPoint(context, pointX, y+h+10);
        CGContextStrokePath(context);
        
        if (i < total) {
            CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
            CGContextSetLineWidth(context, 2);
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, prePoint.x, prePoint.y);
            CGContextAddLineToPoint(context, x+w/2, y-10);
            CGContextStrokePath(context);
        }
        prePoint = CGPointMake(x+w/2, y-10);
        
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", i] attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:10] }];
        [attrStr drawInRect:CGRectMake(x, (y+h/4), w, 50)];
    }
    
    bgview.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    // self.context
    //CGContextRef context1 = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context0, [UIColor magentaColor].CGColor);
    CGContextSetLineWidth(context0, 2);
    CGContextStrokeRect(context0, rect);
    [@"fixed" drawInRect:CGRectMake(rect.size.width-50, 50, 50, 20) withAttributes:nil];
}


- (void)GestureAction_Pan:(UIPanGestureRecognizer *)gesture {
    UIView *v = gesture.view;
    CGPoint translationPoint = [gesture translationInView:v];
    v.center = CGPointMake(v.center.x+translationPoint.x, v.center.y);
    [gesture setTranslation:CGPointZero inView:v];
}


- (void)GestureAction_LongPress:(UILongPressGestureRecognizer *)gesture {
    UIView *v = gesture.view;
    CGPoint pressPoint = [gesture locationInView:v];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _tempLine.hidden = NO;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        _tempLine.hidden = YES;
    }
    CGRect tempFrame = _tempLine.frame;
    tempFrame.origin.y = pressPoint.y;
    _tempLine.frame = tempFrame;
}


- (void)GestureAction_Pinch:(UIPinchGestureRecognizer *)gesture {
    UIView *v = gesture.view;
    gesture.scale = gesture.scale - _lastPinchScale + 1;
    CGRect tempFrame = v.frame;
    tempFrame.origin.x = (1-gesture.scale)*self.bounds.size.width/2 + tempFrame.origin.x*gesture.scale;  // 缩放中心点在可见区域中心 （坐标轴上画图写出计算公式再敲代码）
    tempFrame.size.width = tempFrame.size.width * gesture.scale;
    v.frame = tempFrame;
    _lastPinchScale = gesture.scale;
    // *_* 蜡烛可以缩放，线不缩放
}

@end
