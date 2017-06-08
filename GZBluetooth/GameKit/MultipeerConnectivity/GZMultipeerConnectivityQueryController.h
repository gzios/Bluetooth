//
//  GZMultipeerConnectivityQueryController.h
//  GZBluetooth
//
//  Created by ATabc on 2017/6/8.
//  Copyright © 2017年 ATabc. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 在两个程序中无论是MCBrowserViewController还是MCAdvertiserAssistant在初始化的时候都指定了一个服务类型“cmj-photo”，这是唯一标识一个服务类型的标记，可以按照官方的要求命名，应该尽可能表达服务的作用。需要特别指出的是，如果广播命名为“cmj-photo”那么发现节点只有在MCBrowserViewController中指定为“cmj-photo”才能发现此服务。
 */
@interface GZMultipeerConnectivityQueryController : UIViewController

@end
