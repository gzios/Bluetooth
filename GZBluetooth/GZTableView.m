//
//  GZTableView.m
//  GZBluetooth
//
//  Created by ATabc on 2017/6/8.
//  Copyright © 2017年 ATabc. All rights reserved.
//

#import "GZTableView.h"

@interface GZTableView ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) UITableView *tableViews;

@end

@implementation GZTableView

-(UITableView *)tableViews{
    if (!_tableViews) {
        _tableViews =[[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        _tableViews.dataSource =self;
        _tableViews.delegate =self;
        [_tableViews registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
        [self addSubview:_tableViews];
    }
    return _tableViews;
}

-(void)setEquipmentArray:(NSMutableArray *)equipmentArray{
    _equipmentArray =equipmentArray;
    [self.tableViews reloadData];
    
}
#pragma mark UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.equipmentArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text =self.equipmentArray[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    !self.delegate ?:[self.delegate selectRowAtIndexPath:indexPath];
}

@end
