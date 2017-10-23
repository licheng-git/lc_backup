//
//  NavBarItemView.m
//  lcAhwTest
//
//  Created by licheng on 15/4/24.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "NavBarItemView.h"
#import "KUtils.h"

@interface NavBarItemView ()
{
    NavBarType _navBarType;
}
@end

@implementation NavBarItemView

- (instancetype)initWithFrame:(CGRect)frame
                   navBarType:(NavBarType)type
                     delegate:(id)delegate
{
    if (self = [super initWithFrame:frame])
    {
        _navBarType = type;
        self.delegate = delegate;
        
        // 添加imageView
        CGSize imgSize = {30.0, 30.0};
        CGRect rect = CGRectMake(0.0, 0.0, imgSize.width, frame.size.height);
        if (_navBarType == RightBarType)
        {
            rect = CGRectMake(self.frame.size.width - imgSize.width, 0.0, imgSize.width, frame.size.height);
        }
        self.barImgView = [[UIImageView alloc] initWithFrame:rect];
        self.barImgView.backgroundColor = [UIColor clearColor];
        self.barImgView.userInteractionEnabled = YES;
        self.barImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.barImgView];
        
        // 添加Label
        rect = CGRectMake(CGRectGetMaxX(self.barImgView.frame),
                          0.0,
                          self.frame.size.width - self.barImgView.frame.size.width,
                          frame.size.height
                          );
        NSInteger align = NSTextAlignmentLeft;
        if (_navBarType == RightBarType)
        {
            rect.origin.x = 0.0;
            align = NSTextAlignmentRight;
        }
        self.barLabel = [KUtils createLabelWithFrame:rect
                                               text:nil
                                           fontSize:13.0
                                      textAlignment:align
                                                tag:kDEFAULT_TAG];
        self.barLabel.backgroundColor = [UIColor clearColor];
        self.barLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.barLabel];
        
        // 添加气泡btn（自己造一个badgeValue）
        UIImage *imgBubble = [UIImage imageNamed:@"top-message-round"];
        CGFloat bubbleX = self.barImgView.frame.size.width - imgBubble.size.width/2;
        CGFloat bubbleY = CGRectGetMinY(self.barImgView.frame) + 3.0;
        rect = CGRectMake(bubbleX, bubbleY, imgBubble.size.width, imgBubble.size.height);
        self.barBtn_bubble = [KUtils createButtonWithFrame:rect
                                                     title:nil
                                                titleColor:[UIColor whiteColor]
                                                    target:nil
                                                       tag:kDEFAULT_TAG];
        self.barBtn_bubble.titleLabel.font = [UIFont systemFontOfSize:10];
        self.barBtn_bubble.backgroundColor = [UIColor clearColor];
        [self.barBtn_bubble setBackgroundImage:imgBubble forState:UIControlStateNormal];
        self.barBtn_bubble.hidden = YES;
        [self.barImgView addSubview:self.barBtn_bubble];
        
        // 添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
    }
    return self;
}

// 点击实现委托
- (void)tapAction:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickNavBarItemView:navBarType:)])
    {
        [self.delegate clickNavBarItemView:self navBarType:_navBarType];
    }
}

// 设置气泡值
- (void)setBubbleTitle:(NSString *)title
{
    self.barBtn_bubble.hidden = title ? NO : YES;
    [self.barBtn_bubble setTitle:title forState:UIControlStateNormal];
}

@end
