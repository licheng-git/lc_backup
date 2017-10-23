//
//  HMBannerView.m
//  lcAhwTest
//
//  Created by licheng on 15/4/16.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "HMBannerView.h"

#define Banner_StartTag    1000
#define Banner_StartTag1 2000

@interface HMBannerView()
{
    UIScrollView                 *_scrollView;
    UIPageControl                *_pageControl;
    NSArray                      *_imgArr;
    BannerViewScrollDirection    _scrollDirection;
    BOOL                         _enableRolling;
    NSInteger                    _totalPage;
    NSInteger                    _currentPage;
    
    NSTimer  *_timer;
}
@end


@implementation HMBannerView

- (id)initWithFrame:(CGRect)frame
    scrollDirection:(BannerViewScrollDirection)direction
             images:(NSArray *)images
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // 没有下发图片
        if (!images || images.count==0)
        {
            return self;
        }
        
        _imgArr = [[NSArray alloc] initWithArray:images];
        _scrollDirection = direction;
        _totalPage = _imgArr.count;
        _currentPage = 0;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        if (_totalPage < 2)
        {
            // 不滚
            _scrollView.scrollEnabled = NO;
        }
        if (_scrollDirection == ScrollDirectionLandscape)
        {
            // 水平方向滚
            _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _totalPage, _scrollView.frame.size.height);
        }
        else if (_scrollDirection == ScrollDirectionPortait)
        {
            // 垂直方向滚
            _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height * _totalPage);
        }
        
        
        //for (NSInteger i=0; i<_totalPage; i++) // scrollView添加图片
        for (NSInteger i=0; i<3; i++) // scrollView添加UIImageView，不添加图片
        {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
            //imgView.image = [imgArr objectAtIndex:i]; // 循环滚需动态添加图片
            imgView.tag = Banner_StartTag + i;
            
            imgView.userInteractionEnabled = YES;  // *_* 允许触发gesture
            
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [imgView addGestureRecognizer:singleTap];
            
            if (_scrollDirection == ScrollDirectionLandscape)
            {
                // 逐个左移
                imgView.frame = CGRectOffset(imgView.frame, _scrollView.frame.size.width * i, 0);
            }
            else if (_scrollDirection == ScrollDirectionPortait)
            {
                // 逐个下移
                imgView.frame = CGRectOffset(imgView.frame, 0, imgView.frame.size.height * i);
            }
            [_scrollView addSubview:imgView];
        }
        
        [self refreshScrollView];
        
        CGFloat pageControlW = 70.0;
        CGFloat pageControlH = 20.0;
        CGFloat pageControlX = self.frame.size.width - pageControlW - 20.0;
        CGFloat pageControlY = self.frame.size.height - pageControlH;
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(pageControlX, pageControlY, pageControlW, pageControlH)];
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.numberOfPages = _totalPage;
        _pageControl.currentPage = 0;
        _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        [self addSubview:_pageControl];
        
        if (_totalPage < 2)
        {
            _pageControl.hidden = YES;
            [self stopRolling]; // 不允许自动滚
        }
        else
        {
            _pageControl.hidden = NO;
            [self startRolling]; // 可以自动滚
        }
    }
    return self;
}

// 刷新scrollView 不需要对整个imgArr做排序，只需从中取出当前页，前一页，下一页三项即可
- (void)refreshScrollView
{
    NSArray *currentImgs = [self getDisplayImagesWithCurrentPageIndex];
    // 添加图片
    for (NSInteger i=0; i<3; i++)
    {
        UIImageView *imgView = (UIImageView *)[_scrollView viewWithTag:Banner_StartTag + i];
        if (imgView && [imgView isKindOfClass:[UIImageView class]])
        {
            //imgView.image = [currentImgs objectAtIndex:i];
            
            // 异步下载，不至于卡死；自动使用缓存
            [imgView sd_setImageWithURL:[currentImgs objectAtIndex:i] placeholderImage:nil];
        }
    }
    
    // scrollView定位到中间的图片
    if (_scrollDirection == ScrollDirectionLandscape)
    {
        _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0);
    }
    else if (_scrollDirection == ScrollDirectionPortait)
    {
        _scrollView.contentOffset = CGPointMake(0, _scrollView.frame.size.height);
    }
    
    _pageControl.currentPage = _currentPage;
}


// 从imgArr中取出当前页，前一页，下一页三项 （不需要对整个imgArr做排序）
- (NSArray *)getDisplayImagesWithCurrentPageIndex
{
    // 前一页index
    NSInteger pre = _currentPage - 1;
    if (_currentPage == 0)
    {
        // 若当前是第一页，则前一页为最后一页
        pre = _totalPage - 1;
    }
    
    NSInteger next = _currentPage + 1;
    if (_currentPage == _totalPage - 1)
    {
        next = 0;
    }
    
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:3];
    [images addObject:[_imgArr objectAtIndex:pre]];
    [images addObject:[_imgArr objectAtIndex:_currentPage]];
    [images addObject:[_imgArr objectAtIndex:next]];
    
    return images;
}

// UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    NSInteger xy;
    NSInteger wh;
    if (_scrollDirection == ScrollDirectionLandscape)
    {
        xy = sender.contentOffset.x;
        wh = sender.frame.size.width;
    }
    else if (_scrollDirection == ScrollDirectionPortait)
    {
        xy = sender.contentOffset.y;
        wh = sender.frame.size.height;
    }
    
    // 向后滚
    if (xy >= wh * 2)
    {
        if (_currentPage == _totalPage - 1)
        {
            // 最后一页 滚回去第一页
            _currentPage = 0;
        }
        else
        {
            // 非最后一页，向后滚一个
            _currentPage += 1;
        }
        [self refreshScrollView];
    }
    
    // 向前滚
    if (xy <= 0)
    {
        if (_currentPage == 0)
        {
            // 第一页 滚到最后一页
            _currentPage = _totalPage - 1;
        }
        else
        {
            // 非第一页，向前滚一个
            _currentPage -= 1;
        }
        [self refreshScrollView];
    }
}

// 停止自动滚
- (void)stopRolling
{
    _enableRolling = NO;
    // 取消已加入的延迟线程
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(rollingScrollAction)
                                               object:nil];
    
    //[_timer invalidate];
}

// 自动滚
- (void)startRolling
{
    if (_imgArr.count < 2)
    {
        return;
    }
    [self stopRolling];
    _enableRolling = YES;
    
    [self performSelector:@selector(rollingScrollAction)
               withObject:nil
               afterDelay:self.rollingDelayTime];
    
//    _timer = [NSTimer scheduledTimerWithTimeInterval:3.0
//                                              target:self
//                                            selector:@selector(rollingScrollAction)
//                                            userInfo:nil
//                                             repeats:YES];
//    //[_timer fire];
//    [_timer setFireDate:[NSDate distantPast]];
}

- (void)rollingScrollAction
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         if (_scrollDirection == ScrollDirectionLandscape)
                         {
                             _scrollView.contentOffset = CGPointMake(1.99*_scrollView.frame.size.width, 0);
                         }
                         else if (_scrollDirection == ScrollDirectionPortait)
                         {
                             _scrollView.contentOffset = CGPointMake(0, 1.99*_scrollView.frame.size.height);
                         }
                     }
                     completion:^(BOOL finished){
                         if (_currentPage == _totalPage -1)
                         {
                             _currentPage = 0;
                         }
                         else
                         {
                             _currentPage += 1;
                         }
                         [self refreshScrollView];
                         
                         if (_enableRolling)
                         {
                             [self performSelector:@selector(rollingScrollAction)
                                        withObject:nil
                                        afterDelay:self.rollingDelayTime];
                         }
                     }];
    
//    if (!_enableRolling)
//    {
//        //[_timer invalidate];  // 永久停止
//        [_timer setFireDate:[NSDate distantPast]];  // 还能再起来
//    }
    
}


// 图片点击触发委托
- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if ([self.bDelegate respondsToSelector:@selector(bannerView:didSelectImageView:)])
    {
        [self.bDelegate bannerView:self didSelectImageView:_currentPage];
    }
}

@end
