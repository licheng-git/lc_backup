//
//  dragViewController.m
//  lcAhwTest
//
//  Created by licheng on 16/6/20.
//  Copyright © 2016年 lc. All rights reserved.
//

#import "dragViewController.h"
#import "KUtils.h"


// UITapGestureRecognizer        // 点击
// UIPinchGestureRecognizer      // 捏合
// UIRotationGestureRecognizer   // 旋转
// UISwipeGestureRecognizer      // 快速滑动、横扫竖扫
// UIPanGestureRecognizer        // 慢速拖动
// UILongPressGestureRecognizer  // 长按


@interface dragViewController()
{
    UIView  *_swipedView;
    UIView  *_bgView;
    CGPoint _startLocation;  // 长按手势坐标
    
    CGPoint        _orginLocation;  // 需互换的视图center位置
    NSMutableArray *_bgSubviewArr;
}
@end

@implementation dragViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"drag";
    _bgView = [[UIView alloc] initWithFrame:CGRectInset(self.view.bounds, 5, 100)];
    [self.view addSubview:_bgView];
    _bgView.layer.borderWidth = 1;
    _bgView.layer.borderColor = [UIColor grayColor].CGColor;
    _bgView.backgroundColor = [UIColor lightGrayColor];
    UIView *v0 = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kSCREEN_WIDTH-30, 50)];
    [_bgView addSubview:v0];
    [self addGestureToView:v0];
    v0.backgroundColor = [UIColor greenColor];
    v0.tag = 100;
    UIView *v1 = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(v0.frame)+10, kSCREEN_WIDTH-30, 50)];
    [_bgView addSubview:v1];
    [self addGestureToView:v1];
    v1.backgroundColor = [UIColor yellowColor];
    v1.tag = 101;
    UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(v1.frame)+10, kSCREEN_WIDTH-30, 50)];
    [_bgView addSubview:v2];
    [self addGestureToView:v2];
    v2.backgroundColor = [UIColor redColor];
    v2.tag = 102;
    _bgSubviewArr = [[NSMutableArray alloc] initWithArray:@[v0, v1, v2]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"结果" style:UIBarButtonItemStylePlain target:self action:@selector(showSortResult:)];
    
    _swipedView = [[UIView alloc] initWithFrame:CGRectMake(10, kSCREEN_HEIGHT-80, kSCREEN_WIDTH-20, 50)];
    [self.view addSubview:_swipedView];
    _swipedView.backgroundColor = [UIColor orangeColor];
    //UISwipeGestureRecognizer *gestureSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionSwipe:)];
    //gestureSwipe.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;  // *_* 一个Swipe手势只能识别一个方向
    //[_bgView addGestureRecognizer:gestureSwipe];
    UISwipeGestureRecognizer *gestureSwipe_up = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionSwipe:)];
    gestureSwipe_up.direction = UISwipeGestureRecognizerDirectionUp;
    [_bgView addGestureRecognizer:gestureSwipe_up];
    UISwipeGestureRecognizer *gestureSwipe_down = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionSwipe:)];
    gestureSwipe_down.direction = UISwipeGestureRecognizerDirectionDown;
    [_bgView addGestureRecognizer:gestureSwipe_down];
}


- (void)addGestureToView:(UIView *)v {
    UILongPressGestureRecognizer *gestureLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(actionLongPress:)];
    //gestureLongPress.minimumPressDuration = 0.5;
    [v addGestureRecognizer:gestureLongPress];
    
    UIPanGestureRecognizer *gesturePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionPan:)];
    [v addGestureRecognizer:gesturePan];
}


- (void)actionSwipe:(UISwipeGestureRecognizer *)gesture {
    if (gesture.direction == UISwipeGestureRecognizerDirectionUp) {
        _swipedView.hidden = NO;
    }
    else if (gesture.direction == UISwipeGestureRecognizerDirectionDown) {
        _swipedView.hidden = YES;
    }
}


- (void)actionLongPress:(UILongPressGestureRecognizer *)gesture {
    UIView *v = gesture.view;
    CGFloat minY = 10;
    CGFloat maxY = _bgView.bounds.size.height - v.bounds.size.height - 10;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按开始");
        v.frame = CGRectInset(v.frame, -5, -5);
        v.alpha = 0.8;
        [_bgView bringSubviewToFront:v];
        _startLocation = [gesture locationInView:v];
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        NSLog(@"长按拖动");
        CGPoint newLocation = [gesture locationInView:v];
        CGFloat deltaY = newLocation.y - _startLocation.y;
        BOOL bOverUp = (v.frame.origin.y<=minY && deltaY<=0);
        BOOL bOverDown = (v.frame.origin.y>=maxY && deltaY>=0);
        if (bOverUp || bOverDown) {
            NSLog(@"超出范围");
            if (bOverUp) {
                v.frame = CGRectMake(v.frame.origin.x, minY, v.frame.size.width, v.frame.size.height);
            }
            else if (bOverDown) {
                v.frame = CGRectMake(v.frame.origin.x, maxY, v.frame.size.width, v.frame.size.height);
            }
            return;
        }
        v.center = CGPointMake(v.center.x, v.center.y+deltaY);
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"长按结束");
        v.frame = CGRectInset(v.frame, 5, 5);
        v.alpha = 1.0;
        if (v.frame.origin.y < minY) {
            v.frame = CGRectMake(v.frame.origin.x, minY, v.frame.size.width, v.frame.size.height);
        }
        else if (v.frame.origin.y > maxY) {
            v.frame = CGRectMake(v.frame.origin.x, maxY, v.frame.size.width, v.frame.size.height);
        }
    }
}


- (void)actionPan:(UIPanGestureRecognizer *)gesture {
    UIView *v = gesture.view;
    CGPoint gestureLocation = [gesture locationInView:_bgView];    // 手势的位置
    CGPoint panTranslation = [gesture translationInView:self.view];  // 手势的移动距离
    
//    // 校验是否可拖
//    CGRect tempFrame = v.frame;
//    CGFloat minY = 10;
//    CGFloat maxY = _bgView.frame.size.height - tempFrame.size.height - 10;
//    BOOL bOverUp = (tempFrame.origin.y<=minY && panTranslation.y<=0);
//    BOOL bOverDown = (tempFrame.origin.y>=maxY && panTranslation.y>=0);
//    if (bOverUp || bOverDown) {
//        NSLog(@"超出范围");
//        if (bOverUp) {
//            tempFrame.origin.y = minY;
//        }
//        if (bOverDown) {
//            tempFrame.origin.y = maxY;
//        }
//        v.frame = tempFrame;
//        return;
//    }
//    
//    // 手势开始时效果
//    if (gesture.state == UIGestureRecognizerStateBegan) {
//        //v.frame = CGRectInset(v.frame, -5, -5);
//        v.alpha = 0.8;
//        [_bgView bringSubviewToFront:v];
//    }
//    
//    // 拖，视图随手势改变位置
//    tempFrame.origin.y += panTranslation.y;
//    v.frame = tempFrame;
//    [gesture setTranslation:CGPointZero inView:self.view];  // 清空手势的移动距离
//    
//    // 手势结束后修正位置
//    if (gesture.state == UIGestureRecognizerStateEnded) {
//        if (v.frame.origin.y < minY) {
//            tempFrame.origin.y = minY;
//            v.frame = tempFrame;
//        }
//        else if (v.frame.origin.y > maxY) {
//            tempFrame.origin.y = maxY;
//            v.frame = tempFrame;
//        }
//        // 手势结束时效果
//        //v.frame = CGRectInset(v.frame, 5, 5);
//        v.alpha = 1.0;
//    }
    
    // 拖动时切换并固定位置
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _orginLocation = v.center;
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        v.center = CGPointMake(v.center.x, v.center.y+panTranslation.y);
        [gesture setTranslation:CGPointZero inView:self.view];
        //for (UIView *subview in _bgSubviewArr) {
        for (UIView *subview in _bgView.subviews) {
            //if (subview.tag == v.tag) {
            if ([subview isEqual:v]) {
                continue;
            }
            BOOL bContain = CGRectContainsPoint(subview.frame, gestureLocation);
            if (!bContain) {
                continue;
            }
            CGPoint tempLocation = subview.center;
            subview.center = _orginLocation;
            _orginLocation = tempLocation;
            //NSInteger tempTag = v.tag;
            //v.tag = subview.tag;
            //subview.tag = tempTag;
        }
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        v.center = _orginLocation;
    }
}

// 显示排序结果
- (void)showSortResult:(id)sender {
    //NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES];
    //NSArray *arrSorted = [_bgSubviewArr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sd, nil]];
    //_bgSubviewArr = [[NSMutableArray alloc] initWithArray:arrSorted];
    
    // 根据subview.frame.origin.y冒泡排序
    for (int i=0; i<_bgSubviewArr.count; i++) {
        for (int j=0; j<_bgSubviewArr.count-1-i; j++) {
            UIView *vj = _bgSubviewArr[j];
            UIView *vj_next = _bgSubviewArr[j+1];
            if (vj.frame.origin.y > vj_next.frame.origin.y) {
                _bgSubviewArr[j] = vj_next;
                _bgSubviewArr[j+1] = vj;
            }
        }
    }
    
    NSLog(@"(%@, %@, %@)", [UIColor greenColor], [UIColor yellowColor], [UIColor redColor]);
    for (UIView *subview in _bgSubviewArr) {
        //NSLog(@"%li", subview.tag);
        NSLog(@"%@", subview.backgroundColor);
    }
}

@end
