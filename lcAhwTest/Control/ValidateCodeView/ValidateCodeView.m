//
//  ValidateCodeView.m
//  lcAhwTest
//
//  Created by licheng on 15/6/10.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "ValidateCodeView.h"

@interface ValidateCodeView()
{
    NSArray *_changeArr;
}
@end


@implementation ValidateCodeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor lightGrayColor];
        [self change];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self change];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // 背景颜色
    float red = arc4random() % 100 / 100.0;
    float green = arc4random() % 100 / 100.0;
    float blue = arc4random() % 100 / 100.0;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    self.backgroundColor = color;
    
    NSString *text = self.codeString;
    CGSize cSize = [@"C" sizeWithFont:[UIFont systemFontOfSize:20.0]];
    int width = rect.size.width / text.length - cSize.width;
    int height = rect.size.height - cSize.height;
    
    CGPoint point;
    float pX, pY;
    for (int i=0; i<text.length; i++)
    {
        pX = arc4random() % width + rect.size.width / text.length * i;
        pY = arc4random() % height;
        point = CGPointMake(pX, pY);
        unichar c = [text characterAtIndex:i];
        NSString *textC = [NSString stringWithFormat:@"%C", c];
        [textC drawAtPoint:point withFont:[UIFont systemFontOfSize:20.0]];
    }
    
    // 干扰线
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    for (int i=0; i<10; i++)
    {
        red = arc4random() % 100 / 100.0;
        green = arc4random() % 100 / 100.0;
        blue = arc4random() % 100 / 100.0;
        color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        CGContextSetStrokeColorWithColor(context, [color CGColor]);
        pX = arc4random() % (int)rect.size.width;
        pY = arc4random() % (int)rect.size.height;
        CGContextMoveToPoint(context, pX, pY);
        pX = arc4random() % (int)rect.size.width;
        pY = arc4random() % (int)rect.size.height;
        CGContextAddLineToPoint(context, pX, pY);
        CGContextStrokePath(context);
    }
}

- (void)change
{
//    _changeArr = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",nil];
    _changeArr = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    self.codeString = [[NSMutableString alloc] init];
    for (int i=0; i<4; i++) {
        NSInteger index = arc4random() % (_changeArr.count-1);
        self.codeString = (NSMutableString *)[self.codeString stringByAppendingString:[_changeArr objectAtIndex:index]];
    }
}

@end
