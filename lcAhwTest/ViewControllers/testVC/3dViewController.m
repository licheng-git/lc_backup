//
//  3dViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/12/22.
//  Copyright © 2015年 lc. All rights reserved.
//

#import "3dViewController.h"

@interface _3dViewController()
{
    UIButton *_btn0;
    UIButton *_btn1;
    UIButton *_btn2;
    UIButton *_btn3;
    UIButton *_btn4;
    UIButton *_btn5;
}
@end

@implementation _3dViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createAnimation3D];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"3d";
    
    UIImageView *imgView_Normal = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH - 140, 80, 120, 120)];
    imgView_Normal.image = [UIImage imageNamed:@"type_salary_image"];
    [self.view addSubview:imgView_Normal];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 80, 120, 120)];
    imgView.image = [UIImage imageNamed:@"type_salary_image"];
    [self.view addSubview:imgView];
    UIView *bgView = [[UIView alloc] initWithFrame:imgView.frame];
    bgView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:bgView];
    UIView *lineX0 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(bgView.frame), kSCREEN_WIDTH, 1)];
    lineX0.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:lineX0];
    UIView *lineX1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMidY(bgView.frame), kSCREEN_WIDTH, 1)];
    lineX1.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:lineX1];
    UIView *lineX2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bgView.frame), kSCREEN_WIDTH, 1)];
    lineX2.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:lineX2];
    UIView *lineY0 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(bgView.frame), 0, 1, kSCREEN_HEIGHT)];
    lineY0.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:lineY0];
    UIView *lineY1 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(bgView.frame), 0, 1, kSCREEN_HEIGHT)];
    lineY1.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:lineY1];
    UIView *lineY2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bgView.frame), 0, 1, kSCREEN_HEIGHT)];
    lineY2.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:lineY2];
    
    
    
//    // 2d  CGAffineTransform  view.tansform
//    
//    imgView.transform = CGAffineTransformMakeTranslation(50, 0);  // 位移
//    imgView.transform = CGAffineTransformMakeScale(0.5, 1);  // 缩放
//    imgView.transform = CGAffineTransformMakeRotation(M_PI*0.25);  // 旋转（绕着中点imgView.center，+顺时针，-逆时针）
//    imgView.transform = CGAffineTransformIdentity;  // 还原

//    imgView.layer.anchorPoint = CGPointZero;  // 默认(0.5,0.5,0)
//    //imgView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI*0.25);

//    CGAffineTransform translate = CGAffineTransformMakeTranslation(50, 0);
//    CGAffineTransform scale = CGAffineTransformMakeScale(0.5, 1);
//    CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI*0.25);
//    imgView.transform = CGAffineTransformInvert(translate);  // 颠倒（相反效果）
//    imgView.transform = CGAffineTransformConcat(rotate, scale);  // 串联（组合效果，区别先后顺序）  先rotate再scale
//    imgView_Normal.transform = CGAffineTransformRotate(scale, M_PI*0.25);  // 同上，组合效果，先旋转再缩放
//
//    // CGAffineTransformIdentity组合时无差别
//    imgView.transform = CGAffineTransformMakeRotation(M_PI*0.25);
//    imgView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI*0.25);
//    imgView.transform = CGAffineTransformConcat(CGAffineTransformIdentity, rotate);
//    imgView.transform = CGAffineTransformConcat(rotate, CGAffineTransformIdentity);
    
//    imgView.transform = CGAffineTransformMake(1, 0, -0.5, 1, 0, 0);  // *_*
////    CGAffineTransform  仿射变换  矩阵
////    |a    b    0|
////    |c    d    0|
////    |tx   ty   1|
////    默认值为单位矩阵（a=d=1，其他为0）  *_*其中tx,ty为平移距离，a,d为缩放比例系数，b,c为旋转角度
////    位移是矩阵相加，旋转和缩放是矩阵相乘
////    View上的点坐标为{x,y}，变化后是{x',y'}，则 {x',y',1} = {x, y, 1} * 矩阵 ＝ (x*a+y*c+1*tx, x*b+y*d+1*ty, 1)
    
    
    
    // 3d  CATransform3D  view.layer.tansform
    
//    imgView.layer.transform = CATransform3DMakeTranslation(50, 0, 0); // 位移
//    imgView.layer.transform = CATransform3DMakeScale(0.5, 1, 1);  // 缩放
//    imgView.layer.transform = CATransform3DMakeRotation(M_PI*0.25, 0, 0, 1);  // 旋转（绕着坐标轴线  *_*垂直屏幕的为z轴，向里）
    
    // 透视投影
    bgView.layer.anchorPointZ = 100;
    CATransform3D perspective = CATransform3DIdentity;
    CGFloat d = 200;
    perspective.m34 = -1 / d;  // m34默认为0（d默认无穷大），d表示观察者眼睛到投射面到距离
//    struct CATransform3D
//    {
//        CGFloat m11（x缩放）, m12（y切变）, m13（）, m14（）;
//        CGFloat m21（x切变）, m22（y缩放）, m23（）, m24（）;
//        CGFloat m31（）, m32（）, m33（）, m34（透视）;
//        CGFloat m41（x平移）, m42（y平移）, m43（z平移）, m44（）;
//    };
    //imgView.layer.transform = CATransform3DRotate(perspective, M_PI*0.25, 1, 0, 0);  // 先旋转后透视
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DConcat(transform, CATransform3DMakeRotation(M_PI *0.25, 1, 0, 0));
    transform = CATransform3DConcat(transform, perspective);
    imgView.layer.transform = transform;
    
//    imgView.layer.transform = CATransform3DPerspective(rotateX, imgView.center, 200);
}


// 透视投影
CG_EXTERN CATransform3D
CATransform3DMakePerspective(CGPoint center, float disZ)
{
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f/disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}

CG_INLINE CATransform3D
CATransform3DPerspective(CATransform3D t, CGPoint center, float disZ)
{
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ));
}

- (CATransform3D)createPerspective:(CATransform3D)rotate
{
    CATransform3D perspective = CATransform3DIdentity;
    CGFloat d = 200;
    perspective.m34 = -1 / d;  // m34默认为0（d默认无穷大），d表示观察者眼睛到投射面到距离
//    struct CATransform3D
//    {
//        CGFloat m11（x缩放）, m12（y切变）, m13（）, m14（）;
//        CGFloat m21（x切变）, m22（y缩放）, m23（）, m24（）;
//        CGFloat m31（）, m32（）, m33（）, m34（透视）;
//        CGFloat m41（x平移）, m42（y平移）, m43（z平移）, m44（）;
//    };
    perspective = CATransform3DConcat(rotate, perspective);  // 旋转在先
    return perspective;
}




// 3d动画效果
- (void)createAnimation3D
{
    CGFloat btnW = 100;
    _btn0 = [self addBtn:CGRectMake(30, 230, btnW, btnW) title:@"plane00" tag:0];
    _btn1 = [self addBtn:_btn0.frame title:@"plane01" tag:1];
    _btn2 = [self addBtn:_btn0.frame title:@"plane02" tag:2];
    _btn3 = [self addBtn:_btn0.frame title:@"plane03" tag:3];
    _btn4 = [self addBtn:_btn0.frame title:@"plane04" tag:4];
    _btn5 = [self addBtn:_btn0.frame title:@"plane05" tag:5];
    CGFloat angle = M_PI * 0.45;
//    _btn0.layer.anchorPointZ = -btnW/2;  // 正面
//    _btn5.layer.anchorPointZ = btnW/2;  // 背面
//    _btn5.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);  // 背面倒转
    [UIView animateWithDuration:3 animations:^{
        
        CATransform3D rotate = CATransform3DMakeRotation(angle, 1, 0, 0);  // 旋转到垂直屏幕
        CATransform3D perspective = [self createPerspective:rotate];  // 透视
        CATransform3D translate = CATransform3DMakeTranslation(0, -btnW/2, 0);  // 上移到顶部
        _btn1.layer.transform = CATransform3DConcat(perspective, translate);  // 动画
        rotate = CATransform3DMakeRotation(-angle, 1, 0, 0);
        perspective = [self createPerspective:rotate];
        translate = CATransform3DMakeTranslation(0, btnW/2, 0);
        _btn2.layer.transform = CATransform3DConcat(perspective, translate);
        
        rotate = CATransform3DMakeRotation(angle, 0, 1, 0);
        perspective = [self createPerspective:rotate];
        translate = CATransform3DMakeTranslation(-btnW/2, 0, 0);
        _btn3.layer.transform = CATransform3DConcat(perspective, translate);
        rotate = CATransform3DMakeRotation(angle, 0, -1, 0);
        perspective = [self createPerspective:rotate];
        translate = CATransform3DMakeTranslation(btnW/2, 0, 0);
        _btn4.layer.transform = CATransform3DConcat(perspective, translate);
        
        _btn0.alpha = 0;
        _btn5.layer.opacity = 0;
        
    } completion:^(BOOL finished) {
        
    }];
    
    
    UIButton *btn10 = [self addBtn:CGRectMake(30, 420, btnW, btnW) title:@"plane10" tag:10];
    UIButton *btn11 = [self addBtn:CGRectMake(30, 320, btnW, btnW) title:@"plane11" tag:11];
    UIButton *btn12 = [self addBtn:CGRectMake(130, 420, btnW, btnW) title:@"plane12" tag:12];
    UIButton *btn13 = [self addBtn:btn10.frame title:@"plane13" tag:13];
    btn13.layer.anchorPoint = CGPointMake(0.5, -0.5);  // frame=(30,520,100,100)，不仅仅改变frame，还会影响3d变换
    NSLog(@"(x=%f,y=%f)", btn13.frame.origin.x, btn13.frame.origin.y);
    UIButton *btn14 = [self addBtn:btn10.frame title:@"plane14" tag:14];
    btn14.layer.anchorPoint = CGPointMake(1.5, 0.5);  // frame=(-70,420,100,100)
    [UIView animateWithDuration:3 animations:^{
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DConcat(transform, CATransform3DMakeTranslation(0, -btnW/2, 0));  // *_*  透视效果
        transform = CATransform3DConcat(transform, CATransform3DMakeRotation(angle, -1, 0, 0));
        transform = [self createPerspective:transform];
        transform = CATransform3DConcat(transform, CATransform3DMakeTranslation(0, btnW/2, 0));
        btn11.layer.transform = transform;
        
        btn13.layer.transform = transform;  // *_* layer.anchorPoint
        
        transform = CATransform3DIdentity;
        transform = CATransform3DConcat(transform, CATransform3DMakeTranslation(btnW/2, 0, 0));
        transform = CATransform3DConcat(transform, CATransform3DMakeRotation(angle, 0, -1, 0));
        transform = [self createPerspective:transform];
        transform = CATransform3DConcat(transform, CATransform3DMakeTranslation(-btnW/2, 0, 0));
        btn12.layer.transform = transform;
        
        transform = CATransform3DIdentity;
        transform = CATransform3DConcat(transform, CATransform3DMakeTranslation(btnW/2, 0, 0));
        transform = CATransform3DConcat(transform, CATransform3DMakeRotation(angle, 0, 1, 0));
        transform = [self createPerspective:transform];
        transform = CATransform3DConcat(transform, CATransform3DMakeTranslation(-btnW/2, 0, 0));
        btn14.layer.transform = transform;
    }];
    
    
    // 2d
    UIButton *btn20 = [self addBtn:CGRectMake(150, 260, btnW, btnW) title:@"plane20" tag:20];
    UIButton *btn21 = [self addBtn:CGRectMake(CGRectGetMinX(btn20.frame), CGRectGetMinY(btn20.frame)-btnW, btnW, btnW) title:@"plane21" tag:21];
    UIButton *btn22 = [self addBtn:CGRectMake(CGRectGetMaxX(btn20.frame), CGRectGetMinY(btn20.frame), btnW, btnW) title:@"plane22" tag:22];
//    UIButton *btn23 = [self addBtn:btn20.frame title:@"plane23" tag:23];
//    btn23.layer.anchorPoint = CGPointMake(-0.5, 0.5);
//    //UIButton *btn24 = [self addBtn:btn20.frame title:@"plane24" tag:24];
//    UIButton *btn24 = [self addBtn:CGRectMake(CGRectGetMidX(btn20.frame), CGRectGetMidY(btn20.frame), btnW, btnW) title:@"plane24" tag:24];
//    btn24.layer.anchorPoint = CGPointMake(0, 0);
    [UIView animateWithDuration:3 animations:^{
        CGAffineTransform af = CGAffineTransformIdentity;
        af = CGAffineTransformConcat(af, CGAffineTransformMakeRotation(M_PI*0.25));
        af = CGAffineTransformConcat(af, CGAffineTransformMakeScale(2, 1));
        af = CGAffineTransformConcat(af, CGAffineTransformMakeRotation(-M_PI*0.149));
        af = CGAffineTransformConcat(af, CGAffineTransformMakeScale(0.64, 0.3));
        af = CGAffineTransformConcat(af, CGAffineTransformMakeTranslation(30, 30));
        btn21.transform = af;
    
        btn22.transform = CGAffineTransformMake(0.6, -0.38, 0, 1, -19, -19);
        
//        btn23.transform = CGAffineTransformMake(0.2, 0.2, 0, 1, 40, -10);
//        af = btn24.transform;
//        af = CGAffineTransformConcat(af, CGAffineTransformMakeTranslation(2, 2));
//        af = CGAffineTransformConcat(af, CGAffineTransformMakeRotation(M_PI*0.4));
//        af = CGAffineTransformConcat(af, CGAffineTransformMakeScale(1, 0.3));
//        af = CGAffineTransformConcat(af, CGAffineTransformMakeRotation(M_PI*0.03));
//        af = CGAffineTransformConcat(af, CGAffineTransformMakeScale(1.05, 0.9));
//        btn24.transform = af;
    }];
}

- (UIButton *)addBtn:(CGRect)btnFrame title:(NSString *)titleStr tag:(NSInteger)tag
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = btnFrame;
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:titleStr forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"type_salary_image"] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor blueColor].CGColor;
    btn.tag = tag;
    [self.view addSubview:btn];
    return btn;
}

- (void)buttonClick:(UIButton *)btn
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:btn.titleLabel.text delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alertView show];
}


@end
