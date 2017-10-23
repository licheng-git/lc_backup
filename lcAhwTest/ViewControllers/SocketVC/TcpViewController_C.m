//
//  TcpViewController_C.m
//  lcAhwTest
//
//  Created by licheng on 16/1/25.
//  Copyright © 2016年 lc. All rights reserved.
//

#import "TcpViewController_C.h"
#include <sys/socket.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>

@interface TcpViewController_C()
{
    UITextView   *_tvLog;
}
@end

@implementation TcpViewController_C

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"tcp - c语言";  // tcp，C语言，非异步，手机＋模拟器可测试（需改ip）
    
    UIButton *btnTcpServer = [KUtils createButtonWithFrame:CGRectMake(30, 80, 120, 30) title:@"服务器监听" titleColor:[UIColor blueColor] target:self tag:100];
    UIButton *btnTcpClient = [KUtils createButtonWithFrame:CGRectMake(160, 80, 120, 30) title:@"客户端连接" titleColor:[UIColor blueColor] target:self tag:101];
    [self.view addSubview:btnTcpServer];
    [self.view addSubview:btnTcpClient];
    
    _tvLog = [[UITextView alloc] initWithFrame:CGRectMake(10, 150, 300, 400)];
    _tvLog.editable = NO;
    [self.view addSubview:_tvLog];
    _tvLog.text = @"日志：\n";
}

- (void)buttonAction:(UIButton *)btn
{
    btn.backgroundColor = [UIColor orangeColor];
    if (btn.tag == 100)
    {
        [self tcpServer];
    }
    else if (btn.tag == 101)
    {
        [self tcpClient];
    }
}

- (void)tvLogShow:(NSString *)msg
{
    NSLog(@"%@", msg);
    _tvLog.text = [NSString stringWithFormat:@"%@\n%@", _tvLog.text, msg];
}


- (void)tcpServer
{
    int err;
    bool success = false;
    int fd = socket(PF_INET, SOCK_STREAM, 0);    // *服务端socket
    success = (fd != -1);
    if (!success)
    {
        return;
    }
    //NSLog(@"tcp server - socket");
    [self tvLogShow:[NSString stringWithFormat:@"tcp server - socket"]];
    
    struct sockaddr_in addr;                // 服务端网络地址结构
    memset(&addr, 0, sizeof(addr));         // 数据初始化－－清零
    addr.sin_family = AF_INET;              // 设置为ip通信
    addr.sin_addr.s_addr = INADDR_ANY;      // 服务器ip地址－－允许连接到所有本地地址上
    //addr.sin_addr.s_addr = inet_addr("10.18.204.66");
    addr.sin_port = htons(8000);            // 服务端端口号
    //size_t addr_len = sizeof(addr) = sizeof(struct sockaddr)
    err = bind(fd, (const struct sockaddr *)&addr, sizeof(addr));  // *绑定  *_*成功率很随机，why?
    success = (err == 0);
    if (!success)
    {
        return;
    }
    //NSLog(@"tcp server - bind , local server address : %s , port : %d", inet_ntoa(addr.sin_addr), ntohs(addr.sin_port));
    [self tvLogShow:[NSString stringWithFormat:@"tcp server - bind, local server address : %s , port : %d", inet_ntoa(addr.sin_addr), ntohs(addr.sin_port)]];
    
    err = listen(fd, 5);  // *监听
    success = (err == 0);
    if (!success)
    {
        return;
    }
    //NSLog(@"tcp server - listen");
    [self tvLogShow:[NSString stringWithFormat:@"tcp server - listen"]];
    
    //while (true)  // 实际开发中需要异步多线程持续监听
    {
        int client_fd;                   // 客户端socket
        struct sockaddr_in client_addr;  // 客户端网络地址结构
        socklen_t client_addr_len = sizeof(client_addr);
        client_fd = accept(fd, (struct sockaddr *)&client_addr, &client_addr_len);  // *客户端连接请求  waiting...
        success = (client_fd != -1);
        if (!success)
        {
            return;
        }
        //NSLog(@"tcp server - accept , remote client address : %s , port : %d", inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));
        [self tvLogShow:[NSString stringWithFormat:@"tcp server - accept , remote client address : %s , port : %d", inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port)]];
        
        char tcp_receive_buf[BUFSIZ];
        size_t tcp_receive_len = recv(client_fd, tcp_receive_buf, BUFSIZ, 0);  // *接收数据
        tcp_receive_buf[tcp_receive_len] = '\0';
        NSString *str = [NSString stringWithCString:tcp_receive_buf encoding:NSUTF8StringEncoding];
        //NSLog(@"tcp server - receive : %@ *_*", str);
        [self tvLogShow:[NSString stringWithFormat:@"tcp server - receive : %@ *_*", str]];
        
        char *tcp_send_str = "hello this data is from tcp server by lc with C语言";
        size_t tcp_send_str_len = strlen(tcp_send_str);
        size_t tcp_send = send(client_fd, tcp_send_str, tcp_send_str_len, 0);  // *发送数据
        //NSLog(@"tcp server - send (length=%zu)", tcp_send);
        [self tvLogShow:[NSString stringWithFormat:@"tcp server - send (length=%zu)", tcp_send]];
        
        close(client_fd);
        //NSLog(@"tcp server - close client");
        [self tvLogShow:[NSString stringWithFormat:@"tcp server - close client"]];
    }
    
    close(fd);
    //NSLog(@"tcp server - close");
    [self tvLogShow:[NSString stringWithFormat:@"tcp server - close"]];
}


- (void)tcpClient
{
    int err;
    bool success = false;
    int fd = socket(AF_INET, SOCK_STREAM, 0);    // *客户端socket
    success = (fd != -1);
    if (!success)
    {
        return;
    }
    //NSLog(@"tcp client - socket");
    [self tvLogShow:[NSString stringWithFormat:@"tcp client - socket"]];
    
    struct sockaddr_in server_addr;                           // 服务端网络地址结构
    memset(&server_addr, 0, sizeof(server_addr));             // 数据初始化－－清零
    server_addr.sin_family = AF_INET;                         // 设置为ip通信
    server_addr.sin_addr.s_addr = inet_addr("10.18.204.66");  // 服务端ip地址
    server_addr.sin_port = htons(8000);                       // 服务端端口号
    err = connect(fd, (const struct sockaddr *)&server_addr, sizeof(server_addr));  // *连接
    success = (err == 0);
    if (!success)
    {
        return;
    }
    //NSLog(@"tcp client - connect , remote server address : %s , port : %d", inet_ntoa(server_addr.sin_addr), ntohs(server_addr.sin_port));
    [self tvLogShow:[NSString stringWithFormat:@"tcp client - connect , remote server address : %s , port : %d", inet_ntoa(server_addr.sin_addr), ntohs(server_addr.sin_port)]];
    
    char *tcp_send_str = "lc 哈哈，tcp客户端发送的数据 使用C语言";
    size_t tcp_send_str_len = strlen(tcp_send_str);
    size_t tcp_send = send(fd, tcp_send_str, tcp_send_str_len, 0);  // *发送数据
    //NSLog(@"tcp client - send (length=%zu)", tcp_send);
    [self tvLogShow:[NSString stringWithFormat:@"tcp client - send (length=%zu)", tcp_send]];
    
    char tcp_receive_buf[BUFSIZ];
    size_t tcp_receive_len = recv(fd, tcp_receive_buf, BUFSIZ, 0);  // *接收数据
    tcp_receive_buf[tcp_receive_len] = '\0';
    NSString *str = [NSString stringWithCString:tcp_receive_buf encoding:NSUTF8StringEncoding];
    //NSLog(@"tcp client - receive : %@ *_*", str);
    [self tvLogShow:[NSString stringWithFormat:@"tcp client - receive : %@ *_*", str]];
    
    close(fd);
    //NSLog(@"tcp client - close");
    [self tvLogShow:[NSString stringWithFormat:@"tcp client - close"]];
}


@end

