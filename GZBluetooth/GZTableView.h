//
//  GZTableView.h
//  GZBluetooth
//
//  Created by ATabc on 2017/6/8.
//  Copyright © 2017年 ATabc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GZTableViewDeleagte <NSObject>

-(void)selectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface GZTableView : UIView

@property(nonatomic,strong)NSMutableArray *equipmentArray;

@property(nonatomic,weak) id<GZTableViewDeleagte> delegate;

@end
