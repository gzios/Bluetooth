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
 
 */

#import <UIKit/UIKit.h>

@interface GZCBCentralController : UIViewController

@end
