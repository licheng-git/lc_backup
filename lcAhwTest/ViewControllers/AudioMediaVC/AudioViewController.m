//
//  AudioViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/8/19.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "AudioViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "VoiceConverter.h"

@interface AudioViewController()<AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
    AVAudioRecorder  *_audioRecorder;  // 录音机
    NSString         *_localPath;      // 文件路径
    NSTimer          *_timer;          // 定时器 录音时实时刷新显示音量
    UIProgressView   *_progressView;   // 进度条 显示音量
    
    AVAudioPlayer    *_audioPlayer;    // 播放器 *_*要使用全局变量，否则播放时需sleep阻塞才有声音
}
@end

@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"音频";
    
    UIButton *btn0 = [KUtils createButtonWithFrame:CGRectMake(10, 100, 100, 30) title:@"长按录音" titleColor:[UIColor blueColor] target:nil tag:0];
    [btn0 addTarget:self action:@selector(btn0Down:) forControlEvents:UIControlEventTouchDown];
    [btn0 addTarget:self action:@selector(btn0Up:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn0];

    UIButton *btn1 = [KUtils createButtonWithFrame:CGRectMake(120, 100, 100, 30) title:@"播放录音" titleColor:[UIColor blueColor] target:self tag:1];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [KUtils createButtonWithFrame:CGRectMake(120, 150, 120, 30) title:@"播放本地资源" titleColor:[UIColor blueColor] target:self tag:2];
    [self.view addSubview:btn2];
    
    // 进度条 音量
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 80, 200, 30)];
    _progressView.progressViewStyle = UIProgressViewStyleDefault;
    _progressView.backgroundColor = [UIColor orangeColor];
    _progressView.progressTintColor = [UIColor greenColor];
    _progressView.trackTintColor = [UIColor yellowColor];
    _progressView.progress = 0.2;
    [_progressView setProgress:0.5 animated:YES];
    [self.view addSubview:_progressView];
    
    // 定时器  实时刷新进度条（音量）
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(recordingRefresh) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];  // 先不要开启
    
    [self createAudioRecorder];
}


- (void)createAudioRecorder
{
    NSError *err = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&err];  // 可以在后台播放（需Custom iOS Target Properties选项卡中添加Required background modes）
    [audioSession setActive:YES error:&err];
    
    // 麦克风权限检测
//    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
//        [audioSession requestRecordPermission:^(BOOL granted) {
//            if (!granted) {
//                NSLog(@"麦克风权限没开");
//                //return;
//            }
//        }];
//    }
    AVAuthorizationStatus avAuthStatus_Audio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (avAuthStatus_Audio == AVAuthorizationStatusRestricted || avAuthStatus_Audio == AVAuthorizationStatusDenied) {
        NSLog(@"麦克风权限没开");
        return;
    }
    
    _localPath = [NSTemporaryDirectory() stringByAppendingString:@"xx.caf"];  // 文件缓存位置  格式？.caf
    NSURL *url = [NSURL fileURLWithPath:_localPath];  // 录音文件保存位置
    
    // 录音设置
    NSMutableDictionary *recorderSettings = [[NSMutableDictionary alloc] init];
    [recorderSettings setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];  // 格式?
    [recorderSettings setObject:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityKey];  // 质量
    [recorderSettings setObject:@(1) forKey:AVNumberOfChannelsKey];  // 通道（1、2），这里1是单声道
    [recorderSettings setObject:@(8000) forKey:AVSampleRateKey];  // 采样率（8000、44100、96000），这里8000是电话采样率
    [recorderSettings setObject:[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];  // 每个采样点位数（8、16、24、32）
    [recorderSettings setObject:@(YES) forKey:AVLinearPCMIsFloatKey];  // 是否浮动采样
    
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:recorderSettings error:&err];
    if (err)
    {
        NSLog(@"创建录音机对象时错误 *_* %@", err);
        return;
    }
    _audioRecorder.delegate = self;
    _audioRecorder.meteringEnabled = YES;  // 开启音量检测
}


- (void)buttonAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 1)
    {
        [self playVoice];
    }
    else if (btn.tag == 2)
    {
        [self playVoice2];
    }
}

- (void)btn0Down:(UIButton *)btn0
{
    NSLog(@"按下按钮");
    if([_audioRecorder record])
    {
        NSLog(@"录音开始 *_* %f", _audioRecorder.currentTime);
        //[_timer fire];
        [_timer setFireDate:[NSDate distantPast]];
    }
    else
    {
        NSLog(@"录音开始失败");
    }
}

- (void)btn0Up:(UIButton *)btn0
{
    NSLog(@"松开按钮");
    if (_audioRecorder.recording)
    {
        [_audioRecorder stop];
        NSLog(@"录音停止 *_* %f", _audioRecorder.currentTime);
        //[_timer invalidate];  // 永久停止
        [_timer setFireDate:[NSDate distantFuture]];  // 还能再起来
    }
}


- (void)recordingRefresh
{
    [_audioRecorder updateMeters];  // 刷新音量数据
    float avergePower = [_audioRecorder averagePowerForChannel:0];  // 平均音量
    float peakPower = [_audioRecorder peakPowerForChannel:0];  // 最大音量
    double kk = pow(10, (peakPower * 0.5));  // 幂 10^-x
    [_progressView setProgress:kk animated:YES];
    NSLog(@"录音中 *_* %f 平均音量=%f 最大音量=%f", _audioRecorder.currentTime, avergePower, peakPower);
}


- (void)playVoice
{
    NSURL *url = [NSURL fileURLWithPath:_localPath];  // 音频文件位置
    NSError *err = nil;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    if (err)
    {
        NSLog(@"创建播放器对象时错误 *_* %@", err);
        return;
    }
    _audioPlayer.numberOfLoops = -1;  // 只播放一次
    _audioPlayer.volume = 15.0;  // 音量
    _audioPlayer.delegate = self;
    [_audioPlayer prepareToPlay];
    if ([_audioPlayer play])
    {
        NSLog(@"播放 音频时长%f", _audioPlayer.duration);
    }
    else
    {
        NSLog(@"播放失败");
    }
    
}


- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"录音结束 successfully *_* %hhd *_* %f", flag, recorder.currentTime);
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"录音出错 *_* %@", error);
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"播放结束 successfully *_* %hhd", flag);
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"播放出错 *_* %@", error);
}


// 播放本地音频
- (void)playVoice2
{
//    // <AVFoundation/AVFoundation.h>
//    _localPath = [[NSBundle mainBundle] pathForResource:@"folder_references/audio.mp3" ofType:@""];
//    [self playVoice];
    // 安卓的amr格式录音需转化成wav才能播放
    _localPath = [[NSBundle mainBundle] pathForResource:@"folder_references/audio_android_err.amr" ofType:@""];
    NSData *amrData = [NSData dataWithContentsOfFile:_localPath];
    NSData *wavData = [VoiceConverter amrToWavWithAmrData:amrData];
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:wavData error:nil];
    _audioPlayer.numberOfLoops = -1;
    _audioPlayer.volume = 15.0;
    _audioPlayer.delegate = self;
    [_audioPlayer play];
    
    
//    // <AudioToolbox/AudioToolbox.h>
//    // <30s；很小的提示音；系统音
//    
//    //AudioServicesPlaySystemSound(1007);  // 系统默认声音
//    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); // 震动
//    
//    CFURLRef fileUrlRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("audio_iOS"), CFSTR("m4a"), nil);
//    SystemSoundID sysSoundId;
//    AudioServicesCreateSystemSoundID(fileUrlRef, &sysSoundId);
//    AudioServicesPlaySystemSound(sysSoundId);
    
}


@end
