//
//  taskViewController.m
//  lcAhwTest
//
//  Created by licheng on 16/3/8.
//  Copyright © 2016年 lc. All rights reserved.
//

#import "taskViewController.h"

@interface taskViewController ()
{
    NSTimer *_timer;
    UIBackgroundTaskIdentifier _bgTask;
    int _count;
    UILabel *_lb;
}
@end

@implementation taskViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"后台任务／计时器／本地推送";
    
    [self bgTask];  // 后台任务一般写到AppDelegate的applicationDidEnterBackground:方法里
}


// 后台任务    无限时间？能否审核通过？
- (void)bgTask
{
    // 后台播放音乐、定位、下载、voip网络电话  无限时间  Required background modes
    
    
    // 后台任务（180s/600s/总时间10分钟内）
    _bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"超时");
        //[[UIApplication sharedApplication] endBackgroundTask:_bgTask];  // 结束后台任务
    }];
    _lb = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 200, 20)];
    _lb.text = @"后台任务";
    [self.view addSubview:_lb];
    
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(test0) userInfo:nil repeats:YES];
    [_timer fire];
    
    //[_timer invalidate];  // 永久停止
    //[_timer setFireDate:[NSDate distantPast]];
    //[_timer setFireDate:[NSDate distantPast]];  // 停止了还能再起来
    
    
    //_timer = [WeakTimerObj scheduledTimerWithTimeInterval:1 target:self selector:@selector(test0) userInfo:nil repeats:YES];
}

- (void)test0
{
    _count++;
    _lb.text = [NSString stringWithFormat:@"后台任务 *_* %i", _count];
    NSLog(@"count=%i", _count);
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
        NSTimeInterval bgTimeRemaing = [[UIApplication sharedApplication] backgroundTimeRemaining];  // 剩余时间
        NSLog(@"bgTimeRemaining=%0.0f", bgTimeRemaing);
    }
    
    if (_count == 10*60+100)
    {
        NSLog(@"结束任务");
        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];  // 结束后台任务
        [_timer invalidate];
    }
    
    
    // 本地推送
    if (_count == 10)
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        localNotif.alertBody = [NSString stringWithFormat:@"hello 本地推送 内容 *_* %i *_* %p", _count, self];
        localNotif.alertAction = @"hi 本地推送 锁屏提示";
        localNotif.applicationIconBadgeNumber = 3;
        localNotif.soundName = @"msg.wav";
        localNotif.userInfo = @{ @"id" : @"xx哈哈", @"name" : @"艾弗森" };
        localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        localNotif.repeatInterval = 0;  // 不循环推
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }
}


//- (void)clickNavBarItemView:(NavBarItemView *)navBarItemView navBarType:(NavBarType)type
//{
//    if (type == LeftBarType)
//    {
//        [_timer invalidate];
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//}

- (void)dealloc
{
    NSLog(@"self释放成功");
    [_timer invalidate];  // WeakTimerObj释放
}

@end



// NSTimer会对其target进行retain，没有[timer invalidate]将其从循环池中移除的话 它所引用的对象将一直存在 造成内存泄漏
// 所以这里要不对self进行retain 保证self的dealloc一定执行，然后在self的dealloc方法中[_timer invalidate]释放掉WeakTimerObj
@interface WeakTimerObj()
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@end
@implementation WeakTimerObj
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    WeakTimerObj *weakObj = [[WeakTimerObj alloc] init];
    weakObj.target = aTarget;
    weakObj.selector = aSelector;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:ti target:weakObj selector:@selector(fire:) userInfo:userInfo repeats:yesOrNo];
    return timer;
}
- (void)fire:(id)obj
{
    [self.target performSelector:self.selector withObject:obj];
    NSLog(@"WeakTimerObj repeat");
}
- (void)dealloc
{
    NSLog(@"WeakTimerObj释放成功");
}
@end



