//
//  CustomTabBar.m
//  lcAhwTest
//
//  Created by licheng on 15/4/9.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "CustomTabBarView.h"
#import "KUtils.h"
#import "Constants.h"


@implementation CustomTabBarView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles delegate:(id)delegate
{
    if (self = [super initWithFrame:frame])
    {
        _cDelegate = delegate;
        
        self.backgroundColor = kCOLORRGB(246,246,246);
        CGFloat btn_w = [[UIScreen mainScreen] bounds].size.width / titles.count;
        CGFloat btn_h = CGRectGetHeight(self.frame);
        for (NSInteger i = 0; i < titles.count; i++)
        {
            CGRect rect = CGRectMake(btn_w*i, 0.0, btn_w, btn_h);
            UIButton *btn = [KUtils createButtonWithFrame:rect
                                                    title:[titles objectAtIndex:i]
                                               titleColor:[UIColor grayColor]
                                                   target:self
                                                      tag:HomePageBtn_tag + i];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [self addSubview:btn];
            if (i == 0)
            {
                btn.selected = YES;
            }
        }
    }
    return self;
}

- (void)buttonAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (_cDelegate && [_cDelegate respondsToSelector:@selector(clickAtCustomTabBar:)])
    {
        // 调用委托
        BOOL deleGoOn = [_cDelegate clickAtCustomTabBar:btn.tag - BAR_BASETAG];
        if (deleGoOn)
        {
            // 改变颜色
            btn.selected = YES;
            for (UIView *sView in self.subviews)
            {
                if ([sView isKindOfClass:[UIButton class]])
                {
                    UIButton *temp = (UIButton *)sView;
                    if (temp.tag != btn.tag)
                    {
                        temp.selected = NO;
                    }
                }
            }
        }
    }
}

- (void)setCurrentSelectedBtn:(NSInteger)index
{
    index += BAR_BASETAG;
    UIButton *btn = (UIButton *)[self viewWithTag:index];
    [self buttonAction:btn];
}

@end
