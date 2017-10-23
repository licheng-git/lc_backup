//
//  KUtils.m
//  lcAhwTest
//
//  Created by licheng on 15/4/9.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "KUtils.h"

@implementation KUtils


- (void)buttonAction:(id) sender
{
}

- (void)textFieldValueChange:(id) sender
{
}

/************************************************************
 ** 创建UIButton
 ** titleColor：标题文本颜色，如果使用默认问题颜色，则传nil
 ** tag：按钮标识，如果不设置，则默认使用
 ************************************************************/
+ (UIButton *)createButtonWithFrame:(CGRect)frame
                              title:(NSString *)title
                         titleColor:(UIColor *)titleColor
                             target:(id)target
                                tag:(NSInteger)tag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.adjustsImageWhenHighlighted = NO;
    [button setTitle:title forState:UIControlStateNormal];
    
    if (tag != kDEFAULT_TAG)
    {
        [button setTag:tag];
    }
    
    if (titleColor)
    {
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    }
    
    [button addTarget:target action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

/************************************************************
 ** 创建label
 ** tag 按钮标识，如果不设置，则默认使用kDEFAULT_TAG
 ************************************************************/
+ (UILabel *)createLabelWithFrame:(CGRect)frame
                             text:(NSString *)text
                         fontSize:(CGFloat)fontSize
                    textAlignment:(NSInteger)align
                              tag:(NSInteger)tag
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setText:text];
    [label setTextColor:[UIColor darkGrayColor]];
    [label setTextAlignment:align];
    [label setFont:[UIFont systemFontOfSize:fontSize]];
    if (tag != kDEFAULT_TAG)
    {
        [label setTag:tag];
    }
    return label;
}

/************************************************************
 ** 创建textField
 ** tag 按钮标识，如果不设置，则默认使用kDEFAULT_TAG
 ************************************************************/
+ (UITextField *)createTextFieldWithFrame:(CGRect)frame
                                 fontSize:(CGFloat)fontSize
                                   enable:(BOOL)enable
                                 delegate:(id)delegate
                                      tag:(NSInteger)tag
{
    UITextField *textFd = [[UITextField alloc] initWithFrame:frame];
    textFd.font = [UIFont systemFontOfSize:fontSize];
    textFd.textColor = kTextFieldFontColor;
    textFd.enabled = enable;
    textFd.delegate = delegate;
    [textFd addTarget:delegate action:@selector(textFieldValueChange:) forControlEvents:UIControlEventEditingChanged];
    if (tag != kDEFAULT_TAG)
    {
        textFd.tag = tag;
    }
    
    return textFd;
}

/************************************************************
 动画 弹出页面
 从上往下：Animationtype:kCATransitionMoveIn andSubtype:kCATransitionFromBottom
 从左往右：Animationtype:kCATransitionMoveIn andSubtype:kCATransitionFromRight
 ************************************************************/
+ (void)showView:(UIView *)view withAnimationType:(NSString *)type andSubtype:(NSString *)subType
{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.4f;
    animation.speed = 1.0f;
//    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fillMode = kCAFillModeBackwards;
    animation.removedOnCompletion = YES;
    animation.type = type;
    animation.subtype = subType;
    
    [view.layer removeAllAnimations];
    [view.layer addAnimation:animation forKey:@"animation"];
}


// 判断是否为空字符串
+ (BOOL)isNullOrEmptyStr:(NSString *)str
{
    if (!str)  // str == nil
    {
        return YES;
    }
    if ([str isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    if (![str respondsToSelector:@selector(length)] || [str length]<=0)
    {
        return YES;
    }
    return NO;
}

// 是否 空字典或空数组
+ (BOOL)isNullOrEmptyArr:(id)arr_or_dic
{
    if (!arr_or_dic || [arr_or_dic isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    if (![arr_or_dic respondsToSelector:@selector(count)] || [arr_or_dic count]<=0)
    {
        return YES;
    }
    return NO;
}

// App版本号
+ (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

// ios系统版本号
+ (NSString *)sysVersion
{
    return [UIDevice currentDevice].systemVersion;
}

// 判断是否ios7以上
+ (BOOL)isIOS7
{
    return ([[self sysVersion] floatValue] >= 7.0);
}

// 判断是否ios8以上
+ (BOOL)isIOS8
{
    return ([[self sysVersion] floatValue] >= 8.0);
}

// 设备／模拟器 屏幕分辨率  判断是iPhone几
+ (BOOL)isScreenEqualToSize:(CGSize)size
{
    BOOL flag = NO;
    if ([UIScreen instancesRespondToSelector:@selector(currentMode)])
    {
        CGSize size_current = [UIScreen mainScreen].currentMode.size;
        flag = CGSizeEqualToSize(size_current, size);
    }
    return flag;
}

// iPhone4/4s
+ (BOOL)isIPhone4
{
    return [self isScreenEqualToSize:CGSizeMake(640, 960)];
}
// iPhone5/5s/5c
+ (BOOL)isIPhone5
{
    return [self isScreenEqualToSize:CGSizeMake(640, 1136)];
}
// iPhone6
+ (BOOL)isIPhone6
{
    return [self isScreenEqualToSize:CGSizeMake(750, 1334)];
}
// iPhone6+
+ (BOOL)isIPhone6Plus
{
    return [self isScreenEqualToSize:CGSizeMake(1242, 2208)];
}

// 系统语言  en英语,zh-Hans简体中文,zh-Hant繁体中文,...？
+ (NSString *)sysLanguage {
    NSArray *arrLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];  // 所有语言
    NSString *strCurrentLanguage = arrLanguages[0];  // 当前语言
    for (NSString *strLanguage in arrLanguages) {
        NSLog(@"语言 %@", strLanguage);
    }
    return strCurrentLanguage;
}

// 检查网络是否可用
+ (BOOL)isConnectionAvailable
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags");
        return NO;
    }
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}

// md5 32位 加密 （小写）
+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[32];
    
    // CC_LONG强制转换
    CC_MD5( cStr, (CC_LONG)(strlen(cStr)), result );
    
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
           ];
}

// aes加密
+ (NSString *)aes:(NSString *)str
{
    return [AESCrypt encrypt:str password:@"1234567891234567"];
}

// 创建唯一标识 UUID（Guid）
+ (NSString *)createUUID
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    NSString *sUUID = [NSString stringWithString:(__bridge NSString *)uuidStr];
    CFRelease(uuidStr);
    CFRelease(uuid);
    return sUUID;
}


// 拨打电话
+ (void)openTelphone:(NSString *)telNum
{
    NSString *strUrl_tel = [NSString stringWithFormat:@"tel://%@", telNum];
    NSURL *url_tel = [NSURL URLWithString:strUrl_tel];
#if TARGET_IPHONE_SIMULATOR
    //[self showAlertMessage:strUrl_Tel];
#else
    [[UIApplication sharedApplication] openURL:url_tel];
#endif
}

// newVersion是否最新版本 （是则需更新）
+ (BOOL)isLatestVersion:(NSString *)newVersion
{
    NSString *currentVersion = [KUtils appVersion];
    NSArray *newArr = [newVersion componentsSeparatedByString:@"."];
    NSArray *currentArr = [currentVersion componentsSeparatedByString:@"."];
    for (int i=0; i<newArr.count && i<currentArr.count; i++)
    {
        int newValue = [[newArr objectAtIndex:i] intValue];
        int currentValue = [[currentArr objectAtIndex:i] intValue];
        if (newValue > currentValue)
        {
            return YES;
        }
        else if(newValue < currentValue)
        {
            return NO;
        }
    }
    return NO;
}

// 更新 根据应用AppID打开AppStore
+ (void)openAppDownLoadAddress
{
    NSString *appDownLoadAddress = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@",kAppID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appDownLoadAddress]];
}

// 强制退出程序 － 动画方式  （*_*有可能审核被拒）
+ (void)exitApplication
{
    //[UIView animateWithDuration:0.5 animations:^{
    //    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
    //                           forView:[UIApplication sharedApplication].keyWindow
    //                             cache:NO];
    //    [UIApplication sharedApplication].keyWindow.bounds = CGRectMake(0, 0, 0, 0);
    //} completion:^(BOOL finished) {
    //    abort();
    //}];
    
    [UIView beginAnimations:@"exitApplication" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                           forView:[UIApplication sharedApplication].keyWindow
                             cache:NO];
    [UIApplication sharedApplication].keyWindow.bounds = CGRectMake(0, 0, 0, 0);
    [UIView setAnimationDidStopSelector:@selector(animationFinished:context:)];
    [UIView commitAnimations];
}

+ (void)animationFinished:(NSString *)animationID context:(void *)context
{
    if ([animationID compare:@"exitApplication"] == 0) // [animationID isEqualToString:@"exitApplication"]
    {
        /*
         警告：不要使用exit(0)函数，调用exit会让用户感觉程序崩溃了，不会有按Home键返回时的平滑过渡和动画效果；另外，使用exit可能会丢失数据，因为调用exit并不会调用-applicationWillTerminate:方法和UIApplicationDelegate方法；
         如果在开发或者测试中确实需要强行终止程序时，推荐使用abort()函数和assert宏
         */
        abort();
    }
}


// 视图生成图片
+ (UIImage *)imageFromView:(UIView *)view
{
    //UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, view.layer.contentsScale);
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];  // 子视图都加进去
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

// 缩放图片到指定大小
+ (UIImage *)image:(UIImage *)img scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *imgScaled = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imgScaled;
}

// 裁剪图片（前提是img.size>参数size）
+ (UIImage *)image:(UIImage *)img clipToSize:(CGSize)size
{
    NSLog(@"(%zu,%zu) (%f,%f)", CGImageGetWidth(img.CGImage), CGImageGetHeight(img.CGImage), img.size.width, img.size.height);
    
//    // 从原图上切一块下来
//    UIGraphicsBeginImageContext(size);
//    [img drawInRect:CGRectMake(-20, -50, img.size.width, img.size.height)];
//    UIImage *imgClipped = UIGraphicsGetImageFromCurrentImageContext();
    
    // 先等比缩小，再切中心的一块，size<img.size
    float scaleW = size.width/img.size.width;
    float scaleH = size.height/img.size.height;
    float scale = (scaleW > scaleH) ? scaleW : scaleH;
    CGFloat x = (img.size.width*scale - size.width) / 2;
    CGFloat y = (img.size.height*scale - size.height) / 2;
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(-x, -y, img.size.width*scale, img.size.height*scale)];
    UIImage *imgClipped = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imgClipped;
}




// 内存使用值 ?
+ (unsigned long)memoryUsage {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    //unsigned long memorySize = info.resident_size >> 10;
    unsigned long memorySize = info.resident_size;
    return memorySize;
}

// 内存总大小
+ (long long)memoryTotal {
    return [NSProcessInfo processInfo].physicalMemory;
}

// CPU占用率
+ (CGFloat)cpuUsage {
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    thread_basic_info_t    basic_info_th;
    
    // get threads in the task
    kern_return_t kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    CGFloat tot_cpu = 0;
    
    // for each thread
    for (int j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,(thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (CGFloat)TH_USAGE_SCALE * 100.0;
        }
    }
    
    // free memory
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}


static int kRefreshTag = -1024000;
static int kRefreshTimes = 0;

// 监测性能（内存值和cup占用率）
+ (void)monitor {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 20)];
    v.backgroundColor = [UIColor blackColor];
    v.tag = kRefreshTag;
    [[UIApplication sharedApplication].keyWindow addSubview:v];
    UILabel *lb = [self createLabelWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 20) text:nil fontSize:14 textAlignment:NSTextAlignmentCenter tag:0];
    lb.text = @"监测";
    lb.textColor = [UIColor whiteColor];
    lb.backgroundColor = [UIColor clearColor];
    [v addSubview:lb];
    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(refreshMonitor) userInfo:nil repeats:YES];
    [t fire];
}

+ (void)refreshMonitor {
    UIView *v = [[UIApplication sharedApplication].keyWindow viewWithTag:kRefreshTag];
    UILabel *lb = v.subviews[0];
    lb.text = [NSString stringWithFormat:@"监测(%i) 内存%0.1fMB cpu%0.0f%%",
               kRefreshTimes++,
               (float)([self memoryUsage]/1024/1024),
               [self cpuUsage]];
}


// 记录崩溃日志
+ (void)uncaughtExceptionLog {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}

void uncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];
    NSString *strName = [exception name];
    NSString *strReason = [exception reason];
    NSString *strCallStackSymbols = [arr componentsJoinedByString:@"\n"];
    NSLog(@"*_* 崩溃日志\n 名称 %@\n 原因 %@\n 调用栈 %@", strName, strReason, strCallStackSymbols);
}

@end
