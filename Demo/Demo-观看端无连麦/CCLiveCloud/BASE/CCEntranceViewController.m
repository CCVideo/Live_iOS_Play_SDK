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
#import "CCPlayerController.h"
#import "CCPlayBackController.h"
#import "CCcommonDefine.h"
#import "CCDownloadViewController.h"

#define loginBtnImageName @"default_btn"

@interface CCEntranceViewController ()


@end

@implementation CCEntranceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
/**
 *  @brief  创建UI
 */
    [self setupUI];
    
    [self addObserver];
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
    [palyButton setBackgroundImage: [UIImage imageNamed:loginBtnImageName] forState:UIControlStateNormal];
    [palyButton setBackgroundImage: [UIImage imageNamed:loginBtnImageName] forState:UIControlStateHighlighted];

    [palyButton setTitle:@"观看直播" forState:UIControlStateNormal];
    [palyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    palyButton.titleLabel.font = [UIFont systemFontOfSize:FontSize_36];
    palyButton.layer.cornerRadius = 25;
    [self.view addSubview:palyButton];
    CGFloat deviceOffset = iPhone5_5s_5c_5SE ? 30 : 50;
    [palyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(SCREENH_HEIGHT/2+deviceOffset);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(50);
    }];
    [palyButton layoutIfNeeded];
    [palyButton addTarget:self action:@selector(palyButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
//观看回放
    UIButton *palyBackButton = [[UIButton alloc] init];
    [palyBackButton setBackgroundImage: [UIImage imageNamed:loginBtnImageName] forState:UIControlStateNormal];
    [palyBackButton setBackgroundImage: [UIImage imageNamed:loginBtnImageName] forState:UIControlStateHighlighted];
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
    
    
//离线回放
    UIButton *localPlayButton = [[UIButton alloc]init];
    [localPlayButton setBackgroundImage:[UIImage imageNamed:loginBtnImageName] forState:UIControlStateNormal];
    [localPlayButton setBackgroundImage:[UIImage imageNamed:loginBtnImageName] forState:UIControlStateHighlighted];
    [localPlayButton setTitle:@"离线回放" forState:UIControlStateNormal];
    [localPlayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    localPlayButton.titleLabel.font = [UIFont systemFontOfSize:FontSize_36];
    [self.view addSubview:localPlayButton];
    [localPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(palyBackButton);
        make.top.equalTo(palyBackButton.mas_bottom).offset(20);
    }];
    [localPlayButton addTarget:self action:@selector(localPlayButtonClick) forControlEvents:UIControlEventTouchUpInside];
    localPlayButton.layer.cornerRadius = 25;
    
    
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"版本: hd_sdk_v3.10.0";
    label.textColor = [UIColor lightGrayColor];
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-30);
    }];
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
 *  @brief  点击观看离线回放
 */
- (void)localPlayButtonClick {
    CCDownloadViewController *vc = [[CCDownloadViewController alloc] init];
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
#pragma mark - 添加通知
-(void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openUrl:)
                                                 name:@"openUrl"
                                               object:nil];
}
-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openUrl" object:nil];
}

-(void)dealloc {
    [self removeObserver];
}
-(void)openUrl:(NSNotification *)info {
    for (UIViewController *controller in self.navigationController.viewControllers) {
        /*        当存在登录直播页面或者直播回放页面时   需要清除这些控制器     */
        if ([controller isKindOfClass:[CCPlayLoginController class]] || [controller isKindOfClass:[CCPalyBackLoginController class]]) {
            if (controller.presentedViewController) {
                [controller.presentedViewController dismissViewControllerAnimated:NO completion:nil];
                /* 移除控制器中一些添加在window上的视图  */
                for (UIView *view in APPDelegate.window.subviews) {
                    [view removeFromSuperview];
                }
            }
            [self.navigationController popToRootViewControllerAnimated:NO];
            break;
        }
    }
    
    NSString *roomType = info.userInfo[@"roomType"];
    if ([roomType isEqualToString:@"live"]) {//进入观看直播
        CCPlayLoginController *vc = [[CCPlayLoginController alloc] init];
        //两周跳转方式
        //    [self presentViewController:vc animated:YES completion:nil];
        [self.navigationController pushViewController:vc animated:NO];
        if ([GetFromUserDefaults(AUTOLOGIN) isEqualToString:@"true"]) {
            /*     自动登录      */
            [vc loginAction];
        }
    }else{//进入观看回放
        CCPalyBackLoginController *vc = [[CCPalyBackLoginController alloc] init];
        //两种跳转方式
        //        [self presentViewController:vc animated:YES completion:nil];
        [self.navigationController pushViewController:vc animated:NO];
        if ([GetFromUserDefaults(AUTOLOGIN) isEqualToString:@"true"]) {
            /*     自动登录      */
            [vc loginAction];
        }
    }
    
}
@end
