//
//  UdpViewController_C.m
//  lcAhwTest
//
//  Created by licheng on 16/1/25.
//  Copyright © 2016年 lc. All rights reserved.
//

#import "UdpViewController_C.h"
#include<sys/socket.h>
#include<netinet/in.h>
#import <arpa/inet.h>

@interface UdpViewController_C()
{
    UITextView   *_tvLog;
}
@end

@implementation UdpViewController_C

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"udp - c语言";  // udp，C语言，非异步，手机＋模拟器可测试（需改ip）
    
    UIButton *btnUdpServer = [KUtils createButtonWithFrame:CGRectMake(20, 80, 140, 30) title:@"udp作为服务端" titleColor:[UIColor blueColor] target:self tag:100];
    UIButton *btnUdpClient = [KUtils createButtonWithFrame:CGRectMake(160, 80, 140, 30) title:@"udp作为客户端" titleColor:[UIColor blueColor] target:self tag:101];
    [self.view addSubview:btnUdpServer];
    [self.view addSubview:btnUdpClient];
    
    _tvLog = [[UITextView alloc] initWithFrame:CGRectMake(10, 150, 300, 400)];
    _tvLog.editable = NO;
    [self.view addSubview:_tvLog];
    _tvLog.text = @"日志：\n";
}

- (void)buttonAction:(UIButton *)btn
{
    if (btn.tag == 100)
    {
        [self udpServer];
    }
    else if (btn.tag == 101)
    {
        [self udpClient];
    }
    btn.backgroundColor = [UIColor orangeColor];
}

- (void)tvLogShow:(NSString *)msg
{
    NSLog(@"%@", msg);
    _tvLog.text = [NSString stringWithFormat:@"%@\n%@", _tvLog.text, msg];
}


- (void)udpServer
{
    int err;
    bool success = false;
    int fd = socket(AF_INET, SOCK_DGRAM, 0);
    success = (fd > 0);
    if (!success)
    {
        return;
    }
    //NSLog(@"udp (as server) - socket");
    [self tvLogShow:[NSString stringWithFormat:@"udp (as server) - socket"]];
    
    struct sockaddr_in addr;
    bzero(&addr, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons(8000);
    err = bind(fd, (const struct sockaddr *)&addr, sizeof(addr));
    success = (err != -1);
    if (!success)
    {
        return;
    }
    //NSLog(@"udp (as server) - bind");
    [self tvLogShow:[NSString stringWithFormat:@"udp (as server) - bind"]];
    
    struct sockaddr_in client_addr;
    socklen_t client_addr_len = sizeof(struct sockaddr_in);
    
    char udp_receive_buf[BUFSIZ];
    size_t udp_receive_len = recvfrom(fd, udp_receive_buf, BUFSIZ, 0, (struct sockaddr *)&client_addr, &client_addr_len);  // waiting...
    udp_receive_buf[udp_receive_len] = '\0';
    NSString *str = [NSString stringWithCString:udp_receive_buf encoding:NSUTF8StringEncoding];
    //NSLog(@"udp (as server) - receiveFrom , remote address : %s , port : %d , msg : %@ *_*", inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port), str);
    [self tvLogShow:[NSString stringWithFormat:@"udp (as server) - receiveFrom , remote address : %s , port : %d , msg : %@ *_*", inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port), str]];
    
    char *udp_send_str = "hello this data is from udp as server by lc with C语言";
    size_t udp_send_str_len = strlen(udp_send_str);
    size_t udp_send = sendto(fd, udp_send_str, udp_send_str_len, 0, (const struct sockaddr *)&client_addr, client_addr_len);
    //NSLog(@"udp (as server) - send (length=%zu)", udp_send);
    [self tvLogShow:[NSString stringWithFormat:@"udp (as server) - send (length=%zu)", udp_send]];
    
    close(fd);
    //NSLog(@"udp (as server) - close");
    [self tvLogShow:[NSString stringWithFormat:@"udp (as server) - close"]];
}

- (void)udpClient
{
    int fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0)
    {
        return;
    }
    //NSLog(@"udp (as client) - socket");
    [self tvLogShow:[NSString stringWithFormat:@"udp (as client) - socket"]];
    
    struct sockaddr_in server_addr;
    bzero(&server_addr, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = inet_addr("10.18.204.66");  // 服务端ip
    server_addr.sin_port = htons(8000);
    socklen_t server_addr_len = sizeof(server_addr);
    
    char *udp_send_str = "lc 哈哈，udp作为客户端发送的数据 使用C语言";
    size_t udp_send_str_len = strlen(udp_send_str);
    size_t udp_send = sendto(fd, udp_send_str, udp_send_str_len, 0, (const struct sockaddr *)&server_addr, server_addr_len);
    //NSLog(@"udp (as client) - send (length=%zu)", udp_send);
    [self tvLogShow:[NSString stringWithFormat:@"udp (as client) - send (length=%zu)", udp_send]];
    
    char udp_receive_buf[BUFSIZ];
    size_t udp_receive_len = recvfrom(fd, udp_receive_buf, BUFSIZ, 0, (struct sockaddr *)&server_addr, &server_addr_len);
    udp_receive_buf[udp_receive_len] = '\0';
    NSString *str = [NSString stringWithCString:udp_receive_buf encoding:NSUTF8StringEncoding];
    //NSLog(@"udp (as client) - receiveFrom , remote address : %s , port : %d , msg : %@ *_*", inet_ntoa(server_addr.sin_addr), ntohs(server_addr.sin_port), str);
    [self tvLogShow:[NSString stringWithFormat:@"udp (as client) - receiveFrom , remote address : %s , port : %d , msg : %@ *_*", inet_ntoa(server_addr.sin_addr), ntohs(server_addr.sin_port), str]];
    
    close(fd);
    //NSLog(@"udp (as client) - close");
    [self tvLogShow:[NSString stringWithFormat:@"udp (as client) - close"]];
}


@end

