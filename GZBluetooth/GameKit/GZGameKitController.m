//
//  GZGameKitController.m
//  GZBluetooth
//
//  Created by ATabc on 2017/6/8.
//  Copyright © 2017年 ATabc. All rights reserved.
//

#import "GZGameKitController.h"
#import <GameKit/GameKit.h>

@interface GZGameKitController ()<GKPeerPickerControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong,nonatomic) UIImageView *imageView;//照片显示视图
@property (strong,nonatomic) GKSession *session;//蓝牙连接会话
@end

@implementation GZGameKitController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    self.navigationItem.rightBarButtonItems =@[[[UIBarButtonItem alloc] initWithTitle:@"测试" style:UIBarButtonItemStyleDone target:self action:@selector(selectClick:)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sendClick:)]];
    
    GKPeerPickerController *pearPickerController =[[GKPeerPickerController alloc] init];
    pearPickerController.delegate =self;
    [pearPickerController show];
}
-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView =[[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.userInteractionEnabled =YES;
        [self.view addSubview:_imageView];
    }
    return _imageView;
}
#pragma mark - GKPeerPickerController代理方法
/**
 *  连接到某个设备
 *
 *  @param picker  蓝牙点对点连接控制器
 *  @param peerID  连接设备蓝牙传输ID
 *  @param session 连接会话
 */
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session{
    self.session =session;
    NSLog(@"已连接客户端设备%@.",peerID);
    [self.session setDataReceiveHandler:self withContext:nil];
    [picker dismiss];
}
- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker{
    NSLog(@"断开连接%@",picker);
    [self showConnectionPrompt:@"断开连接"];
}
#pragma mark 蓝牙数据接收
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context{
    UIImage *image=[UIImage imageWithData:data];
    self.imageView.image=image;
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    [self showConnectionPrompt:@"数据接收成功！"];
}

#pragma mark - UIImagePickerController代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    self.imageView.image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)sendClick:(UIBarButtonItem *)sender {
    NSData *data=UIImagePNGRepresentation(self.imageView.image);
    NSError *error=nil;
    [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error];
    if (error) {
        NSLog(@"发送图片过程中发生错误，错误信息:%@",error.localizedDescription);
        [self showConnectionPrompt:[NSString stringWithFormat:@"发送图片过程中发生错误，错误信息:%@",error.localizedDescription]];
    }else{
        [self showConnectionPrompt:@"发送成功"];
    }
}

#pragma mark - UI事件
- (void)selectClick:(UIBarButtonItem *)sender {
    UIImagePickerController *imagePickerController=[[UIImagePickerController alloc]init];
    imagePickerController.delegate=self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
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
