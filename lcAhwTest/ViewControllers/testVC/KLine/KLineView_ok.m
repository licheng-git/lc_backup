//
//  KLineView_ok.m
//  KLine_lcTest
//
//  Created by 李诚 on 17/2/15.
//  Copyright © 2017年 李诚. All rights reserved.
//



#import "KLineView_ok.h"
#import "KLineEntity.h"

@interface KLineView_ok ()
{
    UIColor *_bgColor;
    UIColor *_bgBorderColor;
    UIColor *_candleRiseColor;
    UIColor *_candleFallColor;
    CGFloat _candleWidth;
    CGFloat _candleMaxWidth;
    CGFloat _candleMinWidth;
    CGFloat _shadowLineWith;
    UIColor *_lbColor;
    CGFloat _lbSize;
    UIColor *_ma5LineColor;
    CGFloat _ma5LineWith;
    UIColor *_crosslineColor;
    
    int _startDrawIndex;
    int _visibleCandleCount;
    CGFloat _margin;
    BOOL _bCrossLineShowing;
    int _crosslineIndex;
    CGFloat _lastPinchScale;
    
    CGFloat _uperChartHeight;
    CGFloat _middleLableHeight;
    CGFloat _bottomChartHeight;
    CGFloat _leftLableWidth;
    CGFloat _contentWidth;
}
@end

@implementation KLineView_ok

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(GestureAction_Pan:)];
        [self addGestureRecognizer:panGesture];
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(GestureAction_Pinch:)];
        [self addGestureRecognizer:pinchGesture];
        UILongPressGestureRecognizer *lpGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(GestureAction_LongPress:)];
        [self addGestureRecognizer:lpGesture];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(GestureAction_Tap:)];
        [self addGestureRecognizer:tapGesture];
        
        _bgColor = [UIColor blackColor];
        _bgBorderColor = [UIColor grayColor];
        _candleRiseColor = [UIColor redColor];
        _candleFallColor = [UIColor greenColor];
        _candleWidth = 8;
        _candleMaxWidth = 30;
        _candleMinWidth = 1;
        _shadowLineWith = 1;
        _lbColor = [UIColor orangeColor];
        _lbSize = 10;
        _ma5LineColor = [UIColor purpleColor];
        _ma5LineWith = 1;
        _crosslineColor = [UIColor blueColor];
        _margin = 3;
        _bCrossLineShowing = NO;
        _lastPinchScale = 1;
    }
    return self;
}


- (void)firstDraw {
    _uperChartHeight = self.bounds.size.height * _uperChartHeightScale;
    _middleLableHeight = 20;
    _bottomChartHeight = self.bounds.size.height - _uperChartHeight - _middleLableHeight;
    _leftLableWidth = 60;
    _contentWidth = self.bounds.size.width - _leftLableWidth;
    
    _visibleCandleCount = (_contentWidth - _margin*2) / _candleWidth;
    _startDrawIndex = (int)_arrEntity.count - _visibleCandleCount;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!_arrEntity || _arrEntity.count<=0) {
        return;
    }
    _startDrawIndex = _startDrawIndex > 0 ? _startDrawIndex : 0;
    CGFloat space = _candleWidth / 5.0;
    CGFloat w = _candleWidth - space;
    CGFloat h_lb = _middleLableHeight;
    NSDictionary *dictLbAttr = @{ NSForegroundColorAttributeName : _lbColor, NSFontAttributeName : [UIFont systemFontOfSize:_lbSize] };
    
    // 背景颜色填充（手势触发时覆盖原来的k线图然后重新绘图）
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _bgColor.CGColor);
    CGContextFillRect(context, rect);
    // 边框
    CGContextSetStrokeColorWithColor(context, _bgBorderColor.CGColor);
    CGContextSetLineWidth(context, 0.5);
    CGContextStrokeRect(context, CGRectMake(_leftLableWidth, 0, _contentWidth, _uperChartHeight));
    CGContextStrokeRect(context, CGRectMake(_leftLableWidth, _uperChartHeight+_middleLableHeight, _contentWidth, _bottomChartHeight));
    
    // 最高价和最低价，最高成交量和最低成交量，坐标轴比例
    CGFloat maxPrice = CGFLOAT_MIN;
    CGFloat minPrice = CGFLOAT_MAX;
    CGFloat maxVolume = 0.0;
    for (int i=_startDrawIndex; i<_startDrawIndex+_visibleCandleCount&&i<_arrEntity.count; i++) {  // 可见区域
        KLineEntity *entity = _arrEntity[i];
        maxPrice = maxPrice > entity.high ? maxPrice : entity.high;
        minPrice = minPrice < entity.low ? minPrice : entity.low;
        maxVolume = maxVolume > entity.volume ? maxVolume : entity.volume;
        if (entity.ma5 > 0) {
            maxPrice = maxPrice > entity.ma5 ? maxPrice : entity.ma5;
            minPrice = minPrice < entity.ma5 ? minPrice : entity.ma5;
        }
    }
    if (maxPrice==minPrice || maxVolume==0) {
        NSLog(@"*_*  maxPrice==minPrice || maxVolume==0");
        return;
    }
    CGFloat coordinateScale = _uperChartHeight / (maxPrice - minPrice);  // 坐标轴比例转化(仅高度需要转化)
    CGFloat coordinateScale_volume = _bottomChartHeight / maxVolume;
    
    // 坐标轴上显示最高价和最低价
    NSString *strMaxPrice = [NSString stringWithFormat:@"%0.2f", maxPrice];
    [strMaxPrice drawInRect:CGRectMake(0, 0, _leftLableWidth, h_lb) withAttributes:dictLbAttr];
    NSString *strMinPrice = [NSString stringWithFormat:@"%0.2f", minPrice];
    [strMinPrice drawInRect:CGRectMake(0, _uperChartHeight-h_lb, _leftLableWidth, h_lb) withAttributes:dictLbAttr];
    // 坐标轴上显示成交量
    NSString *strMaxVolume = [NSString stringWithFormat:@"%0.2f", maxVolume];
    [strMaxVolume drawInRect:CGRectMake(0, _uperChartHeight+h_lb, _leftLableWidth, h_lb) withAttributes:dictLbAttr];
    NSString *strVolumeUnit = @"(万/亿)手";
    [strVolumeUnit drawInRect:CGRectMake(0, self.bounds.size.height-h_lb, _leftLableWidth, h_lb) withAttributes:dictLbAttr];
    // *_* 可以计算一下文字的宽度然后让它靠右
    
    // 绘制可见区域内的k线图
    for (int i=_startDrawIndex; i<_startDrawIndex+_visibleCandleCount&&i<_arrEntity.count; i++) {
        KLineEntity *entity = _arrEntity[i];
        
        // 阴阳线
        CGFloat open = (maxPrice - entity.open) * coordinateScale;
        CGFloat close = (maxPrice - entity.close) * coordinateScale;
        CGFloat hight = (maxPrice - entity.high) * coordinateScale;
        CGFloat low = (maxPrice - entity.low) * coordinateScale;
        CGFloat x = _candleWidth * (i - _startDrawIndex) + _margin + _leftLableWidth;  // 实体x
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
        if (i > 0 && i!=_startDrawIndex) {
            CGFloat x_ma5 = x_shadow;
            CGFloat y_ma5 = (maxPrice - entity.ma5) * coordinateScale;
            KLineEntity *preEntity = _arrEntity[i-1];
            CGFloat x_ma5_pre = x_ma5 - _candleWidth;
            CGFloat y_ma5_pre = (maxPrice - preEntity.ma5) * coordinateScale;
            CGContextSetStrokeColorWithColor(context, _ma5LineColor.CGColor);
            CGContextSetLineWidth(context, _ma5LineWith);
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, x_ma5_pre, y_ma5_pre);
            CGContextAddLineToPoint(context, x_ma5, y_ma5);
            CGContextStrokePath(context);
        }
        
        // 成交量
        CGFloat h_volume = entity.volume * coordinateScale_volume;
        if (open < close) {
            CGContextSetFillColorWithColor(context, _candleFallColor.CGColor);
        }
        else if (open > close) {
            CGContextSetFillColorWithColor(context, _candleRiseColor.CGColor);
        }
        CGContextFillRect(context, CGRectMake(x, self.bounds.size.height-h_volume, w, h_volume));
        
//        // 日期时间 （美观就好，无所谓具体哪天要显示）
//        if (i>_startDrawIndex+5 && i<_arrEntity.count-5) {
//            if (i % (NSInteger)(180/_candleWidth) == 0) {
////                CGContextSetStrokeColorWithColor(context, _bgBorderColor.CGColor);
////                CGContextSetLineWidth(context, 0.5);
////                CGContextBeginPath(context);
////                CGContextMoveToPoint(context, _leftLableWidth, _uperChartHeight/2);
////                CGContextAddLineToPoint(context, _leftLableWidth+_contentWidth, _uperChartHeight/2);
////                CGContextMoveToPoint(context, x_shadow, 0);
////                CGContextAddLineToPoint(context, x_shadow, _uperChartHeight);
////                CGContextMoveToPoint(context, x_shadow, _uperChartHeight+_middleLableHeight);
////                CGContextAddLineToPoint(context, x_shadow, self.bounds.size.height);
////                CGContextStrokePath(context);
//                
//                NSString *strDate = entity.date;
//                CGFloat w_date = 80;
//                [strDate drawInRect:CGRectMake(x_shadow-w_date/2, _uperChartHeight, w_date, _middleLableHeight) withAttributes:dictLbAttr];
//                
//                NSString *strPrice = [NSString stringWithFormat:@"%0.2f", (maxPrice+minPrice)/2];
//                [strPrice drawInRect:CGRectMake(0, (_uperChartHeight-h_lb)/2, _leftLableWidth, h_lb) withAttributes:dictLbAttr];
//            }
//        }
        
        // 十字线 （横线是收盘价close，竖线在中点显示时间）
        if (_bCrossLineShowing && i==_crosslineIndex) {
            CGContextSetStrokeColorWithColor(context, _crosslineColor.CGColor);
            CGContextSetLineWidth(context, 0.5);
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, _leftLableWidth, close);
            CGContextAddLineToPoint(context, _leftLableWidth+_contentWidth, close);
            CGContextMoveToPoint(context, x_shadow, 0);
            CGContextAddLineToPoint(context, x_shadow, self.bounds.size.height);
            CGContextStrokePath(context);
            
            NSString *strDate = entity.date;
            CGFloat w_date = 80;
            [strDate drawInRect:CGRectMake(x_shadow-w_date/2, _uperChartHeight, w_date, _middleLableHeight) withAttributes:dictLbAttr];
            
            NSString *strClosePrice = [NSString stringWithFormat:@"%0.2f", entity.close];
            [strClosePrice drawInRect:CGRectMake(0, close-h_lb/2, _leftLableWidth, h_lb) withAttributes:dictLbAttr];
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
    [self setNeedsDisplay];
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (_startDrawIndex + _visibleCandleCount > _arrEntity.count) {
            _startDrawIndex = (int)_arrEntity.count - _visibleCandleCount;
            [self setNeedsDisplay];
        }
    }
}


// 长按显示十字线
- (void)GestureAction_LongPress:(UILongPressGestureRecognizer *)gesture {
    CGPoint pressPoint = [gesture locationInView:self];
    _crosslineIndex = _startDrawIndex + (pressPoint.x-_leftLableWidth-_margin)/_candleWidth;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _bCrossLineShowing = YES;
    }
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
    int currentVisibleCandleCount = (_contentWidth - _margin*2) / _candleWidth;
    int offsetIndex = (currentVisibleCandleCount - _visibleCandleCount) / 2;
    if (offsetIndex != 0) {
        _visibleCandleCount = currentVisibleCandleCount;
        _startDrawIndex -= offsetIndex;
        [self setNeedsDisplay];
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (_startDrawIndex + _visibleCandleCount > _arrEntity.count) {
            _startDrawIndex = (int)_arrEntity.count - _visibleCandleCount;
            [self setNeedsDisplay];
        }
    }
    _lastPinchScale = gesture.scale;
}

@end
