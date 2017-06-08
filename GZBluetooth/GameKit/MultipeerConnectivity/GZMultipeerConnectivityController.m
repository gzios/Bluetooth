//
//  GZMultipeerConnectivityController.m
//  GZBluetooth
//
//  Created by ATabc on 2017/6/8.
//  Copyright © 2017年 ATabc. All rights reserved.
//

#import "GZMultipeerConnectivityController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface GZMultipeerConnectivityController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,MCSessionDelegate,MCAdvertiserAssistantDelegate>
@property (strong,nonatomic) UIImageView *imageView;//照片显示视图
@property (strong,nonatomic) MCSession *session;
@property (strong,nonatomic) MCAdvertiserAssistant *advertiserAssistant;
@end

@implementation GZMultipeerConnectivityController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    self.title =@"广播";
    self.navigationItem.leftBarButtonItems =@[[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(popClick:)],[[UIBarButtonItem alloc] initWithTitle:@"开始广播" style:UIBarButtonItemStyleDone target:self action:@selector(selectClick:)]];
    self.navigationItem.rightBarButtonItems =@[[[UIBarButtonItem alloc] initWithTitle:@"选择照片" style:UIBarButtonItemStyleDone target:self action:@selector(sendClick:)],[[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(send:)]];
    //创建节点，displayName是用来提供给周边设备查看和区分此服务的
    MCPeerID *peerId =[[MCPeerID alloc] initWithDisplayName:@"你就说贱不贱"];
    _session =[[MCSession alloc] initWithPeer:peerId];
    _session.delegate =self;
    //创建广播///cmj-stream
    _advertiserAssistant =[[MCAdvertiserAssistant alloc] initWithServiceType:@"cmj-stream" discoveryInfo:nil session:_session];
    _advertiserAssistant.delegate =self;
    _imageView =[[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_imageView];
    
}

#pragma mark - UIImagePickerController代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    self.imageView.image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 选择照片
-(void)sendClick:(UIBarButtonItem *)sender {
    UIImagePickerController *imagePickerController=[[UIImagePickerController alloc]init];
    imagePickerController.delegate=self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}
#pragma mark - 发送数据
-(void)send:(UIBarButtonItem *)sender {
    //发送数据给所有已连接设备
    if (!self.imageView.image) {
        return;
    }
    NSError *error =nil;
    NSData *data =UIImagePNGRepresentation(self.imageView.image);
    [self.session sendData:data toPeers:[self.session connectedPeers] withMode:MCSessionSendDataReliable error:&error];
    NSLog(@"开始发送数据...");
    if (error) {
         NSLog(@"发送数据过程中发生错误，错误信息：%@",error.localizedDescription);
        [self showConnectionPrompt:[NSString stringWithFormat:@"发送数据过程中发生错误，错误信息：%@",error.localizedDescription]];
    }else{
       [self showConnectionPrompt:@"数据发送成功"];
    }
}
#pragma mark - 开始广播
-(void)selectClick:(UIBarButtonItem *)sender {
    //开始广播
    [self.advertiserAssistant start];
}

#pragma mark - 返回停止广播
-(void)popClick:(UIBarButtonItem *)sender {
    [self.advertiserAssistant stop];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - MCSessionDelegate代理方法
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    NSLog(@"%s",__FUNCTION__);
    /**
     MCSessionStateNotConnected,
     MCSessionStateConnecting,
     MCSessionStateConnected
     */
    switch (state) {
        case MCSessionStateNotConnected:
            [self showConnectionPrompt:@"连接成功"];
            break;
        case MCSessionStateConnecting:
             [self showConnectionPrompt:@"正在连接。。。"];
            break;
        case MCSessionStateConnected:
             [self showConnectionPrompt:@"连接失败"];
            break;
    }
}
//接收数据
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSLog(@"开始接收数据");
    UIImage *image=[UIImage imageWithData:data];
    [self.imageView setImage:image];
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
