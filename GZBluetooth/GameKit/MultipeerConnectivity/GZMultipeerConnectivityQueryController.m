//
//  GZMultipeerConnectivityQueryController.m
//  GZBluetooth
//
//  Created by ATabc on 2017/6/8.
//  Copyright © 2017年 ATabc. All rights reserved.
//

#import "GZMultipeerConnectivityQueryController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface GZMultipeerConnectivityQueryController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,MCSessionDelegate,MCBrowserViewControllerDelegate>
@property (strong,nonatomic) UIImageView *imageView;//照片显示视图
@property (strong,nonatomic) MCSession *session;
@property (strong,nonatomic) MCBrowserViewController *browserController;
@end

@implementation GZMultipeerConnectivityQueryController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    self.title =@"发现";
    self.navigationItem.leftBarButtonItems =@[[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(popClick:)],[[UIBarButtonItem alloc] initWithTitle:@"查找设备" style:UIBarButtonItemStyleDone target:self action:@selector(findClick:)]];
    self.navigationItem.rightBarButtonItems =@[[[UIBarButtonItem alloc] initWithTitle:@"选择照片" style:UIBarButtonItemStylePlain target:self action:@selector(selectedClick:)],[[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(send:)]];
    
    MCPeerID *peerId =[[MCPeerID alloc] initWithDisplayName:@"贱的很。。。"];
    _session =[[MCSession alloc] initWithPeer:peerId];
    _session.delegate =self;
    
    
}

-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView =[[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_imageView];
    }
    return _imageView;
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
-(void)selectedClick:(UIBarButtonItem *)sender {
    UIImagePickerController *imagePickerController=[[UIImagePickerController alloc]init];
    imagePickerController.delegate=self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - 查找设备
-(void)findClick:(UIBarButtonItem *)sender {
    //创建接收者
    _browserController =[[MCBrowserViewController alloc] initWithServiceType:@"cmj-stream" session:self.session];
    _browserController.delegate =self;
    [self presentViewController:_browserController animated:YES completion:nil];
}
#pragma mark - 返回
-(void)popClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark  连接提示
-(void)showConnectionPrompt:(NSString *)titleMessage{
    UIAlertController*alertController = [UIAlertController alertControllerWithTitle:@"提示框"message:titleMessage preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction*_Nonnullaction) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark MCBrowserViewControllerDelegate

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [self showConnectionPrompt:@"已选择"];
    [self.browserController dismissViewControllerAnimated:YES completion:nil];
}

// Notifies delegate that the user taps the cancel button.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [self showConnectionPrompt:@"取消浏览"];
    [self.browserController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MCSessionDelegate
#pragma mark 连接状态
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    switch (state) {
        case MCSessionStateNotConnected:
            [self showConnectionPrompt:@"连接成功"];
            [self.browserController dismissViewControllerAnimated:YES completion:nil];
            break;
        case MCSessionStateConnecting:
            [self showConnectionPrompt:@"正在连接。。。"];
            break;
        case MCSessionStateConnected:
            [self showConnectionPrompt:@"连接失败"];
            break;
    }
}

#pragma mark 接收数据
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSLog(@"开始接收数据...");
    UIImage *image=[UIImage imageWithData:data];
    [self.imageView setImage:image];
    [self showConnectionPrompt:@"结束数据完成"];
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

@end
