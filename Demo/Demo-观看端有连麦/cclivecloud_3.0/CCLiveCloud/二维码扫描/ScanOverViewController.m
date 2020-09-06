//
//  ScanOverViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/12/5.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "ScanOverViewController.h"

@interface ScanOverViewController ()

@property(strong,nonatomic)UIView                       *overWindowView;//背景视图
@property(copy,nonatomic)  OkBtnClickBlock              block;//确认回调

@end

@implementation ScanOverViewController

-(instancetype)initWithBlock:(OkBtnClickBlock)block {
    self = [super init];
    if(self) {
        self.block = block;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //添加overWindowView
    [self.view addSubview:self.overWindowView];
    WS(ws)
    [_overWindowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    //添加弹窗视图
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:SCAN_ALERTSTRING preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(ws.block) {
            ws.block();//确认回调
        }
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//初始化弹窗视图
-(UIView *)overWindowView {
    if(!_overWindowView) {
        _overWindowView = [[UIView alloc] init];
        _overWindowView.backgroundColor = CCRGBAColor(0, 0, 0, 0.4);
    }
    return _overWindowView;
}

@end
