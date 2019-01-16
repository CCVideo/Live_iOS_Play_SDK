//
//  CCPalyBackLoginController.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/29.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCPalyBackLoginController.h"
#import "TextFieldUserInfo.h"
#import <AVFoundation/AVFoundation.h>
#import "ScanViewController.h"
#import "CCSDK/CCLiveUtil.h"
#import "CCSDK/RequestDataPlayBack.h"
#import "InformationShowView.h"
#import "LoadingView.h"
#import "CCPlayBackController.h"

@interface CCPalyBackLoginController ()<UITextFieldDelegate,RequestDataPlayBackDelegate>

@property(nonatomic,strong)UILabel                      * informationLabel;//直播间信息
@property(nonatomic,strong)UIButton                     * loginBtn;//登录
@property(nonatomic,strong)LoadingView                  * loadingView;//加载视图
@property(nonatomic,strong)UIBarButtonItem              * leftBarBtn;//返回按钮
@property(nonatomic,strong)UIBarButtonItem              * rightBarBtn;//扫码
@property(nonatomic,strong)TextFieldUserInfo            * textFieldUserId;//UserId
@property(nonatomic,strong)TextFieldUserInfo            * textFieldRoomId;//RoomId
@property(nonatomic,strong)TextFieldUserInfo            * textFieldLiveId;//LiveId
@property(nonatomic,strong)TextFieldUserInfo            * textFieldRecordId;//RecordId
@property(nonatomic,strong)TextFieldUserInfo            * textFieldUserName;//用户名
@property(nonatomic,strong)TextFieldUserInfo            * textFieldUserPassword;//密码
@property(nonatomic,strong)InformationShowView          * informationView;//提示窗

@end

@implementation CCPalyBackLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];//创建UI
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5" alpha:1.0f];
    self.navigationItem.leftBarButtonItem=self.leftBarBtn;
    self.navigationItem.rightBarButtonItem=self.rightBarBtn;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"38404b" alpha:1.0f],NSForegroundColorAttributeName,[UIFont systemFontOfSize:FontSize_34],NSFontAttributeName,nil]];
    [self.navigationController.navigationBar setBackgroundImage:
     [self createImageWithColor:CCRGBColor(255,255,255)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.textFieldUserId.text = GetFromUserDefaults(PLAYBACK_USERID);
    self.textFieldRoomId.text = GetFromUserDefaults(PLAYBACK_ROOMID);
    self.textFieldLiveId.text = GetFromUserDefaults(PLAYBACK_LIVEID);
    self.textFieldRecordId.text = GetFromUserDefaults(PLAYBACK_RECORDID);
    self.textFieldUserName.text = GetFromUserDefaults(PLAYBACK_USERNAME);
    self.textFieldUserPassword.text = GetFromUserDefaults(PLAYBACK_PASSWORD);
    
    if(StrNotEmpty(_textFieldUserId.text) && StrNotEmpty(_textFieldRoomId.text) && StrNotEmpty(_textFieldUserName.text) && StrNotEmpty(_textFieldLiveId.text)) {
        self.loginBtn.enabled = YES;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
    } else {
        self.loginBtn.enabled = NO;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
    }
}

#pragma mark- 必须实现的代理方法RequestDataPlayBackDelegate
/**
 *    @brief    请求成功
 */
-(void)loginSucceedPlayBack {
    SaveToUserDefaults(PLAYBACK_USERID,_textFieldUserId.text);
    SaveToUserDefaults(PLAYBACK_ROOMID,_textFieldRoomId.text);
    SaveToUserDefaults(PLAYBACK_LIVEID,_textFieldLiveId.text);
    SaveToUserDefaults(PLAYBACK_RECORDID,_textFieldRecordId.text);
    SaveToUserDefaults(PLAYBACK_USERNAME,_textFieldUserName.text);
    SaveToUserDefaults(PLAYBACK_PASSWORD,_textFieldUserPassword.text);
    [_loadingView removeFromSuperview];
    _loadingView = nil;
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    CCPlayBackController *playBackVC = [[CCPlayBackController alloc] init];
    [self presentViewController:playBackVC animated:YES completion:nil];
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
    
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(informationViewRemove) userInfo:nil repeats:NO];
}

/**
 点击登录
 */
-(void)loginAction {
    [self.view endEditing:YES];
    [self keyboardHide];
    if(self.textFieldUserName.text.length > 20) {
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:USERNAME_CONFINE];
        [self.view addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(informationViewRemove) userInfo:nil repeats:NO];
        return;
    }
    _loadingView = [[LoadingView alloc] initWithLabel:@"正在登录" centerY:NO];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
    PlayParameter *parameter = [[PlayParameter alloc] init];
    parameter.userId = self.textFieldUserId.text;
    parameter.roomId = self.textFieldRoomId.text;
    parameter.liveId = self.textFieldLiveId.text;
    parameter.recordId = self.textFieldRecordId.text;
    parameter.viewerName = self.textFieldUserName.text;
    parameter.token = self.textFieldUserPassword.text;
    parameter.security = NO;
    RequestDataPlayBack *requestDataPlayBack = [[RequestDataPlayBack alloc] initLoginWithParameter:parameter];
    requestDataPlayBack.delegate = self;
}

-(void)informationViewRemove {
    [_informationView removeFromSuperview];
    _informationView = nil;
}

#pragma mark UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidChange:(UITextField *) TextField {
    if(StrNotEmpty(_textFieldUserId.text) && StrNotEmpty(_textFieldRoomId.text) && StrNotEmpty(_textFieldUserName.text) && StrNotEmpty(_textFieldLiveId.text)) {
        self.loginBtn.enabled = YES;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
    } else {
        self.loginBtn.enabled = NO;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
    }
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
//监听touch事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [self keyboardHide];
}
-(void)userNameTextFieldChange {
    if(_textFieldUserName.text.length > 20) {
        _textFieldUserName.text = [_textFieldUserName.text substringToIndex:20];
    }
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
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:3];;
                        [self.navigationController pushViewController:scanViewController animated:NO];
                    }else{
                        //用户拒绝
                        ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:3];
                        [self.navigationController pushViewController:scanViewController animated:NO];
                    }
                });
            }];
        }
            break;
        case AVAuthorizationStatusAuthorized:{
            // 已经开启授权，可继续
            ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:3];
            [self.navigationController pushViewController:scanViewController animated:NO];
        }
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            // 用户明确地拒绝授权，或者相机设备无法访问
            ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:3];
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
        _textFieldUserId.delegate = self;
        [_textFieldUserId textFieldWithLeftText:@"CC账号ID" placeholder:@"16位账号ID" lineLong:YES text:GetFromUserDefaults(PLAYBACK_USERID)];
        _textFieldUserId.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldUserId.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldUserId addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserId;
}

-(TextFieldUserInfo *)textFieldRoomId {
    if(_textFieldRoomId == nil) {
        _textFieldRoomId = [TextFieldUserInfo new];
        _textFieldRoomId.delegate = self;
        [_textFieldRoomId textFieldWithLeftText:@"直播间ID" placeholder:@"32位直播间ID" lineLong:NO text:GetFromUserDefaults(PLAYBACK_ROOMID)];
        _textFieldRoomId.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldRoomId.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldRoomId addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldRoomId;
}

-(TextFieldUserInfo *)textFieldLiveId {
    if(_textFieldLiveId == nil) {
        _textFieldLiveId = [TextFieldUserInfo new];
        _textFieldLiveId.delegate = self;
        [_textFieldLiveId textFieldWithLeftText:@"直播ID" placeholder:@"16位直播ID" lineLong:NO text:GetFromUserDefaults(PLAYBACK_LIVEID)];
        _textFieldLiveId.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldLiveId.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldLiveId addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldLiveId;
}

-(TextFieldUserInfo *)textFieldRecordId {
    if(_textFieldRecordId == nil) {
        _textFieldRecordId = [TextFieldUserInfo new];
        _textFieldRecordId.delegate = self;
        [_textFieldRecordId textFieldWithLeftText:@"回放ID" placeholder:@"16位回放ID" lineLong:NO text:GetFromUserDefaults(PLAYBACK_RECORDID)];
        _textFieldRecordId.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldRecordId.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldRecordId addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldRecordId;
}

-(TextFieldUserInfo *)textFieldUserName {
    if(_textFieldUserName == nil) {
        _textFieldUserName = [TextFieldUserInfo new];
        _textFieldUserName.delegate = self;
        [_textFieldUserName textFieldWithLeftText:@"昵称" placeholder:@"聊天中显示的名字" lineLong:NO text:GetFromUserDefaults(PLAYBACK_USERNAME)];
        _textFieldUserName.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldUserName.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldUserName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserName;
}

-(TextFieldUserInfo *)textFieldUserPassword {
    if(_textFieldUserPassword == nil) {
        _textFieldUserPassword = [TextFieldUserInfo new];
        _textFieldUserPassword.delegate = self;
        [_textFieldUserPassword textFieldWithLeftText:@"密码" placeholder:@"观看密码" lineLong:NO text:GetFromUserDefaults(PLAYBACK_PASSWORD)];
        _textFieldUserPassword.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldUserPassword.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldUserPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _textFieldUserPassword.secureTextEntry = YES;
    }
    return _textFieldUserPassword;
}
//test groupId
//-(TextFieldUserInfo *)groupId {
//    if(_groupId == nil) {
//        _groupId = [TextFieldUserInfo new];
//        [_groupId textFieldWithLeftText:@"groupId" placeholder:@"groupId" lineLong:NO text:GetFromUserDefaults(@"groupId")];
//        _groupId.delegate = self;
//        _groupId.tag = 5;
//        _groupId.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
//        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
//        _groupId.rightViewMode = UITextFieldViewModeAlways;
//    }
//    return _groupId;
//}
//-------------------------------------------
-(void)onSelectVC {
    [self.navigationController popToRootViewControllerAnimated:YES];
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

#pragma mark keyboard notification
- (void)keyboardWillShow:(NSNotification *)notif {
    if(![self.textFieldRoomId isFirstResponder] && ![self.textFieldUserId isFirstResponder] && [self.textFieldUserName isFirstResponder] && ![self.textFieldUserPassword isFirstResponder] && ![self.textFieldLiveId isFirstResponder] && ![self.textFieldRecordId isFirstResponder]) {
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
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        [ws.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [self keyboardHide];
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

- (void)setupUI {
    self.title = @"观看回放";
    
    [self.view addSubview:self.informationLabel];
    
    [_informationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).with.offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(self.view).with.offset(CCGetRealFromPt(30));
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];
    [self.view addSubview:self.textFieldUserId];
    [self.view addSubview:self.textFieldRoomId];
    [self.view addSubview:self.textFieldLiveId];
    [self.view addSubview:self.textFieldRecordId];
    [self.view addSubview:self.textFieldUserName];
    [self.view addSubview:self.textFieldUserPassword];
    //test   groupId
//    [self.view addSubview:self.groupId];
    
    [self.textFieldUserName addTarget:self action:@selector(userNameTextFieldChange) forControlEvents:UIControlEventEditingChanged];
    
    [self.textFieldUserId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.informationLabel.mas_bottom).with.offset(CCGetRealFromPt(22));
        make.height.mas_equalTo(CCGetRealFromPt(92));
    }];
    
    [self.textFieldRoomId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.textFieldUserId);
        make.top.mas_equalTo(self.textFieldUserId.mas_bottom);
        make.height.mas_equalTo(self.textFieldUserId.mas_height);
    }];
    
    [self.textFieldLiveId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.textFieldUserId);
        make.top.mas_equalTo(self.textFieldRoomId.mas_bottom);
        make.height.mas_equalTo(self.textFieldUserId.mas_height);
    }];
    
    [self.textFieldRecordId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.textFieldUserId);
        make.top.mas_equalTo(self.textFieldLiveId.mas_bottom);
        make.height.mas_equalTo(self.textFieldUserId.mas_height);
    }];
    
    [self.textFieldUserName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.textFieldUserId);
        make.top.mas_equalTo(self.textFieldRecordId.mas_bottom);
        make.height.mas_equalTo(self.textFieldUserId.mas_height);
    }];
    
    [self.textFieldUserPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.textFieldUserId);
        make.top.mas_equalTo(self.textFieldUserName.mas_bottom);
        make.height.mas_equalTo(self.textFieldUserId);
    }];
    //test   groupId
//    [self.groupId mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.mas_equalTo(self.textFieldUserId);
//        make.top.mas_equalTo(self.textFieldUserPassword.mas_bottom);
//        make.height.mas_equalTo(self.textFieldUserName);
//    }];
    
    UIView *line = [UIView new];
    [self.view addSubview:line];
    [line setBackgroundColor:CCRGBColor(238,238,238)];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.textFieldUserPassword.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    [self.view addSubview:self.loginBtn];
    [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line.mas_bottom).with.offset(CCGetRealFromPt(80));
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(300);
    }];

    [self addObserver];
}

-(UIButton *)loginBtn {
    if(_loginBtn == nil) {
        _loginBtn = [[UIButton alloc] init];
        [_loginBtn setTitle:@"登 录" forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_36]];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"default_btn"] forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage: [UIImage imageNamed:@"default_btn"] forState:UIControlStateHighlighted];
        _loginBtn.layer.cornerRadius = 25;
        [_loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        [_loginBtn.layer setMasksToBounds:YES];
    }
    return _loginBtn;
}

@end
