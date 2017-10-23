//
//  TcpSocketViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/8/5.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "TcpSocketViewController.h"
#import "AsyncSocket.h"

@interface TcpSocketViewController ()<AsyncSocketDelegate>
{
    AsyncSocket *_tcpSocket;
    
    UILabel *_lb;
}
@end

@implementation TcpSocketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"tcp 异步socket";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 30);
    [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"tcp发送" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor blueColor].CGColor;
    btn.layer.cornerRadius = 5.0;
    [self.view addSubview:btn];
    
    _lb = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 300, 20)];
    _lb.text = @"状态";
    _lb.textColor = [UIColor blueColor];
    _lb.backgroundColor = [UIColor clearColor];
    _lb.textAlignment = NSTextAlignmentLeft;
    _lb.font = [UIFont systemFontOfSize:14];
    _lb.numberOfLines = 0;
    [self.view addSubview:_lb];

    
    _tcpSocket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *err = nil;
    if (![_tcpSocket connectToHost:@"10.18.192.65" onPort:8099 withTimeout:1 error:&err])
    {
        NSLog(@"连接出错 %@",err);
        _lb.text = [NSString stringWithFormat:@"连接出错 %@",err];
        [_lb sizeToFit];
    }
}


// 连接建立
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"连接已建立 *_* %@ *_* %@:%d", sock, host, port);
    _lb.text = [NSString stringWithFormat:@"连接已建立 *_* %@ *_* %@:%d", sock, host, port];
    [_lb sizeToFit];
}


// 遇到错误时关闭连接
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"遇到错误，关闭连接 *_* %@", err);
    _lb.text = [NSString stringWithFormat:@"遇到错误，关闭连接 *_* %@", err];
    [_lb sizeToFit];
}


// 连接断开
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"连接断开");
//    _lb.text = [NSString stringWithFormat:@"连接断开"];
//    [_lb sizeToFit];
}


// 读取数据 事件
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *receiveStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"接收到服务器数据 *_* %@", receiveStr);
    _lb.text = [NSString stringWithFormat:@"接收到服务器数据 *_* %@", receiveStr];
    [_lb sizeToFit];
}


// 发送数据 事件
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"发送数据");
    _lb.text = [NSString stringWithFormat:@"发送数据"];
    [_lb sizeToFit];
}


// 发送数据 方法
- (void)sendData
{
    if (![_tcpSocket isConnected])
    {
        NSLog(@"连接断开了，数据发不出去");
        _lb.text = [NSString stringWithFormat:@"连接断开了，数据发不出去"];
        [_lb sizeToFit];
        return;
    }
    
    NSString *sendStr = @"hello 哈哈 this is a tcp socket msg from client by lc using iOS ; and a mp3 file";
    NSData *sendData = [sendStr dataUsingEncoding:NSUTF8StringEncoding];
    
    int len = sendData.length;  // 自定义协议 数据长度 sizeof(int) = 4个字节
    NSData *lenData = [NSData dataWithBytes:&len length:sizeof(len)];
    NSLog(@"字符串长度%i err *_* 字节流长度%i ok", sendStr.length, sendData.length);
    
    NSString *type = @"text_";  // 自定义协议 数据类型 text_|image|audio|media|other  5个字节，自定义
    NSData *typeData = [type dataUsingEncoding:NSASCIIStringEncoding];
    
    NSMutableData *sendData_final = [[NSMutableData alloc] initWithData:lenData];
    [sendData_final appendData:typeData];
    [sendData_final appendData:sendData];
    
    [_tcpSocket writeData:sendData_final withTimeout:1 tag:0];  // 发送数据到服务器
    
    [_tcpSocket readDataWithTimeout:1 tag:0];  // 读取服务器返回数据
}


- (void)buttonAction:(UIButton *)sender
{
    [self sendData];
}

@end
