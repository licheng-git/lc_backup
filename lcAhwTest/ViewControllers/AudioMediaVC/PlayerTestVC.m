//
//  PlayerTestVC.m
//  lcAhwTest
//
//  Created by licheng on 16/5/6.
//  Copyright © 2016年 lc. All rights reserved.
//

#import "PlayerTestVC.h"
#import <AVFoundation/AVFoundation.h>
#import "KUtils.h"
#import "WebViewController.h"
#import "SVProgressHUD.h"

@interface PlayerTestVC()<UIWebViewDelegate>
{
    AVPlayer        *_player;
    AVPlayerLayer   *_playerLayer;
    BOOL            _bPlaying;
}
@end

@implementation PlayerTestVC

+ (instancetype)defaultPlayer
{
    static PlayerTestVC *pm = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pm = [[PlayerTestVC alloc] init];
    });
    return pm;
}


#pragma mark - AVPlayer

- (void)play:(UIViewController *)targetVC
{
    UIButton *btn = [KUtils createButtonWithFrame:CGRectMake(150, 100, 120, 30) title:@"播放/暂停" titleColor:[UIColor blueColor] target:self tag:0];
    [self.view addSubview:btn];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"folder_references/test.mov" ofType:@""];
    NSURL *url = [NSURL fileURLWithPath:path];
    
//    NSString *path = @"http:/ /persistence.oss-us-west-1.aliyuncs.com/3d00ba2403f68ef51462507300825.mov?OSSAccessKeyId=lgHEco01mAhOIZwW&Expires=1463623165&Signature=P2gD0N5RleHoeIunMiWHw5CWkzw%3D";  // 卡
//    //NSString *path = @"http://v.youku.com/player/getM3U8/vid/XNzc5NzMwMDQ4/type/mp4/v.m3u8";
//    //NSString *path = @"http://121.199.63.236:7613/m3u8/cckw1/szws.m3u8?from=bab&fun=yes&chk=y&chunk=xax&ppw=yuntutv&auth=yuntutvyuntutvyuntutv&auth=yuntutvyuntutvyuntutv&nwtime=1406515232&sign=033d5483609e6bc87987fc7d2f30a024";
//    NSURL *url = [NSURL URLWithString:path];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];  // 播放完
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];  // 按home键（进入后台）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];  // 按home键（即将进入后台）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerInterruption:) name:AVAudioSessionInterruptionNotification object:nil];  // 被打断（如电话、闹钟等）
    
    _player = [AVPlayer playerWithURL:url];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.backgroundColor = [UIColor blueColor].CGColor;
    _playerLayer.frame = CGRectMake(10, 200, kSCREEN_WIDTH - 20, 300);
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_playerLayer];
    
    _bPlaying = NO;
    //[targetVC.navigationController.view addSubview:self.view];
    [targetVC.navigationController pushViewController:self animated:YES];
}

- (void)avPlayerFinished:(NSNotification *)notification
{
    [_player seekToTime:kCMTimeZero];
    _bPlaying = NO;
    //[[AVAudioSession sharedInstance] setActive:NO error:nil];  // *_* err
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

//- (void)avPlayerDidEnterBackground:(NSNotification *)notification
//{
//    [_player pause];
//    _bPlaying = NO;
//    //[[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];  // *_* 后台播放音频    Info.plist -> Required background modes -> + -> 选择 App plays audio or streams audio/video using AirPlay        *_* 审核被拒绝（申明了Info.plist->UIBackgroundModes.audio又没有后台播放音频的功能）
//}
- (void)avPlayerWillResignActive:(NSNotification *)notification
{
    [_player pause];
    _bPlaying = NO;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (void)avPlayerInterruption:(NSNotification *)notification
{
}

- (void)buttonAction:(UIButton *)btn
{
    if (_bPlaying) {
        [_player pause];
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }
    else {
        [_player play];
        [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }
    _bPlaying = !_bPlaying;
}




#pragma mark - webView

- (void)playInWebView:(UIViewController *)targetVC
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 100, kSCREEN_WIDTH-20, 400)];
    webView.mediaPlaybackRequiresUserAction = YES;  // 不自动播放，用户点击再播放
    //webView.scalesPageToFit = NO;
    self.view.backgroundColor = [UIColor orangeColor];
    webView.backgroundColor = [UIColor greenColor];
    
    
    //NSString *urlStr = @"http://v.youku.com/v_show/id_XNzc5NzMwMDQ4.html";
    //NSString *urlStr = @"http://v.youku.com/player/getM3U8/vid/XNzc5NzMwMDQ4/type/mp4/v.m3u8";  // err
    //NSString *urlStr = @"http://121.199.63.236:7613/m3u8/cckw1/szws.m3u8?from=bab&fun=yes&chk=y&chunk=xax&ppw=yuntutv&auth=yuntutvyuntutvyuntutv&auth=yuntutvyuntutvyuntutv&nwtime=1406515232&sign=033d5483609e6bc87987fc7d2f30a024";  // err
    NSString *urlStr = @"http://player.youku.com/embed/XNzc5NzMwMDQ4";  // iframe.src
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [webView loadRequest:urlRequest];
    
    
    
//    // cloud.youku.com/tools
//    NSString *clientId = @"b1b8d127374e42ee";
//    NSString *vid = @"XMTU0NzA3OTU1Mg";
//    NSString *htmlStr = [NSString stringWithFormat:@"<div id=\"youkuplayer\"></div> <script type=\"text/javascript\" src=\"http://player.youku.com/jsapi\"> player = new YKU.Player('youkuplayer',{ styleid: '0', client_id: '%@', vid: '%@',autoplay: true}); </script>", clientId, vid];
    
    
//    //NSString *urlStr = @"http://v.youku.com/v_show/id_XNzc5NzMwMDQ4.html";
//    NSString *htmlStr = @"<iframe src='http://player.youku.com/embed/XNzc5NzMwMDQ4' width=100% height=95% frameborder=0 allowfullscreen></iframe>";  // 优酷
//    
//    //NSString *urlStr = @"http://www.iqiyi.com/v_19rrlepcnc.html";
//    //NSString *htmlStr = @"<iframe src='http://open.iqiyi.com/developer/player_js/coopPlayerIndex.html?vid=a9402bafe31e2de90e89748ede4a06d5&tvId=492689700&accessToken=2.f22860a2479ad60d8da7697274de9346&appKey=3955c3425820435e86d0f4cdfe56f5e7&appId=1368' width='100%' height='95%' frameborder='0' allowfullscreen='true'></iframe>";  // 爱奇艺 慢得需loading，高度有问题
//    
//    //NSString *urlStr = @"http://v.qq.com/cover/u/uypsgtbnuh02jpq.html?vid=u0020nzzt7s";
//    //NSString *htmlStr = @"<iframe src='http://v.qq.com/iframe/player.html?vid=u0020nzzt7s' frameborder='0' width='100%' height='95%' frameborder='0' allowfullscreen='true'></iframe>";  // qq
//    
//    //NSString *urlStr = @"https://www.youtube.com/watch?v=gOFjItu92lw";
//    //NSString *htmlStr = @"<iframe src='https://www.youtube.com/embed/gOFjItu92lw?rel=0' width='560' height='315' frameborder='0' allowfullscreen></iframe>";  // youtub 待测试
//    
//    [webView loadHTMLString:htmlStr baseURL:nil];
    
    
    [self.view addSubview:webView];
    [targetVC.navigationController pushViewController:self animated:YES];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate_Device:) name:UIDeviceOrientationDidChangeNotification object:nil];  // 设备转屏
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate_AppStatusBar:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];  // 布局转屏
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD show];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nonnull NSError *)error
{
    [SVProgressHUD dismissWithError:error.description];
}

- (void)didRotate_Device:(NSNotification *)notification
{
    int k0 = [UIDevice currentDevice].orientation;
    int k1 = [UIApplication sharedApplication].statusBarOrientation;
    NSLog(@"UIDeviceOrientationDidChangeNotification *_* %i,%i", k0, k1);
    //self.view.transform = ...;
}

@end

