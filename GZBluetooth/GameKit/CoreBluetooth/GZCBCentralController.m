//
//  GZCBCentralController.m
//  GZBluetooth
//
//  Created by ATabc on 2017/6/12.
//  Copyright © 2017年 ATabc. All rights reserved.
//

#import "GZCBCentralController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#define kServiceUUID @"C4FB2349-72FE-4CA2-94D6-1F3CB16331EE" //服务的UUID
#define kCharacteristicUUID @"6A3E4B28-522D-4B3B-82A9-D5E2004534FC" //特征的UUID
@interface GZCBCentralController ()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (strong, nonatomic) UITextView *log; //日志记录

@property (nonatomic,strong) CBCentralManager *centralManager; //中心设备管理器

@property (strong,nonatomic) NSMutableArray *peripherals;//连接的外围设备


@end

@implementation GZCBCentralController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    self.navigationItem.leftBarButtonItems =@[[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(popClick:)],[[UIBarButtonItem alloc] initWithTitle:@"启动" style:UIBarButtonItemStyleDone target:self action:@selector(startClick:)]];
}
-(UITextView *)log{
    if (!_log) {
        _log =[[UITextView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) -300)/2, (CGRectGetHeight(self.view.frame) -300)/2, 300, 300)];
        _log.textColor =[UIColor blackColor];
        [self.view addSubview:_log];
    }
    return _log;
}
-(NSMutableArray *)peripherals{
    if (!_peripherals) {
        _peripherals =[NSMutableArray array];
    }
    return _peripherals;
}
#pragma mark - 启动
-(void)startClick:(UIBarButtonItem *)sender {
    _centralManager =[[CBCentralManager alloc] initWithDelegate:self queue:nil];
}
#pragma mark - 返回
-(void)popClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark  CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStatePoweredOn:
            NSLog(@"BLE已打开.");
            [self showConnectionPrompt:@"BLE已打开."];
            //扫描外围设备
            //            [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            
            [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            break;
            
        default:
            NSLog(@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备.");
            [self showConnectionPrompt:@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备."];
            break;
    }
}
/**
 *  发现外围设备
 * central              中心设备
 * peripheral           外围设备
 * advertisementData    特征数据
 * RSSI                 信号质量（信号强度）
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"发现外围设备...");
    [self showConnectionPrompt:@"发现外围设备..."];
    
    if (peripheral) {
          //添加保存外围设备，注意如果这里不保存外围设备（或者说peripheral没有一个强引用，无法到达连接成功（或失败）的代理方法，因为在此方法调用完就会被销毁
        if (![self.peripherals containsObject:peripheral]) {
            [self.peripherals addObject:peripheral];
        }
        NSLog(@"开始连接外围设备...");
        [self showConnectionPrompt:@"开始连接外围设备..."];
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}
//连接到外围设备
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"连接外围设备成功!");
    [self showConnectionPrompt:@"连接外围设备成功!"];
    //停止扫描
    [self.centralManager stopScan];
    
    peripheral.delegate=self;
    //外围设备开始寻找服务
    [peripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
}
//连接外围设备失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接外围设备失败!");
    [self showConnectionPrompt:@"连接外围设备失败!"];
}


#pragma mark - CBPeripheral 代理方法
//外围设备寻找到服务后
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"已发现可用服务...");
    [self showConnectionPrompt:@"已发现可用服务..."];
    if(error){
        NSLog(@"外围设备寻找服务过程中发生错误，错误信息：%@",error.localizedDescription);
        [self showConnectionPrompt:[NSString stringWithFormat:@"外围设备寻找服务过程中发生错误，错误信息：%@",error.localizedDescription]];
    }
    //遍历查找到的服务
    CBUUID *serviceUUID=[CBUUID UUIDWithString:kServiceUUID];
    CBUUID *characteristicUUID=[CBUUID UUIDWithString:kCharacteristicUUID];
    for (CBService *service in peripheral.services) {
        if([service.UUID isEqual:serviceUUID]){
            //外围设备查找指定服务中的特征
            [peripheral discoverCharacteristics:@[characteristicUUID] forService:service];
        }
    }
}
//外围设备寻找到特征后
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"已发现可用特征...");
    [self showConnectionPrompt:@"已发现可用特征..."];
    if (error) {
        NSLog(@"外围设备寻找特征过程中发生错误，错误信息：%@",error.localizedDescription);
        [self showConnectionPrompt:[NSString stringWithFormat:@"外围设备寻找特征过程中发生错误，错误信息：%@",error.localizedDescription]];
    }
    //遍历服务中的特征
    CBUUID *serviceUUID=[CBUUID UUIDWithString:kServiceUUID];
    CBUUID *characteristicUUID=[CBUUID UUIDWithString:kCharacteristicUUID];
    if ([service.UUID isEqual:serviceUUID]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:characteristicUUID]) {
                //情景一：通知
                /*找到特征后设置外围设备为已通知状态（订阅特征）：
                 *1.调用此方法会触发代理方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
                 *2.调用此方法会触发外围设备的订阅代理方法
                 */
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                //情景二：读取
                //                [peripheral readValueForCharacteristic:characteristic];
                //                    if(characteristic.value){
                //                    NSString *value=[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
                //                    NSLog(@"读取到特征值：%@",value);
                //                }
            }
        }
    }
}
//特征值被更新后
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"收到特征更新通知...");
    [self showConnectionPrompt:@"收到特征更新通知..."];
    if (error) {
        NSLog(@"更新通知状态时发生错误，错误信息：%@",error.localizedDescription);
    }
    //给特征值设置新的值
    CBUUID *characteristicUUID=[CBUUID UUIDWithString:kCharacteristicUUID];
    if ([characteristic.UUID isEqual:characteristicUUID]) {
        if (characteristic.isNotifying) {
            if (characteristic.properties==CBCharacteristicPropertyNotify) {
                NSLog(@"已订阅特征通知.");
                [self showConnectionPrompt:@"已订阅特征通知."];
                return;
            }else if (characteristic.properties ==CBCharacteristicPropertyRead) {
                //从外围设备读取新值,调用此方法会触发代理方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
                [peripheral readValueForCharacteristic:characteristic];
            }
            
        }else{
            NSLog(@"停止已停止.");
            [self showConnectionPrompt:@"停止已停止."];
            //取消连接
            [self.centralManager cancelPeripheralConnection:peripheral];
        }
    }
}
//更新特征值后（调用readValueForCharacteristic:方法或者外围设备在订阅后更新特征值都会调用此代理方法）
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"更新特征值时发生错误，错误信息：%@",error.localizedDescription);
        [self showConnectionPrompt:[NSString stringWithFormat:@"更新特征值时发生错误，错误信息：%@",error.localizedDescription]];
        return;
    }
    if (characteristic.value) {
        NSString *value=[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"读取到特征值：%@",value);
        [self showConnectionPrompt:[NSString stringWithFormat:@"读取到特征值：%@",value]];
    }else{
        NSLog(@"未发现特征值.");
        [self showConnectionPrompt:@"未发现特征值."];
    }
}
#pragma mark  连接提示
-(void)showConnectionPrompt:(NSString *)titleMessage{
    self.log.text=[NSString stringWithFormat:@"%@\r\n%@",self.log.text,titleMessage];
    //    UIAlertController*alertController = [UIAlertController alertControllerWithTitle:@"提示框"message:titleMessage preferredStyle:UIAlertControllerStyleAlert];
    //    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction*_Nonnullaction) {
    //        [alertController dismissViewControllerAnimated:YES completion:nil];
    //    }]];
    //    [self presentViewController:alertController animated:YES completion:nil];
}

@end
