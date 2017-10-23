//
//  UdpSocketViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/8/7.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "UdpSocketViewController.h"
#import "AsyncUdpSocket.h"

#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>

@interface UdpSocketViewController ()<AsyncUdpSocketDelegate>
{
    AsyncUdpSocket *_udpSocket;
    
    UILabel *_lb;
}
@end

@implementation UdpSocketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"upd 异步socket";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 30);
    [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"udp发送" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor blueColor].CGColor;
    btn.layer.cornerRadius = 5.0;
    [self.view addSubview:btn];
    
    _lb = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 280, 20)];
    _lb.text = @"状态";
    _lb.textColor = [UIColor blueColor];
    _lb.backgroundColor = [UIColor clearColor];
    _lb.textAlignment = NSTextAlignmentLeft;
    _lb.font = [UIFont systemFontOfSize:14];
    _lb.numberOfLines = 0;
    [_lb sizeToFit];
    [self.view addSubview:_lb];
    [_lb addObserver:self forKeyPath:@"text" options:0 context:nil];  // kvo
    
    
    _udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    NSError *err = nil;
    //if (![_udpSocket bindToPort:8888 error:&err])
    if (![_udpSocket bindToAddress:@"127.0.0.1" port:8888 error:&err])
    {
        NSLog(@"绑定出错 %@",err);
        _lb.text = [NSString stringWithFormat:@"绑定出错 %@", err];
        [_lb sizeToFit];
    }
    
//    NSLog(@"本机ip %@", _udpSocket.localHost);
//    NSLog(@"本机ip %@", [self ipAddress]);
    
//    // 组播
//    [_udpSocket bindToPort:8888 error:&err];
//    [_udpSocket enableBroadcast:YES error:&err];
//    [_udpSocket joinMulticastGroup:@"224.0.0.2" error:&err];
    
    [_udpSocket receiveWithTimeout:-1 tag:0];  // timeout *_* <0 监听； >0 触发事件
}


// 接收数据 事件
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    [_udpSocket receiveWithTimeout:-1 tag:0];
    
    NSString *receiveStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"接收到服务器（%@:%d）数据 *_* %@", host, port, receiveStr);
    _lb.text = [NSString stringWithFormat:@"接收到服务器（%@:%d）数据 *_* %@", host, port, receiveStr];
    return YES;
}


// 发送数据 事件
- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"发送数据");
    _lb.text = [NSString stringWithFormat:@"发送数据"];
}


// 接收数据出错
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"接收数据出错 %@", error);
    _lb.text = [NSString stringWithFormat:@"接收数据出错 %@", error];
}


// 发送数据出错
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"发送数据出错 %@", error);
    _lb.text = [NSString stringWithFormat:@"发送数据出错 %@", error];
}


// 连接关闭
- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
    NSLog(@"连接关闭");
    _lb.text = [NSString stringWithFormat:@"连接关闭"];
}


// 发送数据 方法
- (void)sendData
{
    NSString *sendStr = @"hello 哈哈 this is a udp socket msg from client by lc using iOS";
    NSData *sendData = [sendStr dataUsingEncoding:NSUTF8StringEncoding];
    [_udpSocket sendData:sendData toHost:@"10.18.192.65" port:8099 withTimeout:1 tag:0];
    
    //[_udpSocket sendData:sendData toHost:@"224.0.0.2" port:8888 withTimeout:1 tag:0];  // 组播
}


- (void)buttonAction:(UIButton *)sender
{
    [self sendData];
}


// kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _lb && [keyPath isEqualToString:@"text"])
    {
        _lb.frame = CGRectMake(20, 150, 280, 20);
        [_lb sizeToFit];
    }
}




//// 获取本机ip
//- (NSString *)ipAddress
//{
//    NSString *ip = nil;
//    struct ifaddrs *addrs;
//    if (getifaddrs(&addrs)==0) {
//        const struct ifaddrs *cursor = addrs;
//        while (cursor != NULL) {
//            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
//            {
//                //NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
//                //if ([name isEqualToString:@"en0"]) // Wi-Fi adapter
//                {
//                    ip = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
//                    break;
//                }
//            }
//            cursor = cursor->ifa_next;
//        }
//        freeifaddrs(addrs);
//    }
//    return ip;
//}


@end
