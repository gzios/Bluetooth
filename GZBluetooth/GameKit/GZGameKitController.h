//
//  GZGameKitController.h
//  GZBluetooth
//
//  Created by ATabc on 2017/6/8.
//  Copyright © 2017年 ATabc. All rights reserved.
//
/**
 GKPeerPickerController：蓝牙查找、连接用的视图控制器，通常情况下应用程序A打开后会调用此控制器的show方法来展示一个蓝牙查找的视图，一旦发现了另一个同样在查找蓝牙连接的客户客户端B就会出现在视图列表中，此时如果用户点击连接B，B客户端就会询问用户是否允许A连接B，如果允许后A和B之间建立一个蓝牙连接。
 
 GKSession：连接会话，主要用于发送和接受传输数据。一旦A和B建立连接GKPeerPickerController的代理方法会将A、B两者建立的会话（GKSession）对象传递给开发人员，开发人员拿到此对象可以发送和接收数据。
 
 */
#import <UIKit/UIKit.h>

@interface GZGameKitController : UIViewController

@end
