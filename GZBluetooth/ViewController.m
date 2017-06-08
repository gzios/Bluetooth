//
//  ViewController.m
//  GZBluetooth
//
//  Created by ATabc on 2017/6/8.
//  Copyright © 2017年 ATabc. All rights reserved.
//

#import "ViewController.h"
#import "GZTableView.h"
#import "GZCoreBluetoothController.h"
#import "GZGameKitController.h"
#import "GZMultipeerConnectivityController.h"
#import "GZMultipeerConnectivityQueryController.h"

@interface ViewController ()<GZTableViewDeleagte>{
    GZTableView *_tabview;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tabview =[[GZTableView alloc] initWithFrame:self.view.bounds];

    NSString * vcStr =@"GZMultipeerConnectivityQueryController";
    if (TARGET_IPHONE_SIMULATOR) {
       vcStr = @"GZMultipeerConnectivityController";
    }
    _tabview.equipmentArray = @[@"GZCoreBluetoothController",@"GZGameKitController",vcStr].mutableCopy;
    _tabview.delegate =self;
    [self.view addSubview:_tabview];
    
}

#pragma mark  GZTableViewDeleagte
-(void)selectRowAtIndexPath:(NSIndexPath *)indexPath{
    Class claas =NSClassFromString(_tabview.equipmentArray[indexPath.row]);
    UIViewController * Vc =[[(id)claas alloc] init];
    [self.navigationController pushViewController:Vc animated:YES];
}

@end
