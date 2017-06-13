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

#define kPeripheralName @"Kenshin Cui's Device" //外围设备名称
#define kServuceUUID @"C4FB2349-72FE-4CA2-94D6-1F3CB16331EE" //服务的UUID
#define kxServuceUUID @"C4FB2354-72FE-4CA2-94D6-1F3CB16331EE" //服务的UUID

#define kCharacteristicUUID @"6A3E4B28-522D-4B3B-82A9-D5E2004534FC"  //特征的UUID
#define krCharacteristicUUID @"6A3E4B28-522D-4B3B-82A9-D5E2004334FC"  //特征的UUID
#define kreCharacteristicUUID @"6A3E4B28-522D-4B3B-82A9-D2E2004334FC"  //特征的UUID


@interface GZCoreBluetoothController ()<CBPeripheralManagerDelegate>

@property(nonatomic,strong) CBPeripheralManager *peripheralManager; //外围设备管理器

@property (strong, nonatomic) UITextView *log; //日志记录

@property (strong,nonatomic) NSMutableArray *centralM;//订阅此外围设备特征的中心设备

@property (strong,nonatomic) CBMutableCharacteristic *characteristicM;//特征

@end

@implementation GZCoreBluetoothController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
//    创建一个外围设备通常分为以下几个步骤：
    
//    创建外围设备CBPeripheralManager对象并指定代理。
//    创建特征CBCharacteristic、服务CBSerivce并添加到外围设备
//    外围设备开始广播服务（startAdvertisting:）。
//    和中央设备CBCentral进行交互。
    self.navigationItem.leftBarButtonItems =@[[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(popClick:)],[[UIBarButtonItem alloc] initWithTitle:@"开始广播" style:UIBarButtonItemStyleDone target:self action:@selector(startClick:)]];
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"更新" style:UIBarButtonItemStyleDone target:self action:@selector(updateClick:)];
}

-(UITextView *)log{
    if (!_log) {
        _log =[[UITextView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) -300)/2, (CGRectGetHeight(self.view.frame) -300)/2, 300, 300)];
        _log.textColor =[UIColor blackColor];
        [self.view addSubview:_log];
    }
    return _log;
}
#pragma mark -属性
-(NSMutableArray *)centralM{
    if (!_centralM) {
        _centralM=[NSMutableArray array];
    }
    return _centralM;
}
#pragma mark  添加服务
//创建特征、服务并添加服务到外围设备
-(void)setupServer{
     //特征值
//    NSString *valueStr =kPeripheralName;
//    NSData *value =[valueStr dataUsingEncoding:NSUTF8StringEncoding];
    //创建特征
    /**
     * uuid:特征标识
     * properties:特征属性，eg：可通知、可写、可读
     * value: 特征值
     * permissions: 特征的权限
     */
    
    /**
     标识这个characteristic的属性是广播
     CBCharacteristicPropertyBroadcast												= 0x01,
     标识这个characteristic的属性是读
     CBCharacteristicPropertyRead													= 0x02,
     标识这个characteristic的属性是写-没有响应
     CBCharacteristicPropertyWriteWithoutResponse									= 0x04,
     标识这个characteristic的属性是写
     CBCharacteristicPropertyWrite													= 0x08,
     标识这个characteristic的属性是通知
     CBCharacteristicPropertyNotify													= 0x10,
     标识这个characteristic的属性是声明
     CBCharacteristicPropertyIndicate												= 0x20,
     标识这个characteristic的属性是通过验证的
     CBCharacteristicPropertyAuthenticatedSignedWrites								= 0x40,
     标识这个characteristic的属性是拓展
     CBCharacteristicPropertyExtendedProperties										= 0x80,
     标识这个characteristic的属性是需要加密的通知
     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)		= 0x100,
     标识这个characteristic的属性是需要加密的申明
     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)	= 0x200
      
     indecate和notify的区别就在于，indecate是一定会收到数据，notify有可能会丢失数据（不会有central收到数据的回应），write也分为response和noresponse，如果是response，那
     */
    /**
     可读的
     CBAttributePermissionsReadable					= 0x01,
     可写的
     CBAttributePermissionsWriteable					= 0x02,
     需验证
     CBAttributePermissionsReadEncryptionRequired	= 0x04,
     CBAttributePermissionsWriteEncryptionRequired	= 0x08
     */
   
    //characteristics字段描述
    CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
    
    /*
     可以通知的Characteristic
     properties：CBCharacteristicPropertyNotify
     permissions CBAttributePermissionsReadable
     */
    CBMutableCharacteristic *notiyCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:kCharacteristicUUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];

    
    
    /*
     可读写的characteristics
     properties：CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead
     permissions CBAttributePermissionsReadable | CBAttributePermissionsWriteable
     */
    CBMutableCharacteristic *readwriteCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:krCharacteristicUUID] properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];

    //设置description
    CBMutableDescriptor *readwriteCharacteristicDescription1 = [[CBMutableDescriptor alloc]initWithType: CBUUIDCharacteristicUserDescriptionStringUUID value:@"name"];
    [readwriteCharacteristic setDescriptors:@[readwriteCharacteristicDescription1]];
    
    /*
     只读的Characteristic
     properties：CBCharacteristicPropertyRead
     permissions CBAttributePermissionsReadable
     */
    CBMutableCharacteristic *readCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:kreCharacteristicUUID] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
    
    
      //创建服务并设置特征
    //创建服务的UUID 对象
    CBUUID *serviceUUID =[CBUUID UUIDWithString:kServuceUUID];
    //创建服务
    CBMutableService *serviceM =[[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    //设置服务的特征
    [serviceM setCharacteristics:@[notiyCharacteristic,readwriteCharacteristic]];
    
    //service2初始化并加入一个characteristics
    CBMutableService *service2 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:kxServuceUUID] primary:YES];
    [service2 setCharacteristics:@[readCharacteristic]];
    
    //将服务添加到外围设备上
    [self.peripheralManager addService:serviceM];
    [self.peripheralManager addService:service2];

}
//外围设备添加服务后调用
int asdasd;
-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    
    if (error) {
        NSLog(@"向外围设备添加服务失败，错误详情：%@",error.localizedDescription);
        [self showConnectionPrompt:[NSString stringWithFormat:@"向外围设备添加服务失败，错误详情：%@",error.localizedDescription]];
        return;
    }
    asdasd ++;
    if (asdasd == 2) {
        //添加服务后开始广播
//        NSDictionary *dic =@{CBAdvertisementDataLocalNameKey:kPeripheralName};//广播设置
//        [self.peripheralManager startAdvertising:dic]; //开始广播
//        
        [self.peripheralManager startAdvertising:@{
                                              CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:kServuceUUID],[CBUUID UUIDWithString:kxServuceUUID]],
                                              CBAdvertisementDataLocalNameKey:@"测试"
                                              }
         ];
        NSLog(@"向外围设备添加了服务并开始广播...");
        [self showConnectionPrompt:@"向外围设备添加了服务并开始广播..."];
    }
    
    
}
//开始广播时调用
-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    if (error) {
        NSLog(@"启动广播过程中发生错误，错误信息：%@",error.localizedDescription);
        [self showConnectionPrompt:[NSString stringWithFormat:@"启动广播过程中发生错误，错误信息：%@",error.localizedDescription]];
        return;
    }
    NSLog(@"启动广播");
    [self showConnectionPrompt:@"启动广播"];
}
//订阅特征
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
     NSLog(@"中心设备：%@ 已订阅特征：%@.",central,characteristic);
    NSLog(@"didSubscribeToCharacteristic");
     [self showConnectionPrompt:[NSString stringWithFormat:@"中心设备：%@ 已订阅特征：%@.",central.identifier.UUIDString,characteristic.UUID]];
    
    //发现中心设备并存储
    if (![self.centralM containsObject:central]) {
        [self.centralM addObject:central];
    }
    
}

//取消订阅特征
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"didUnsubscribeFromCharacteristic");
}
-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(CBATTRequest *)request{
    NSLog(@"didReceiveWriteRequests");
}
-(void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict{
    NSLog(@"willRestoreState");
}

//更新特征值
-(void)updateCharacteristicValue{
    //特征值
    NSString *valueStr =[NSString stringWithFormat:@"%@ --%@",kPeripheralName,[NSDate   date]];
    NSData *value =[valueStr dataUsingEncoding:NSUTF8StringEncoding];
    
    //更新特征值
    [self.peripheralManager updateValue:value forCharacteristic:self.characteristicM  onSubscribedCentrals:nil];
    [self showConnectionPrompt:[NSString stringWithFormat:@"更新特征值：%@",valueStr]];
}

#pragma mark - 开始广播
-(void)startClick:(UIBarButtonItem *)sender {
    self.peripheralManager =[[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
}
#pragma mark - 更新
-(void)updateClick:(UIBarButtonItem *)sender {
    [self updateCharacteristicValue];
}
#pragma mark - 返回
-(void)popClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark   CBPeripheralManagerDelegate
//外围设备状态发生变化后调用
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    /**
     CBManagerStateUnknown = 0,
     CBManagerStateResetting,
     CBManagerStateUnsupported,
     CBManagerStateUnauthorized,
     CBManagerStatePoweredOff,
     CBManagerStatePoweredOn,
     */
    switch (peripheral.state) {
        case CBManagerStatePoweredOn:
            NSLog(@"BLE已打开");
            [self showConnectionPrompt:@"BLE已打开"];
            //添加服务
            [self setupServer];
            break;
        default:
            [self showConnectionPrompt:@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备."];
            break;
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
