//
//  threadViewController.m
//  lcAhwTest
//
//  Created by licheng on 16/3/10.
//  Copyright © 2016年 lc. All rights reserved.
//

#import "threadViewController.h"

@interface threadViewController ()
{
    // 售票
    int          _tickets;
    NSThread     *_thread0;
    NSLock       *_lock;
    NSCondition  *_condition;
    
    // runloop
    NSTimer  *_timer;
    UIView   *_bgview;
    NSArray  *_arrImg;
    NSInteger _kTag;
}
@end

@implementation threadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"thread";
    /*
     异步
     1.GCD (Grand Central Dispatch)
     2.Cocoa NSOperation
     3.NSThread
     */
    //[self gcdTest];
    //[self opterationTest];
    //[self threadTest];
    //[self sellTickets];
    //[self gcdTest_group];
    //[self gcdTest_barrier];
    //[self gcdTest_others];
    [self runloopTest];
    [self runloopTest_timer];
}


#pragma mark - 异步下载 (GCD NSOperation NSThread)

// GCD (Grand Central Dispatch)
- (void)gcdTest
{
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 80, 50, 50)];
    loadingView.color = [UIColor blueColor];
    [self.view addSubview:loadingView];
    [loadingView startAnimating];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, 200, 150)];
    [self.view addSubview:imgView];
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
            [loadingView stopAnimating];
        });
    });
}


// Cocoa NSOperation
- (void)opterationTest
{
//    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
//    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(threadDownloadImage) object:nil];
//    [operationQueue addOperation:operation];
    
//    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
//    //operationQueue.maxConcurrentOperationCount = 5;  // 设置最大并发线程数
//    //for ()  // 线程并行
////    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
////        [self threadDownloadImage];
////    }];
////    [operationQueue addOperation:blockOperation];
//    [operationQueue addOperationWithBlock:^{
//        [self threadDownloadImage];
//    }];
//    
//    // threadDownloadImage中添加更新UI操作（mainQueue是UI主线程）
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        [self mainThreadUpdateUI:img];
//    }];
}


// NSThread
- (void)threadTest
{
    //[NSThread sleepForTimeInterval:2.0];  // 线程休眠
    //sleep(2);

    //[self performSelectorInBackground:@selector(threadDownloadImage) withObject:nil];
    //[NSThread detachNewThreadSelector:@selector(threadDownloadImage) toTarget:self withObject:nil];
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadDownloadImage) object:nil];  // 创建线程
    [thread start];
    
//    //thread.name = @"thread0";  // 线程名称
//    //thread.threadPriority = 1.0;  // 线程优先级（0～1，默认0.5）
//    //BOOL bThreadStatus = thread.isCancelled || thread.isExecuting || thread.isFinished;  // 线程状态
//    //BOOL bMainThread = thread.isMainThread;  // 是否是主线程
//    //[thread cancel];  // 设置为取消状态
//    //[NSThread exit];  // 终止当前线程
}

- (void)threadDownloadImage
{
    NSURL *imgurl = [NSURL URLWithString:@"http://119.147.82.70:8099/Images/Banner/banner_bz.jpg"];
    NSData *imgdata = [NSData dataWithContentsOfURL:imgurl];
    UIImage *img = [UIImage imageWithData:imgdata];
    // 线程间通讯
    [self performSelectorOnMainThread:@selector(mainThreadUpdateUI:) withObject:img waitUntilDone:YES];  // 更新主线程
    //[self performSelector:@selector() onThread:(NSThread *) withObject:(id) waitUntilDone:(BOOL)]  // 更新其他线程
}

- (void)mainThreadUpdateUI:(UIImage *)img
{
    if (img)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 150, 200, 150)];
        imgView.image = img;
        [self.view addSubview:imgView];
    }
}


#pragma mark -  售票（NSThread 线程同步、锁）

// NSThread 线程同步
- (void)sellTickets
{
    _tickets = 31;  // 当前余票
    _lock = [[NSLock alloc] init];  // 锁
    _condition = [[NSCondition alloc] init];  // 锁
    _thread0 = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];  // 售票线程
    _thread0.name = @"lc thread 0";
    [_thread0 start];
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [thread1 setName:@"lc_thread1"];
    [thread1 start];
    
//    // 线程的顺序执行 （[_condition signal] [_condition wait]）
//    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(run2) object:nil];  // 这个线程用来唤醒其他两个线程锁中的wait
//    [thread2 setName:@"thread2"];
//    [thread2 start];
}

- (void)run
{
    while (true)
    {
//        [_condition lock];
//        [_condition wait];  // 等待唤醒
        
        [_lock lock];  // 上锁
        if (_tickets > 0)
        {
            _tickets--;  // 卖出去票
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"当前票数是:%d,线程名:%@", _tickets, [NSThread currentThread].name);
        }
        else
        {
            break;
        }
        [_lock unlock];  // 如果没有线程同步的lock，卖票数可能是-1。加上锁之后线程同步保证了数据的正确性。
        
//        [_condition unlock];
    }
}

//- (void)run2
//{
//    while (YES)
//    {
//        [_condition lock];
//        [NSThread sleepForTimeInterval:1];
//        [_condition signal];  // 发送信号的方式唤醒另一个等待的进程
//        [_condition unlock];
//    }
//}


// 网络请求 -> NSURLSession 同步请求
//dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//dispatch_semaphore_signal(semaphore);
//dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//[condition lock];
//[condition signal];
//[_condition wait];
//[condition unlock];


//还有其他的一些锁对象，比如：循环锁NSRecursiveLock，条件锁NSConditionLock，分布式锁NSDistributedLock等等

//// @synchronized 来简化 NSLock的使用  （单例模式）
//static SettingManager *instance = nil;
//+ (SettingManager *)shareInstance
//{
//    @synchronized(self) // 独占锁
//    {
//        if (instance == nil)
//        {
//            instance = [[self alloc] init];
//        }
//    }
//    return instance;
//}
//[SettingManager shareInstance].kk ...
//
//+ (HttpClient *)sharedInstance
//{
//    // 单例
//    static id sharedInstance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken,^{
//        sharedInstance = [[self alloc] init];
//    });
//    return sharedInstance;
//}


#pragma mark -  GCD（Grand Central Dispatch）
/*
 dispatch queue分为三种：
 Serial（串行队列） 又称为private dispatch queues ：同时只执行一个任务。Serial queue通常用于同步访问特定的资源或数据。当创建多个Serial queue时，虽然它们各自是同步执行的，但Serial queue与Serial queue之间是并发执行的。
 Main dispatch queue ：它是全局可用的serial queue，它是在应用程序主线程上执行任务的。
 Concurrent（并行队列）  又称为global dispatch queue ：可以并发地执行多个任务，但是执行完成的顺序是随机的。
 */

//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    //耗时的操作
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //更新界面
//    });
//});

// dispatch_group_async 监听一组任务是否完成，完成后得到通知执行其他操作。例如：三个下载任务，都完成了才通知界面
- (void)gcdTest_group
{
    NSLog(@"begin");
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);  // 全局的异步并行队列
    //dispatch_queue_t queue = dispatch_queue_create("lc.gcdTest_queue", DISPATCH_QUEUE_CONCURRENT);  // 异步并行队列
    //dispatch_queue_t queue = dispatch_queue_create("lc.gcdTest_queue", DISPATCH_QUEUE_SERIAL);  // 同步串行队列
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"dispatch_group0");
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"dispatch_group1");
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:3];
        NSLog(@"dispatch_group2");
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"dispatch_main_queue UpdateUI");
    });
    //dispatch_release(group);  // 非arc需释放
    NSLog(@"end");
    //begin->end->每一秒打印一个，三个任务都完成后打印ui
}

// dispatch_barrier_async
// dispatch_barrier_sync
// barrier 障碍物
- (void)gcdTest_barrier
{
    NSLog(@"begin");
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"dispatch_async0");
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"dispatch_async1");
    });
    dispatch_barrier_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"dispatch_barrier_async");
    });
//    dispatch_barrier_sync(queue, ^{
//        [NSThread sleepForTimeInterval:2];
//        NSLog(@"dispatch_barrier_sync");
//    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"dispatch_async2");
    });
    NSLog(@"end");
    //async: begin->end->?
    //sync: begin->?->end->?
}

- (void)gcdTest_others
{
    // dispatch_apply 执行某个代码片段N次 这个方法不是异步执行
    NSLog(@"begin");
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(3, queue, ^(size_t index) {
        NSLog(@"dispatch_apply %zu", index);
    });
    NSLog(@"end");
    //begin->0->1->2->end
    
    
    //dispatch_once(dispatch_once_t *predicate, ^{})  // 单次执行一个任务，此方法中的任务只会执行一次，重复调用也没办法重复执行（单例模式中常用此方法）。
    
    //dispatch_time(dispatch_time_t when, int64_t delta)
    //dispatch_after(dispatch_time_t when, dispatch_queue_t queue, ^{});  // 一定时间后加入队列
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSLog(@"3秒后加入主线程");
        // 注意：
        // 1.不是一定时间后执行相应的任务，而是一定时间后，将执行的操作加入到队列中（队列里面再分配执行的时间）
        //   [self performSelector:@selector(gotoDetailVC:) withObject:userInfo afterDelay:1.0];
        // 2.主线程 RunLoop 1/60秒检测时间，追加的时间范围 3s~(3+1/60)s
    });
    
    //dispatch_block_create(dispatch_block_flags_t flags, ^{})
    //dispatch_block_perform(dispatch_block_flags_t flags, ^{})
    //dispatch_block_cancel(^{})
    //dispatch_block_notify(^{}, dispatch_queue_t queue, ^{})
    //dispatch_block_wait(^{}, dispatch_time_t timeout)
}




#pragma mark -  RunLoop

/*
 基本作用
  保持程序的持续运行（ios程序为什么能一直活着不会死）
  处理app中的各种事件（比如触摸事件、定时器事件【NSTimer】、selector事件【obj performSelector···】）
  节省CPU资源，提高程序性能，有事情就做事情，没事情就休息
 
 Runloop与线程
  Runloop和线程的关系：一个Runloop对应着一个唯一的线程
  Runloop的创建：主线程Runloop已经创建好了，子线程的runloop需要手动创建
  Runloop的生命周期：在第一次获取时创建，在线程结束时销毁
 
 1.CFRunloopModeRef代表着Runloop的运行模式
 2.一个Runloop中可以有多个mode,一个mode里面又可以有多个source\observer\timer等等
 3.每次runloop启动的时候，只能指定一个mode,这个mode被称为该Runloop的当前mode
 4.如果需要切换mode,只能先退出当前Runloop,再重新指定一个mode进入
 5.这样做主要是为了分割不同组的定时器等，让他们相互之间不受影响
 6.系统默认注册了5个mode
   a.kCFRunLoopDefaultMode：App的默认Mode，通常主线程是在这个Mode下运行
   b.UITrackingRunLoopMode：界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响
   c.UIInitializationRunLoopMode: 在刚启动 App 时第进入的第一个 Mode，启动完成后就不再使用
   d.GSEventReceiveRunLoopMode: 接受系统事件的内部 Mode，通常用不到
   e.kCFRunLoopCommonModes: 这是一个占位用的Mode，不是一种真正的Mode
*/

- (void)runloopTest {
    NSRunLoop *mainRunLoop = [NSRunLoop mainRunLoop];  // 获取主线程对应的runloop
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];  // 获取当前线程对应的runloop
    
    NSLog(@"mainRunLoop - %p", mainRunLoop);
    NSLog(@"currentRunLoop - %p", currentRunLoop);
    NSLog(@"currentRunLoop - %p", [NSRunLoop currentRunLoop]);  // currentRunLoop是延迟加载，同一个线程中多次创建会返回同一个对象
}


#pragma mark -  RunLoop_Timer

- (void)runloopTest_timer {
    NSString *strImg0 = [[NSBundle mainBundle] pathForResource:@"folder_references/排序算法_快速排序.gif" ofType:@""];
    NSString *strImg1 = [[NSBundle mainBundle] pathForResource:@"folder_references/排序算法_快速排序.jpg" ofType:@""];
    NSString *strImg2 = [[NSBundle mainBundle] pathForResource:@"folder_references/排序算法.jpg" ofType:@""];
    NSString *strImg3 = [[NSBundle mainBundle] pathForResource:@"folder_references/icon_blue.png" ofType:@""];
    NSString *strImg4 = [[NSBundle mainBundle] pathForResource:@"folder_references/icon_red.png" ofType:@""];
    _arrImg = @[[UIImage imageNamed:strImg0],
                [UIImage imageNamed:strImg1],
                [UIImage imageNamed:strImg2],
                [UIImage imageNamed:strImg3],
                [UIImage imageNamed:strImg4]
                ];
    _kTag = 2000;
    CGFloat imgW = 60;
    CGFloat margin = 10;
    _bgview = [[UIView alloc] initWithFrame:CGRectMake(50, 100, (imgW+margin)*4, (imgW+margin*2))];
    _bgview.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_bgview];
    for (int i=0; i<_arrImg.count; i++) {
        UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake((imgW+margin)*i-imgW/2, margin, imgW, imgW)];
        imgview.image = _arrImg[i];
        imgview.tag = _kTag+i;
        [_bgview addSubview:imgview];
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(_bgview.frame)+margin*2, kSCREEN_WIDTH-margin*2, 200)];
    scrollView.backgroundColor = [UIColor grayColor];
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height*1.5);
    UIView *v0 = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
    v0.backgroundColor = [UIColor orangeColor];
    [scrollView addSubview:v0];
    UIView *v1 = [[UIView alloc] initWithFrame:CGRectMake(10, scrollView.frame.size.height-15, 30, 30)];
    v1.backgroundColor = [UIColor purpleColor];
    [scrollView addSubview:v1];
    [self.view addSubview:scrollView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_btn_back"] style:UIBarButtonItemStylePlain target:self action:@selector(navItemAction_Left:)];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(imgKeepScrolling) userInfo:nil repeats:YES];  // 创建并添加到currentRunLoop_DefaultModes （scrollView滚动时timer会停止）
    
    //_timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(imgKeepScrolling) userInfo:nil repeats:YES];  // 仅创建
    //[[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];  // 添加到currentRunLoop_CommonModes  （scrollView滚动时timer正常）
    ////NSRunLoopCommonModes = NSDefaultRunLoopMode + UITrackingRunLoopMode
    
    //[_timer fire];  // fire马上触发；如果不fire则会等到下一个循环即2秒后触发
}

- (void)imgKeepScrolling {
    NSLog(@"*_* imgKeepScrolling");
    CGRect tempFrame = CGRectZero;
    for (int i=0; i<_arrImg.count; i++) {
        UIImageView *imgview = [_bgview viewWithTag:(_kTag+i)];
        tempFrame = imgview.frame;
        tempFrame.origin.x -= (imgview.frame.size.width+10);
        imgview.frame = tempFrame;
        imgview.tag--;
    }
    UIImageView *imgview0 = [_bgview viewWithTag:(_kTag-1)];
    tempFrame.origin.x += (imgview0.frame.size.width+10);
    imgview0.frame = tempFrame;
    imgview0.tag = _kTag+_arrImg.count-1;
}

- (void)navItemAction_Left:(UIBarButtonItem *)navItem {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    NSLog(@"*_* dealloc");
}

@end



