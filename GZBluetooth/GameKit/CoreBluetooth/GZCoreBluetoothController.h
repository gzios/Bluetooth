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
 
 */
#import <UIKit/UIKit.h>

@interface GZCoreBluetoothController : UIViewController

@end
