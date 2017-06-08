//
//  GZCoreBluetoothController.m
//  GZBluetooth
//
//  Created by ATabc on 2017/6/8.
//  Copyright © 2017年 ATabc. All rights reserved.
//

#import "GZCoreBluetoothController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "GZTableView.h"
@interface GZCoreBluetoothController ()<CBCentralManagerDelegate,GZTableViewDeleagte,CBPeripheralDelegate>{
    //系统蓝牙设备管理对象,可以把他理解为主设备，通过它可以去扫描和链接外设
    CBCentralManager *_manager;
    //用于保存被发现设备
    NSMutableArray *_peripherals;
    //当前设备状态
    CBManagerState _state;
    GZTableView *_tabview;
}


@end

@implementation GZCoreBluetoothController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    /*  设置主设备的委托，CBCentralManagerDelegate
     必须实现的：
     //主设备状态改变的委托，在初始化CBCebtralManager的时候会打开设备，只有当设备正确打开之后才能使用
     - (void)centralManagerDidUpdateState:(CBCentralManager *)central;
     //其他几个比较重要的委托方法
     - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI; //找到外设的委托
     - (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;//连接外设成功的委托
     - (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;//外设连接失败的委托
     - (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;//断开外设的委托
     */
    
    //初始化并设置委托和线程队列，最好一个线程的参数可以为Nil，默认是main线程
    _manager =[[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
    UIButton * btn =[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(CGRectGetMaxX(self.view.frame) - 150, CGRectGetMaxY(self.view.frame) -50, 150, 50);
    [btn setBackgroundColor:[UIColor blueColor]];
    [btn setTitle:@"开始扫描设备" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnstartScannings) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    _peripherals =[NSMutableArray array];
    _tabview =[[GZTableView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame))];
    _tabview.delegate =self;
    [self.view addSubview:_tabview];
    
    
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    /*
     CBManagerStateUnknown = 0,
     CBManagerStateResetting,
     CBManagerStateUnsupported,
     CBManagerStateUnauthorized,
     CBManagerStatePoweredOff,
     CBManagerStatePoweredOn,
     */
    _state =central.state;
    
}

//扫描到外设会进入方法
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"当前扫描到的外设%@",peripheral.name);
    if (peripheral.name.length > 0) {
        if ([_peripherals containsObject:peripheral])return;
        [_peripherals addObject:peripheral];
        _tabview.equipmentArray =[_peripherals valueForKey:@"name"];
    }
}
//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self showConnectionPrompt:[NSString stringWithFormat:@">>>连接到名称为（%@）的设备-成功", [peripheral name]]];
    //设置peripheral委托CBPeripheralDelegate
    [peripheral setDelegate:self];
    //扫描外设Services，成功后会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    [peripheral discoverServices:nil];
}

//连接到Peripherals-失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    [self showConnectionPrompt:[NSString stringWithFormat:@">>>连接到名称为（%@）的设备-失败,原因: %@\n", [peripheral name], [error localizedDescription]]];
}

//Peripherals断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self showConnectionPrompt:[NSString stringWithFormat:@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]]];
}

#pragma mark 开始扫描设备
-(void)btnstartScannings{
    switch (_state) {
        case CBManagerStateUnknown:
            [self showConnectionPrompt:@"状态未知,更新迫在眉睫"];
            break;
        case CBManagerStateResetting:
            
            [self showConnectionPrompt:@"与系统连接服务暂时丢失,更新迫在眉睫"];
            break;
        case CBManagerStateUnsupported:
            [self showConnectionPrompt:@"这个平台不支持蓝牙低能量中心/客户角色"];
            break;
        case CBManagerStateUnauthorized:
            [self showConnectionPrompt:@"应用程序未被授权使用蓝牙低能量的作用"];
            break;
        case CBManagerStatePoweredOff:
            [self showConnectionPrompt:@"目前蓝牙驱动已关闭"];
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"目前蓝牙驱动,可以使用。");
            /*
             第一个参数nil就是扫描周围所有的外设，扫描到外设后会进入
             */
            [_manager scanForPeripheralsWithServices:nil options:nil];
            
            break;
    }
}

#pragma mark CBPeripheralDelegate
//扫描到Services
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@">>>扫描到服务：%@",peripheral.services);
}
#pragma mark  GZTableViewDeleagte
-(void)selectRowAtIndexPath:(NSIndexPath *)indexPath{
    //连接设备
    [_manager connectPeripheral:_peripherals[indexPath.row] options:nil];
}
#pragma mark  连接提示
-(void)showConnectionPrompt:(NSString *)titleMessage{
    UIAlertController*alertController = [UIAlertController alertControllerWithTitle:@"提示框"message:titleMessage preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction*_Nonnullaction) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
