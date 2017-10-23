//
//  socketViewController.m
//  lcAhwTest
//
//  Created by licheng on 16/1/22.
//  Copyright © 2016年 lc. All rights reserved.
//

#import "socketViewController.h"
#import "TcpSocketViewController.h"
#import "UdpSocketViewController.h"
#import "TcpViewController_C.h"
#import "UdpViewController_C.h"
#import "SimplePingHelper.h"
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>

@implementation socketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"socket(tcp/udp)";
    
    UIButton *btn00 = [KUtils createButtonWithFrame:CGRectMake(10, 80, 300, 30) title:@"tcp *_* CocoaAsyncSocket oc+C#" titleColor:[UIColor blueColor] target:self tag:0];
    UIButton *btn01 = [KUtils createButtonWithFrame:CGRectMake(10, 110, 300, 30) title:@"udp *_* CocoaAsyncSocket oc+C#" titleColor:[UIColor blueColor] target:self tag:1];
    UIButton *btn10 = [KUtils createButtonWithFrame:CGRectMake(10, 150, 300, 30) title:@"tcp *_* c语言" titleColor:[UIColor greenColor] target:self tag:10];
    UIButton *btn11 = [KUtils createButtonWithFrame:CGRectMake(10, 180, 300, 30) title:@"udp *_* c语言" titleColor:[UIColor greenColor] target:self tag:11];
    UIButton *btn20 = [KUtils createButtonWithFrame:CGRectMake(10, 220, 300, 30) title:@"tcp *_* 聊天测试" titleColor:[UIColor redColor] target:self tag:20];
    UIButton *btn21 = [KUtils createButtonWithFrame:CGRectMake(10, 250, 300, 30) title:@"udp *_* 聊天测试" titleColor:[UIColor redColor] target:self tag:21];
    [self.view addSubview:btn00];
    [self.view addSubview:btn01];
    [self.view addSubview:btn10];
    [self.view addSubview:btn11];
    [self.view addSubview:btn20];
    [self.view addSubview:btn21];
    
    UILabel *lbIp = [KUtils createLabelWithFrame:CGRectMake(10, 300, 200, 30) text:nil fontSize:16 textAlignment:NSTextAlignmentLeft tag:0];
    lbIp.text = [NSString stringWithFormat:@"本机ip：%@", [self ipAddress]];
    [self.view addSubview:lbIp];
    
    [self pingAction];
}

- (void)buttonAction:(UIButton *)btn
{
    if (btn.tag == 0)
    {
        TcpSocketViewController *tcpVC = [[TcpSocketViewController alloc] init];
        [self.navigationController pushViewController:tcpVC animated:YES];
    }
    else if (btn.tag == 1)
    {
        UdpSocketViewController *udpVC = [[UdpSocketViewController alloc] init];
        [self.navigationController pushViewController:udpVC animated:YES];
    }
    else if (btn.tag == 10)
    {
        TcpViewController_C *tcpVC_C = [[TcpViewController_C alloc] init];
        [self.navigationController pushViewController:tcpVC_C animated:YES];
    }
    else if (btn.tag == 11)
    {
        UdpViewController_C *udpVC_C = [[UdpViewController_C alloc] init];
        [self.navigationController pushViewController:udpVC_C animated:YES];
    }
}



- (void)pingAction
{
    [SimplePingHelper ping:@"113.106.167.178" target:self sel:@selector(pingResult:)];
}
- (void)pingResult:(NSNumber *)success
{
    if (success.boolValue)
    {
        NSLog(@"ping通");
        
    }
    else
    {
        NSLog(@"ping不通");
    }
}



- (NSString *)ipAddress
{
    NSString *ip = nil;
    struct ifaddrs *addrs;
    if (getifaddrs(&addrs)==0) {
        const struct ifaddrs *cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                //NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                //if ([name isEqualToString:@"en0"]) // Wi-Fi adapter
                {
                    ip = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                    break;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return ip;
}


@end

