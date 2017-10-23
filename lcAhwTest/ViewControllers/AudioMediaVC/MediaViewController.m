//
//  MediaViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/8/19.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "MediaViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
//#import <Photos/Photos.h>
#import "PlayerTestVC.h"

@interface MediaViewController()
{
    NSString  *_localPath;    // 文件路径
    
    MPMoviePlayerController  *_moviePlayerC;    // 播放器（封装更方便）  <MediaPlayer/MediaPlayer.h>

    
    AVPlayer        *_player;          // 播放器（自定义性更强）  <AVFoundation/AVFoundation.h>
    AVPlayerLayer   *_playerLayer;
    UIProgressView  *_progressView;    // 播放进度条
}
@end

@implementation MediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"视频";
    
    
    UIButton *btn0 = [KUtils createButtonWithFrame:CGRectMake(10, 100, 100, 30) title:@"录制视频" titleColor:[UIColor blueColor] target:self tag:100];
    [self.view addSubview:btn0];
    UIButton *btn1 = [KUtils createButtonWithFrame:CGRectMake(110, 100, 100, 30) title:@"播放视频" titleColor:[UIColor blueColor] target:self tag:101];
    [self.view addSubview:btn1];
    UIButton *btn2 = [KUtils createButtonWithFrame:CGRectMake(210, 100, 100, 30) title:@"网络视频" titleColor:[UIColor blueColor] target:self tag:102];
    [self.view addSubview:btn2];
    
    _localPath = [[NSBundle mainBundle] pathForResource:@"folder_references/media_iOS.mov" ofType:@""];
    
    [self getVideoThumbnail_AVAssetImageGenerator];  // 获取视频缩略图
    //[self getVideoThumbnail_MPMoviePlayerController];  // 获取视频缩略图 *_* ?
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_moviePlayerC)
    {
        NSLog(@"playbackState %i", _moviePlayerC.playbackState);
        [_moviePlayerC stop];
        //[_moviePlayerC.view removeFromSuperview];
    }
}

- (void)buttonAction:(UIButton *)btn
{
    if (btn.tag == 100)
    {
        // 录视频
        // UIImagePickerController  封装更方便
        // AVCaptureDevice  自定义性更强（视频、音频、拍照、截图）
        
        [self takeVaieo_AVCaptureDevice];
    }
    else if (btn.tag == 101)
    {
        // 播放视频
        //MPMoviePlayerController  封装更方便
        //AVPlayer  自定义性更强
        
        //[self playVideo_MPMoverPlayerController];
        [self playVideo_AVPlayer];
    }
    else if (btn.tag == 102)
    {
        //[[PlayerTestVC defaultPlayer] play:self];
        [[PlayerTestVC defaultPlayer] playInWebView:self];
    }
}




- (void)takeVaieo_AVCaptureDevice
{
//    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    NSError *error = nil;
//    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
//    
//    if (deviceInput) {
//        [_session addInput:deviceInput];
//    }
//    else {
//        DDLogInfo(@"Some wierd shit happened");
//        return;
//    }
//    
//    // Session output
//    /*
//     AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
//     [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
//     [_session addOutput:output];
//     output.metadataObjectTypes = @[AVMetadataObjectTypeFace];
//     AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeMetadata];
//     connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
//     */
//    
//    // Session output
//    AVCaptureMovieFileOutput *videoOutput = [[AVCaptureMovieFileOutput alloc] init];
//    [_session addOutput:videoOutput];
//    AVCaptureConnection *connection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
//    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
//    
//    // Preview layer
//    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
//    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    _previewLayer.frame = CGRectMake(0, 0, self.middleView.frame.size.width, self.middleView.frame.size.height);
//    [self.middleView.layer addSublayer:_previewLayer];
//    
//    [_session startRunning];
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        NSLog(@"摄像头权限没开");
        return;
    }
//    NSArray *deviceArr = [AVCaptureDevice devices];
//    for (AVCaptureDevice *device in deviceArr)
//    {
//        NSLog(@"%@", device.localizedName);
//    }
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *err = nil;
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    AVCaptureInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&err];
    if (deviceInput)
    {
        [session addInput:deviceInput];
    }
    //AVCaptureOutput *deviceOutput = [[AVCaptureOutput alloc] init];
    
}




- (void)playVideo_MPMoverPlayerController
{
    NSURL *url = [NSURL fileURLWithPath:_localPath];  // 本地视频文件位置
    
//    NSString *webPath = @"http://image.test.cdn.sep.blemobi.com/90a3b3a2c060a0f91471490032149.mov?OSSAccessKeyId=9onpvIAMCEA8bWI7&Expires=1472354052&Signature=bv4h4r4x14B%2BFGifk3sj5ya7Rz0%3D";
//    //NSString *webPath = @"http://image.test.cdn.sep.blemobi.com/a27a0e098d037f7d1471338977883.3gp?OSSAccessKeyId=9onpvIAMCEA8bWI7&Expires=1472287762&Signature=H1W09fVpLDsx%2B10sCVnYOw6Nf9M%3D";
//    NSURL *url = [NSURL URLWithString:webPath];  // 网络视频文件位置（录播）
    
    _moviePlayerC = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [self.navigationController.view addSubview:_moviePlayerC.view];
//    _moviePlayerC.controlStyle = MPMovieControlStyleFullscreen;
//    _moviePlayerC.view.frame = self.view.bounds;
    _moviePlayerC.controlStyle = MPMovieControlStyleDefault;
    _moviePlayerC.view.frame = CGRectMake(10, kDEFAULT_ORIGIN_Y - 10, kSCREEN_WIDTH - 20, kSCREEN_HEIGHT - kDEFAULT_ORIGIN_Y);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerControllerCallback_PlayDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayerC];    //  注册一个播放结束的通知
    [_moviePlayerC play];
}

// 播放结束
- (void)moviePlayerControllerCallback_PlayDidFinish:(NSNotification *)notify
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayerC];    // 销毁通知
    //MPMoviePlayerController *moviePlayerC = [notify object];
    [_moviePlayerC.view removeFromSuperview];
}




- (void)playVideo_AVPlayer
{
    NSError *err = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];  // 否则真机没声音
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&err];  // 独占方式播放，其他app的声音先停掉
    [audioSession setActive:YES error:&err];
    
    NSURL *url = [NSURL fileURLWithPath:_localPath];  // 本地视频地址
//    NSString *webPath = @"http://image.test.cdn.sep.blemobi.com/90a3b3a2c060a0f91471490032149.mov?OSSAccessKeyId=9onpvIAMCEA8bWI7&Expires=1472354052&Signature=bv4h4r4x14B%2BFGifk3sj5ya7Rz0%3D";
//    //NSString *webPath = @"http://image.test.cdn.sep.blemobi.com/a27a0e098d037f7d1471338977883.3gp?OSSAccessKeyId=9onpvIAMCEA8bWI7&Expires=1472287762&Signature=H1W09fVpLDsx%2B10sCVnYOw6Nf9M%3D";
//    NSURL *url = [NSURL URLWithString:webPath];  // 网络视频文件位置（录播）
    
    _player = [AVPlayer playerWithURL:url];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.backgroundColor = [UIColor blueColor].CGColor;
    _playerLayer.frame = CGRectMake(10, 200, kSCREEN_WIDTH - 20, 300);
    //_playerLayer.masksToBounds = YES;
    //_playerLayer.cornerRadius = 20.0;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;  // 视频占满_playerLayer.frame
    [self.view.layer addSublayer:_playerLayer];  // 搞到视频截图了 第一帧
    [_player play];  // 播放视频
    
    // 播放进度条
     _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_playerLayer.frame) + 10, CGRectGetMaxY(_playerLayer.frame) - 10, _playerLayer.frame.size.width - 20, 30)];
    _progressView.progressViewStyle = UIProgressViewStyleBar;
    _progressView.backgroundColor = [UIColor orangeColor];
    _progressView.progressTintColor = [UIColor greenColor];
    _progressView.trackTintColor = [UIColor yellowColor];
    [self.view addSubview:_progressView];
    
    // 画面上加自定义视图
    UIView *kkView = [[UIView alloc] initWithFrame:CGRectMake(50, 30, 50, 30)];
    kkView.backgroundColor = [UIColor cyanColor];
    [_playerLayer addSublayer:kkView.layer];
    kkView.hidden = YES;
    
    __weak typeof(UIProgressView) *progressView__weakSelf = _progressView;
    __block typeof(UIView) *kkView__block = kkView;
    
    // 视频总时长
    AVPlayerItem *playerItem = _player.currentItem;
    float totalSeconds0 = CMTimeGetSeconds(playerItem.duration);
    NSLog(@"*_*err 总时长%.2f秒", totalSeconds0);
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
    float totalSeconds1 = CMTimeGetSeconds(urlAsset.duration);
    NSLog(@"总时长%.2f秒", totalSeconds1);
    
    // 更新播放进度
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 3) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // CMTimeMake(1, 3) 一秒三帧，每隔0.33秒更新一次播放进度
        float totalSeconds = CMTimeGetSeconds(playerItem.duration);
        float currentSeconds = CMTimeGetSeconds(time);
        NSLog(@"总时长%.2f秒，已播放%.2f秒", totalSeconds, currentSeconds);
        if (currentSeconds)
        {
            [progressView__weakSelf setProgress:(currentSeconds/totalSeconds) animated:YES];
            if (currentSeconds >= 3.0 && currentSeconds <= 8.0)
            {
                kkView__block.hidden = NO;
            }
            else
            {
                kkView__block.hidden = YES;
            }
        }
        //lb.text = [NSString stringWithFormat:@"%02d:%02d", currentSeconds/60, currentSeconds%60];
    }];
    
    // 注册播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemCallback_PlayDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)avPlayerItemCallback_PlayDidFinish:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //[_player seekToTime:kCMTimeZero];
    //[_player replaceCurrentItemWithPlayerItem:nil];
    //[[AVAudioSession sharedInstance] setActive:NO error:nil];  // 其他app的声音继续播放
}





// 播放前获取缩略图  <AVFoundation/AVFoundation.h>
- (void)getVideoThumbnail_AVAssetImageGenerator
{
    NSURL *url = [NSURL fileURLWithPath:_localPath];
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *assetImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    //CMTime t = CMTimeMakeWithSeconds(1, 10);  // CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要获得某一秒的第几帧可以使用CMTimeMake方法)
    NSError *err;
    CGImageRef cgImgRef_Media = [assetImageGenerator copyCGImageAtTime:kCMTimeZero actualTime:nil error:&err];
    if (!err)
    {
        UIImage *img = [UIImage imageWithCGImage:cgImgRef_Media];
        CGImageRelease(cgImgRef_Media);
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 200, kSCREEN_WIDTH-40, 300)];
        imgView.image = img;
        [self.view addSubview:imgView];
        UIImage *imgClipped = [KUtils image:img clipToSize:imgView.frame.size];
        imgView.image = imgClipped;
    }
    
//    CGFloat totalSeconds = CMTimeGetSeconds(urlAsset.duration);
//    NSLog(@"总时长%.2f秒", totalSeconds);
}


// 播放前获取缩略图 *_* ?
- (void)getVideoThumbnail_MPMoviePlayerController
{
    NSURL *url = [NSURL fileURLWithPath:_localPath];
    _moviePlayerC = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [_moviePlayerC requestThumbnailImagesAtTimes:@[@0, @(3), @(_moviePlayerC.duration)] timeOption:MPMovieTimeOptionNearestKeyFrame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerControllerCallback_ThumbnailImageRequestDidFinish:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:_moviePlayerC];
}

- (void)moviePlayerControllerCallback_ThumbnailImageRequestDidFinish:(NSNotification *)notify
{
    UIImage *img = [notify.userInfo objectForKey:MPMoviePlayerThumbnailImageKey];
    if (img)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 200, img.size.width, img.size.height)];
        imgView.image = img;
        [self.view addSubview:imgView];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:_moviePlayerC];
}


@end
