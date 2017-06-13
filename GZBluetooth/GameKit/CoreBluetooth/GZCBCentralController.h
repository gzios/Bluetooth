//
//  GZCBCentralController.h
//  GZBluetooth
//
//  Created by ATabc on 2017/6/12.
//  Copyright © 2017年 ATabc. All rights reserved.
//  中央设备
/**
 中央设备的创建一般可以分为如下几个步骤：
 
 创建中央设备管理对象CBCentralManager并指定代理。
 扫描外围设备，一般发现可用外围设备则连接并保存外围设备。
 查找外围设备服务和特征，查找到可用特征则读取特征数据。
 
 
 蓝牙中心模式流程
 
 1. 建立中心角色
 2. 扫描外设（discover）
 3. 连接外设(connect)
 4. 扫描外设中的服务和特征(discover)
 - 4.1 获取外设的services
 - 4.2 获取外设的Characteristics,获取Characteristics的值，获取Characteristics的Descriptor和Descriptor的值
 5. 与外设做数据交互(explore and interact)
 6. 订阅Characteristic的通知
 7. 断开连接(disconnect)
 */

#import <UIKit/UIKit.h>

@interface GZCBCentralController : UIViewController

@end
