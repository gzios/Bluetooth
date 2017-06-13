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
#import "GZCBCentralController.h"
#include <stdio.h>
#import <objc/message.h>
//结构体类型
struct GZDate {
    int year;
    int month;
    int day;
};


struct GZPerson {
    char *name;
    int age;
    struct GZDate birthday;//一个结构体中包含另一个结构体，结构体类型变量声明前必须加上struct关键字
    float height;
};

void changeValue(struct GZPerson person){
    person.height =1.80;
}

char teste(){
//    struct GZPerson p ={"Kenshin",28,{1986,8,8},1.72};
//     printf("name=%s,age=%d,birthday=%d-%d-%d,height=%.2f\n",p.name,p.age,p.birthday.year,p.birthday.month,p.birthday.day,p.height);
    
    struct GZPerson persons[] = {
        {"Kenshin",28,{1986,8,8},1.72},
        {"Kaoru",27,{1987,8,8},1.60},
        {"Rosa",29,{1985,8,8},1.60}
    };
    for (int i=0; i<3; ++i) {
        printf("name=%s,age=%d,birthday=%d-%d-%d,height=%.2f\n",
               persons[i].name,
               persons[i].age,
               persons[i].birthday.year,
               persons[i].birthday.month,
               persons[i].birthday.day,
               persons[i].height);
    }
    struct GZPerson person =persons[0];
    changeValue(person);
    printf("name=%s,age=%d,birthday=%d-%d-%d,height=%.2f\n",
           persons[0].name,
           persons[0].age,
           persons[0].birthday.year,
           persons[0].birthday.month,
           persons[0].birthday.day,
           persons[0].height);
    
    struct GZPerson *p=&person;
    printf("name=%s,age=%d,birthday=%d-%d-%d,height=%.2f\n",
           (*p).name,
           (*p).age,
           (*p).birthday.year,
           (*p).birthday.month,
           (*p).birthday.day,
           (*p).height);
    printf("name=%s,age=%d,birthday=%d-%d-%d,height=%.2f\n",
           p->name,
           p->age,
           p->birthday.year,
           p->birthday.month,
           p->birthday.day,
           p->height);
//    return "name=%s,age=%d,birthday=%d-%d-%d,height=%.2f\n",p.name,p.age,p.birthday.year,p.birthday.month,p.birthday.day,p.height;
    return "name=%s,age=%d,birthday=%d-%d-%d,height=%.2f\n",p->name,p->age,p->birthday.year,p->birthday.month,p->birthday.day,p->height;
    
    
}

//枚举
enum GZseason{ //默认是从0开始排序的
    GZseasonspring,
    GZseasonsummer,
    GZseasonautumn,
    GZseasonainter
};

void entst(){
    enum GZseason seaon =GZseasonautumn; //枚举赋值
    printf("枚举的数值%d\n",seaon);
    for (seaon =GZseasonspring; seaon < GZseasonainter; ++seaon) {
        printf("element value=%d\n",seaon);
    }
}

//共用体
union GZType {
    char a;
    short int b;
    int c;
};

void untest(){
    union GZType t;
    t.a ='a';
    t.b =10;
    t.c =65562;
    printf("address(Type)=%x,address(t.a)=%s,address(t.b)=%x,address(t.c)=%x\n",&t,&t.a,&t.b,&t.c);
    //结果：address(Type)=5fbff7b8,address(t.a)=5fbff7b8,address(t.b)=5fbff7b8,address(t.c)=5fbff7b8
    
    printf("len(Type)=%lu\n",sizeof(union GZType));
    //结果：len(Type)=4
    
    printf("t.a=%d,t.b=%d,t.c=%d\n",t.a,t.b,t.c);
    //结果:t.a=4,t.b=260,t.c=65796
}
@interface ViewController ()<GZTableViewDeleagte>{
    GZTableView *_tabview;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    NSString * string = [NSString stringWithFormat:@"%c", teste()];
    NSLog(@"%@",string);
    
    entst();
    
    untest();
    
    _tabview =[[GZTableView alloc] initWithFrame:self.view.bounds];

    NSString * vcStr =@"GZMultipeerConnectivityQueryController";
    if (TARGET_IPHONE_SIMULATOR) {
       vcStr = @"GZMultipeerConnectivityController";
    }
    _tabview.equipmentArray = @[@"GZCBCentralController",@"GZCoreBluetoothController",@"GZGameKitController",vcStr].mutableCopy;
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
