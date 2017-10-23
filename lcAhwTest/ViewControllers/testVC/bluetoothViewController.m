//
//  bluetoothViewController.m
//  lcAhwTest
//
//  Created by licheng on 16/1/18.
//  Copyright © 2016年 lc. All rights reserved.
//




//<GameKit/GameKit.h>  iOS7以前，只支持iOS设备，传输内容仅限于沙盒或照片库中的文件，只能在同一应用间传输
//<MultipeerConnectivity/MultipeerConnectivity.h>  iOS7及以后，只支持iOS设备，传输内容仅限于沙盒或照片库中的文件，可以在不同应用间传输

//<CoreBluetooth/CoreBluetooth.h>  iOS6及以后，支持非iOS设备，要求设备支持蓝牙4.0，BLE4.0标准，可用于智能家居、无线支付等

//h ttp://www.cnblogs.com/kenshincui/p/4220402.html




/*
#import "bluetoothViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#define kServiceType  @"lc-ServiceType"  // 广播和发现的参数

@interface bluetoothViewController()<MCSessionDelegate, MCAdvertiserAssistantDelegate, MCBrowserViewControllerDelegate>
{
    MCSession  *_session;
    MCAdvertiserAssistant  *_advertiserAssistant;
    MCBrowserViewController  *_browserVC;
}
@end

typedef enum
{
    BtnTag_1a = 100,
    BtnTag_2b,
    BtnTag_3a,
} BtnTag;

@implementation bluetoothViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"蓝牙";
    
    UILabel *lb = [KUtils createLabelWithFrame:CGRectMake(10, 80, 200, 20) text:@"请确保蓝牙已经打开" fontSize:14 textAlignment:NSTextAlignmentLeft tag:0];
    [self.view addSubview:lb];
    UIButton *btn0 = [KUtils createButtonWithFrame:CGRectMake(10, 100, 100, 30) title:@"1.a广播" titleColor:[UIColor blueColor] target:self tag:BtnTag_1a];
    [self.view addSubview:btn0];
    UIButton *btn1 = [KUtils createButtonWithFrame:CGRectMake(110, 100, 100, 30) title:@"2.b发现" titleColor:[UIColor blueColor] target:self tag:BtnTag_2b];
    [self.view addSubview:btn1];
    UIButton *btn2 = [KUtils createButtonWithFrame:CGRectMake(210, 100, 100, 30) title:@"3.a发送数据" titleColor:[UIColor blueColor] target:self tag:BtnTag_3a];
    [self.view addSubview:btn2];
}


- (void)buttonAction:(UIButton *)btn
{
    if (btn.tag == BtnTag_1a)
    {
        // 广播
        MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:@"lc蓝牙_外设"];  // 创建节点   外设即耳机键盘等
        _session = [[MCSession alloc] initWithPeer:peerID];
        _session.delegate = self;
        _advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:kServiceType discoveryInfo:nil session:_session];  // 创建广播
        _advertiserAssistant.delegate = self;
        [_advertiserAssistant start];  // 开始广播
        btn.backgroundColor = [UIColor orangeColor];
    }
    
    else if (btn.tag == BtnTag_3a)
    {
        // 发送数据
        NSString *path = [[NSBundle mainBundle] pathForResource:@"folder_references/icon_blue.png" ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:path];
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSArray *peerArr = [_session connectedPeers];
        NSError *error = nil;
        [_session sendData:data toPeers:peerArr withMode:MCSessionSendDataUnreliable error:&error];
        NSLog(@"蓝牙开始发送数据");
        if (error)
        {
            NSLog(@"蓝牙发送数据过程中发生错误 %@", error);
        }
        btn.backgroundColor = [UIColor orangeColor];
    }
    
    else if (btn.tag == BtnTag_2b)
    {
        // 发现
        MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:@"lc蓝牙_中心设备"];
        _session = [[MCSession alloc] initWithPeer:peerID];
        _session.delegate = self;
        _browserVC = [[MCBrowserViewController alloc] initWithServiceType:kServiceType session:_session];
        _browserVC.delegate = self;
        [self presentViewController:_browserVC animated:YES completion:nil];
        btn.backgroundColor = [UIColor orangeColor];
    }
    
}


- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnecting)
    {
        NSLog(@"%@ 蓝牙连接状态变化 正在连接", peerID.displayName);
    }
    else if (state == MCSessionStateConnected)
    {
        NSLog(@"%@ 蓝牙连接状态变化 连接成功", peerID.displayName);
    }
    else if (state == MCSessionStateNotConnected)
    {
        NSLog(@"%@ 蓝牙连接状态变化 连接失败", peerID.displayName);
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"蓝牙接受数据成功");
    UIImage *img = [UIImage imageWithData:data];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 150, 200, 100)];
    imgView.image = img;
    [self.view addSubview:imgView];
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"蓝牙数据接收中 %@，%@， %lld", resourceName, peerID.displayName, progress.completedUnitCount);
}
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"session didFinishReceiving");
}
- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    NSLog(@"session didReceiveCertificate");
}
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"session didReceiveStream");
}


- (void)advertiserAssistantWillPresentInvitation:(MCAdvertiserAssistant *)advertiserAssistant
{
    NSLog(@"广播弹出框出现  (xx wants to connect.)");
}
- (void)advertiserAssistantDidDismissInvitation:(MCAdvertiserAssistant *)advertiserAssistant
{
    NSLog(@"广播弹出框消失");
}


- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    NSLog(@"蓝牙取消选择");
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    NSLog(@"蓝牙已选择");
    [_browserVC dismissViewControllerAnimated:YES completion:nil];
}


@end
*/




#import "bluetoothViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

//peripheral 外围设备（耳机键盘等，广播，发送数据）
//central 中央设备（发现，接收数据）
//一台设备不能同时做外围设备和中央设备

#define kPeripheralName      @"lc_peripheral外围设备"                   // 外围设备名称
#define kServiceUUID         @"C4FB2349-72FE-4CA2-94D6-1F3CB16331EE"  // 服务UUID，外围设备和中央设备相同，查找和判断的依据
#define kCharacteristicUUID  @"6A3E4B28-522D-4B3B-82A9-D5E2004534FC"  // 特征UUID，外围设备和中央设备相同，查找和判断的依据

@interface bluetoothViewController()<CBPeripheralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBPeripheralManager      *_peripheralManager;  // 外围设备管理器
    CBMutableCharacteristic  *_mCharacteristic;    // 特征
    NSMutableArray           *_centralArr;         // 订阅此外围设备特征的中心设备
    
    CBCentralManager  *_centralManager;  // 中心设备管理器
    NSMutableArray    *_peripheralArr;   // 连接的外围设备
    
    UITextView *_tvLog;
}
@end

@implementation bluetoothViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        _centralArr = [[NSMutableArray alloc] init];
        _peripheralArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"蓝牙";
    
    UILabel *lbP = [KUtils createLabelWithFrame:CGRectMake(10, 80, 80, 30) text:@"外围设备" fontSize:16 textAlignment:NSTextAlignmentLeft tag:0];
    UIButton *btnP0 = [KUtils createButtonWithFrame:CGRectMake(100, 80, 100, 30) title:@"1.a启动" titleColor:[UIColor blueColor] target:self tag:100];
    UIButton *btnP1 = [KUtils createButtonWithFrame:CGRectMake(200, 80, 100, 30) title:@"3.a发送" titleColor:[UIColor blueColor] target:self tag:101];
    [self.view addSubview:lbP];
    [self.view addSubview:btnP0];
    [self.view addSubview:btnP1];
    UILabel *lbC = [KUtils createLabelWithFrame:CGRectMake(10, 120, 80, 30) text:@"中心设备" fontSize:16 textAlignment:NSTextAlignmentLeft tag:0];
    UIButton *btnC0 = [KUtils createButtonWithFrame:CGRectMake(100, 120, 100, 30) title:@"2.b发现" titleColor:[UIColor blueColor] target:self tag:200];
    [self.view addSubview:lbC];
    [self.view addSubview:btnC0];
    _tvLog = [[UITextView alloc] initWithFrame:CGRectMake(10, 150, 300, 400)];
    _tvLog.editable = NO;
    [self.view addSubview:_tvLog];
}


- (void)buttonAction:(UIButton *)btn
{
    if (btn.tag == 100)  // 外围设备 启动
    {
        [self startPeripheral];
    }
    else if (btn.tag == 101)  // 外围设备 更新（发送数据）
    {
        [self updateCharacteristicValue];
    }
    else if (btn.tag == 200)  // 中心设备 发现
    {
        [self startCentral];
    }
}

- (void)tvLogShow:(NSString *)msg
{
    NSLog(@"%@", msg);
    _tvLog.text = [NSString stringWithFormat:@"%@\n%@", _tvLog.text, msg];
}


#pragma mark - 外围设备

// 启动（触发peripheralManagerDidUpdateState委托方法，若蓝牙未打开会先弹出框提示）
- (void)startPeripheral
{
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

// 创建特征、服务并添加服务
- (void)addService
{
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
//    NSString *valueStr = kPeripheralName;
//    NSData *valueData = [valueStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *valueData = nil;
    _mCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:valueData permissions:CBAttributePermissionsReadable];  // 创建特征
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    CBMutableService *mService = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];  // 创建服务
    mService.characteristics = @[_mCharacteristic];  // 设置服务的特征
    [_peripheralManager addService:mService];  // 添加服务到外围设备
}

// 更新特征值（发送数据）
- (void)updateCharacteristicValue
{
    NSString *valueStr = [NSString stringWithFormat:@"*_*%@--%@", kPeripheralName, [NSDate date]];
    NSData *valueData = [valueStr dataUsingEncoding:NSUTF8StringEncoding];
    [_peripheralManager updateValue:valueData forCharacteristic:_mCharacteristic onSubscribedCentrals:nil];
}


// 蓝牙状态变化
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        NSLog(@"外围设备蓝牙状态变化 已打开");
        [self tvLogShow:[NSString stringWithFormat:@"外围设备蓝牙状态变化 已打开"]];
        [self addService];  // 添加服务（触发peripheralManager_didAddService_error委托方法）
    }
    else
    {
        NSLog(@"外围设备蓝牙状态变化 %ld 蓝牙未打开或设备不支持BLE4.0", peripheral.state);
        [self tvLogShow:[NSString stringWithFormat:@"外围设备蓝牙状态变化 %ld 蓝牙未打开或设备不支持BLE4.0", peripheral.state]];
    }
}

// 添加服务
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"外围设备添加服务 失败 %@", error);
        [self tvLogShow:[NSString stringWithFormat:@"外围设备添加服务 失败 %@", error]];
        return;
    }
    NSLog(@"外围设备添加服务");
    [self tvLogShow:[NSString stringWithFormat:@"外围设备添加服务"]];
    
    NSDictionary *dic = @{ CBAdvertisementDataLocalNameKey : kPeripheralName };  // 广播设置
    [_peripheralManager startAdvertising:dic];  // 开始广播（触发peripheralManagerDidStartAdvertising委托方法）
}

// 启动广播
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if(error)
    {
        NSLog(@"外围设备启动广播 失败 %@", error);
        [self tvLogShow:[NSString stringWithFormat:@"外围设备启动广播 失败 %@", error]];
        return;
    }
    NSLog(@"外围设备启动广播");
    [self tvLogShow:[NSString stringWithFormat:@"外围设备启动广播"]];
}

// 订阅特征（中心设备发现时触发）
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"订阅特征 中心设备：%@，特征：%@", central, characteristic);
    [self tvLogShow:[NSString stringWithFormat:@"订阅特征 中心设备：%@，特征：%@", central, characteristic]];
    if (![_centralArr containsObject:central])  // 发现中心设备并存储
    {
        [_centralArr addObject:central];
    }
}
// 取消订阅特征（中心设备释放时触发）
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"取消订阅特征 中心设备：%@，特征：%@", central, characteristic);
    [self tvLogShow:[NSString stringWithFormat:@"取消订阅特征 中心设备：%@，特征：%@", central, characteristic]];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSLog(@"peripheralManager didReceiveReadRequest");
    [self tvLogShow:[NSString stringWithFormat:@"peripheralManager didReceiveReadRequest"]];
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(nonnull NSDictionary<NSString *,id> *)dict
{
    NSLog(@"peripheralManager willRestoreState");
    [self tvLogShow:[NSString stringWithFormat:@"peripheralManager willRestoreState"]];
}


#pragma mark - 中心设备

// 发现（触发centralManagerDidUpdateState委托方法，若蓝牙未打开会先弹出框提示）
- (void)startCentral
{
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

// 扫描外围设备
- (void)scanPeripherals
{
//    NSArray *cbuuidArr = @[[CBUUID UUIDWithString:kServiceUUID]];
    NSDictionary *optionDic = @{ CBCentralManagerScanOptionAllowDuplicatesKey:@YES };
    [_centralManager scanForPeripheralsWithServices:nil options:optionDic];
}

// 蓝牙状态变化
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        NSLog(@"中心设备蓝牙状态变化 已打开");
        [self tvLogShow:[NSString stringWithFormat:@"中心设备蓝牙状态变化 已打开"]];
        [self scanPeripherals];  // 扫描外围设备
    }
    else
    {
        NSLog(@"中心设备蓝牙状态变化 %ld 蓝牙未打开或设备不支持BLE4.0", central.state);
        [self tvLogShow:[NSString stringWithFormat:@"中心设备蓝牙状态变化 %ld 蓝牙未打开或设备不支持BLE4.0", central.state]];
    }
}

// 发现外围设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"中心设备发现外设：%@", peripheral.name);
    [self tvLogShow:[NSString stringWithFormat:@"中心设备发现外设：%@", peripheral.name]];
    [central stopScan];  // 停止扫描
    if (peripheral && ![_peripheralArr containsObject:peripheral])  // 发现外围设备并存储（如果不保存，或者说没有一个强引用，就无法达到连接成功失败的委托方法，因为在此方法调用完就会被销毁）
    {
        [_peripheralArr addObject:peripheral];
    }
    [_centralManager connectPeripheral:peripheral options:nil];  // 连接外围设备
}

// 与外设连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"中心设备与外设连接成功：%@", peripheral.name);
    [self tvLogShow:[NSString stringWithFormat:@"中心设备与外设连接成功：%@", peripheral.name]];
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];  // 外围设备开始寻找服务
}

// 与外设连接出错
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"中心设备与外设连接出错：%@\n%@", peripheral.name, error);
    [self tvLogShow:[NSString stringWithFormat:@"中心设备与外设连接出错：%@\n%@", peripheral.name, error]];
}

// 与外设连接断开
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"中心设备与外设连接断开：%@\n%@", peripheral.name, error);
    [self tvLogShow:[NSString stringWithFormat:@"中心设备与外设连接断开：%@\n%@", peripheral.name, error]];
}


// 外围设备发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"外围设备发现服务 失败 %@", error);
        [self tvLogShow:[NSString stringWithFormat:@"外围设备发现服务 失败 %@", error]];
        return;
    }
    NSLog(@"外围设备发现服务");
    [self tvLogShow:[NSString stringWithFormat:@"外围设备发现服务"]];
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    for (CBService *service in peripheral.services)  // 遍历查找到的服务
    {
        if ([service.UUID isEqual:serviceUUID])  // 指定的服务
        {
            [peripheral discoverCharacteristics:@[characteristicUUID] forService:service];  // 寻找服务中指定的特征
        }
    }
}

// 外围设备中发现特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"外围设备发现特征 失败 %@", error);
        [self tvLogShow:[NSString stringWithFormat:@"外围设备发现特征 失败 %@", error]];
        return;
    }
    NSLog(@"外围设备发现特征");
    [self tvLogShow:[NSString stringWithFormat:@"外围设备发现特征"]];
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    if ([service.UUID isEqual:serviceUUID])
    {
        for (CBCharacteristic *characteristic in service.characteristics)  // 遍历特征
        {
            if ([characteristic.UUID isEqual:characteristicUUID])  // 指定的特征
            {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];  // 通知 （触发peripheral_didUpdateNotificationStateForCharacteristic_error委托方法）
                
//                [peripheral readValueForCharacteristic:characteristic];  // 读取（触发peripheral_didUpdateValueForCharacteristic_error委托方法）
//                NSLog(@"读取到特征值：%@", characteristic.value);
//                [self tvLogShow:[NSString stringWithFormat:@"读取到特征值：%@", characteristic.value]];
            }
        }
    }
}


// 特征值被更新
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"特征值被更新 通知 失败 %@", error);
        [self tvLogShow:[NSString stringWithFormat:@"特征值被更新 通知 失败 %@", error]];
        return;
    }
    NSLog(@"特征值被更新 通知");
    [self tvLogShow:[NSString stringWithFormat:@"特征值被更新 通知"]];
    
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    if ([characteristic.UUID isEqual:characteristicUUID])
    {
        if (characteristic.isNotifying)
        {
            if (characteristic.properties == CBCharacteristicPropertyNotify)
            {
                NSLog(@"已订阅特征通知");
                [self tvLogShow:[NSString stringWithFormat:@"已订阅特征通知"]];
                return;
            }
            else if (characteristic.properties == CBCharacteristicPropertyRead)
            {
                [peripheral readValueForCharacteristic:characteristic];  // 读取（触发peripheral_didUpdateValueForCharacteristic_error委托方法）
            }
        }
        else
        {
            NSLog(@"通知已停止");
            [self tvLogShow:[NSString stringWithFormat:@"通知已停止"]];
            [_centralManager cancelPeripheralConnection:peripheral];  // 取消连接
        }
    }
}

// 特征值被更新（外围设备发送数据）
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"特征值被更新 失败 %@", error);
        [self tvLogShow:[NSString stringWithFormat:@"特征值被更新 失败 %@", error]];
        return;
    }
    NSLog(@"特征值被更新");
    [self tvLogShow:[NSString stringWithFormat:@"特征值被更新"]];
    
    NSString *valueStr = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"读取到特征值：%@\n%@", characteristic.value, valueStr);
    [self tvLogShow:[NSString stringWithFormat:@"读取到特征值：%@\n%@", characteristic.value, valueStr]];
}


@end




