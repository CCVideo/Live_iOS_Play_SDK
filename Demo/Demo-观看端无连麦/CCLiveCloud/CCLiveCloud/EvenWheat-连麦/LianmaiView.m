//
//  LianmaiView.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/12/26.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//
#import "LianmaiView.h"

@interface LianmaiView()

@property(nonatomic,strong)UILabel                  *msgLabel;//消息提示
@property(nonatomic,strong)UIImageView              *icon;//没有网络提示视图
@property(nonatomic,strong)UILabel                  *nonetwork;//没有网络提示文字
@property(nonatomic,strong)UIButton                 *cameraBgView;//摄像头权限按钮
@property(nonatomic,strong)UILabel                  *cameraLabel;//摄像头权限提示文字
@property(nonatomic,strong)UIImageView              *rightIconCamera;//摄像头权限已设置提示视图
@property(nonatomic,strong)UIButton                 *micBgView;//麦克风权限按钮
@property(nonatomic,strong)UILabel                  *micLabel;//麦克风权限提示文字
@property(nonatomic,strong)UIImageView              *rightIconMic;//麦克风权限已设置提示视图
@property(nonatomic,strong)UIView                   *lineView;//分割线

@property (strong,nonatomic)NSTimer                 *connectTimer;//连麦计时器
@property (assign,nonatomic)NSTimeInterval          currenttime;//当前的时间
@property (assign,nonatomic)AVAuthorizationStatus   videoPermission;//视频权限
@property (assign,nonatomic)AVAuthorizationStatus   audioPermission;//音频权限
@property (assign,nonatomic)BOOL                    isVideo;//是否是视频

@property (nonatomic,strong)UIView                  *bgView;//背景视图
@property (nonatomic,strong)UIImageView             *cornerImage;//气泡
@end

@implementation LianmaiView

/**
 视图销毁
 */
-(void)dealloc {
    [self stopConnectTimer];
//    NSLog(@"连麦视图移除");
}
#pragma mark - 公有方法

/**
 初始化方法

 @param videoPermission 视频权限
 @param audioPermission 音频权限
 */
-(void)initUIWithVideoPermission:(AVAuthorizationStatus)videoPermission AudioPermission:(AVAuthorizationStatus)audioPermission {
    
    //初始化函数
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    self.videoPermission = statusVideo;
    self.audioPermission = statusAudio;
    //添加背景视图
    [self addSubview:self.bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-CCGetRealFromPt(15));
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
    //为bgView添加角
    [self addSubview:self.cornerImage];
    [_cornerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_right).offset(-CCGetRealFromPt(2));
        make.top.mas_equalTo(self).offset(CCGetRealFromPt(30));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(17), CCGetRealFromPt(30)));
    }];
    
    //判断是否有权限
    if(videoPermission == AVAuthorizationStatusAuthorized && audioPermission == AVAuthorizationStatusAuthorized) {
        //设置连麦视图
        [self setLianmaiView];
    } else {
        //设置权限视图
        [self setPermissionView];
    }
}

/**
 连接成功
 */
-(void)connectWebRTCSuccess {
    self.cancelLianmainBtn.hidden = YES;
    self.hungupLianmainBtn.hidden = NO;
    self.msgLabel.hidden = NO;
//设置连麦时间戳
    self.currenttime = [[NSDate date] timeIntervalSince1970];
    self.msgLabel.text = LIANMAI_MSGLABEL(self.isVideo);
//    if(self.isVideo) {
//        self.msgLabel.text = @"视频连麦中 00:00";
//    } else {
//        self.msgLabel.text = @"语音连麦中 00:00";
//    }
    [self stopConnectTimer];
    _connectTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timefunc) userInfo:nil repeats:YES];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

/**
 是否正在连接

 @return 是否连接
 */
-(BOOL)isConnecting {
    return [_connectTimer isValid];
}

/**
 停止连接
 */
-(void)stopConnectTimer {
    if([_connectTimer isValid]) {
        [_connectTimer invalidate];
    }
    _connectTimer = nil;
}


/**
 更新连麦时间戳
 */
-(void)timefunc {
    NSInteger value = [[NSDate date] timeIntervalSince1970] - self.currenttime;
    int minutes = (int)value / 60;
    int seconds = (int)value % 60;
    if(self.isVideo) {
        self.msgLabel.text = [NSString stringWithFormat:@"%@ %02d:%02d", LIANMAI_VIDEOCONNECTING,minutes,seconds];
    } else {
        self.msgLabel.text = [NSString stringWithFormat:@"%@ %02d:%02d", LIANMAI_AUDIOCONNECTING,minutes,seconds];
    }
}

/**
 初始化状态
 */
-(void)initialState {
    [self stopConnectTimer];
    self.videoBtn.hidden = NO;
    self.audioBtn.hidden = NO;
    self.msgLabel.hidden = YES;
    self.cancelLianmainBtn.hidden = YES;
    self.hungupLianmainBtn.hidden = YES;
}

/**
 正在连接至RTC
 */
-(void)connectingToRTC {
    self.videoBtn.hidden = YES;
    self.audioBtn.hidden = YES;
    self.msgLabel.hidden = NO;
    self.cancelLianmainBtn.hidden = NO;
    self.hungupLianmainBtn.hidden = YES;
    self.msgLabel.text = LIANMAI_APPLYFOR(self.isVideo);
}

/**
 没有网络
 */
-(void)hasNoNetWork {
    _msgLabel.hidden = YES;
    self.videoBtn.hidden = YES;
    self.audioBtn.hidden = YES;
    _cancelLianmainBtn.hidden = YES;
    _hungupLianmainBtn.hidden = YES;
    _cameraBgView.hidden = YES;
    _micBgView.hidden = YES;
    _cameraLabel.hidden = YES;
    _micLabel.hidden = YES;
    _rightIconCamera.hidden = YES;
    _rightIconMic.hidden = YES;
    self.needToRemoveLianMaiView = YES;
    //添加没有网络图片
    [self addSubview:self.icon];
    [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(CCGetRealFromPt(40));
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(70), CCGetRealFromPt(70)));
    }];
    //添加没有网络提示
    [self addSubview:self.nonetwork];
    [_nonetwork mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(-CCGetRealFromPt(30));
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(CCGetRealFromPt(28));
        make.width.mas_equalTo(self);
    }];
}
#pragma mark - 私有方法

/**
 设置连麦视图
 */
-(void)setLianmaiView{
    //先添加视频连麦和语音连麦两个btn，选中后改变isVideo的值,并且传给控制器,去除请求连麦btn,直接申请中
    WS(ws)
    //添加视频连麦btn
    [self addSubview:self.videoBtn];
    [_videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws);
        make.top.mas_equalTo(ws);
        make.height.mas_equalTo(CCGetRealFromPt(105));
    }];
    [self createImageWithImgName:@"videoType" andTitle:LIANMAI_VIDEO withBtn:_videoBtn];
    
    //添加分割线
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = [UIColor colorWithHexString:@"#dddddd" alpha:1.f];
    [self addSubview:_lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws);
        make.width.mas_equalTo(CCGetRealFromPt(230));
        make.centerY.mas_equalTo(ws);
        make.height.mas_equalTo(CCGetRealFromPt(1));
    }];
    
    //添加语音连麦btn
    [self addSubview:self.audioBtn];
    [_audioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws);
        make.bottom.mas_equalTo(ws);
        make.height.mas_equalTo(CCGetRealFromPt(105));
    }];
    [self createImageWithImgName:@"lianmai_voice" andTitle:LIANMAI_AUDIO withBtn:_audioBtn];
    
    //消息提示label
    [self addSubview:self.msgLabel];
    [_msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws);
        make.height.mas_equalTo(CCGetRealFromPt(28));
        make.top.mas_equalTo(ws).offset(CCGetRealFromPt(40));
        make.width.mas_equalTo(ws);
    }];
    _msgLabel.hidden = YES;
    
    //添加取消连麦btn
    [self addSubview:self.cancelLianmainBtn];
    [_cancelLianmainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws).offset(CCGetRealFromPt(75));
        make.bottom.mas_equalTo(ws).offset(-CCGetRealFromPt(41));
        make.width.mas_equalTo(CCGetRealFromPt(180));
        make.height.mas_equalTo(CCGetRealFromPt(64));
    }];
    self.cancelLianmainBtn.hidden = YES;
    
    //添加挂断连麦btn
    [self addSubview:self.hungupLianmainBtn];
    [_hungupLianmainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.cancelLianmainBtn);
    }];
    self.hungupLianmainBtn.hidden = YES;
}

/**
 设置开启权限视图
 */
-(void)setPermissionView{
    WS(ws)
    //msgLabel
    [self addSubview:self.msgLabel];
    self.msgLabel.text = LIANMAI_PERMISSION;
    [_msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws);
        make.height.mas_equalTo(CCGetRealFromPt(28));
        make.top.mas_equalTo(ws).offset(CCGetRealFromPt(40));
        make.width.mas_equalTo(ws);
    }];
    
    //摄像头权限按钮
    [self addSubview:self.cameraBgView];
    [_cameraBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws).offset(CCGetRealFromPt(30));
        make.top.mas_equalTo(ws).offset(CCGetRealFromPt(98));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(318), CCGetRealFromPt(68)));
    }];
    
    //麦克风权限按钮
    [self addSubview:self.micBgView];
    [_micBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.cameraBgView);
        make.top.mas_equalTo(ws.cameraBgView.mas_bottom).offset(CCGetRealFromPt(10));
        make.size.mas_equalTo(ws.cameraBgView);
    }];
    
    //获取摄像头权限label
    [self.cameraBgView addSubview:self.cameraLabel];
    [_cameraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.cameraBgView).offset(CCGetRealFromPt(29));
        make.centerY.mas_equalTo(ws.cameraBgView);
        make.right.mas_equalTo(ws.cameraBgView);
        make.height.mas_equalTo(CCGetRealFromPt(26));
    }];
    
    //获取麦克风权限label
    [self.micBgView addSubview:self.micLabel];
    [_micLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.micBgView).offset(CCGetRealFromPt(30));
        make.centerY.mas_equalTo(ws.micBgView);
        make.right.mas_equalTo(ws.micBgView);
        make.height.mas_equalTo(CCGetRealFromPt(26));
    }];
    
    //摄像头权限已设置
    [self.cameraBgView addSubview:self.rightIconCamera];
    [_rightIconCamera mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.cameraBgView).offset(-CCGetRealFromPt(28));
        make.centerY.mas_equalTo(ws.cameraBgView);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(32), CCGetRealFromPt(22)));
    }];
    _rightIconCamera.hidden = YES;
    
    //麦克风权限已设置
    [self.micBgView addSubview:self.rightIconMic];
    [_rightIconMic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.micBgView).offset(-CCGetRealFromPt(28));
        make.centerY.mas_equalTo(ws.micBgView);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(32), CCGetRealFromPt(22)));
    }];
    _rightIconMic.hidden = YES;
    //设置视频权限被许可样式
    if(self.videoPermission == AVAuthorizationStatusAuthorized) {
        _rightIconCamera.hidden = NO;
        _cameraLabel.textColor = [UIColor colorWithHexString:@"#ffffff" alpha:0.4];
    }
    //设置音频权限被许可样式
    if(self.audioPermission == AVAuthorizationStatusAuthorized) {
        _rightIconMic.hidden = NO;
        _cameraLabel.textColor = [UIColor colorWithHexString:@"#ffffff" alpha:0.4];
    }
}
#pragma mark - 懒加载
//背景视图
-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor colorWithHexString:@"#ffffff" alpha:1.f];
        _bgView.layer.borderColor = [UIColor colorWithHexString:@"#dddddd" alpha:1.f].CGColor;
        _bgView.layer.borderWidth = CCGetRealFromPt(1);
        _bgView.layer.masksToBounds = YES;
        _bgView.layer.cornerRadius = CCGetRealFromPt(10);
        _bgView.userInteractionEnabled = YES;
    }
    return _bgView;
}
//气泡
-(UIImageView *)cornerImage{
    if (!_cornerImage) {
        _cornerImage = [[UIImageView alloc] init];
        _cornerImage.image = [UIImage imageNamed:@"lianmai_window"];
    }
    return _cornerImage;
}
//音频按钮
-(UIButton *)audioBtn{
    if(!_audioBtn){
        _audioBtn = [[UIButton alloc] init];
        [_audioBtn addTarget:self action:@selector(audioBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _audioBtn;
}
//点击音频按钮
-(void)audioBtnClicked{
    _isVideo = NO;
    _lineView.hidden = YES;
    if(self.delegate) {
        [_delegate requestLianmaiBtnClicked:NO];
    }
}
//点击视频按钮
-(void)videoBtnClicked{
    _isVideo = YES;
    _lineView.hidden = YES;
    if(self.delegate) {
        [_delegate requestLianmaiBtnClicked:YES];
    }
}
//视频连麦
-(UIButton *)videoBtn{
    if(!_videoBtn){
        _videoBtn = [[UIButton alloc] init];
        [_videoBtn addTarget:self action:@selector(videoBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoBtn;
}
//取消申请
-(UIButton *)cancelLianmainBtn {
    if(!_cancelLianmainBtn) {
        _cancelLianmainBtn = [[UIButton alloc] init];
        _cancelLianmainBtn.backgroundColor = [UIColor colorWithHexString:@"#38404b" alpha:1.f];
        
        [_cancelLianmainBtn setTitle:LIANMAI_CANCEL forState:UIControlStateNormal];
        [_cancelLianmainBtn.layer setMasksToBounds:YES];
        [_cancelLianmainBtn.layer setCornerRadius:CCGetRealFromPt(6)];
        [_cancelLianmainBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_30]];
        [_cancelLianmainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelLianmainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_cancelLianmainBtn addTarget:self action:@selector(cancelLianmainBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelLianmainBtn;
}
//点击取消连麦按钮
-(void)cancelLianmainBtnClicked {
    _lineView.hidden = YES;
    if([_delegate respondsToSelector:@selector(cancelLianmainBtnClicked)]) {
        [_delegate cancelLianmainBtnClicked];
    }
}
//挂断连麦
-(UIButton *)hungupLianmainBtn {
    if(!_hungupLianmainBtn) {
        _hungupLianmainBtn = [[UIButton alloc] init];
        _hungupLianmainBtn.backgroundColor = [UIColor colorWithHexString:@"#f55757" alpha:1.f];
        
        [_hungupLianmainBtn setTitle:@"挂断" forState:UIControlStateNormal];
        [_hungupLianmainBtn.layer setMasksToBounds:YES];
        [_hungupLianmainBtn.layer setCornerRadius:CCGetRealFromPt(6)];
        [_hungupLianmainBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_30]];
        [_hungupLianmainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_hungupLianmainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_hungupLianmainBtn addTarget:self action:@selector(hungupLianmainiBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hungupLianmainBtn;
}
//点击挂断连麦按钮
-(void)hungupLianmainiBtnClicked {
    if([_delegate respondsToSelector:@selector(hungupLianmainiBtnClicked)]) {
        [_delegate hungupLianmainiBtnClicked];
    }
}
//提示文字信息
-(UILabel *)msgLabel {
    if(!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.text = LIANMAI_INTERACTION(_isVideo);
        _msgLabel.backgroundColor = CCClearColor;
        _msgLabel.textColor = [UIColor colorWithHexString:@"#38404b" alpha:1.f];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.font = [UIFont systemFontOfSize:FontSize_28];
    }
    return _msgLabel;
}
//没有网络时提示文本
-(UILabel *)nonetwork {
    if(!_nonetwork) {
        _nonetwork = [[UILabel alloc] init];
        _nonetwork.text = LIANMAI_LOSENETWORK;
        _nonetwork.backgroundColor = CCClearColor;
        _nonetwork.textColor = [UIColor colorWithHexString:@"#38404b" alpha:1.f];
        _nonetwork.textAlignment = NSTextAlignmentCenter;
        _nonetwork.font = [UIFont systemFontOfSize:FontSize_28];
    }
    return _nonetwork;
}
//视频权限提示文本
-(UILabel *)cameraLabel {
    if(!_cameraLabel) {
        _cameraLabel = [[UILabel alloc] init];
        _cameraLabel.text = LIANMAI_GETVIDEOPERMISSION;
        _cameraLabel.backgroundColor = CCClearColor;
        _cameraLabel.userInteractionEnabled = NO;
        _cameraLabel.textColor = [UIColor colorWithHexString:@"#ffffff" alpha:1.f];
        _cameraLabel.textAlignment = NSTextAlignmentLeft;
        _cameraLabel.font = [UIFont systemFontOfSize:FontSize_26];
    }
    return _cameraLabel;
}
//麦克风权限提示文本
-(UILabel *)micLabel {
    if(!_micLabel) {
        _micLabel = [[UILabel alloc] init];
        _micLabel.text = LIANMAI_GETVOICEPERMISSION;
        _micLabel.backgroundColor = CCClearColor;
        _micLabel.userInteractionEnabled = NO;
        _micLabel.textColor = [UIColor colorWithHexString:@"#ffffff" alpha:1.f];
        _micLabel.textAlignment = NSTextAlignmentLeft;
        _micLabel.font = [UIFont systemFontOfSize:FontSize_26];
    }
    return _micLabel;
}
//视频权限提示图标
-(UIImageView *)rightIconCamera {
    if(!_rightIconCamera) {
        _rightIconCamera = [[UIImageView alloc] init];
        _rightIconCamera.image = [UIImage imageNamed:@"agreed_right"];
        _rightIconCamera.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _rightIconCamera;
}
//麦克风权限提示视图
-(UIImageView *)rightIconMic {
    if(!_rightIconMic) {
        _rightIconMic = [[UIImageView alloc] init];
        _rightIconMic.image = [UIImage imageNamed:@"agreed_right"];
        _rightIconMic.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _rightIconMic;
}
//没有网络提示视图
-(UIImageView *)icon {
    if(!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
        _icon.image = [UIImage imageNamed:@"network_anomaly"];
        _icon.backgroundColor = CCClearColor;
    }
    return _icon;
}
//摄像头权限按钮
-(UIButton *)cameraBgView {
    if(!_cameraBgView) {
        _cameraBgView = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraBgView.backgroundColor = [UIColor colorWithHexString:@"#38404b" alpha:1.f];
        _cameraBgView.layer.cornerRadius = CCGetRealFromPt(4);
        _cameraBgView.layer.masksToBounds = YES;
        [_cameraBgView addTarget:self action:@selector(cameraBgViewClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraBgView;
}
//点击摄像头权限按钮
-(void)cameraBgViewClicked {
    if(self.videoPermission == AVAuthorizationStatusAuthorized) return;

//    if ([UIDevice currentDevice].systemVersion.floatValue <= 10.0) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=com.cc.NewCCDemo&path=CAMERA"]];
//    }else{
        // iOS10 之后, 比较特殊, 只能跳转到设置界面 , UIApplicationOpenSettingsURLString这个只支持iOS8之后.
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            // 还可以跳过success这个bool值进行更加精确的判断.
            //NSLog(@"跳转成功回调");
        }];
    } else {
        // Fallback on earlier versions
    }
//    }
}
//麦克风权限按钮
-(UIButton *)micBgView {
    if(!_micBgView) {
        _micBgView = [UIButton buttonWithType:UIButtonTypeCustom];
        _micBgView.backgroundColor = [UIColor colorWithHexString:@"#38404b" alpha:1.f];
        _micBgView.layer.cornerRadius = CCGetRealFromPt(4);
        _micBgView.layer.masksToBounds = YES;
        [_micBgView addTarget:self action:@selector(micBgViewClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _micBgView;
}
//点击麦克风权限按钮
-(void)micBgViewClicked {
    if(self.audioPermission == AVAuthorizationStatusAuthorized) return;
//    if ([UIDevice currentDevice].systemVersion.floatValue <= 10.0) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=com.cc.NewCCDemo&path=MICROPHONE"]];
//    }else{
        // iOS10 之后, 比较特殊, 只能跳转到设置界面 , UIApplicationOpenSettingsURLString这个只支持iOS8之后.
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            // 还可以跳过success这个bool值进行更加精确的判断.
            //NSLog(@"跳转成功回调");
        }];
    } else {
        // Fallback on earlier versions
    }
//    }
}
#pragma mark - 为btn添加图片和文字

/**
 为一个btn添加指定图片和文字

 @param imgName 图片名称
 @param title 提示文字
 @param btn btn
 */
-(void)createImageWithImgName:(NSString *)imgName andTitle:(NSString *)title withBtn:(UIButton *)btn{
    UIImageView *imgView = [[UIImageView alloc] init];
    [imgView setImage:[UIImage imageNamed:imgName]];
    [btn addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(btn).offset(CCGetRealFromPt(63));
        make.top.mas_equalTo(btn).offset(CCGetRealFromPt(40));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(40), CCGetRealFromPt(40)));
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:FontSize_30];
    label.textColor = [UIColor colorWithHexString:@"#38404b" alpha:1.f];
    label.text = title;
    [btn addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(btn).offset(CCGetRealFromPt(133));
        make.top.mas_equalTo(btn).offset(CCGetRealFromPt(45));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(160), CCGetRealFromPt(30)));
    }];
}

@end
