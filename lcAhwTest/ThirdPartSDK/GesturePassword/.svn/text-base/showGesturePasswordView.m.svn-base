//
//  showGesturePasswordView.m
//  GesturePassword
//
//  Created by hhx on 14-10-23.
//  Copyright (c) 2014年 黑と白の印记. All rights reserved.
//

#import "showGesturePasswordView.h"

#define LABEL_BASE_TAG         11110

#define ROW_COUNT              3
#define COLUM_COUNT            3


@implementation showGesturePasswordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createView];
    }
    
    return self;
}

- (void)createView
{
    int row = 0;
    int colum = 0;
    
    const CGFloat space = 6.0;
    CGFloat width = ((self.frame.size.width - 2*space)/COLUM_COUNT);
    CGFloat height = width;
    
    for (int i = 0; i < 9; i++)
    {
        row = i/ROW_COUNT;
        colum = i%COLUM_COUNT;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(colum*(space + width), row*(space + height), width, height)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label.layer setCornerRadius:width/2.0];
        [label.layer setBorderColor:[UIColor whiteColor].CGColor];
        [label.layer setBorderWidth:3];
        label.tag = i + LABEL_BASE_TAG;
        [self addSubview:label];
    }
}

// 改变状态
- (void)changeStateWithTouchesArray:(NSArray *)touchesArray
{
    // 当touchesArray == nil时，还原初始状态 add by hhx 2015.03.11
    if (touchesArray == nil)
    {
        for (int i = 0; i < 9; i++)
        {
            UILabel *label = (UILabel *)[self viewWithTag:(i + LABEL_BASE_TAG)];
            if (label)
            {
                [label.layer setBackgroundColor:[UIColor clearColor].CGColor];
                [label.layer setBorderColor:[UIColor whiteColor].CGColor];
            }
        }
        
        return;
    }
    
    for (NSDictionary * num in touchesArray)
    {
        NSString *numStr = [num objectForKey:@"num"];
        if(!numStr)
            break;
        
        int number = [numStr intValue];
        UILabel *label = (UILabel *)[self viewWithTag:(number + LABEL_BASE_TAG)];
        if (label)
        {
            [label.layer setBorderColor:[UIColor blueColor].CGColor];
            [label.layer setBackgroundColor:[UIColor blueColor].CGColor];
        }
    }
}

@end
