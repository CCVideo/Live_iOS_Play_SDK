//
//  ScanOverViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/12/5.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "ScanOverViewController.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>
@interface ScanOverViewController ()

@property(strong,nonatomic)UIView                       *overWindowView;
@property(copy,nonatomic)  OkBtnClickBlock              block;

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
    
    [self.view addSubview:self.overWindowView];
    WS(ws)
    [_overWindowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"请在iPhone的“设置-隐私-相机”选项中，允许CC云直播访问你的相机。" preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(ws.block) {
            ws.block();
        }
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView *)overWindowView {
    if(!_overWindowView) {
        _overWindowView = [UIView new];
        _overWindowView.backgroundColor = CCRGBAColor(0, 0, 0, 0.4);
    }
    return _overWindowView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
