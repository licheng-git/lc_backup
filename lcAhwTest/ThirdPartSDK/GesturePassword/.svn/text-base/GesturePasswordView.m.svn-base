//
//  GesturePasswordView.m
//  GesturePassword
//
//  Created by hb on 14-8-23.
//  Copyright (c) 2014年 黑と白の印记. All rights reserved.
//

#import "GesturePasswordView.h"
#import "GesturePasswordButton.h"
#import "TentacleView.h"


#define SCREEN_WIDTH           [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT          [[UIScreen mainScreen] bounds].size.height

#define IOS_VERSION            [[[UIDevice currentDevice] systemVersion] floatValue]
#define IS_iPhone4Or4s   ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_ABOVE_IOS7          ((IOS_VERSION >= 7.0) ? YES : NO)

//#define ImageView_Y            ((!IS_iPhone4Or4s) ? 60.0 : 20.0)  // 顶部头像Y坐标
//#define BottomBtnOffset        ((!IS_iPhone4Or4s) ? 50.0 : 40.0)  // 底部按钮Y偏移

#define BACKGROUND_COLOR       [UIColor colorWithRed:71/255.0 green:71/255.0 blue:73/255.0 alpha:1]

#define ROW_COUNT              3
#define COLUM_COUNT            3

@implementation GesturePasswordView {
    NSMutableArray * buttonArray;
    
    CGPoint lineStartPoint;
    CGPoint lineEndPoint;
    
}
@synthesize imgView;
@synthesize forgetButton;
@synthesize changeButton;

@synthesize tentacleView;
@synthesize name, state;
@synthesize gesturePasswordDelegate;

- (id)initWithFrame:(CGRect)frame isResetPwd:(BOOL)isResetPwd
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        CGFloat imageView_Y = 60.0;
        if (IS_iPhone4Or4s && !IS_ABOVE_IOS7)
        {
            imageView_Y = 20.0;
        }
        else if (IS_iPhone4Or4s && IS_ABOVE_IOS7)
        {
            imageView_Y = 40.0;
        }
        
        // 头像或显示设置手势图
        _isResetPwd = isResetPwd;
        const CGFloat view_Y = imageView_Y;
        const CGFloat view_W = 70.0f;
        const CGFloat view_H = 70.0f;
        CGRect rect = CGRectMake((frame.size.width-view_W)/2, view_Y, view_W, view_H);
        
        // 重置密码时，显示记录手势密码
        _showGesturePwdView = [[showGesturePasswordView alloc] initWithFrame:rect];
        [self addSubview:_showGesturePwdView];
        
        // 验证密码时，显示头像
        imgView = [[UIImageView alloc]initWithFrame:rect];
        imgView.image = kIMG(@"account_head_image");
        [imgView setBackgroundColor:[UIColor whiteColor]];
        [imgView.layer setCornerRadius:view_W/2];
        [imgView.layer setBorderColor:[UIColor grayColor].CGColor];
        [imgView.layer setBorderWidth:3];
        [self addSubview:imgView];
        
        if (_isResetPwd)
        {   // 重置密码时
            _showGesturePwdView.hidden = NO;
            imgView.hidden = YES;
        }
        else
        {   // 验证密码时
            _showGesturePwdView.hidden = YES;
            imgView.hidden = NO;
        }
        
        UIFont *font = [UIFont systemFontOfSize:KFONTSIZE_14];
        
        // 账号名 add by hhx 2015.03.12
        const CGFloat space = 10.0f;
        const CGFloat name_W = 280.0f;
        const CGFloat name_X = (frame.size.width - name_W)/2;
        const CGFloat name_Y = rect.origin.y + rect.size.height + space;
        const CGFloat name_H = 20.0f;
        rect = CGRectMake(name_X, name_Y, name_W, name_H);
        name = [[UILabel alloc]initWithFrame:rect];
        [name setTextAlignment:kTextAlignmentCenter];
        [name setTextColor:[UIColor whiteColor]];
        [name setFont:font];
        [name setBackgroundColor:[UIColor clearColor]];
        [self addSubview:name];
        
        // 提示语
        const CGFloat state_W = name_W;
        const CGFloat state_X = (frame.size.width - state_W)/2;
        const CGFloat state_Y = rect.origin.y + rect.size.height/* + space*/;
        const CGFloat state_H = 20.0f;
        rect = CGRectMake(state_X, state_Y, state_W, state_H);
        state = [[UILabel alloc]initWithFrame:rect];
        [state setTextAlignment:kTextAlignmentCenter];
        [state setTextColor:[UIColor whiteColor]];
        [state setFont:font];
        [state setBackgroundColor:[UIColor clearColor]];
        [self addSubview:state];
        
        // 初始提示语 add by hhx 2015.03.11
        if (_isResetPwd)
        {
            [state setText:@"请绘制您的手势密码"];
        }
        
        // 设置手势界面
        buttonArray = [[NSMutableArray alloc]initWithCapacity:0];
        
        // Button Frame
        CGFloat margin = 30.0f;
        CGFloat width = (frame.size.width - 4*margin)/3;
        CGFloat height = width;
        
        // view frame
        rect.origin.x = 0.0f;
        rect.origin.y = rect.origin.y + rect.size.height + space;
        rect.size = CGSizeMake(frame.size.width, frame.size.width - margin*2);
        UIView * view = [[UIView alloc]initWithFrame:rect];
        
        for (int i=0; i<9; i++) {
            NSInteger row = i/ROW_COUNT;
            NSInteger col = i%COLUM_COUNT;
            CGRect btnFrame = CGRectMake(col*(width+margin) + margin, row*(height + margin), width, height);
            GesturePasswordButton * gesturePasswordButton = [[GesturePasswordButton alloc]initWithFrame:btnFrame];
            [gesturePasswordButton setTag:i];
            [view addSubview:gesturePasswordButton];
            [buttonArray addObject:gesturePasswordButton];
        }
//        [view setBackgroundColor:[UIColor greenColor]];
        [self addSubview:view];
        
        tentacleView = [[TentacleView alloc]initWithFrame:view.frame];
        [tentacleView setButtonArray:buttonArray];
        [tentacleView setTouchBeginDelegate:self];
        [self addSubview:tentacleView];
        
    
//        CGFloat bottomBtnOffset = 50.0;
//        if (IS_iPhone4Or4s && !IS_ABOVE_IOS7)
//        {
//            bottomBtnOffset = 50.0;
//        }
//        else if (IS_iPhone4Or4s && IS_ABOVE_IOS7)
//        {
//            bottomBtnOffset = 30.0;
//        }
        
        // 忘记手势密码 按钮
        const CGFloat forget_X = margin;
        const CGFloat forget_Y = rect.origin.y + rect.size.height + 30;//frame.size.height - bottomBtnOffset;
        const CGFloat forget_W = (frame.size.width - 2*forget_X)/2;
        const CGFloat forget_H = 20.0;
        forgetButton = [[UIButton alloc] initWithFrame:CGRectMake(forget_X, forget_Y, forget_W, forget_H)];
        [forgetButton.titleLabel setFont:font];
        [forgetButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [forgetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [forgetButton.titleLabel setTextColor:[UIColor whiteColor]];// 没用
        [forgetButton setTitle:@"忘记手势密码？" forState:UIControlStateNormal];
//        [forgetButton setBackgroundColor:[UIColor redColor]];
        [forgetButton addTarget:self action:@selector(forget) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:forgetButton];
        
        // 改变手势密码 / 切换账号登录
        const CGFloat change_W = forget_W;
        const CGFloat change_H = forget_H;
        const CGFloat change_X = forget_X + forget_W;
        const CGFloat change_Y = forget_Y;
        changeButton = [[UIButton alloc]initWithFrame:CGRectMake(change_X, change_Y, change_W, change_H)];
        [changeButton.titleLabel setFont:font];
        [changeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];;
        [changeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [changeButton setTitle:@"用其他账号登录" forState:UIControlStateNormal];
//        [changeButton setBackgroundColor:[UIColor blueColor]];
        [changeButton addTarget:self action:@selector(change) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:changeButton];
        
        [self setBackgroundColor:BACKGROUND_COLOR];
    }
    
    return self;
}

// delete by hhx 2014.10.24
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
//    CGFloat colors[] =
//    {
//        134 / 255.0, 157 / 255.0, 147 / 255.0, 1.00,
//        3 / 255.0,  3 / 255.0, 37 / 255.0, 1.00,
//    };
//    CGGradientRef gradient = CGGradientCreateWithColorComponents
//    (rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
//    CGColorSpaceRelease(rgb);
//    CGContextDrawLinearGradient(context, gradient,CGPointMake
//                                (0.0,0.0) ,CGPointMake(0.0,self.frame.size.height),
//                                kCGGradientDrawsBeforeStartLocation);
//}

- (void)gestureTouchBegin {
    [self.state setText:@""];
}

- (void)gestureTouchEnd:(NSArray *)touchsArray {
    [_showGesturePwdView changeStateWithTouchesArray:touchsArray];
}

-(void)forget {
    [gesturePasswordDelegate forget];
}

-(void)change {
    [gesturePasswordDelegate change];
}


@end
