//
//  aVC.m
//  lcAhwTest
//
//  Created by licheng on 15/6/30.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "aVC.h"

@interface aVC ()<UIScrollViewDelegate>
{
    UIScrollView  *_scrollView;
    
    UIScrollView  *_scrollViewForZoom;
    UIView        *_zoomView;
    //CGPoint       zoomViewCenter;
}
@end

@implementation aVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"滚动视图＋字体";
    self.view.backgroundColor = [UIColor greenColor];
    
    [self test];
    
    
    //self.navigationController.navigationBarHidden = YES;    // slideVC里面做一个假的navC
    
    /*self.navRightBarItemView.barImgView.image = [UIImage imageNamed:@"menu"];*/
    
}

/*
// NavBarItemViewDelegate 点击导航栏按钮
- (void)clickNavBarItemView:(NavBarItemView *)navBarItemView navBarType:(NavBarType)type
{
    if (type == LeftBarType)
    {
        //[self.navigationController popViewControllerAnimated:YES];
        //self.navigationController 里面只有self一个vc

        if (self.delegate && [self.delegate respondsToSelector:@selector(navPopView)])
        {
            [self.delegate navPopView];
        }

    }
    else if (type == RightBarType)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(changeSlideView)])
        {
            [self.delegate changeSlideView];
        }
    }
}
*/




- (void)test
{
    [self createScrollView];
    [self testFloat];
    [self showFamilyNames];
}


// 创建滚动视图
- (void)createScrollView
{
    // 滚动
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT)];
    _scrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, kSCREEN_HEIGHT * 4.5);
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    // contentSize是可以滚动的区域  *_* 例如frame=(0,0,320,480),contentSize=(320,960)，表示scrollView可以上下滚动，滚动范围是frame.size.height的两倍
    // contentOffset是偏移量  *_* 例如上面的例子，滚到最下面，则contentOffset=(0,480)，即y偏移了480
    // contentInset是内容视图的顶点相对于scrollView的位置  *_* 例如contentInset=(0,100)，表示内容是从scrollView的(0,100)开始显示
    // 另外，子类UITableView通过代理方法实现
    
    // 缩放
    _scrollViewForZoom = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 50, kSCREEN_WIDTH - 20, 350)];
    _scrollViewForZoom.backgroundColor = [UIColor lightGrayColor];
    _scrollViewForZoom.delegate = self;
    _scrollViewForZoom.maximumZoomScale = 2.0;
    _scrollViewForZoom.minimumZoomScale = 0.5;
    _scrollViewForZoom.multipleTouchEnabled = YES;
    [_scrollView addSubview:_scrollViewForZoom];
//    _zoomView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 80)];
//    //_zoomView.center = _scrollViewForZoom.center;
    CGFloat zoomView_W = 100;
    CGFloat zoomView_H = 80;
    CGFloat zoomView_X = (_scrollViewForZoom.frame.size.width - zoomView_W) / 2;
    CGFloat zoomView_Y = (_scrollViewForZoom.frame.size.height - zoomView_H) / 2;
    _zoomView = [[UIView alloc] initWithFrame:CGRectMake(zoomView_X, zoomView_Y, zoomView_W, zoomView_H)];
    _zoomView.backgroundColor = [UIColor orangeColor];
    [_scrollViewForZoom addSubview:_zoomView];
    
    //zoomViewCenter = _zoomView.center;
}

// UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView == _scrollViewForZoom)
    {
        return _zoomView;  // 可以缩放的视图
    }
    else
    {
        return nil;  // nothing happens
    }
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (scrollView == _scrollViewForZoom)
    {
        // 缩放过程中_zoomView.center 居中
        CGFloat boundsW = _scrollViewForZoom.bounds.size.width;
        CGFloat contentW = _scrollViewForZoom.contentSize.width;
        CGFloat offsetX = (boundsW > contentW) ? ((boundsW - contentW) / 2) : 0;
        CGFloat boundsH = _scrollViewForZoom.bounds.size.height;
        CGFloat contentH = _scrollViewForZoom.contentSize.height;
        CGFloat offsetY = (boundsH > contentH) ? ((boundsH - contentH) / 2) : 0;
        _zoomView.center = CGPointMake(contentW/2 + offsetX, contentH/2 + offsetY);
        
        //_zoomView.center = zoomViewCenter;
    }
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
}


- (void)testFloat
{
//    [_scrollView addSubview:kk]  // scrollView滚动时 滚过去
//    [self.view addSubview:kk]    // scrollView滚动时 浮动效果
    
    UIView *unFloatView = [[UIView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH - 70, 80, 50, 40)];
    unFloatView.backgroundColor = [UIColor purpleColor];
    [_scrollView addSubview:unFloatView];
    
//    UIView *floatView = [[UIView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH - 70, 80 , 50, 40)];
//    floatView.backgroundColor = [UIColor purpleColor];
//    [self.view addSubview:floatView];
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:unFloatView];
    UIView *floatView_deepcopy = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    [self.view addSubview:floatView_deepcopy];
}


// 把所有字体名称打印出来
- (void)showFamilyNames
{
    NSString *str = @"字体 abc&ABC123 *_* ";
    NSArray *nameArr = [UIFont familyNames];
    NSLog(@"%i", nameArr.count);
    
    // NSArry排序
//    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"dic.key" ascending:YES];  // yes升序，no降序 ； objArr排序字段为obj.property即dic.key，strArr排序字段为nil）
//    NSArray *nameArrSorted = [nameArr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sd, nil]];
    
    NSArray *nameArrSortedAsc = [nameArr sortedArrayUsingSelector:@selector(compare:)];  // 升序
    NSMutableArray *nameArrSortedDesc = [[NSMutableArray alloc] init];  // 降序（降序要使用到升序）
    for (id obj in [nameArrSortedAsc reverseObjectEnumerator])
    {
        [nameArrSortedDesc addObject:obj];
    }
    
    NSArray *nameArrSorted = nameArrSortedAsc;
    
    CGRect rect = CGRectMake(10, 40, kSCREEN_WIDTH - 20 , 20);
    for (int i=0; i<nameArrSorted.count; i++)
    {
        NSString *fontName = [nameArrSorted objectAtIndex:i];
        UILabel *lb = [[UILabel alloc] initWithFrame:rect];
        lb.text = [str stringByAppendingString:fontName];
        lb.font = [UIFont fontWithName:fontName size:14];  // font.ttf SimHei
        lb.textColor = [UIColor blueColor];
        [_scrollView addSubview:lb];
        rect.origin.y += 30;
    }
}


@end

