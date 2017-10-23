//
//  SettingViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/4/27.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()
{
    // 手势回退
    UIImageView *_imgViewPreScreenShot;      // self.navC里倒数第二个vc的截图，即之前一个vc
    UIImageView *_imgViewSelfNavScreenShot;  // self.navC的截图 （self.navC不会随着滑动，所以需要做个假的）
    
    id _kovObj;  // kov 键值观察
    
    UILabel *_lbToggle;  // 展开/折叠
    
    //NSMutableArray<ALAsset *>  *_assetArr;
    NSMutableArray  *_dataArr_asset;         // ALAssetsLibrary NSData数据
    NSMutableArray  *_imgThumbailArr_asset;  // 缩略图
    
    UICollectionView *_collectionView;  // 流式布局，点击坐标找到cell
}
@property (nonatomic, strong) UIView *pView;
@end

typedef enum
{
    BtnTagOthers_thread = 10000,
    BtnTagOthers_socket,
    BtnTagOthers_audio,
    BtnTagOthers_media,
    BtnTagOthers_block,
    BtnTagOthers_request,
    BtnTagOthers_nav,
    BtnTagOthers_AesDes,
    BtnTagOthers_UIBezierPath,
    BtnTagOthers_2d,
    BtnTagOthers_3d,
    BtnTagOthers_map,
    BtnTagOthers_addressbook,
    BtnTagOthers_bluethooth,
    BtnTagOthers_bgTask,
    BtnTagOthers_keyboard,
    BtnTagOthers_autolayout,
    BtnTagOthers_drag,
    BtnTagOthers_kLine,
    BtnTagOthers_aa,
    BtnTagOthers_bb,
    BtnTagOthers_cc,
} BtnTagOthers;

typedef NS_ENUM(NSInteger, BtnTag)
{
    BtnTag_dialog = 200,
    BtnTag_dialog1,
    BtnTag_a,
    BtnTag_b,
    BtnTag_c,
};
// 枚举类型转换
//id obj = @(BtnTag_dialog)  <->  xx.tag = (BtnTag)[obj integerValue];

typedef NS_OPTIONS(NSInteger, kkOptions)
{
    kkOptions_a,
    kkOptions_b,
    kkOptions_c,
};

#define kMarginSpace (10 + 2 -1)
static const NSInteger kSpace = 10+5;
static NSInteger kSpace1 = 15;
const NSInteger kSpace2 = 15;
int kSpace3 = 15;


@implementation SettingViewController


// 子类属性与父类属性重名
//@synthesize basedata = _basedata;
//@dynamic basedata;  // 修饰符一致时可使用dynamic

// synthesize如果没有手动实现getter/setter方法则编译器自动生成；dynamic告诉编译器getter/setter方法由用户自己实现而不是自动生成


- (id)init
{
    self = [super init];
    if (self)
    {
        self.bIsNeedKeyboardNotifications = YES;  // 键盘弹起，遮住部分上移；键盘隐藏，上移部分还原  *_* UITextField ok; UITextView 不ok 查看keyboardViewController
        self.bIsNeedTapGesture = YES;             // 点击背景取消编辑textField，触发键盘隐藏，触发监听
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.title = @"各种测试";
    self.navigationItem.title = @"各种测试";
    
    // 系统菊花 异步下载
    [self downloadImg];
    
    // 开关 UISwitch + 手动更新
    [self createSwitch];
    
    // UITextView 文本框 + UIMenuController 菜单（长按弹出）
    [self createTextView];
    
    // 流式布局 容器 CollectionView
    [self createCollectionView];
    
    // 搜索框
    [self createSearchBar];
    
    // 按钮 UIButton + 弹出框
    [self createButton];
    
    // 标签 UILabel
    [self createLabel];
    
    // 摇一摇 相册、拍照、录视频
    [self shake];
    
    // 右导航 查看slideVC滑动效果
    self.navRightBarItemView.barImgView.image = [UIImage imageNamed:@"menu"];
    
    // 手势回退
    //[self createPopGesture];  // 回退手势导致textView键盘有问题
    
    // js + native 混合编程 （hybrid app）
    [self jsTest];
    
    // 不定参数
    [self paramsTest];
    
    // 正则表达式
    [self regTest];
    
    // 按钮 其他测试
    [self addBtn:CGRectMake(50, 300, 100, 20) title:@"多线程" tag:BtnTagOthers_thread];
    [self addBtn:CGRectMake(170, 140, 140, 20) title:@"socket(tcp/udp)" tag:BtnTagOthers_socket];
    [self addBtn:CGRectMake(260, 165, 50, 20) title:@"音频" tag:BtnTagOthers_audio];
    [self addBtn:CGRectMake(205, 165, 50, 20) title:@"视频" tag:BtnTagOthers_media];
    [self addBtn:CGRectMake(260, 190, 50, 20) title:@"block" tag:BtnTagOthers_block];
    [self addBtn:CGRectMake(230, 215, 80, 20) title:@"网络请求" tag:BtnTagOthers_request];
    [self addBtn:CGRectMake(260, 240, 50, 20) title:@"nav" tag:BtnTagOthers_nav];
    [self addBtn:CGRectMake(230, 265, 80, 20) title:@"aes/des" tag:BtnTagOthers_AesDes];
    [self addBtn:CGRectMake(190, 290, 120, 20) title:@"手写电子签名" tag:BtnTagOthers_UIBezierPath];
    [self addBtn:CGRectMake(240, 315, 70, 20) title:@"2d绘图" tag:BtnTagOthers_2d];
    [self addBtn:CGRectMake(185, 315, 50, 20) title:@"3d" tag:BtnTagOthers_3d];
    [self addBtn:CGRectMake(260, 340, 50, 20) title:@"地图" tag:BtnTagOthers_map];
    [self addBtn:CGRectMake(170, 365, 140, 20) title:@"通讯录短信邮件" tag:BtnTagOthers_addressbook];
    [self addBtn:CGRectMake(260, 390, 50, 20) title:@"蓝牙" tag:BtnTagOthers_bluethooth];
    [self addBtn:CGRectMake(230, 415, 80, 20) title:@"后台任务" tag:BtnTagOthers_bgTask];
    [self addBtn:CGRectMake(260, 440, 50, 20) title:@"键盘" tag:BtnTagOthers_keyboard];
    [self addBtn:CGRectMake(230, 465, 80, 20) title:@"自动布局" tag:BtnTagOthers_autolayout];
    [self addBtn:CGRectMake(260, 490, 50, 20) title:@"拖动" tag:BtnTagOthers_drag];
    [self addBtn:CGRectMake(210, 515, 100, 20) title:@"股票k线图" tag:BtnTagOthers_kLine];
    
    // 其它nslog测试
    [self test];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.imgTest)
    {
        UIImageView *imgViewTest = [[UIImageView alloc] initWithFrame:CGRectMake(80, kDEFAULT_ORIGIN_Y, 50, 50)];
        imgViewTest.image = self.imgTest;
        [self.view addSubview:imgViewTest];
    }
}



#pragma mark - 系统菊花 + 异步下载

- (void)downloadImg
{
    // ios不支持gif图片
    UIImage *img_Loading = [UIImage imageNamed:@"loading.gif"];
    UIImageView *imgView_Loading = [[UIImageView alloc] initWithFrame:CGRectMake(60, 220, img_Loading.size.width, img_Loading.size.height)];
    imgView_Loading.image = img_Loading;
    [self.view addSubview:imgView_Loading];
    
    // 网页显示gif图片 （大小，颜色，效果不好）
    //UIWebView *webView_Loading = [[UIWebView alloc] initWithFrame:CGRectMake(100, 220, img_Loading.size.width, img_Loading.size.height)];
    UIWebView *webView_Loading = [[UIWebView alloc] initWithFrame:CGRectMake(100, 220, 100, 100)];
    webView_Loading.scalesPageToFit = YES;
    webView_Loading.userInteractionEnabled = NO;
    webView_Loading.opaque = NO;  // 透明
    webView_Loading.backgroundColor = [UIColor clearColor];
    webView_Loading.layer.borderColor = [UIColor darkGrayColor].CGColor;
    webView_Loading.layer.borderWidth = 1;
    NSString *imgFilePath = [[NSBundle mainBundle] pathForResource:@"folder_references/img_loading2.gif" ofType:@""];
    //NSString *imgFilePath2 = [[NSBundle mainBundle] pathForResource:@"loading.gif" ofType:@""];
    NSData *dataImgFile = [NSData dataWithContentsOfFile:imgFilePath];
    [webView_Loading loadData:dataImgFile MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    [self.view addSubview:webView_Loading];
    
    // UIImageView 可以播放gif动画，图片数组
    NSMutableArray<UIImage *> *arrImgs = [[NSMutableArray alloc] init];
    for (int i=0; i<13; i++) {
        NSString *imgName = [NSString stringWithFormat:@"folder_references/img_loading_meituan/img_loading_gif_%i.png", i];
        NSString *imgFilePath = [[NSBundle mainBundle] pathForResource:imgName ofType:@""];
        UIImage *img = [UIImage imageWithContentsOfFile:imgFilePath];
        [arrImgs addObject:img];
    }
    UIImageView *imgView_Loading1 = [[UIImageView alloc] initWithFrame:CGRectMake(80, 70, 68/2, 95/2)];
    [self.view addSubview:imgView_Loading1];
    imgView_Loading1.animationImages = arrImgs;
    imgView_Loading1.animationDuration = 3.0;
    imgView_Loading1.animationRepeatCount = 0;
    [imgView_Loading1 startAnimating];
    
    // 系统菊花 UIActivityIndicatorView
    //UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] init];
    //aiView.center = CGPointMake(kSCREEN_WIDTH / 2, 400);
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 210, 50, 50)];
    aiView.color = [UIColor blueColor];
    [self.view addSubview:aiView];
    [aiView startAnimating];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 250, 200, 150)];
    [self.view addSubview:imgView];
    // 异步 下载图片
    __block UIImage *img = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *imgUrl = [NSURL URLWithString:@"http://119.147.82.70:8099/Images/Banner/banner_bz.jpg"];
        NSData *imgData = [NSData dataWithContentsOfURL:imgUrl];
        img = [UIImage imageWithData:imgData];
        [NSThread sleepForTimeInterval:5.0];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (img)
            {
                imgView.image = img;
            }
            //[aiView stopAnimating];
        });
    });
    
    
    // 圆形图
    imgView.layer.cornerRadius = 70;
    imgView.layer.masksToBounds = YES;
    
//    // 圆形图  UIBeizerPath贝塞尔曲线 + CoreGraphics
//    UIGraphicsBeginImageContextWithOptions(imgView.bounds.size, NO, [UIScreen mainScreen].scale);
//    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:imgView.bounds cornerRadius:imgView.frame.size.width];
//    [bezierPath addClip];
//    [imgView drawRect:imgView.bounds];
//    imgView.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
//    // 圆形图  UIBeizerPath贝塞尔曲线 + CAShapeLayer
//    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:imgView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:imgView.bounds.size];
//    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
//    shapeLayer.frame = imgView.bounds;
//    shapeLayer.path = bezierPath.CGPath;
//    imgView.layer.mask = shapeLayer;
    
}




#pragma mark - UISwitch + CustomIOSAlertView弹出框 + 强制更新（手动）

- (void)createSwitch
{
    UISwitch *uiswitch = [[UISwitch alloc] initWithFrame:CGRectMake(10, 100, 50, 30)];
    uiswitch.onTintColor = [UIColor yellowColor];
    uiswitch.on = YES;
    [uiswitch addTarget:self action:@selector(clickUISwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:uiswitch];
}

// 点击uiswitch
- (void)clickUISwitch:(UISwitch *)uiswith
{
    // 更新/强制更新
    NSString *serverVersion = @"1.2.0";
    if(uiswith.on && [KUtils isLatestVersion:serverVersion])
    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"强制更新"
//                                                            message:@"检测到新版本，要更新吗?"
//                                                           delegate:self
//                                                  cancelButtonTitle:@"取消"
//                                                  otherButtonTitles:@"更新", nil];
//        [alertView show];
        [self createCustomAlertView];
    }
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 0)
//    {
//        // 取消
//    }
//    else if (buttonIndex == 1)
//    {
//        // 更新
//    }
//}

// 弹出CustomAlertView
- (void)createCustomAlertView
{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    alertView.buttonTitles = [NSArray arrayWithObjects:@"取消", @"更新", nil];
    alertView.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
    [alertView show];
    
    UILabel *alertMsgLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 300, 20)];
    alertMsgLb.text = @"检测到新版本，要更新吗?";
    alertMsgLb.textAlignment = NSTextAlignmentCenter;
    [alertView.containerView addSubview:alertMsgLb];
    
    for (UIView *tempView in alertView.dialogView.subviews)
    {
        if ([tempView isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)tempView;
            if (btn.tag == 0)
            {
                // 取消 灰色
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
            else if (btn.tag == 1)
            {
                // 更新 橘色
                [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            }
        }
    }
    
    //@interface xx()<CustomIOSAlertViewDelegate>
    //alertView.delegate = self;
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex){
        if (buttonIndex == 0)
        {
            // 取消 强制退出
            [KUtils exitApplication];
        }
        else if (buttonIndex == 1)
        {
            // 更新 打开AppStore下载地址
            [KUtils openAppDownLoadAddress];
        }
        //[alertView close];
    }];
}

//// CustomIOSAlertView Deleage 点击按钮
//- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 0)
//    {
//        // 取消
//    }
//    else if (buttonIndex == 1)
//    {
//        // 更新
//    }
//    [alertView close];
//}




#pragma mark - UITextView 文本框 + UITextViewDelegate + UIMenuController

//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//    
//    if ([self.text length] == 0 && self.placeHolder) {
//        [self.placeHolderTextColor set];
//        
//        [self.placeHolder drawInRect:CGRectInset(rect, 7.0f, 5.0f)
//                      withAttributes:[self jsq_placeholderTextAttributes]];
//    }
//}
- (void)createTextView
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 500, 200, 60)];
    [self.view addSubview:textView];
    textView.delegate = self;
    textView.keyboardType = UIKeyboardTypeDefault;
    textView.returnKeyType = UIReturnKeyDone;
    //textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;  // 滚动时键盘消失
    
    NSString *strText = @"UITextView哈哈嘿嘿吼吼嘎嘎 啊s咔 <a href='http://119.147.82.70:8099'>链接</a>  哈哈嘿嘿吼吼嘎嘎  <a href='lc://ahw.test.app/xxVC?param=detailID&&custId=123'>链接打开自己的详情页</a>  哈哈嘿嘿吼吼嘎嘎";
//    textView.text = strText;
//    textView.textColor = [UIColor orangeColor];
    
    // NSAttributedString html支持，字体效果等
    //NSAttributedString *attributedStr = [[NSAttributedString alloc] initWithString:strText];
    NSData *dataText = [strText dataUsingEncoding:NSUnicodeStringEncoding];
    NSDictionary *dicOptions = @{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType };
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithData:dataText options:dicOptions documentAttributes:nil error:nil];
    NSRange kRange = NSMakeRange(9, 2);
    if (kRange.location != NSNotFound)
    {
        NSLog(@"%li *_* %ld", kRange.location, NSNotFound);
    }
    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:kRange];
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] range:kRange];
    textView.attributedText = attributedStr;
    //[textView.textStorage addAttribute:NSTextEffectAttributeName value:NSTextEffectLetterpressStyle range:kRange];
    [textView.textStorage addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:kRange];
    
    // 动态字体（设置－通用－辅助功能－字体大小）
    //textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kk:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    // 路径排除（环绕效果）
    //UIBezierPath *floatingPath = 不规则路径
    UIBezierPath *floatingPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 100, 30)];
    textView.textContainer.exclusionPaths = @[floatingPath];
    
    
    // UIMenuItem 菜单（长按弹出）
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"sharedMenuController" action:@selector(kkMenuControlAction_itemX:)];
    UIMenuController *menuC = [UIMenuController sharedMenuController];
    NSArray *menuItemArr = [NSArray arrayWithObject:menuItem];
    [menuC setMenuItems:menuItemArr];
    
    
    UIButton *btn = [KUtils createButtonWithFrame:CGRectMake(0, 0, 80, 30) title:@"本地按钮" titleColor:[UIColor redColor] target:self tag:-1];
    [textView addSubview:btn];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 470, 100, 30)];
    textField.delegate = self;  // baseVC
    [self.view addSubview:textField];
    textField.placeholder = @"UITextField";
    textField.backgroundColor = [UIColor purpleColor];
}

// UITapGestureRecognizer
//- (void)textViewDidEndEditing:(UITextView *)textView
//{
//    [textView resignFirstResponder];  // *_*
//    NSLog(@"textViewDidEndEditing");
//}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqual:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


// *_* _scrollView影响到了
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    UITouch *anyTouch = event.allTouches.anyObject;
//    if (anyTouch.view != _textView && [_textView isFirstResponder])
//    {
//        [_textView resignFirstResponder];
//    }
//    
//    [super touchesBegan:touches withEvent:event];
//}

//- (BOOL)canBecomeFirstResponder
//{
//    return YES;
//}
//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
//{
//    if (action == @selector(kkMenuItemAction:))
//    {
//        if (_textView.selectedRange.length > 0)
//        {
//            return YES;
//        }
//    }
//    return NO;
//}
- (void)kkMenuControlAction_itemX:(UIMenuController *)menuC
{
    NSLog(@"kkMenuControlAction_itemX");
}




#pragma mark - 流式布局 容器 CollectionView

- (void)createCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(40, 30);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 580, kSCREEN_WIDTH - 20, 150) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor orangeColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    if (section == 0)
//    {
//        return 3;
//    }
//    else
//    {
//        return 4;
//    }
    return 10;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(50, 50);
//}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //return UIEdgeInsetsMake(-64, 10, -48, 10);
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    gesture.minimumPressDuration = 2.0;
    [cell addGestureRecognizer:gesture];
    return cell;
}

//self.bIsNeedTapGesture
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    NSLog(@"collectionView:didSelectItemAtIndexPath:");
}


- (void)longPress:(id)sender
{
    UIGestureRecognizer *gesture = (UIGestureRecognizer *)sender;
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint p = [gesture locationInView:_collectionView];
        NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:p];
        UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
        cell.backgroundColor = [UIColor yellowColor];
    }
    
//    UIButton *btn = (UIButton *)sender;
//    //CGPoint p = [btn convertPoint:btn.center toView:self.collectView];  //*_*
//    CGPoint p = [btn.superview convertPoint:btn.superview.center toView:_collectionView];
//    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:p];
}



#pragma mark - 搜索框

- (void)createSearchBar
{
    //UISearchBar
    //UISearchController
}





#pragma mark - Button按钮 自定义弹出框

- (void)createButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(150, 100, 150, 30);
    [btn addTarget:self action:@selector(buttonAction_dialog:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"自定义弹出框" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor magentaColor].CGColor;
    btn.layer.cornerRadius = 5.0;
    btn.tag = BtnTag_dialog;
    
    UIImage *imgBtnBg = [UIImage imageNamed:@"btn_bg"];
    UIImage *imgBtnBgStretched = [imgBtnBg stretchableImageWithLeftCapWidth:imgBtnBg.size.width/2 topCapHeight:imgBtnBg.size.height/2];
    [btn setBackgroundImage:imgBtnBgStretched forState:UIControlStateNormal];
    
    UIImage *imgBtnArrow = [UIImage imageNamed:@"btn_arrow"];
    [btn setImage:imgBtnArrow forState:UIControlStateNormal];
    //btn.imageEdgeInsets = UIEdgeInsetsMake(0, btn.bounds.size.width - 10, 0, 0);
    [btn layoutIfNeeded];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, -imgBtnArrow.size.width, 0, imgBtnArrow.size.width);
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, btn.titleLabel.bounds.size.width+10, 0, -btn.titleLabel.bounds.size.width);
    
    [self.view addSubview:btn];
    
    
    UIButton *btn1 = [KUtils createButtonWithFrame:CGRectMake(150, 70, 150, 30) title:@"自定义弹出框1" titleColor:[UIColor cyanColor] target:nil tag:BtnTag_dialog1];
    [btn1 addTarget:self action:@selector(buttonAction_dialog:) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setImage:imgBtnArrow forState:UIControlStateNormal];
    [self.view addSubview:btn1];
}

// 点击按钮 自定义弹出框
- (void)buttonAction_dialog:(UIButton *)btn
{
    if (btn.tag == BtnTag_dialog)
    {
        DialogView *dialogView = [[DialogView alloc] initWithContainerFrame:CGRectMake((kSCREEN_WIDTH-200)/2, 10, 200, 300)];
        //[self.view addSubview:dialogView];
        [dialogView show];

        UIImageView *adImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, dialogView.containerView.frame.size.width, dialogView.containerView.frame.size.height)];
        adImgView.image = [UIImage imageNamed:@"5s_guide_1"];
        [dialogView.containerView addSubview:adImgView];
    }
    else if (btn.tag == BtnTag_dialog1)
    {
        DialogView1 *dialogView1 = [[DialogView1 alloc] initWithBgFrame:[UIScreen mainScreen].bounds andContainerSize:CGSizeMake(250, 150)];
        //[self.view addSubview:dialogView1];
        [[UIApplication sharedApplication].keyWindow addSubview:dialogView1];
        
        dialogView1.onBtnsTouchUpInside = ^(DialogView1 *currentDialogView, int buttonIndex) {
            [currentDialogView removeFromSuperview];
            NSLog(@"dialogView1 block %i", buttonIndex);
        };
    }
}




#pragma mark - Label标签

- (void)createLabel
{
    CGRect rect = CGRectMake(20, 150, 130, 20);
    UILabel *lb = [[UILabel alloc] initWithFrame:rect];
    lb.text = @"摇一摇 *_* \ntest -> 相册 拍照 录视频";
    lb.textColor = [UIColor purpleColor];
    lb.backgroundColor = [UIColor clearColor];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.font = [UIFont systemFontOfSize:16];
    //lb.font = [UIFont boldSystemFontOfSize:16];  // 加粗
    lb.tag = kDEFAULT_TAG;
    lb.numberOfLines = 0;  // 不限行数
    [lb sizeToFit];  // 自适应
    lb.shadowColor = [UIColor yellowColor];  // 阴影
    lb.shadowOffset = CGSizeMake(-1, -1);
    [self.view addSubview:lb];
    
    // vertical-align 竖向对齐方式
    rect = CGRectMake(150, 150, 100, 20*3);
    UILabel *lb1 = [[UILabel alloc] initWithFrame:rect];
    lb1.text = @"lb.text top";
    lb1.backgroundColor = [UIColor orangeColor];
    [self labelVertialAlignTop:lb1];
    [self.view addSubview:lb1];
    
    // 部分变色
    //lb.attributedText ...
    
    // 展开/折叠
    NSString *str = @"这里是一大堆字符串测试 至少要4行 显示两行隐藏两行 一点就都显示 再点又回去 靠靠靠靠 快使用双截棍 淡定 inner peace 瓦吼吼吼吼吼啊嘎嘎嘎嘎 ";
    rect = CGRectMake(20, 380, 250, 20);
    _lbToggle = [KUtils createLabelWithFrame:rect text:str fontSize:16 textAlignment:NSTextAlignmentLeft tag:0];
    _lbToggle.numberOfLines = 2;
    [_lbToggle sizeToFit];
    [self.view addSubview:_lbToggle];
    rect = CGRectMake(CGRectGetMidX(_lbToggle.frame) - 20, CGRectGetMaxY(_lbToggle.frame), 60, 30);
    UIButton *btn = [KUtils createButtonWithFrame:rect title:nil titleColor:[UIColor greenColor] target:nil tag:kDEFAULT_TAG];
    [btn addTarget:self action:@selector(buttonAction_lb:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"展开" forState:UIControlStateNormal];
    [btn setTitle:@"折叠" forState:UIControlStateSelected];
    [self.view addSubview:btn];
}

// label category
- (void)labelVertialAlignTop:(UILabel *)lb
{
//    CGSize maxSize = CGSizeMake(lb.frame.size.width, 999);
//    lb.adjustsFontSizeToFitWidth = NO;
//    CGSize actualSize = [lb.text sizeWithFont:lb.font constrainedToSize:maxSize lineBreakMode:lb.lineBreakMode];
//    CGRect rect = lb.frame;
//    rect.size.height = actualSize.height;
//    lb.frame = rect;
    
    
    lb.font = [UIFont systemFontOfSize:14];
    lb.numberOfLines = 30;
    
    // lb.text的文本单行高度
    CGFloat singleLineHeight;
    if ([KUtils isIOS7])
    {
        NSDictionary *dicAttributes = @{ NSFontAttributeName:lb.font };
        singleLineHeight = [lb.text sizeWithAttributes:dicAttributes].height;  // NS_AVAILABLE_IOS(7_0)
    }
    else
    {
        singleLineHeight = [lb.text sizeWithFont:lb.font].height;
    }
    
    // lb的大小
    //CGSize lbSize = lb.frame.size;
    CGSize lbSize = CGSizeMake(lb.frame.size.width, singleLineHeight * lb.numberOfLines);
    
    CGSize constrainedSize_MaxHeight = CGSizeMake(lb.frame.size.width, MAXFLOAT);
    // lb.text的文本大小
    CGSize textStringSize;
    if ([lb.text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        textStringSize = [lb.text boundingRectWithSize:constrainedSize_MaxHeight options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:lb.font } context:nil].size;  // ios7
    }
    else
    {
        //textStringSize = [lb.text sizeWithFont:lb.font constrainedToSize:constrainedSize_MaxHeight lineBreakMode:lb.lineBreakMode];
        textStringSize = [lb.text sizeWithFont:lb.font constrainedToSize:constrainedSize_MaxHeight];
    }
    
    // lb的高度减去lb.text的文本高度，剩余需要填充换行符的高度
    int newLinesToPad = (lbSize.height - textStringSize.height) / singleLineHeight;
    for (int i=0; i<newLinesToPad; i++)
    {
        lb.text = [lb.text stringByAppendingString:@"\n"];
    }
    
}

- (void)buttonAction_lb:(UIButton *)btn
{
    _lbToggle.numberOfLines = (_lbToggle.numberOfLines == 0 ? 2: 0);  // 展开/折叠
    [_lbToggle sizeToFit];
    
    CGRect rect = btn.frame;
    rect.origin.y = CGRectGetMaxY(_lbToggle.frame);
    btn.frame = rect;
    btn.selected = !btn.selected;
}



#pragma mark - 摇一摇

- (void)shake
{
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    [self becomeFirstResponder];
}

// 摇动开始
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}
// 摇动取消
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}
// 摇动结束
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    // 程序在前台（没有锁屏）时才执行
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        return;
    }
    
    if (event.subtype == UIEventSubtypeMotionShake)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); //震动
        
        // UIActionSheet 菜单 iOS8以下
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"请选择"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:@"删除（红色）"
                                                        otherButtonTitles:@"相册", @"拍照", @"录视频", nil];
        //[actionsheet addButtonWithTitle:@"buttonIndex *_*"];
        [actionsheet showInView:self.view];
        
//        // iOS8及以上
//        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"title" message:@"msg" preferredStyle:UIAlertControllerStyleActionSheet];
//        UIAlertAction *alertAction_cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//        [alertC addAction:alertAction_cancel];
//        UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:@"删除（红色）" style:UIAlertActionStyleDestructive handler:nil];
//        [alertC addAction:alertAction1];
//        UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self openLocalLibary_PHAsset];
//        }];
//        [alertC addAction:alertAction2];
//        // 苹果私有API，不可调用，否则会审核被拒
//        //UIAlertAction *alertAction3 = [UIAlertAction actionWithTitle:@"该颜色加图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
//        //[alertC addAction:alertAction3];
//        //if ([alertAction3 respondsToSelector:@selector(_titleTextColor)]) {
//        //    [alertAction3 setValue:[UIColor orangeColor] forKey:@"_titleTextColor"];
//        //}
//        //if ([alertAction3 respondsToSelector:@selector(image)]) {
//        //    [alertAction3 setValue:[UIImage imageNamed:@"note_left_menu_setting"] forKey:@"image"];
//        //}
//        [self presentViewController:alertC animated:YES completion:nil];
//
//        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"title" message:@"msg" preferredStyle:UIAlertControllerStyleAlert];
//        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//            textField.placeholder = @"哈哈";
//        }];
//        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"kk" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            NSLog(@"%@", alertC.textFields[0].text);  // UIAlertControllerStyleAlert only
//        }];
//        [alertC addAction:alertAction];
//        [self presentViewController:alertC animated:YES completion:nil];
////        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
////            //sleep(1);
////            dispatch_async(dispatch_get_main_queue(), ^{
////                [self presentViewController:alertC animated:YES completion:nil];
////            });
////        //});
////        MediaViewController *mediaVC = [[MediaViewController alloc] init];
////        [self.navigationController pushViewController:mediaVC animated:YES];
//
//        SheetItem *item0 = [[SheetItem alloc] initWithTitle:@"哈哈" icon:@"note_left_menu_setting"];
//        SheetItem *item1 = [[SheetItem alloc] init];
//        item1.icon = @"note_left_menu_msg";
//        item1.title = @"嘿嘿";
//        NSArray *itemArr = [NSArray arrayWithObjects:item0, item1, nil];
//        ActionSheetExt *ase = [[ActionSheetExt alloc] initWithList:itemArr title:@"请选择"];
//        ase.delegate = self;  // self.bIsNeedTapGesture = NO;
//        [ase showInView:self];
    }
}


#pragma mark - UIActionSheet Delegate

// UIActionSheetDelegate 按钮点击
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // buttonIndex 按钮从上到下顺序
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        // cancel 最后
    }
    else if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        // destructive 0
    }
    else if (buttonIndex == 1)
    {
        [self openLocalCamera:@"相册"];
        //[self openLocalLibrary_ALAsset];
        //[self openLocalLibary_PHAsset];
        //[self openLocalLibrary_QBImagePickerController];
    }
    else if (buttonIndex == 2)
    {
        [self openLocalCamera:@"拍照"];
    }
    else if (buttonIndex == 3)
    {
        [self openLocalCamera:@"录视频"];
    }
}

//- (void)ActionSheetExtDdidSelectIndex:(NSInteger)index
//{
//    NSLog(@"index=%i", index);
//}

#pragma mark - 访问相册、拍照、录视频（UIImagePickerController，单选）； ALAssetsLibrary访问资源库（自定义）

// 打开摄像头  相册，拍照，录视频
- (void)openLocalCamera:(NSString *)actionType
{
    UIImagePickerController *imgPickerC = [[UIImagePickerController alloc] init];
    if ([actionType isEqualToString:@"相册"])
    {
        // 检查相册权限
        PHAuthorizationStatus phAuthStatus = [PHPhotoLibrary authorizationStatus];
        if (phAuthStatus == PHAuthorizationStatusRestricted || phAuthStatus == PHAuthorizationStatusDenied)
        {
            NSLog(@"相册权限没开");
        }
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            NSLog(@"相册不可用");
        }
        
        //imgPickerC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;  // 照片->时刻  只能显示"时刻"
        
        imgPickerC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;  // 照片（时刻＋相机胶卷）
        imgPickerC.mediaTypes = @[@"public.movie", (NSString *)kUTTypeImage];  // 时刻＋相机胶卷＋视频
    }
    else
    {
        // 检查相机权限
        AVAuthorizationStatus avAuthStatus_Video = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (avAuthStatus_Video == AVAuthorizationStatusRestricted || avAuthStatus_Video == AVAuthorizationStatusDenied)
        {
            NSLog(@"相机权限没开");
        }
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            NSLog(@"相机不可用");
        }
        
        imgPickerC.sourceType = UIImagePickerControllerSourceTypeCamera;  // 默认是拍照
        //imgPickerC.cameraDevice = UIImagePickerControllerCameraDeviceFront;  // 前置摄像头（默认是后置）
        if ([actionType isEqualToString:@"录视频"])
        {
            imgPickerC.mediaTypes = @[(NSString *)kUTTypeMovie];
            //imgPickerC.videoQuality = UIImagePickerControllerQualityTypeHigh;  // 视频质量
        }
//        // 同时开放拍照和录视频选项
//        imgPickerC.mediaTypes = @[@"public.movie", (NSString *)kUTTypeImage];
//        imgPickerC.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    }
    //imgPickerC.allowsEditing = YES;  // 允许编辑
    imgPickerC.delegate = self;
    [self presentViewController:imgPickerC animated:YES completion:nil];
    
    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    testView.backgroundColor = [UIColor orangeColor];
    [imgPickerC.view addSubview:testView];
}


// UIImagePickerControllerDelegate
// 取消选择
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
// 打开相册选择照片、视频，或拍完照、录完视频
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"picker信息 *_* %@",info);
    [self imagePickerControllerDidCancel:picker];  // 关闭相册或相机|摄像头界面
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"])  // 选择的是照片（打开相册或拍照之后）
    {
        UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];  // 获取原始图片  若allowsEditing可以通过UIImagePickerControllerEditedImage获取编辑后的图片
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 400, kSCREEN_WIDTH-20, 150)];
        imgView.image = img;
        [self.view addSubview:imgView];
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)  // 拍照之后
        {
            //UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);  // 保存到相册
        }
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])  // 选择的是视频（打开相册或录视频之后）
    {
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"视频位置 %@", videoUrl);
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)  // 录视频之后
        {
            //NSData *data = [[NSData alloc] initWithContentsOfURL:videoUrl];  // 直接获取
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoUrl.path))
            {
                //UISaveVideoAtPathToSavedPhotosAlbum(videoUrl.path, nil, nil, nil);  // 保存到相册
            }
        }
    }
}


// ALAssetsLibrary 访问资源库获取图片，然后自定义UI展现、多选、各种事件、等 （iOS8以下）
/* 
 先遍历所有相册，然后遍历每个相册中的第一张图片
 ALAssetsGroup：一个相册
 ALAsset：一个单一资源文件（也就是一张图片，或者一个视频文件）
 ALAssetRepresentation：封装了ALAsset，包含了一个资源文件中的很多属性。（可以说是ALAsset的不同的表示方式，本质上都表示同一个资源文件）
*/
- (void)openLocalLibrary_ALAsset
{
    _dataArr_asset = [[NSMutableArray alloc] init];  // NSData数据
    _imgThumbailArr_asset = [[NSMutableArray alloc] init];
    
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied)
    {
        NSLog(@"请开权限");
        return;
    }
    ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];  // 资源库
    // 遍历资源库中所有相册
    [assetsLib enumerateGroupsWithTypes:ALAssetsGroupAll
                             usingBlock:^(ALAssetsGroup *group, BOOL *stop){
                                 //NSLog(@"相册 %@", group);
                                 //[group setAssetsFilter:[ALAssetsFilter allPhotos]];  // 过滤，只选择照片
                                 
                                 // 遍历相册中的资源
                                 [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop){
                                     //NSLog(@"资源 %@",result);
                                     //ALAssetRepresentation *assetRepresentation = result.defaultRepresentation;  // 资源属性详细信息
                                     NSString *assetType = [result valueForProperty:ALAssetPropertyType];  // 资源类型
                                     NSURL *assetUrl = [result valueForProperty:ALAssetPropertyAssetURL];  // 资源位置（? 被系统改过）
                                     //NSData *data_asset = [NSData dataWithContentsOfFile:assetUrl.path];
                                     //NSData *data_asset = [NSData dataWithContentsOfURL:assetUrl];
                                     uint8_t *buffer = (Byte *)malloc(result.defaultRepresentation.size);  // 太大会崩溃
                                     [result.defaultRepresentation getBytes:buffer fromOffset:0 length:result.defaultRepresentation.size error:nil];
                                     NSData *data_asset = [[NSData alloc] initWithBytesNoCopy:buffer length:result.defaultRepresentation.size freeWhenDone:YES];
                                     
                                     if (!data_asset)
                                     {
                                         NSLog(@"没找到%i", index);
                                     }
                                     else
                                     {
                                         [_dataArr_asset addObject:data_asset];
                                         if ([assetType isEqualToString:ALAssetTypePhoto])  // 照片类型
                                         {
                                             NSLog(@"找到图片%i", index);
                                         }
                                         else if ([assetType isEqualToString:ALAssetTypeVideo])  // 视频类型
                                         {
                                             NSLog(@"找到视频%i", index);
                                         }
                                     }
                                     
                                     UIImage *imgThumbnail = [UIImage imageWithCGImage:result.thumbnail];  // 资源缩略图
                                     //UIImage *imgFullScreen = [UIImage imageWithCGImage:result.defaultRepresentation.fullScreenImage];  // 全屏图
                                     //UIImage *img = [UIImage imageWithCGImage: result.defaultRepresentation.fullResolutionImage];  // 高清图
                                     
                                     // 自定义UI
                                     UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10+index, kDEFAULT_ORIGIN_Y+10+index, imgThumbnail.size.width, imgThumbnail.size.height)];
                                     imgView.image = imgThumbnail;
                                     [self.view addSubview:imgView];
                                     
                                     NSLog(@"%f*_*%f", imgThumbnail.size.width, imgThumbnail.size.height);
                                     if (imgThumbnail)  // 最后会是nil
                                     {
                                         [_imgThumbailArr_asset addObject:imgThumbnail];
                                     }
                                     
                                 }];
                             }
                           failureBlock:^(NSError *error){
                               NSLog(@"资源库枚举相册失败");
                           }];
    
    NSLog(@"异步 %i",_dataArr_asset.count);
    UIButton *btn = [KUtils createButtonWithFrame:CGRectMake(10, 300, 100, 30) title:@"相册资源" titleColor:[UIColor greenColor] target:nil tag:kDEFAULT_TAG];
    [btn addTarget:self action:@selector(buttonAction_asset:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)buttonAction_asset:(id)sender
{
    NSLog(@"相册资源：%i", _dataArr_asset.count);
    for (int i=0; i<_dataArr_asset.count; i++)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10+i, 200+i, 100, 100)];
        UIImage *img = [UIImage imageWithData:_dataArr_asset[i]];
        imgView.image = img;
        [self.view addSubview:imgView];
        
        // UICollectionView
    }
}


/*
 iOS8及以上
 PHAsset ：一个资源
 PHAssetCollection ：一个相册
 PHFetchResult ：取出的结果集，相册集或资源集
 PHFetchOptions ：获取资源的参数
 PHImageManager ： 用于处理资源的加载，加载图片的过程带有缓存处理，可以通过传入一个 PHImageRequestOptions 控制资源的输出尺寸等规格
 */
- (void)openLocalLibary_PHAsset
{
    //[PHPhotoLibrary sharedPhotoLibrary]
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied)
    {
        NSLog(@"请开权限");
        return;
    }
    
    PHFetchResult *fr = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];  // 智能相册

    PHFetchResult *fr1 = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];  // 用户最近创建的相册
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];  // 时间排序
    PHFetchResult *fr2 = [PHAsset fetchAssetsWithOptions:options];
    
    NSLog(@"%i *_* %i *_* %i", fr.count, fr1.count, fr2.count);
    
    
    PHAsset *asset = fr2[0];  // *_*  if(fr.count>0)
    // 从asset中获取图片
    PHImageManager *im = [PHImageManager defaultManager];
    //PHImageManager *im = [[PHImageManager alloc] init];
    //PHCachingImageManager *im = [[PHCachingImageManager alloc] init];
    [im requestImageForAsset:asset
                  targetSize:CGSizeMake(50, 30)
                 contentMode:PHImageContentModeDefault
                     options:nil
               resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                   UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 400, 150, 90)];
                   imgView.image = result;
                   [self.view addSubview:imgView];
               }];
    // targetSize   尺寸，如果大于资源原图的尺寸则返回原图
    // contentMode  裁剪方式
    // options      PHImageRequestOptionsResizeModeExact质量高与targetSize匹配；PHImageRequestOptionsResizeModeFast效率高质量低大小不匹配
    
    //PHImageRequestOptions *optionsRequest = [[PHImageRequestOptions alloc] init];
    //[optionsRequest setSynchronous:YES];  // 同步，可使用__block
    
    
    // 遍历，真机（照片太多）有问题，内存，ALAssetLibray遍历没问题
    __block int kk = 0;
    //PHFetchResult *fr = [PHAsset fetchAssetsWithOptions:nil];
    //PHFetchResult *fr = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (int i=0; i<fr.count; i++)  // 遍历相册
    {
        if ([fr[i] isKindOfClass:[PHAsset class]])
        {
            NSLog(@"PHAsset fetch ... %i", i);
            PHAsset *asset = fr[i];  // 资源
//            [im requestImageForAsset:asset
//                          targetSize:PHImageManagerMaximumSize
//                         contentMode:PHImageContentModeDefault
//                             options:nil
//                       resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//                           UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(200-(i*5), 400+(i*5), 100, 60)];
//                           imgView.image = result;
//                           [self.view addSubview:imgView];
//                           kk++;
//                       }];
        }
        else if ([fr[i] isKindOfClass:[PHAssetCollection class]])
        {
            NSLog(@"PHAssetCollection fetch ... %i", i);
            PHAssetCollection *ac = fr[i];  // 相册    *_*
            PHFetchResult *fr_a = [PHAsset fetchAssetsInAssetCollection:ac options:nil];  // 从每一个相册中获取到的PHFetchResult中包含的才是真正的资源PHAsset
            for (int j=0; j<fr_a.count; j++)
            {
                NSLog(@"PHAsset fetch InCollection ... %i*_*%i", i, j);
                PHAsset *asset = fr_a[j];  // 资源
//                [im requestImageForAsset:asset
//                              targetSize:PHImageManagerMaximumSize
//                             contentMode:PHImageContentModeDefault
//                                 options:nil
//                           resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//                               UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(200-(j*5), 400+(j*5), 100, 60)];
//                               imgView.image = result;
//                               [self.view addSubview:imgView];
//                               kk++;
//                           }];
            }
        }
        else
        {
            NSLog(@"? *_* %@", fr[i]);
        }
    }
    NSLog(@"%i", kk);
    
    
    // 找视频
    PHFetchOptions *option_v = [[PHFetchOptions alloc] init];
    option_v.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    option_v.fetchLimit = 1;
    PHFetchResult *fr_v = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:option_v];
    if (fr_v.count > 0)
    {
        PHAsset *asset = fr_v[0];
        PHImageManager *im = [[PHImageManager alloc] init];
        [im requestPlayerItemForVideo:asset
                              options:nil
                        resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
                            if (playerItem)
                            {
                                NSLog(@"AVPlayerItem %@", [playerItem valueForKeyPath:@"asset.URL"]);
                            }
                        }];
        [im requestAVAssetForVideo:asset
                            options:nil
                      resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                          if (asset)
                          {
                              NSLog(@"AVAsset %@", [asset valueForKey:@"URL"]);
                          }
                      }];
        // 缩略图
        [im requestImageForAsset:asset
                      targetSize:CGSizeMake(100, 150)
                     contentMode:PHImageContentModeAspectFill
                         options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                             UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 400, 100, 150)];
                             imgView.image = result;
                             [self.view addSubview:imgView];
                         }];
    }
    
}




// QBImagePickerController 可多选
// http ://blog.csdn.net/zyk5219/article/details/50865407
- (void)openLocalLibrary_QBImagePickerController
{
    QBImagePickerController *qbIPC = [QBImagePickerController new];
    qbIPC.delegate = self;
    qbIPC.mediaType = QBImagePickerMediaTypeImage;
    qbIPC.allowsMultipleSelection = YES;
    qbIPC.showsNumberOfSelectedAssets = YES;
    qbIPC.minimumNumberOfSelection = 3;
    qbIPC.maximumNumberOfSelection = 5;
    [self presentViewController:qbIPC animated:YES completion:NULL];
}
// QBImagePickerController delegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
}
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - NavBarItemViewDelegate 点击查看SlideVC效果

// NavBarItemViewDelegate 点击导航栏按钮
- (void)clickNavBarItemView:(NavBarItemView *)navBarItemView navBarType:(NavBarType)type
{
    if (type == LeftBarType)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (type == RightBarType)
    {
        // 查看slideVC滑动效果
        aVC *a = [[aVC alloc] init];
        bVC *b = [[bVC alloc] init];
        
        // 导航栏很诡异 viewWillAppear，navigationBarHidden等 我没弄懂而已
        //SlideViewController *slideVC = [[SlideViewController alloc] initWithMainVC:a sideVC:b direction:SlideFromRight];
        UINavigationController *navC0 = [[UINavigationController alloc] initWithRootViewController:a];
        UINavigationController *navC1 = [[UINavigationController alloc] initWithRootViewController:b];
        SlideViewController *slideVC = [[SlideViewController alloc] initWithMainVC:navC0 sideVC:navC1 direction:SlideFromRight];
        
        /*a.delegate = slideVC;*/
        
        slideVC.mainNavItem = a.navigationItem;
        slideVC.mainNavC = a.navigationController;
        slideVC.isNeedPopBack = YES;
        
        [self.navigationController pushViewController:slideVC animated:YES];
    }
}




#pragma mark - 回退手势

- (void)createPopGesture
{
//    // 手势回退 自带的 ios7以上 需在边上滑触发
//    if ([KUtils isIOS7])
//    {
//        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//        self.navigationController.interactivePopGestureRecognizer.delegate = nil;  // *_* delegate必须是nil啊
//    }
    
    
    // 向右滑手势 回退
    NSArray *viewControllers = self.navigationController.viewControllers;
    NSInteger maxIndex = viewControllers.count - 1;
    if (maxIndex > 0)  // 前一个vc不为空（maxIndex==0表示navC里只有当前一个vc）
    {
        NSInteger preIndex = maxIndex - 1;
        UIViewController *preVC = [viewControllers objectAtIndex:preIndex];
        // 屏幕截图
        UIImage *imgPreScreenShot = [KUtils imageFromView:preVC.view];
        _imgViewPreScreenShot = [[UIImageView alloc] initWithImage:imgPreScreenShot];
        
        // 添加滑动手势
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gesturePop:)];
        //panGesture.delegate = self;
        [self.view addGestureRecognizer:panGesture];
    }
}

// 向右滑 回退
- (void)gesturePop:(UIPanGestureRecognizer *)panGesture
{
    CGPoint gestureTranslation = [panGesture translationInView:self.view];
    
    // 开始滑动时 把上一个vc的截图放在屏幕最下面，这样在手势滑动self时就可以看到前一个vc
    if (panGesture.state == UIGestureRecognizerStateBegan)
    {
        [[UIApplication sharedApplication].keyWindow insertSubview:_imgViewPreScreenShot atIndex:0];
        
        //self.navC无法一起滑动，需做一个假的navC，把真的隐藏
        UIImage *imgNav = [KUtils imageFromView:self.navigationController.view];
        _imgViewSelfNavScreenShot = [[UIImageView alloc] initWithImage:imgNav];
        [self.view addSubview:_imgViewSelfNavScreenShot];
        self.navigationController.navigationBarHidden = YES;
    }
    
    // 边界控制
    if ((self.view.frame.origin.x < kSCREEN_WIDTH && gestureTranslation.x > 0) ||
        (self.view.frame.origin.x > 0 && gestureTranslation.x < 0)
       )
    {
        // 随手势滑动的效果
        CGFloat selfCenterX = self.view.center.x + gestureTranslation.x;
        self.view.center = CGPointMake(selfCenterX, kSCREEN_HEIGHT * 0.5);
        [panGesture setTranslation:CGPointZero inView:self.view];  // *_* 清空手势的移动距离
    }
    
    // 手势结束时修正位置，超过1/3屏幕就navPop，否则还原  加动画效果
    if (panGesture.state == UIGestureRecognizerStateEnded)
    {
        if (self.view.frame.origin.x >= kSCREEN_WIDTH / 3)
        {
            // navPop
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.view.center = CGPointMake(kSCREEN_HEIGHT * 1.5, kSCREEN_HEIGHT / 2);
                             }
                             completion:^(BOOL finished){
                                 [self.navigationController popViewControllerAnimated:NO];
                                 [_imgViewPreScreenShot removeFromSuperview];
                             }];
        }
        else
        {
            // 还原
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.view.center = CGPointMake(kSCREEN_WIDTH / 2, kSCREEN_HEIGHT / 2);
                             }
                             completion:^(BOOL finished){
                                 [_imgViewPreScreenShot removeFromSuperview];
                                 
                                 // 还原navC
                                 self.navigationController.navigationBarHidden = NO;
                                 [_imgViewSelfNavScreenShot removeFromSuperview];
                             }];
        }
    }
}




#pragma mark - 自定义的 广播通知 Notification

//- (void)notificationTest
//{
//    //NSString *sysNotifyName = UIKeyboardDidChangeFrameNotification;
//    NSString *myNotifyName = @"myNotifyName_AppDidEnterBackground";
//    
//    // 注册自定义广播通知
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(kkMethod:)
//                                                 name:myNotifyName
//                                               object:nil];
//    // 注销自定义广播通知
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:myNotifyName object:nil];
//    
//    // 调用自定义广播通知  （如果是系统广播通知则会自动触发，例如键盘keyboardDidChangeFrame等）
//    if (...)
//    {
//        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"paramValue", @"paramKey", nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:myNotifyName object:nil userInfo:dic];
//    }
//}
//
//- (void)kkMethod:(NSNotification *)notify
//{
//    NSDictionary *notifyUserInfo = [notify userInfo];
//    id paramValue = [notifyUserInfo valueForKey:@"paramKey"];
//    //...
//}


#pragma mark - KVO key-value-observing 键值观察模式

- (void)testKVO
{
    _kovObj = [[NSObject alloc] init];
    [_kovObj addObserver:self forKeyPath:@"obj's property" options:0 context:nil];
    //[_kovObj removeObserver:self forKeyPath:@"obj's property"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _kovObj && [keyPath isEqualToString:@"_obj's property"])
    {
        //...
    }
}


#pragma mark - KVC key-value-coding 键值编码

//@interface Account : NSObject
//@property (nonatomic) float balance;
//@end
//
//@interface Person : NSObject
//{
//    @private
//    int _age;
//}
//@property (nonatomic) NSString *name;
//@property (nonatomic) NSString *addr;
//@property (nonatomic) Account *acct;
//@end
//
//- (void)testKVC
//{
//    Person *p = [Person alloc] init];
//    p.name = @"lc";
//    [p setValue:@"China" forKey:@"addr"];
//    [p setValue:@27 forKey:@"age"];
//    [p setValue:@12.0 forKeyPath:@"acct.balance"];
//    NSLog(@"%@", p.addr);
//    NSLog(@"%@", [p valueForKey:@"age"]);
//    NSLog(@"%@", [p valueForKeyPath:@"age"]);
//}




#pragma mark - js + native 混合编程 （hybrid app）

- (void)jsTest
{
    JSContext *jsContext = [[JSContext alloc] init];
    jsContext.exceptionHandler = ^(JSContext *c, JSValue *exception) {
        NSLog(@"js异常 %@", exception);
        c.exception = exception;
    };
    
    // oc call js
    NSString *jsStr = @"'哈哈 this is str from js'";  // alert,confirm,window等需在网页中使用 [webView stringByEvaluatingJavaScriptFromString:]  JavaScriptCore中没用
    JSValue *jsValue = [jsContext evaluateScript:jsStr];
    NSString *jsValueResult = [jsValue toString];
    NSLog(@"js的执行结果 %@", jsValueResult);
    
    // oc call js (with param)
    jsStr = @"function jsFunc_kk(a, b) { return a + b; }";
    [jsContext evaluateScript:jsStr];
    JSValue *jsValue_Func = jsContext[@"jsFunc_kk"];
    NSLog(@"js方法 %@", [jsValue_Func toString]);
    jsValue = [jsValue_Func callWithArguments:@[@(1),@(2)]];
    NSLog(@"js带参数的执行结果 %@", [jsValue toString]);
    
    // js call oc (with param)
    jsContext[@"jsFunc_iOS_popVC"] = ^() {
        NSArray *argsArr = [JSContext currentArguments];
        for (id obj in argsArr) {
            NSLog(@"js传来的参数 %@", obj);
        }
        //[self.navigationController popViewControllerAnimated:YES];
        return @"pop success";
    };
    jsStr = @"jsFunc_iOS_popVC('jsParam','哈哈')";
    jsValue = [jsContext evaluateScript:jsStr];
    NSLog(@"js的调用结果 %@", [jsValue toString]);
    
    // JSExport (js call oc)
}




#pragma mark - 不定参数

// C#中params关键字，js中arguments，oc中...三个点

// C#：  void Method(params object[] args) {}  ->  Method(1, "kk");
// js：  function method() { for(var i=0; i<arguments.length; i++) { alert(arguments[i]); } }  ->  method(1, "kk");

- (void)paramsTestMethod:(id)firstArg, ...
{
    NSLog(@"...不定参数测试 firstArg *_* %@", firstArg);
    va_list argList;
    va_start(argList, firstArg);
    id arg;
    while ((arg = va_arg(argList, id))) {
        NSLog(@"...不定参数测试 args *_* %@", arg);
    }
    //NSString *strArg = va_arg(argList, NSString*);
    //int iArg = va_arg(argList, int);
    //NSLog(@"...不定参数测试 args *_* strArg=%@, iArg=%d", strArg, iArg);
    va_end(argList);
}

- (void)paramsTest
{
    [self paramsTestMethod:nil, @"kk", nil];
    //[self paramsTestMethod:@(1), @"kk", 13, nil];
}




#pragma mark - 正则表达式

- (void)regTest
{
    NSString *str = @"http_//v.qq.com/cover/u/uypsgtbnuh02jpq.html?vid=u0020nzzt7s-_-&k=1&vid=lc&kk=1";
    //NSString *regStr = @"^http_//v\\.qq\\.com/\\S+vid=(\\S+)";
    NSString *regStr = @"vid=([^&]+)";  // *_* oc无法获取()里的内容
    
    // 匹配
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regStr options:NSRegularExpressionCaseInsensitive error:nil];
    // 匹配第一次
    NSTextCheckingResult *regResult = [regExp firstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
    if (regResult)
    {
        NSLog(@"匹配第一次 %@", [str substringWithRange:regResult.range]);
    }
    //// 匹配全部
    //NSArray *regResultArr = [regExp matchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, str.length)];
    //NSLog(@"regResultArr = %@", regResultArr);
    // 匹配全部
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    [regExp enumerateMatchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result)
        {
            NSLog(@"匹配全部 %@", [str substringWithRange:result.range]);
            [resultArr addObject:[str substringWithRange:result.range]];
        }
    }];
    NSLog(@"resultArr = %@", resultArr);
    
    // 匹配，仅第一次
    //regStr = @"(?<=vid=)[^&]+";  // *_* js不支持反向预查
    NSRange range = [str rangeOfString:@"(?<=vid=).+(?=-_-)" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound)
    {
        NSLog(@"匹配，仅第一次 %@", [str substringWithRange:range]);
    }
    
    // 校验  *_* vid=([^&]+)校验结果与js不一样，草
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regStr];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", @"vid="];
    BOOL isValidate = [predicate evaluateWithObject:str];
    NSLog(@"%d (%d, %d)", isValidate, YES, NO);
    NSLog(@"%@", (isValidate ? @"YES" : @"NO"));
}




#pragma mark - lazy延迟加载 （self.pXX与_pXX的区别）
// self.pXX是对属性的间接访问，间接调用了get/set方法；
// _pXX是对局部变量的直接访问，不会调用get/set方法

- (void)lazyTest {
    [self.view addSubview:self.pView];
}

- (UIView *)pView {
    if (!_pView) {
        _pView = [[UIView alloc] initWithFrame:CGRectMake(50, 100, kSCREEN_WIDTH, 100)];
        _pView.backgroundColor = [UIColor grayColor];
    }
    return _pView;
}


#pragma mark - 获取当前语言环境

- (void)sysLanguages {
}


#pragma mark - addBtn 增加按钮 点击跳转其他测试

- (void)addBtn:(CGRect)btnFrame title:(NSString *)titleStr tag:(NSInteger)tag
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = btnFrame;
    [btn addTarget:self action:@selector(buttonClick_Others:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:titleStr forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor blueColor].CGColor;
    btn.tag = tag;
    [self.view addSubview:btn];
}

- (void)buttonClick_Others:(UIButton *)btn
{
    if (btn.tag == BtnTagOthers_thread)
    {
        // 多线程
        threadViewController *threadVC = [[threadViewController alloc] init];
        [self.navigationController pushViewController:threadVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_socket)
    {
        // socket
        socketViewController *socketVC = [[socketViewController alloc] init];
        [self.navigationController pushViewController:socketVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_audio)
    {
        // 音频
        AudioViewController *audioVC = [[AudioViewController alloc] init];
        [self.navigationController pushViewController:audioVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_media)
    {
        // 视频
        MediaViewController *mediaVC = [[MediaViewController alloc] init];
        [self.navigationController pushViewController:mediaVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_block)
    {
        // block
        blockViewController *blockVC = [[blockViewController alloc] init];
        [self.navigationController pushViewController:blockVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_request)
    {
        // 网路请求 暴力破解
        requestViewController *requestVC = [[requestViewController alloc] init];
        [self.navigationController pushViewController:requestVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_nav)
    {
        // NavBar Toolbar
        navViewController *navVC = [[navViewController alloc] init];
        [self.navigationController pushViewController:navVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_AesDes)
    {
        // aes/des加密解密
        aes_desViewController *aes_desVC = [[aes_desViewController alloc] init];
        [self.navigationController pushViewController:aes_desVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_UIBezierPath)
    {
        // 手写电子签名（画画然后生成图片）
        signatureViewController *signatureVC = [[signatureViewController alloc] init];
        [self.navigationController pushViewController:signatureVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_2d)
    {
        // 2d绘图 实线虚线弧线圆三角形等等
        _2dViewController *_2dVC = [[_2dViewController alloc] init];
        [self.navigationController pushViewController:_2dVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_3d)
    {
        // layer 3d
        _3dViewController *_3dVC = [[_3dViewController alloc] init];
        [self.navigationController pushViewController:_3dVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_map)
    {
        // 地图
        MapViewController *mapVC = [[MapViewController alloc] init];
        [self.navigationController pushViewController:mapVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_addressbook)
    {
        // 通讯录、短信、邮件
        addressbookViewController *abVC = [[addressbookViewController alloc] init];
        [self.navigationController pushViewController:abVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_bluethooth)
    {
        // 蓝牙
        bluetoothViewController *btVC = [[bluetoothViewController alloc] init];
        [self.navigationController pushViewController:btVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_bgTask)
    {
        // 后台任务、本地通知
        taskViewController *taskVC = [[taskViewController alloc] init];
        [self.navigationController pushViewController:taskVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_keyboard)
    {
        // 键盘
        keyboardViewController *keyboardVC = [[keyboardViewController alloc] init];
        [self.navigationController pushViewController:keyboardVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_autolayout)
    {
        // storyboard 自动布局
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"sb" bundle:nil];
        UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"vcId"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (btn.tag == BtnTagOthers_drag)
    {
        // 长按拖动
        dragViewController *dragVC = [[dragViewController alloc] init];
        [self.navigationController pushViewController:dragVC animated:YES];
    }
    else if (btn.tag == BtnTagOthers_kLine)
    {
        // 股票k线图
        KLineViewController *klineVC = [[KLineViewController alloc] init];
        [self.navigationController pushViewController:klineVC animated:YES];
    }
}




#pragma mark - 简单测试 NSLog

- (void)test
{
//    // str
//    NSString *kkStr = @"sB";
//    kkStr = [kkStr stringByAppendingString:@" *_*"];  //sB *_*
//    NSLog(@"%@", kkStr);
//    
//    NSMutableString *kkMutableStr = [[NSMutableString alloc] initWithString:@"hello"];
//    [kkMutableStr appendString:@" everyone"];  //hello everyone
//    NSLog(@"%@", kkMutableStr);
//    
//    NSLog(@"%@", [kkStr substringToIndex:4]);  //sB *_
//    NSLog(@"%@", [kkStr substringFromIndex:4]);  //_*
//    NSLog(@"%@", [kkStr substringWithRange:NSMakeRange(3, 2)]);  //*_
//    
//    NSLog(@"%@", [kkStr stringByReplacingOccurrencesOfString:@" " withString:@""]);  //sB*_*
//    
//    NSArray *splitedStrArr = [kkStr componentsSeparatedByString:@" "];  //[sB,*_*]
//    NSLog(@"%@", splitedStrArr);
//
//    BOOL b = [kkStr containsString:@"*_"];  //yes （ios8以上）
//    BOOL b1 = ([kkStr rangeOfString:@"*_"].location != NSNotFound);  //yes
//    
//    //if ([KUtils isNullOrEmptyStr:kkStr])
//    
//    //if ([kkStr isEqualToString:@""])
//    //if (strcmp(kkStr, @"") == 0)
//    
//    NSLog(@"%@", [kkStr uppercaseString]);    // 大写
//    NSLog(@"%@", [kkStr lowercaseString]);    // 小写
//    NSLog(@"%@", [kkStr capitalizedString]);  // 首字母大写
//
//
//    // int <-> str
//    NSString *s = @"2";
//    int i = [s intValue] + 200;
//    NSString *s1 = [NSString stringWithFormat:@"%d", i];
//    NSString *s2 = [[NSNumber numberWithInt:i] stringValue];
//
//    // bool <-> str
//
//    
//    // 把字符串放入指定宽度，不够宽就换行，返回size
//    CGSize constraintSize = CGSizeMake(lb.frame.size.width, 9999);
//    CGSize strSize = [lb.text sizeWithFont:lb.font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
//    NSLog(@"%f *_* %f", strSize.width, strSize.height);
    
    
    
    
//    // 字符长度
//    NSString *str = @"我们ka0";
//    int lenResult = 0;
//    char *p = (char *)[str cStringUsingEncoding:NSUnicodeStringEncoding];
//    NSUInteger lenTemp = [str lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];
//    NSLog(@"lenTemp = %lu", lenTemp);
//    for (int i=0; i<lenTemp; i++) {
//        if (*p) {
//            lenResult++;
//            NSLog(@"*_* %i", lenResult);
//        }
//        p++;
//        NSLog(@"-_-");
//    }
//    NSLog(@"字符长度 = %i", lenResult);
    
    
    
    
//    // date -> str
//    NSDate *currentD = [NSDate date];  // 本机当前时间（不准，本机可以乱调时间）
////    NSString *dStr0 = [NSString stringWithFormat:@"%@", currentD];  // 格林尼治时间  [yyyy-MM-dd ?:mm:ss +0000]
////    NSLog(@"%@", dStr0);
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
////    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    df.dateFormat = @"日期格式哇吼吼 EEE, d MMM yyyy HH:mm:ss";
//    NSString *dStr = [df stringFromDate:currentD];
//    NSLog(@"%@", dStr);
//
//    //G: 公元时代，例如AD公元
//    //yy: 年的后2位
//    //yyyy: 完整年
//    //MM: 月，显示为1-12
//    //MMM: 月，显示为英文月份简写,如 Jan
//    //MMMM: 月，显示为英文月份全称，如 Janualy
//    //dd: 日，2位数表示，如02
//    //d: 日，1-2位显示，如 2
//    //EEE: 简写星期几，如Sun
//    //EEEE: 全写星期几，如Sunday
//    //aa: 上下午，AM/PM
//    //H: 时，24小时制，0-23
//    //K：时，12小时制，0-11
//    //m: 分，1-2位
//    //mm: 分，2位
//    //s: 秒，1-2位
//    //ss: 秒，2位
//    //S: 毫秒
//    
//    // str -> date
//    NSString *strD = @"2015-07-13 18:00:01";
//    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
//    df1.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//    df1.locale = [NSLocale currentLocale];
//    NSDate *d = [df1 dateFromString:strD];

    
//    // 时间与字符串相互转化
//    
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//    NSString *strD = [df stringFromDate:[NSDate date]];
//    
//    NSString *kk = @"2015-07-14 18:00:01";
//    NSDate *d = [df dateFromString:kk];
//    NSTimeInterval ti = [d timeIntervalSinceNow];
////    NSTimeInterval ti1 = [d timeIntervalSinceDate:[NSDate date]];
////    BOOL bb = [d isEqualToDate:[NSDate date]];
//    if (ti <= 0)
//    {
//        NSLog(@"过去%f秒", ti);
//    }
//    else
//    {
//        NSLog(@"未来%f秒", ti);
//    }
    
    
//    NSLog(@"%@", [NSDate distantFuture]);
//    NSLog(@"%@", [NSDate distantPast]);
    
    
//    //lb.text = [NSString stringWithFormat:@"%02d:%02d", currentSeconds/60, currentSeconds%60];
    
//    //"NSString+Addtions.h" category 类别
//    NSString *currentTimeStr = [NSString currentTimeStr];
//    NSURL *str = [@"kk" toURL];
    
    
//    // C语言时间写法
//    time_t currentTime = time(NULL);
//    id obj_preTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"NetworkTime"];
//    time_t preTime = [obj_preTime longValue];
//    printf("*_*  %ld - %ld = %ld \n", currentTime, preTime, currentTime-preTime);
    
    
    
    
//    // 路径
//    NSString *directory = NSHomeDirectory();  // ...(/Documents|Library|tmp)
//    NSString *directory_Documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];  // .../Documents
//    NSString *directory_Library = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];  // .../Library
//    NSString *directory_Library_Caches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];  // .../Library/Caches
//    NSString *directory_tmp = NSTemporaryDirectory();  // .../tmp/
//
//    NSString *resourceFilePath = [[NSBundle mainBundle] pathForResource:@"PropertyList.plist" ofType:@""];
//    NSString *resourceFilePath1 = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"PropertyList.plist"];
//    NSString *resourceFilePath2 = [[NSBundle mainBundle] pathForResource:@"PropertyList" ofType:@"plist"];
//    NSString *resourceFilePath_fr = [[NSBundle mainBundle] pathForResource:@"folder_references/audio.mp3" ofType:@""];
//    NSString *fileExtention = resourceFilePath.pathExtension;  // 文件扩展名 （plist）
//    
//    //NSString *resourceFileUrl = [[NSBundle mainBundle] URLForResource:@"PropertyList.plist" withExtension:@""];
//
//    NSString *createFilePath = [directory_Documents stringByAppendingString:@"/ahw.db"];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL isDir;
//    if (![fileManager fileExistsAtPath:directory isDirectory:&isDir])  // 文件夹（路径）不存在
//    {
//        // 创建文件夹（路径）
//        [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
//    }
    
//    //NSBundle *communityBundle = [NSBundle bundleForClass:[CommunityViewController class]];
//    NSBundle *communityBundle = [NSBundle bundleForClass:self.class];
//    UIImage *imgAdd = [UIImage imageNamed:@"community_notice_add" inBundle:communityBundle compatibleWithTraitCollection:nil];
//    UIImage *imgAdd = [UIImage imageNamed:@"Comunity.bundle/community_notice_add"];
    
    
    
//    // 字典和数组（先于webapi测试）
//    NSDictionary *dic = @{
//                              @"id" : @"",
//                              @"name" : @""
//                          };
//    
//    NSArray *arr = @[
//                         @{ @"id" : @"", @"name" : @"" },
//                         @{ @"id" : @"", @"name" : @"" },
//                         dic,
//                         @"",
//                         @(YES),
//                         [NSNumber numberWithInt:100]
//                     ];
//    
//    NSDictionary *dic1 = @{
//                               @"id" : @"",
//                               @"name" : @"",
//                               @"info" : @{ @"type" : @"", @"desc" : @"" },
//                               @"listdata" : @[@"", @"", @""],
//                               @"remark" : @""
//                           };
//    
////    NSLog(@"请求失败block");
////    YxbListData *test = [[YxbListData alloc] init];
////    _yxbListData = [test unpackJson:dic];
////    [self.tableView reloadData];
    
    
    
    
//    // 类型转换
//    
//    // data  <- str
//    NSString *str = @"字符串 str";
//    NSData *data_str = [str dataUsingEncoding:NSUTF8StringEncoding];
//    // str  <- data
//    NSString *str_data = [[NSString alloc] initWithData:data_str encoding:NSUTF8StringEncoding];
//    NSString *str_data1 = [NSString stringWithUTF8String:data_str.bytes];
//
//    // data  <- int
//    int i = 123;  // 占位符 sizeof(int) = 4
//    NSData *data_int = [NSData dataWithBytes:&i length:sizeof(i)];
//    // int  <- data
//    int j;
//    [data_int getBytes:&j length:sizeof(j)];
//    
//    // data  <- img
//    UIImage *img = [UIImage imageNamed:@"icon_blue.png"];
//    NSData *data_img = UIImagePNGRepresentation(img);
//    // img  <- data
//    UIImage *img_data = [UIImage imageWithData:data_img];
//    
//    // data  <- 网上文件
//    NSURL *fileUrl_web = [NSURL URLWithString:@"http://"];
//    NSData *fileData_web = [NSData dataWithContentsOfURL:fileUrl_web];
//    
//    // data  <- 本地文件
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"folder_references/audio.mp3" ofType:@""];
//    NSData *fileData_local = [NSData dataWithContentsOfFile:filePath];
//    //NSURL *fileUrl_local = [NSURL URLWithString:filePath];  // *_* err
//    NSURL *fileUrl_local = [NSURL fileURLWithPath:filePath];
//    NSData *fileData_local1 = [[NSData alloc] initWithContentsOfURL:fileUrl_local];
//    
//    // 本地文件  <- data
//    NSString *filePath_SaveTo = [NSTemporaryDirectory() stringByAppendingString:@"temp.mp3"];
//    BOOL isSavedSuccess_data = [fileData_local writeToFile:filePath_SaveTo atomically:YES];
//    
//    // str <- 文件
//    NSString *str_fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    // 文件 <- str
//    BOOL isSavedSuccess_str = [str_fileContents writeToFile:filePath_SaveTo atomically:YES encoding:NSUTF8StringEncoding error:nil];
//    
//    
//    NSData *data = data_str;
//
//    // char
//    char *myChar = "hello char";
//    NSLog(@"myChar=%s *_* myChar[0]=%c", myChar, myChar[0]);
//    myChar = nil;
//    char myChar1[] = {'a','b','c','1',' ',2,3};  //不加''为乱码
//    NSLog(@"myChar1=%s *_* myChar1[0]=%c", myChar1, myChar1[0]);
//    //myChar1 = nil;
//    
//    // char <- str
//    const char *char_str = str.UTF8String;
//    const char *char_str1 = [str cStringUsingEncoding:NSUTF8StringEncoding];
//    // str <- char
//    NSString *str_char = [NSString stringWithCString:char_str encoding:NSUTF8StringEncoding];
//    NSString *str_char1 = [[NSString alloc] initWithUTF8String:char_str];
//
//    // char <- data
//    const char *char_data = data.bytes;
//    char char_data1[data.length];
//    memcpy(char_data1, data.bytes, data.length);
//    // data <- char
//    NSData *data_char = [NSData dataWithBytes:char_data length:strlen(char_data)];
//    
//    // byte
//    Byte myByte[] = {'a','b','c','1',2,3};
//    //myByte = nil;
//    // byte <-> str 通过data
//    
//    // byte <- data
//    Byte *byte_data = (Byte *)data.bytes;
//    // data <- byte
//    //NSData *data_byte = [NSData dataWithBytes:byte length:];
//    //NSUInteger strByteLength = [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
//
//
//    // base64
//    NSString *str_data_Base64 = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];  // 加密 （ios7以下使用data.base64Encoding）
//    //str_data_Base64 = [[str_data_Base64 stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];  // 系统base64方法在有中文时会生成\r\n等，需去掉，否则解密不成功 （或者自己写base64加密解密）
//    NSData *data_str_UnBase64 = [[NSData alloc] initWithBase64EncodedString:str options:0];  // 解密 （ios7以下使用[[NSData alloc] initWithBase64Encoding:cipherStr]）
//    NSData *data_data_UnBase64 = [[NSData alloc] initWithBase64EncodedData:data options:0];
    
    
    
    
//    // 读写文件
//    NSMutableArray *arrKey = [[NSMutableArray alloc] init];
//    NSMutableArray *arrValue = [[NSMutableArray alloc] init];
//    NSString *resourcesPath = [[NSBundle mainBundle] pathForResource:@"folder_references/kk.txt" ofType:@""];
//    //NSArray *arr = [[NSArray alloc] initWithContentsOfFile:resourcesPath];  // *_* err
////    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:resourcesPath];  // 顺序乱掉，key值去重
////    for (NSString *strKey in [dict allKeys]) {
////        [arrKey addObject:strKey];
////        [arrValue addObject:[dict objectForKey:strKey]];
////    }
//    NSString *str = [NSString stringWithContentsOfFile:resourcesPath encoding:NSUTF8StringEncoding error:nil];
//    NSArray *arrKV = [str componentsSeparatedByString:@"\r"];
//    for (NSString *strKV in arrKV) {
//        NSArray *arrTemp = [strKV componentsSeparatedByString:@"="];
//        if (arrTemp.count != 2) {
//            NSLog(@"*_* %@", strKV);
//        }
//        else {
//            [arrKey addObject:arrTemp[0]];
//            [arrValue addObject:arrTemp[1]];
//        }
//    }
//    NSString *strPath_key = [NSString stringWithFormat:@"%@/translated_key.txt", NSHomeDirectory()];
//    [arrKey writeToFile:strPath_key atomically:YES];
//    NSString *strPath_value = [NSString stringWithFormat:@"%@/translated_value.txt", NSHomeDirectory()];
//    [arrValue writeToFile:strPath_value atomically:YES];
    
    
    
    
//     // performSelector 参数
//    
//    //[[HomeTabBarController getInstance] handlePushOfNewBid:self.bidID];  // 直接调用
//    
//    //[[HomeTabBarController getInstance] performSelector:@selector(handlePushOfNewBid:) withObject:self.bidID afterDelay:1.0];  // 一个参数
//    
//    // #import <objc/message.h>
//    //objc_msgSend([HomeTabBarController getInstance], @selector(handlePushOfNewBid:), self.bidID, nil);  // 多个参数
    
    
    
    
//    NSString *str_readonly = [SettingManager shareInstance].str_readonly;
//    NSLog(@"*_* %@", str_readonly);
//    SettingManager.str_static = @"str_static";
//    NSLog(@"*_* %@", SettingManager.str_static);
    
    
    
    
    
//    //arc = automatic reference counting 自动引用计数 ; mrc = Mannul Reference Counting ; 引用计数retainCount
//    //[obj alloc] 对象分配后引用计数=1（obj.retainCount为1）
//    //[obj release] 对象引用计数-1，如果为0则释放内存
//    //[obj autorelease] 对象引用计数-1，如果为0不马上释放，最近一个pool时释放
//    //[obj retain] 原对象引用计数+1
//    //[obj copy] 一个对象变成新的对象（新内存地址）引用计数=1，原对象引用计数不变
//
//    //@property(strong)等同于@property(retain)和@property(copy)，强引用
//    //@property(weak)等同于@property(assign)，弱引用
//    // @property (strong) UILabel *lbStrong;  ->  self.lbStrong = [UILabel alloc] init]; ...
//    // @property (weak) UILabel *lbWeak;  -> UILabel *lb = [UILabel alloc] init]; self.lbWeak = lb; ...
//
//    // strong和copy的区别
//    //@property(retain) 持有特性，setter方法将传入对象参数先保留，再赋值，传入参数的retainCount会＋1 （[param retain]; _p=param;）
//    //@property(copy) 复制特性，setter方法将传入对象参数复制一份 （[param copy]; _p=param;）
//    // NSMutableString *kkMutableStr = [NSMutableString stringWithFormat:@"abc"];
//    // self.str_StrongOrRetain = kkMutableStr;  // 与kkMutableStr地址一样
//    // self.str_copy = kkMutableStr;  // 与kkMutableStr地址不一样
//    // [kkMutableStr appendString@"zzz"];  // 此时strong和retain为"abczzz"，copy仍然为"abc"
//
//    // weak和assign的区别
//    //@property(assgin) 赋值特性，setter方法传入参数赋值给实例变量
//    // self.p_weak = obj;
//    // self.p_assign = obj;
//    // obj = nil;
//    // 此后可以使用self.p_weak，而再使用self.p_assign可能会crash。
//    // weak比assign多一个功能就是当属性所指向的对象消失（即retainCount==0）时会自动赋值为nil
//    //arc下只有基本数据类型和结构体需要用assgin，其他优先用weak 如delegate、指针变量
//    
//
//    // arc下  ——  [[NSString alloc] initWithFormat:...]是实例方法，需手动release来释放内存； [NSString stringWithFormat:...]是类方法，内存管理上是autorelease的不需要手动
//    
//    //浅拷贝是对内存地址的复制，目标对象与源对象指向同一片内存空间，改变一个对象另一个对象的成员也会改变；深拷贝是对具体内容的拷贝，而内存地址是自主分配的，新对象与原对象相互之间不会影响
//    
//    // 系统对象NSString,NSArray等  若对象不可变，则copy是浅拷贝，若对象可变，则copy是深拷贝；mutableCopy都是深拷贝
//    NSString *str = @"str";
//    NSString *strCopy = [str copy];
//    NSString *strMutableCopy = [str mutableCopy];
//    // str = @"kk";  // 这样赋值相当于alloc，重新分配了内存地址
//    NSLog(@"%p, %p, %p", str, strCopy, strMutableCopy);
//    NSMutableString *str1 = [[NSMutableString alloc] initWithString:@"str1"];
//    NSMutableString *strCopy1 = [str1 copy];  // 不可再改变
//    NSMutableString *strMutableCopy1 = [str1 mutableCopy];
//    NSLog(@"%p, %p, %p", str1, strCopy1, strMutableCopy1);
//    
//    // 自定义对象
//    MyObj *obj = [[MyObj alloc] init];
//    MyObj *objCopy = [obj copy];
//    NSLog(@"%p, %p", obj, objCopy);
//    NSLog(@"%p, %p, %p, %p", obj.str, obj.mutableStr, obj.arr, obj.mutableArr);
//    NSLog(@"%p, %p, %p, %p", objCopy.str, objCopy.mutableStr, objCopy.arr, objCopy.mutableArr);
//    NSLog(@"%@, %@, %@, %@, %d", objCopy.str, objCopy.mutableStr, objCopy.arr, objCopy.mutableArr, objCopy.kk);
//    obj.str = @"*";
//    [obj.mutableStr appendString:@"!"];
//    obj.arr = @[@"a", @"b", @"c"];
//    [obj.mutableArr removeLastObject];
//    obj.kk = 2;
//    NSLog(@"%p, %p", obj, objCopy);
//    NSLog(@"%p, %p, %p, %p", obj.str, obj.mutableStr, obj.arr, obj.mutableArr);
//    NSLog(@"%p, %p, %p, %p", objCopy.str, objCopy.mutableStr, objCopy.arr, objCopy.mutableArr);
//    NSLog(@"%@, %@, %@, %@, %d", objCopy.str, objCopy.mutableStr, objCopy.arr, objCopy.mutableArr, objCopy.kk);
    
    
    NSMutableArray *arrKey = [[NSMutableArray alloc] init];
    NSMutableArray *arrValue = [[NSMutableArray alloc] init];
    NSString *resourcesPath = [[NSBundle mainBundle] pathForResource:@"folder_references/kk.txt" ofType:@""];
    //NSArray *arr = [[NSArray alloc] initWithContentsOfFile:resourcesPath];  // *_*?
    //NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:resourcesPath];  // 顺序乱掉，key值去重
    //for (NSString *strKey in [dict allKeys]) {
    //    [arrKey addObject:strKey];
    //    [arrValue addObject:[dict objectForKey:strKey]];
    //}
    NSString *str = [NSString stringWithContentsOfFile:resourcesPath encoding:NSUTF8StringEncoding error:nil];
    NSArray *arrKV = [str componentsSeparatedByString:@"\r"];
    for (NSString *strKV in arrKV) {
        NSArray *arrTemp = [strKV componentsSeparatedByString:@"="];
        if (arrTemp.count != 2) {
            NSLog(@"*_* %@", strKV);
        }
        else {
            [arrKey addObject:arrTemp[0]];
            [arrValue addObject:arrTemp[1]];
        }
    }
    NSString *strPath_key = [NSString stringWithFormat:@"%@/translated_key.txt", NSHomeDirectory()];
    [arrKey writeToFile:strPath_key atomically:YES];
    NSString *strPath_value = [NSString stringWithFormat:@"%@/translated_value.txt", NSHomeDirectory()];
    [arrValue writeToFile:strPath_value atomically:YES];
}

@end


// 自定义对象，实现copy
//@interface MyObj : NSObject<NSCopying,NSMutableCopying>
//@interface MyObj() <NSCopying>
@implementation MyObj
- (id)init
{
    self = [super init];
    if (self)
    {
        self.str = @"str";
        self.mutableStr = [[NSMutableString alloc] initWithString:@"mutableStr"];
        self.arr = @[@"1", @"2", @"3"];
        self.mutableArr = [[NSMutableArray alloc] initWithArray:@[@"01", @"02"]];
        self.kk = -1;
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] init];  // 深拷贝
    //return self;  // 浅拷贝
    
//    MyObj *objCopy = [[[self class] allocWithZone:zone] init];
//    objCopy->_str = [_str copy];
//    objCopy->_mutableStr = [_mutableStr copy];
////    objCopy->_str = [_str copyWithZone:zone];
////    objCopy->_mutableStr = [_mutableStr copyWithZone:zone];
//    objCopy->_kk = _kk;
////    objCopy.kk = _kk;
//    return objCopy;
}
//- (id)mutableCopyWithZone:(NSZone *)zone
//{}
@end
