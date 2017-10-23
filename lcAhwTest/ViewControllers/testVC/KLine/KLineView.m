//
//  KLineView.m
//  KLine_lcTest
//
//  Created by 李诚 on 17/2/7.
//  Copyright © 2017年 李诚. All rights reserved.
//


// 每次手势时重绘可见区域的k线图

#import "KLineView.h"
#import "KLineEntity.h"

@interface KLineView ()
{
    UIColor *_bgColor;
    UIColor *_candleRiseColor;
    UIColor *_candleFallColor;
    UIColor *_crosslineColor;
    CGFloat _candleWidth;
    CGFloat _candleMaxWidth;
    CGFloat _candleMinWidth;
    CGFloat _shadowLineWith;
    
    int _startDrawIndex;
    int _visibleCandleCount;
    CGFloat _marginLeft;
    BOOL _bCrossLineShowing;
    int _crosslineIndex;
    CGFloat _lastPinchScale;
}
@end

@implementation KLineView

//- (id)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//    }
//    return self;
//}


// 第一次绘图之前的设置
- (void)setArrEntity:(NSArray *)arrEntity {
    if (!arrEntity || arrEntity.count<=0) {
        return;
    }
    _arrEntity = arrEntity;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(GestureAction_Pan:)];
    [self addGestureRecognizer:panGesture];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(GestureAction_Pinch:)];
    [self addGestureRecognizer:pinchGesture];
    UILongPressGestureRecognizer *lpGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(GestureAction_LongPress:)];
    [self addGestureRecognizer:lpGesture];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(GestureAction_Tap:)];
    [self addGestureRecognizer:tapGesture];
    
    _bgColor = [UIColor lightGrayColor];
    _candleRiseColor = [UIColor redColor];
    _candleFallColor = [UIColor greenColor];
    _crosslineColor = [UIColor grayColor];
    _candleWidth = 8;
    _candleMaxWidth = 30;
    _candleMinWidth = 1;
    _shadowLineWith = 1;
    
    _marginLeft = 3;
    _visibleCandleCount = (self.bounds.size.width - _marginLeft) / _candleWidth;
    _startDrawIndex = (int)_arrEntity.count - _visibleCandleCount;
    //_startDrawIndex = _startDrawIndex > 0 ? _startDrawIndex : 0;
    //NSLog(@"_startDrawIndex = %d", _startDrawIndex );
    
    _bCrossLineShowing = NO;
    _lastPinchScale = 1;
    
    //[self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!_arrEntity || _arrEntity.count<=0) {
        return;
    }
    _startDrawIndex = _startDrawIndex > 0 ? _startDrawIndex : 0;
    
    CGFloat maxPrice = CGFLOAT_MIN;
    CGFloat minPrice = CGFLOAT_MAX;
    //for (int i=0; i<_arrEntity.count; i++) {  // 全部
    for (int i=_startDrawIndex; i<_startDrawIndex+_visibleCandleCount&&i<_arrEntity.count; i++) {  // 可见区域
        KLineEntity *entity = _arrEntity[i];
        maxPrice = maxPrice > entity.high ? maxPrice : entity.high;
        minPrice = minPrice < entity.low ? minPrice : entity.low;
    }
    CGFloat coordinateScale = self.bounds.size.height / (maxPrice - minPrice);  // 坐标轴比例转化(仅高度需要转化)
    
    // 背景颜色填充（手势触发时覆盖原来的k线图然后重新绘图）
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _bgColor.CGColor);
    CGContextFillRect(context, rect);
    
    // 绘制可见区域内的k线图
    CGFloat space = _candleWidth / 5.0;
    CGFloat w = _candleWidth - space;
    for (int i=_startDrawIndex; i<_startDrawIndex+_visibleCandleCount&&i<_arrEntity.count; i++) {  // 缩放到最小时靠左
    //int total = _startDrawIndex + _visibleCandleCount < _arrEntity.count ? _startDrawIndex + _visibleCandleCount : (int)_arrEntity.count;
    //for (int i=total-1; i>=_startDrawIndex; i--) {  // 缩放到最小时靠右
        KLineEntity *entity = _arrEntity[i];
        
        // 阴阳线
        CGFloat open = (maxPrice - entity.open) * coordinateScale;
        CGFloat close = (maxPrice - entity.close) * coordinateScale;
        CGFloat hight = (maxPrice - entity.high) * coordinateScale;
        CGFloat low = (maxPrice - entity.low) * coordinateScale;
        CGFloat x = _candleWidth * (i - _startDrawIndex) + _marginLeft;  // 实体x  // 靠左
        //CGFloat x = rect.size.width - (total - i) * _candleWidth - _marginLeft;  // 实体x  // 靠右
        CGFloat x_shadow = x + w/2;  // 影线x
        CGFloat h = 0.0;
        CGFloat y = 0.0;
        if (open < close) {  // 高开低收，跌，阴线
            h = close - open < 1.0 ? 1.0 : (close - open);
            y = open;
            // 实体 绿色＋实心
            CGContextSetFillColorWithColor(context, _candleFallColor.CGColor);
            CGContextFillRect(context, CGRectMake(x, y, w, h));
            // 影线
            CGContextSetStrokeColorWithColor(context, _candleFallColor.CGColor);
            CGContextSetLineWidth(context, _shadowLineWith);
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, x_shadow, hight);
            CGContextAddLineToPoint(context, x_shadow, low);
            CGContextStrokePath(context);
        }
        else if (open > close) {  // 低开高收，涨，阳线
            h = open - close < 1.0 ? 1.0 : (open - close);
            y = close;
            // 实体 红色＋空心
            CGContextSetStrokeColorWithColor(context, _candleRiseColor.CGColor);
            CGContextSetLineWidth(context, 1);
            CGContextStrokeRect(context, CGRectMake(x, y, w, h));
            // 上影线
            CGContextSetStrokeColorWithColor(context, _candleRiseColor.CGColor);
            CGContextSetLineWidth(context, _shadowLineWith);
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, x_shadow, hight);
            CGContextAddLineToPoint(context, x_shadow, y);
            CGContextStrokePath(context);
            // 下影线
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, x_shadow, y+h);
            CGContextAddLineToPoint(context, x_shadow, low);
            CGContextStrokePath(context);
        }
        
        // ma均线
        
        // 成交量
        
        // 日期时间
        
        // 十字线 （竖线在中点显示时间，横线是收盘价close）
        if (_bCrossLineShowing && i==_crosslineIndex) {
            CGContextSetStrokeColorWithColor(context, _crosslineColor.CGColor);
            CGContextSetLineWidth(context, 0.5);
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, x_shadow, 0);
            CGContextAddLineToPoint(context, x_shadow, rect.size.height);
            CGContextMoveToPoint(context, 0, close);
            CGContextAddLineToPoint(context, rect.size.width, close);
            CGContextStrokePath(context);
        }
    }
}


// 拖动
- (void)GestureAction_Pan:(UIPanGestureRecognizer *)gesture {
    CGPoint translationPoint = [gesture translationInView:self];
    [gesture setTranslation:CGPointZero inView:self];
    CGFloat offsetW = translationPoint.x;  // 拖动位移
    //_startDrawIndex -= offsetW / _candleWidth;  // *_* pinch导致可能一直是0
    _startDrawIndex -= offsetW / 10;
//    if (_startDrawIndex <= 0) {
//        NSLog(@"make delegate to get more data");
//    }
    //_startDrawIndex = _startDrawIndex > 0 ? _startDrawIndex : 0;
    [self setNeedsDisplay];
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (_startDrawIndex + _visibleCandleCount > _arrEntity.count) {
            _startDrawIndex = (int)_arrEntity.count - _visibleCandleCount;
            //_startDrawIndex = _startDrawIndex > 0 ? _startDrawIndex : 0;
            [self setNeedsDisplay];
        }
    }
}


// 长按显示十字线
- (void)GestureAction_LongPress:(UILongPressGestureRecognizer *)gesture {
    CGPoint pressPoint = [gesture locationInView:self];
    _crosslineIndex = _startDrawIndex + (pressPoint.x-_marginLeft)/_candleWidth;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _bCrossLineShowing = YES;
    }
    //else if (gesture.state == UIGestureRecognizerStateEnded) {
    //    _bCrossLineShowing = NO;
    //}
    [self setNeedsDisplay];
}

// 单击去掉十字线
- (void)GestureAction_Tap:(UITapGestureRecognizer *)gesture {
    if (!_bCrossLineShowing) {
        return;
    }
    _bCrossLineShowing = NO;
    [self setNeedsDisplay];
}


// 捏合缩放
- (void)GestureAction_Pinch:(UIPinchGestureRecognizer *)gesture {
    _bCrossLineShowing = NO;
    gesture.scale = gesture.scale - _lastPinchScale + 1;
    _candleWidth *= gesture.scale;
    _candleWidth = _candleWidth < _candleMaxWidth ? _candleWidth : _candleMaxWidth;
    _candleWidth = _candleWidth > _candleMinWidth ? _candleWidth : _candleMinWidth;
    int currentVisibleCandleCount = (self.frame.size.width - _marginLeft) / _candleWidth;
    int offsetIndex = (currentVisibleCandleCount - _visibleCandleCount) / 2;
    if (offsetIndex != 0) {
        _visibleCandleCount = currentVisibleCandleCount;
        _startDrawIndex -= offsetIndex;
        //_startDrawIndex = _startDrawIndex > 0 ? _startDrawIndex : 0;
        [self setNeedsDisplay];
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (_startDrawIndex + _visibleCandleCount > _arrEntity.count) {
            _startDrawIndex = (int)_arrEntity.count - _visibleCandleCount;
            //_startDrawIndex = _startDrawIndex > 0 ? _startDrawIndex : 0;
            [self setNeedsDisplay];
        }
    }
    _lastPinchScale = gesture.scale;
}

@end
