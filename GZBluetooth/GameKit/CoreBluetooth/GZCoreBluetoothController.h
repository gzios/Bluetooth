//
//  GZCoreBluetoothController.h
//  GZBluetooth
//
//  Created by ATabc on 2017/6/8.
//  Copyright © 2017年 ATabc. All rights reserved.
//  外围设备（周边设备）
/**
 CoreBluetooth设计同样也是类似于客户端-服务器端的设计，作为服务器端的设备称为外围设备（Peripheral），作为客户端的设备叫做中央设备（Central），CoreBlueTooth整个框架就是基于这两个概念来设计的。
 
 CBPeripheralManager：外围设备通常用于发布服务、生成数据、保存数据。外围设备发布并广播服务，告诉周围的中央设备它的可用服务和特征。
 
 CBCentralManager：中央设备使用外围设备的数据。中央设备扫描到外围设备后会就会试图建立连接，一旦连接成功就可以使用这些服务和特征。
 
 
 外围设备和中央设备之间交互的桥梁是服务(CBService)和特征(CBCharacteristic)，二者都有一个唯一的标识UUID（CBUUID类型）来唯一确定一个服务或者特征，每个服务可以拥有多个特征
 
 
 蓝牙外设模式流程
 
 1. 启动一个Peripheral管理对象
 2. 本地Peripheral设置服务,特性,描述，权限等等
 3. Peripheral发送广告
 4. 设置处理订阅、取消订阅、读characteristic、写characteristic的委托方法
 
 
 蓝牙设备状态
 
 1. 待机状态（standby）：设备没有传输和发送数据，并且没有连接到任何设
 2. 广播状态（Advertiser）：周期性广播状态
 3. 扫描状态（Scanner）：主动寻找正在广播的设备
 4. 发起链接状态（Initiator）：主动向扫描设备发起连接。
 5. 主设备（Master）：作为主设备连接到其他设备。
 6. 从设备（Slave）：作为从设备连接到其他设备。
 蓝牙设备的五种工作状态
 
 准备（standby）
 广播（advertising）
 监听扫描（Scanning
 发起连接（Initiating）
 已连接（Connected）
 
 */
#import <UIKit/UIKit.h>

@interface GZCoreBluetoothController : UIViewController

@end
