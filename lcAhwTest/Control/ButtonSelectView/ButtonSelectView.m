//
//  ButtonSelectView.m
//  lcAhwTest
//
//  Created by licheng on 15/5/5.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "ButtonSelectView.h"
#import "KUtils.h"

@interface ButtonSelectView()
{
    NSInteger       _selectedIndex;   // 当前选中或滑动到的按钮
    UIScrollView    *_scrollView;     // 滑动视图
    NSMutableArray  *_btnArr;         // 顶部选择器
//    NSMutableArray  *_svSubviews;     // 滑动显示的子视图
    UIImage         *_btnBgImg;       // 按钮背景图片 默认
    UIImage         *_btnBgImgSel;    // 按钮选中时图片 默认
}
@end

@implementation ButtonSelectView

- (id)initWithFrame:(CGRect)frame
       btnsTitleArr:(NSArray *)btnsTitles
 scrollViewSubviews:(NSArray *)svSubviews
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _btnArr = [[NSMutableArray alloc] init];
        // 按钮默认背景图片
        _btnBgImg = [[UIImage imageNamed:@"select_btn_bg_normal"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
        _btnBgImgSel = [[UIImage imageNamed:@"select_btn_bg_sel"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
        
        CGFloat btnX = 0.0;
        CGFloat btnY = 0.0;
        CGFloat btnW = frame.size.width / btnsTitles.count;
        CGFloat btnH = SelectControlBtnsHeight;
        CGRect btnFrame = CGRectZero;
        for (int i = 0; i < btnsTitles.count; i++)
        {
            // 横向排列
            btnFrame = CGRectMake(btnX + btnW * i, btnY, btnW, btnH);
            NSString *btnTitle = [btnsTitles objectAtIndex:i];
            UIButton *btn = [KUtils createButtonWithFrame:btnFrame
                                                    title:btnTitle
                                               titleColor:[UIColor lightGrayColor]
                                                   target:self
                                                      tag:kDEFAULT_TAG];
            // 设置为默认的选中和非选中的背景图片
            [btn setBackgroundImage:_btnBgImg forState:UIControlStateNormal];
            [btn setBackgroundImage:_btnBgImgSel forState:UIControlStateSelected];
            // 设置选中和非选中的文字颜色
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
            
            [self addSubview:btn];
            [_btnArr addObject:btn];
        }
        
        // 滚动视图
        _svSubviews = [[NSMutableArray alloc] initWithArray:svSubviews];
        CGFloat svX = 0.0;
        CGFloat svY = btnH + 1.0f;
        CGFloat svW = frame.size.width;
        CGFloat svH = frame.size.height - btnH;
        CGRect svFrame = CGRectMake(svX, svY, svW, svH);
        _scrollView = [[UIScrollView alloc] initWithFrame:svFrame];
        _scrollView.backgroundColor = kBACKGROUND_COLOR;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        CGRect viewFrame = svFrame;
        for (int i=0; i<svSubviews.count; i++)
        {
            UIView *view = [svSubviews objectAtIndex:i];
//            view.frame = CGRectMake(svFrame.size.width * i, 0.0, svFrame.size.width, svFrame.size.height);  // *_* 子视图在init时添加不是太好
            viewFrame.origin = CGPointMake(svFrame.size.width * i, 0.0);  // 视图的原点
            view.frame = viewFrame;
            [_scrollView addSubview:view];
        }
        _scrollView.contentSize = CGSizeMake(svFrame.size.width * svSubviews.count, svFrame.size.height);
        [self addSubview:_scrollView];
        
        //_selectedIndex = 0;
        //[[_btnArr safeObjectAtIndex:_selectedIndex] setSelected:YES];  // 默认选中第一项
        _selectedIndex = -1;  // 默认不要选中，显式调用选择哪一项

    }
    return self;
}

// 按钮点击
- (void)buttonAction:(id)sender
{
    NSInteger btnIndex = [_btnArr indexOfObject:sender];
    [self selectAtIndex:btnIndex];
}

// UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 每页宽度
    CGFloat pageWith = scrollView.frame.size.width;

    // 根据当前的x坐标和页宽计算出当前页数
    int currentPage = floor((scrollView.contentOffset.x - pageWith / 2) / pageWith) + 1;
    if (currentPage >= 0 && currentPage <= (_svSubviews.count - 1))
    {
        [self selectAtIndex:currentPage];
    }
}

// 点击或滑动 定位
- (void)selectAtIndex:(NSInteger)index
{
    // 还是原来的按钮
    if (_selectedIndex == index)
    {
        return;
    }
    
    _selectedIndex = index;
    UIButton *sender = [_btnArr objectAtIndex:_selectedIndex];
    // 设置按钮选中
    for (id btn in _btnArr)
    {
        [btn setSelected:NO];
    }
    [sender setSelected:YES];
    
    // 设置_scrollView当前的滚动位置
    CGRect svVisibleRect = CGRectMake(_scrollView.frame.size.width * _selectedIndex, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    [_scrollView scrollRectToVisible:svVisibleRect animated:YES];
    
    // 委托
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectChangeAt:index:)])
    {
        [self.delegate selectChangeAt:sender index:index];
    }
}

@end
