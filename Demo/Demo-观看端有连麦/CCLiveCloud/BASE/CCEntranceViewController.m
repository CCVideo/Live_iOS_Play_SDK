//
//  CCEntranceViewController.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/19.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//



#import "CCEntranceViewController.h"
#import "CCLiveCloud.pch"
#import "CCPlayLoginController.h"
#import "CCPalyBackLoginController.h"

@interface CCEntranceViewController ()


@end

@implementation CCEntranceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
/**
 *  @brief  创建UI
 */
    [self setupUI];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
/**
 *  @brief  隐藏导航
 */
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
/**
 *  @brief  显示导航
 */
    self.navigationController.navigationBarHidden = NO;
}
/**
 *  @brief  创建UI
 */
- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    //背景图
    UIImageView *bgView = [[UIImageView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.frame = self.view.frame;
    if (IS_IPHONE_X) {
        bgView.image = [UIImage imageNamed:@"launch_backgroundImage"];
    } else {
        bgView.image = [UIImage imageNamed:@"default_bg"];
    }
    [self.view addSubview:bgView];
//观看直播
    UIButton *palyButton = [[UIButton alloc] init];
    [palyButton setBackgroundImage: [UIImage imageNamed:@"default_btn"] forState:UIControlStateNormal];
    [palyButton setBackgroundImage: [UIImage imageNamed:@"default_btn"] forState:UIControlStateHighlighted];

    [palyButton setTitle:@"观看直播" forState:UIControlStateNormal];
    [palyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    palyButton.titleLabel.font = [UIFont systemFontOfSize:FontSize_36];
    palyButton.layer.cornerRadius = 25;
    [self.view addSubview:palyButton];
    [palyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(SCREENH_HEIGHT/2+50);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(50);
    }];
    [palyButton layoutIfNeeded];
    [palyButton addTarget:self action:@selector(palyButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
//观看回放
    UIButton *palyBackButton = [[UIButton alloc] init];
    [palyBackButton setBackgroundImage: [UIImage imageNamed:@"default_btn"] forState:UIControlStateNormal];
    [palyBackButton setBackgroundImage: [UIImage imageNamed:@"default_btn"] forState:UIControlStateHighlighted];
    [palyBackButton setTitle:@"观看回放" forState:UIControlStateNormal];
    [palyBackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    palyBackButton.titleLabel.font = [UIFont systemFontOfSize:FontSize_36];
    palyBackButton.layer.cornerRadius = 25;
    [self.view addSubview:palyBackButton];
    [palyBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(palyButton);
        make.top.equalTo(palyButton.mas_bottom).offset(20);
    }];
    [palyBackButton addTarget:self action:@selector(palyBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
    palyBackButton.layer.cornerRadius = 25;
}

/**
 *  @brief  点击观看直播
 */
- (void)palyButtonClick {
    CCPlayLoginController *vc = [[CCPlayLoginController alloc] init];
//两周跳转方式
//    [self presentViewController:vc animated:YES completion:nil];
    [self.navigationController pushViewController:vc animated:NO];
}
/**
 *  @brief  点击观看回放
 */
- (void)palyBackButtonClick {
    CCPalyBackLoginController *vc = [[CCPalyBackLoginController alloc] init];
//两种跳转方式
//        [self presentViewController:vc animated:YES completion:nil];
    [self.navigationController pushViewController:vc animated:NO];
}
/**
 *  @brief  旋转屏设置
 */
- (BOOL)shouldAutorotate{
    return YES;
}
//返回优先方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
//返回支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
