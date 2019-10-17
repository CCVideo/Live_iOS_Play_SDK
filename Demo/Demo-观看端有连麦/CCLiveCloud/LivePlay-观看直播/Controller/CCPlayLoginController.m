//
//  CCPlayLoginController.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/29.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCPlayLoginController.h"
#import "TextFieldUserInfo.h"
#import "CCSDK/CCLiveUtil.h"
#import "CCSDK/RequestData.h"
#import <AVFoundation/AVFoundation.h>
#import "ScanViewController.h"
#import "CCLiveCloud.pch"
#import <UIKit/UIKit.h>
#import "CCPlayerController.h"
#import "LoadingView.h"
#import "InformationShowView.h"

@interface CCPlayLoginController ()<UITextFieldDelegate,RequestDataDelegate>

@property (nonatomic, copy)NSString               * roomName;//房间名
@property (nonatomic, strong)UILabel              * informationLabel;//直播间信息
@property (nonatomic, strong)UIButton             * loginBtn;//登录按钮
@property (nonatomic, strong)LoadingView          * loadingView;//加载视图
@property (nonatomic, strong)UIBarButtonItem      * rightBarBtn;//扫码
@property (nonatomic, strong)UIBarButtonItem      * leftBarBtn;//返回
@property (nonatomic, strong)TextFieldUserInfo    * textFieldUserId;//UserId
@property (nonatomic, strong)TextFieldUserInfo    * textFieldRoomId;//RoomId
@property (nonatomic, strong)TextFieldUserInfo    * textFieldUserName;//用户名
@property (nonatomic, strong)TextFieldUserInfo    * textFieldUserPassword;//密码
@property (nonatomic, strong)InformationShowView  * informationView;//提示
@end

@implementation CCPlayLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];//创建UI
    [self addObserver];//添加通知
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //设置导航栏信息
    self.navigationItem.title = LOGIN_PLAY;
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5" alpha:1.0f];
    self.navigationItem.leftBarButtonItem=self.leftBarBtn;
    self.navigationItem.rightBarButtonItem=self.rightBarBtn;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"38404b" alpha:1.0f],NSForegroundColorAttributeName,[UIFont systemFontOfSize:FontSize_34],NSFontAttributeName,nil]];
    [self.navigationController.navigationBar setBackgroundImage:
     [self createImageWithColor:CCRGBColor(255,255,255)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

    //设置输入框和登陆按钮
    self.textFieldUserId.text = GetFromUserDefaults(WATCH_USERID);//userId
    self.textFieldRoomId.text = GetFromUserDefaults(WATCH_ROOMID);//roomId
    self.textFieldUserName.text = GetFromUserDefaults(WATCH_USERNAME);//userName
    self.textFieldUserPassword.text = GetFromUserDefaults(WATCH_PASSWORD);//password
    if(StrNotEmpty(_textFieldUserId.text) && StrNotEmpty(_textFieldRoomId.text) && StrNotEmpty(_textFieldUserName.text)) {
        self.loginBtn.enabled = YES;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
    } else {
        self.loginBtn.enabled = NO;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
#pragma mark- 点击登录

/**
 点击登陆按钮
 */
-(void)loginAction {
    [self.view endEditing:YES];
    //限制用户名长度
    if(self.textFieldUserName.text.length > 20) {
        [self showInformationView];
        return;
    }
    if (self.textFieldUserName.text.length == 0) {
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:@"用户名为空!"];
        [self.view addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
        return;
    }
    //添加提示视图
    [self showLoadingView];
    
    //配置SDK
    [self integrationSDK];
}
/**
 配置SDK
 */
-(void)integrationSDK{
    PlayParameter *parameter = [[PlayParameter alloc] init];
    parameter.userId = self.textFieldUserId.text;//userId
    parameter.roomId = self.textFieldRoomId.text;//roomId
    parameter.viewerName = self.textFieldUserName.text;//观看者昵称
    parameter.token = self.textFieldUserPassword.text;//登陆密码
    parameter.security = YES;//是否使用https
    parameter.viewerCustomua = @"viewercustomua";//自定义参数
    RequestData *requestData = [[RequestData alloc] initLoginWithParameter:parameter];
    requestData.delegate = self;
}
/**
 用户名过长提示
 */
-(void)showInformationView{
    [_informationView removeFromSuperview];
    _informationView = [[InformationShowView alloc] initWithLabel:USERNAME_CONFINE];
    [self.view addSubview:_informationView];
    [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
}
/**
 添加正在登录提示视图
 */
-(void)showLoadingView{
    _loadingView = [[LoadingView alloc] initWithLabel:LOGIN_LOADING centerY:NO];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
}
#pragma mark- 必须实现的代理方法RequestDataDelegate

//@optional
/**
 *    @brief    请求成功
 */
-(void)loginSucceedPlay {
    SaveToUserDefaults(WATCH_USERID,_textFieldUserId.text);
    SaveToUserDefaults(WATCH_ROOMID,_textFieldRoomId.text);
    SaveToUserDefaults(WATCH_USERNAME,_textFieldUserName.text);
    SaveToUserDefaults(WATCH_PASSWORD,_textFieldUserPassword.text);
    [_loadingView removeFromSuperview];
    _loadingView = nil;
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    CCPlayerController *playForPCVC = [[CCPlayerController alloc] initWithRoomName:self.roomName];
    playForPCVC.modalPresentationStyle = 0;
    [self presentViewController:playForPCVC animated:YES completion:^{
    }];
//    [self.navigationController pushViewController:playForPCVC animated:YES];
}
/**
 *    @brief    登录请求失败
 */
-(void)loginFailed:(NSError *)error reason:(NSString *)reason {
    NSString *message = nil;
    if (reason == nil) {
        message = [error localizedDescription];
    } else {
        message = reason;
    }
    
    [_loadingView removeFromSuperview];
    _loadingView = nil;
    [_informationView removeFromSuperview];
    _informationView = [[InformationShowView alloc] initWithLabel:message];
    [self.view addSubview:_informationView];
    [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];

    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
}
/**
 *    @brief  获取房间信息
 *    房间名称：dic[@"name"];
 */
-(void)roomInfo:(NSDictionary *)dic {
    _roomName = dic[@"name"];
}
#pragma mark - 导航栏按钮点击事件
/**
 点击返回按钮
 */
- (void)onSelectVC {
    [self.navigationController popViewControllerAnimated:NO];
}
/**
 点击扫码按钮
 */
-(void)onSweepCode {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            // 许可对话没有出现，发起授权许可
            [self requestAccess];
        }
            break;
        case AVAuthorizationStatusAuthorized:{
            // 已经开启授权，可继续
            ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:2];
            [self.navigationController pushViewController:scanViewController animated:NO];
        }
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            // 用户明确地拒绝授权，或者相机设备无法访问
            ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:2];
            [self.navigationController pushViewController:scanViewController animated:NO];
        }
            break;
        default:
            break;
    }
}
/**
 发起授权许可
 */
-(void)requestAccess{
    WS(ws)
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {//如果同意请求
                ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:2];;
                [ws.navigationController pushViewController:scanViewController animated:NO];
            }
        });
    }];
}
#pragma mark - 移除提示信息
-(void)removeInformationView {
    [_informationView removeFromSuperview];
    _informationView = nil;
}
//监听touch事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
/**
 userName输入框长度改变
 */
-(void)userNameTextFieldChange {
    if(_textFieldUserName.text.length > 20) {
                [self.view endEditing:YES];
        _textFieldUserName.text = [_textFieldUserName.text substringToIndex:20];
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:USERNAME_CONFINE];
        [APPDelegate.window addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];
        //2秒后移除提示视图
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
    }
}

#pragma mark UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidChange:(UITextField *) TextField {
    if(StrNotEmpty(_textFieldUserId.text) && StrNotEmpty(_textFieldRoomId.text) && StrNotEmpty(_textFieldUserName.text)) {
        self.loginBtn.enabled = YES;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
    } else {
        self.loginBtn.enabled = NO;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
    }
}
#pragma mark - 添加通知
-(void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
//移除通知
-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark keyboard notification
- (void)keyboardWillShow:(NSNotification *)notif {
    if(![self.textFieldRoomId isFirstResponder] && ![self.textFieldUserId isFirstResponder] && [self.textFieldUserName isFirstResponder] && ![self.textFieldUserPassword isFirstResponder]) {
        return;
    }
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat y = keyboardRect.size.height;
    for (int i = 1; i <= 4; i++) {
        UITextField *textField = [self.view viewWithTag:i];
        if ([textField isFirstResponder] == true && (SCREENH_HEIGHT - (CGRectGetMaxY(textField.frame) + CCGetRealFromPt(10))) < y) {
            WS(ws)
            [self.informationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
                make.top.mas_equalTo(ws.view).with.offset( - (y - (SCREENH_HEIGHT - (CGRectGetMaxY(textField.frame) + CCGetRealFromPt(10)))));
                make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
                make.height.mas_equalTo(CCGetRealFromPt(24));
            }];
            [UIView animateWithDuration:0.25f animations:^{
                [ws.view layoutIfNeeded];
            }];
        }
    }
}
//键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)notif {
    
}

/**
 UI布局
 */
- (void)setupUI {
    //添加输入框和登陆按钮
    [self.view addSubview:self.textFieldUserId];
    [self.view addSubview:self.textFieldRoomId];
    [self.view addSubview:self.textFieldUserName];
    [self.view addSubview:self.textFieldUserPassword];
    [self.view addSubview:self.informationLabel];
    [self.view addSubview:self.loginBtn];
    
    [self.textFieldUserName addTarget:self action:@selector(userNameTextFieldChange) forControlEvents:UIControlEventEditingChanged];
    //直播间信息
    [self.informationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).with.offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(self.view).with.offset(CCGetRealFromPt(40));
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.3);
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];
    //userId输入框
    [self.textFieldUserId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.informationLabel.mas_bottom).with.offset(CCGetRealFromPt(22));
        make.height.mas_equalTo(CCGetRealFromPt(92));
    }];
    //直播间Id输入框
    [self.textFieldRoomId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.textFieldUserId);
        make.top.mas_equalTo(self.textFieldUserId.mas_bottom);
        make.height.mas_equalTo(self.textFieldUserId.mas_height);
    }];
    //昵称输入框
    [self.textFieldUserName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.textFieldUserId);
        make.top.mas_equalTo(self.textFieldRoomId.mas_bottom);
        make.height.mas_equalTo(self.textFieldRoomId.mas_height);
    }];
    //密码输入框
    [self.textFieldUserPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.textFieldUserId);
        make.top.mas_equalTo(self.textFieldUserName.mas_bottom);
        make.height.mas_equalTo(self.textFieldUserName);
    }];
    //分界线
    UIView *line = [[UIView alloc] init];
    [self.view addSubview:line];
    [line setBackgroundColor:CCRGBColor(238,238,238)];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.textFieldUserPassword.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    //登陆按钮约束
    [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line.mas_bottom).with.offset(CCGetRealFromPt(80));
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(300);
    }];
}
#pragma mark - 懒加载
//登陆按钮
-(UIButton *)loginBtn {
    if(_loginBtn == nil) {
        _loginBtn = [[UIButton alloc] init];
        [_loginBtn setTitle:@"登 录" forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_36]];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"default_btn"] forState:UIControlStateNormal];
        _loginBtn.layer.cornerRadius = 25;
        [_loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        [_loginBtn.layer setMasksToBounds:YES];
    }
    return _loginBtn;
}
//右侧导航按钮
-(UIBarButtonItem *)rightBarBtn {
    if(_rightBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_code"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _rightBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSweepCode)];
    }
    return _rightBarBtn;
}
//左侧返回按钮
-(UIBarButtonItem *)leftBarBtn {
    if(_leftBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_back_nor"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _leftBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSelectVC)];
    }
    return _leftBarBtn;
}
//userId输入框
-(TextFieldUserInfo *)textFieldUserId {
    if(_textFieldUserId == nil) {
        _textFieldUserId = [[TextFieldUserInfo alloc] init];
        [_textFieldUserId textFieldWithLeftText:LOGIN_TEXT_USERID placeholder:LOGIN_TEXT_USERID_PLACEHOLDER lineLong:YES text:GetFromUserDefaults(WATCH_USERID)];
        _textFieldUserId.delegate = self;
        _textFieldUserId.tag = 1;
        _textFieldUserId.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldUserId.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldUserId addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserId;
}
//直播间id输入框
-(TextFieldUserInfo *)textFieldRoomId {
    if(_textFieldRoomId == nil) {
        _textFieldRoomId = [[TextFieldUserInfo alloc] init];
        [_textFieldRoomId textFieldWithLeftText:LOGIN_TEXT_ROOMID placeholder:LOGIN_TEXT_ROOMID_PLACEHOLDER lineLong:NO text:GetFromUserDefaults(WATCH_ROOMID)];
        _textFieldRoomId.delegate = self;
        _textFieldRoomId.tag = 2;
        _textFieldRoomId.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldRoomId.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldRoomId addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldRoomId;
}
//昵称输入框
-(TextFieldUserInfo *)textFieldUserName {
    if(_textFieldUserName == nil) {
        _textFieldUserName = [[TextFieldUserInfo alloc] init];
        [_textFieldUserName textFieldWithLeftText:LOGIN_TEXT_USERNAME placeholder:LOGIN_TEXT_USERNAME_PLACEHOLDER lineLong:NO text:GetFromUserDefaults(WATCH_USERNAME)];
        _textFieldUserName.delegate = self;
        _textFieldUserName.tag = 3;
        _textFieldUserName.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldUserName.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldUserName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserName;
}
//密码输入框
-(TextFieldUserInfo *)textFieldUserPassword {
    if(_textFieldUserPassword == nil) {
        _textFieldUserPassword = [[TextFieldUserInfo alloc] init];
        [_textFieldUserPassword textFieldWithLeftText:LOGIN_TEXT_PASSWORD placeholder:LOGIN_TEXT_PASSWORD_PLACEHOLDER lineLong:NO text:GetFromUserDefaults(WATCH_PASSWORD)];
        _textFieldUserPassword.delegate = self;
        _textFieldUserPassword.tag = 4;
        _textFieldUserPassword.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldUserPassword.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldUserPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _textFieldUserPassword.secureTextEntry = YES;
    }
    return _textFieldUserPassword;
}
//直播间信息提示文本
-(UILabel *)informationLabel {
    if(_informationLabel == nil) {
        _informationLabel = [[UILabel alloc] init];
        [_informationLabel setFont:[UIFont systemFontOfSize:FontSize_24]];
        [_informationLabel setTextColor:CCRGBColor(102, 102, 102)];
        [_informationLabel setTextAlignment:NSTextAlignmentLeft];
        [_informationLabel setText:LOGIN_TEXT_INFOR];
    }
    return _informationLabel;
}
//用color返回一个image
- (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
#pragma mark - 屏幕旋转
- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)dealloc {
    [self removeObserver];
}

@end
