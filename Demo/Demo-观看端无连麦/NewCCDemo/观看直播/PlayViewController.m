//
//  PlayViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/11/23.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "PlayViewController.h"
#import "TextFieldUserInfo.h"
#import "NavigationView.h"
#import "InformationShowView.h"
#import "LoadingView.h"
#import "CCSDK/CCLiveUtil.h"
#import "CCSDK/RequestData.h"
#import <AVFoundation/AVFoundation.h>
#import "ScanViewController.h"
#import "PlayForPCVC.h"

@interface PlayViewController ()<UITextFieldDelegate,RequestDataDelegate>

@property(nonatomic,strong)UIBarButtonItem      *leftBarBtn;
@property(nonatomic,strong)UIBarButtonItem      *rightBarBtn;
@property(nonatomic,strong)UILabel              *informationLabel;

@property(nonatomic,strong)TextFieldUserInfo    *textFieldUserId;
@property(nonatomic,strong)TextFieldUserInfo    *textFieldRoomId;
@property(nonatomic,strong)TextFieldUserInfo    *textFieldUserName;
@property(nonatomic,strong)TextFieldUserInfo    *textFieldUserPassword;

@property(nonatomic,strong)UIButton             *loginBtn;
@property(nonatomic,strong)NavigationView       *navigationView;
@property(nonatomic,strong)LoadingView          *loadingView;

@property(nonatomic,copy) NSString              *roomName;
@property(nonatomic,strong)InformationShowView  *informationView;

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem=self.leftBarBtn;
    self.navigationItem.rightBarButtonItem=self.rightBarBtn;
    [self.navigationController.navigationBar setBackgroundImage:
     [self createImageWithColor:CCRGBColor(255,102,51)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.view.backgroundColor = CCRGBColor(250, 250, 250);
    [self.view addSubview:self.informationLabel];
    
    WS(ws);
    [_informationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
        make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];
    
    [self.view addSubview:self.textFieldUserId];
    [self.view addSubview:self.textFieldRoomId];
    [self.view addSubview:self.textFieldUserName];
    [self.view addSubview:self.textFieldUserPassword];
    
    [self.textFieldUserName addTarget:self action:@selector(userNameTextFieldChange) forControlEvents:UIControlEventEditingChanged];
    
    [self.textFieldUserId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.informationLabel.mas_bottom).with.offset(CCGetRealFromPt(22));
        make.height.mas_equalTo(CCGetRealFromPt(92));
    }];
    
    [self.textFieldRoomId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.textFieldUserId);
        make.top.mas_equalTo(ws.textFieldUserId.mas_bottom);
        make.height.mas_equalTo(ws.textFieldUserId.mas_height);
    }];
    
    [self.textFieldUserName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.textFieldUserId);
        make.top.mas_equalTo(ws.textFieldRoomId.mas_bottom);
        make.height.mas_equalTo(ws.textFieldRoomId.mas_height);
    }];
    
    [self.textFieldUserPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.textFieldUserId);
        make.top.mas_equalTo(ws.textFieldUserName.mas_bottom);
        make.height.mas_equalTo(ws.textFieldUserName);
    }];
    
    UIView *line = [UIView new];
    [self.view addSubview:line];
    [line setBackgroundColor:CCRGBColor(238,238,238)];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.textFieldUserPassword.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    [self.view addSubview:self.loginBtn];
    [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(65));
        make.right.mas_equalTo(ws.view).with.offset(-CCGetRealFromPt(65));
        make.top.mas_equalTo(line.mas_bottom).with.offset(CCGetRealFromPt(70));
        make.height.mas_equalTo(CCGetRealFromPt(86));
    }];
    
    _navigationView = [[NavigationView alloc] initWithTitle:@"观看直播" pushBlock:^(NSInteger index) {
        UIViewController *viewController = nil;
        switch (index) {
            case 1:
//                viewController = [[LiveViewController alloc] init];
                break;
            case 2:
                viewController = [[PlayViewController alloc] init];
                break;
            case 3:
                viewController = [[PlayBackViewController alloc] init];
                break;
            default:
                break;
        }
        [ws.navigationController pushViewController:viewController animated:NO];
    }];

    self.navigationItem.titleView = _navigationView;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:2] forKey:CONTROLLER_INDEX];
    [_navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(165), CCGetRealFromPt(34)));
    }];
    
    [self addObserver];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.textFieldUserId.text = GetFromUserDefaults(WATCH_USERID);
    self.textFieldRoomId.text = GetFromUserDefaults(WATCH_ROOMID);
    self.textFieldUserName.text = GetFromUserDefaults(WATCH_USERNAME);
    self.textFieldUserPassword.text = GetFromUserDefaults(WATCH_PASSWORD);
    
//    self.textFieldUserId.text = @"920022FE264A70C1";
//    self.textFieldRoomId.text = @"DF95B69FE1DA7D919C33DC5901307461";
//    self.textFieldUserName.text = @"尹召青";
//    self.textFieldUserPassword.text = @"111";

    if(StrNotEmpty(_textFieldUserId.text) && StrNotEmpty(_textFieldRoomId.text) && StrNotEmpty(_textFieldUserName.text)) {
        self.loginBtn.enabled = YES;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
    } else {
        self.loginBtn.enabled = NO;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
    }
}

-(void)userNameTextFieldChange {
    if(_textFieldUserName.text.length > 20) {
        //        [self endEditing:YES];
        _textFieldUserName.text = [_textFieldUserName.text substringToIndex:20];
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:@"输入限制在20个字符以内"];
        [APPDelegate.window addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
    }
}

-(void)removeInformationView {
    [_informationView removeFromSuperview];
    _informationView = nil;
}

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

-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc {
    [self removeObserver];
}

-(UIButton *)loginBtn {
    if(_loginBtn == nil) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.backgroundColor = CCRGBColor(255,102,51);
        [_loginBtn setTitle:@"登 录" forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
        [_loginBtn.layer setMasksToBounds:YES];
//        [_loginBtn.layer setBorderWidth:1.0];
//        [_loginBtn.layer setBorderColor:[CCRGBColor(255,71,0) CGColor]];
        [_loginBtn.layer setCornerRadius:CCGetRealFromPt(40)];
        [_loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_loginBtn setBackgroundImage:[self createImageWithColor:CCRGBColor(255,102,51)] forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:[self createImageWithColor:CCRGBAColor(255,102,51,0.2)] forState:UIControlStateDisabled];
        [_loginBtn setBackgroundImage:[self createImageWithColor:CCRGBColor(248,92,40)] forState:UIControlStateHighlighted];
    }
    return _loginBtn;
}

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

//监听touch事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [self keyboardHide];
}

-(void)loginAction {
    [self.view endEditing:YES];
    [self keyboardHide];
    if(self.textFieldUserName.text.length > 20) {
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:@"用户名限制在20个字符以内"];
        [self.view addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
        return;
    }
    
    _loadingView = [[LoadingView alloc] initWithLabel:@"正在登录..." centerY:NO];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
    
    PlayParameter *parameter = [[PlayParameter alloc] init];
    parameter.userId = self.textFieldUserId.text;
    parameter.roomId = self.textFieldRoomId.text;
    parameter.viewerName = self.textFieldUserName.text;
    parameter.token = self.textFieldUserPassword.text;
    parameter.security = YES;
    parameter.viewerCustomua = @"viewercustomua";
    RequestData *requestData = [[RequestData alloc] initLoginWithParameter:parameter];
    requestData.delegate = self;
}

-(UILabel *)informationLabel {
    if(_informationLabel == nil) {
        _informationLabel = [UILabel new];
        [_informationLabel setBackgroundColor:CCRGBColor(250, 250, 250)];
        [_informationLabel setFont:[UIFont systemFontOfSize:FontSize_24]];
        [_informationLabel setTextColor:CCRGBColor(102, 102, 102)];
        [_informationLabel setTextAlignment:NSTextAlignmentLeft];
        [_informationLabel setText:@"直播间信息"];
    }
    return _informationLabel;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

-(UIBarButtonItem *)leftBarBtn {
    if(_leftBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_back_nor"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _leftBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSelectVC)];
    }
    return _leftBarBtn;
}

-(UIBarButtonItem *)rightBarBtn {
    if(_rightBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_code"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _rightBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSweepCode)];
    }
    return _rightBarBtn;
}

//扫码
-(void)onSweepCode {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            // 许可对话没有出现，发起授权许可
            WS(ws)
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:2];;
                        [ws.navigationController pushViewController:scanViewController animated:NO];
                    }else{
                        //用户拒绝
                        ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:2];
                        [ws.navigationController pushViewController:scanViewController animated:NO];
                    }
                });
            }];
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

-(TextFieldUserInfo *)textFieldUserId {
    if(_textFieldUserId == nil) {
        _textFieldUserId = [TextFieldUserInfo new];
        [_textFieldUserId textFieldWithLeftText:@"CC账号ID" placeholder:@"16位账号ID" lineLong:YES text:GetFromUserDefaults(WATCH_USERID)];
        _textFieldUserId.delegate = self;
        _textFieldUserId.tag = 1;
        [_textFieldUserId addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserId;
}

-(TextFieldUserInfo *)textFieldRoomId {
    if(_textFieldRoomId == nil) {
        _textFieldRoomId = [TextFieldUserInfo new];
        [_textFieldRoomId textFieldWithLeftText:@"直播间ID" placeholder:@"32位直播间ID" lineLong:NO text:GetFromUserDefaults(WATCH_ROOMID)];
        _textFieldRoomId.delegate = self;
        _textFieldRoomId.tag = 2;
        [_textFieldRoomId addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldRoomId;
}

-(TextFieldUserInfo *)textFieldUserName {
    if(_textFieldUserName == nil) {
        _textFieldUserName = [TextFieldUserInfo new];
        [_textFieldUserName textFieldWithLeftText:@"昵称" placeholder:@"聊天中显示的名字" lineLong:NO text:GetFromUserDefaults(WATCH_USERNAME)];
        _textFieldUserName.delegate = self;
        _textFieldUserName.tag = 3;
        [_textFieldUserName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserName;
}

-(TextFieldUserInfo *)textFieldUserPassword {
    if(_textFieldUserPassword == nil) {
        _textFieldUserPassword = [TextFieldUserInfo new];
        [_textFieldUserPassword textFieldWithLeftText:@"密码" placeholder:@"观看密码" lineLong:NO text:GetFromUserDefaults(WATCH_PASSWORD)];
        _textFieldUserPassword.delegate = self;
        _textFieldUserPassword.tag = 4;
        [_textFieldUserPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _textFieldUserPassword.secureTextEntry = YES;
    }
    return _textFieldUserPassword;
}

-(void)onSelectVC {
    [self.navigationView hideNavigationView];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CCPushDelegate

//@optional
/**
 *	@brief	请求成功
 */
-(void)loginSucceedPlay {
    SaveToUserDefaults(WATCH_USERID,_textFieldUserId.text);
    SaveToUserDefaults(WATCH_ROOMID,_textFieldRoomId.text);
    SaveToUserDefaults(WATCH_USERNAME,_textFieldUserName.text);
    SaveToUserDefaults(WATCH_PASSWORD,_textFieldUserPassword.text);
    
    [_loadingView removeFromSuperview];
    _loadingView = nil;
//    PlayForMobileVC *playForMobileVC = [[PlayForMobileVC alloc] initWithLeftLabelText:_roomName isScreenLandScape:YES];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    PlayForPCVC *playForPCVC = [[PlayForPCVC alloc] initWithLeftLabelText:_roomName];
    [self presentViewController:playForPCVC animated:YES completion:nil];
}

/**
 *	@brief	登录请求失败
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

#pragma mark keyboard notification
- (void)keyboardWillShow:(NSNotification *)notif {
    if(![self.textFieldRoomId isFirstResponder] && ![self.textFieldUserId isFirstResponder] && [self.textFieldUserName isFirstResponder] && ![self.textFieldUserPassword isFirstResponder]) {
        return;
    }
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat y = keyboardRect.size.height;
    CGFloat x = keyboardRect.size.width;
//    NSLog(@"键盘高度是  %d",(int)y);
//    NSLog(@"键盘宽度是  %d",(int)x);
    
    for (int i = 1; i <= 4; i++) {
        UITextField *textField = [self.view viewWithTag:i];
//        NSLog(@"textField = %@,%f,%f",NSStringFromCGRect(textField.frame),CGRectGetMaxY(textField.frame),SCREENH_HEIGHT);
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

-(void)keyboardHide {
    WS(ws)
    [self.informationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));;
        make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        [ws.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [self keyboardHide];
}

-(void)roomInfo:(NSDictionary *)dic {
    _roomName = dic[@"name"];
}

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

@end
