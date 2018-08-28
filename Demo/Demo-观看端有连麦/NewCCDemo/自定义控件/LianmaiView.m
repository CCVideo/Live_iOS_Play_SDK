//
//  LianmaiView.m
//  NewCCDemo
//
//  Created by cc on 2017/1/5.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "LianmaiView.h"

@interface LianmaiView()

@property(nonatomic,strong)UILabel                  *msgLabel;
@property(nonatomic,strong)UIImageView              *icon;
@property(nonatomic,strong)UIButton                 *cameraBgView;
@property(nonatomic,strong)UIButton                 *micBgView;
@property(nonatomic,strong)UILabel                  *cameraLabel;
@property(nonatomic,strong)UILabel                  *micLabel;
@property(nonatomic,strong)UIImageView              *rightIconCamera;
@property(nonatomic,strong)UIImageView              *rightIconMic;
@property(nonatomic,strong)UILabel                  *nonetwork;

@property (strong,nonatomic)NSTimer                 *connectTimer;
@property (assign,nonatomic)NSTimeInterval          currenttime;
@property (assign,nonatomic)AVAuthorizationStatus   videoPermission;
@property (assign,nonatomic)AVAuthorizationStatus   audioPermission;
@property (assign,nonatomic)BOOL                    isVideo;

@end

@implementation LianmaiView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithVideo:(BOOL)isVideo {
    self = [super init];
    if(self) {
        self.isVideo = isVideo;
        self.needToRemoveLianMaiView = NO;
        self.backgroundColor = CCRGBAColor(0,0,0,0.6);
    }
    return self;
}

-(void)dealloc {
    [self stopConnectTimer];
}

-(void)connectWebRTCSuccess {
    self.requestLianmaiBtn.hidden = YES;
    self.cancelLianmainBtn.hidden = YES;
    self.hungupLianmainBtn.hidden = NO;

    self.currenttime = [[NSDate date] timeIntervalSince1970];
    if(self.isVideo) {
        self.msgLabel.text = @"视频连麦中 00:00";
    } else {
        self.msgLabel.text = @"语音连麦中 00:00";
    }
    [self stopConnectTimer];
    _connectTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timefunc) userInfo:nil repeats:YES];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

-(BOOL)isConnecting {
    return [_connectTimer isValid];
}

-(void)stopConnectTimer {
    if([_connectTimer isValid]) {
        [_connectTimer invalidate];
    }
    _connectTimer = nil;
}

-(void)timefunc {
    NSInteger value = [[NSDate date] timeIntervalSince1970] - self.currenttime;
    int minutes = (int)value / 60;
    int seconds = (int)value % 60;
    if(self.isVideo) {
        self.msgLabel.text = [NSString stringWithFormat:@"视频连麦中 %02d:%02d",minutes,seconds];
    } else {
        self.msgLabel.text = [NSString stringWithFormat:@"语音连麦中 %02d:%02d",minutes,seconds];
    }
}

-(void)initUIWithVideoPermission:(AVAuthorizationStatus)videoPermission AudioPermission:(AVAuthorizationStatus)audioPermission {
    WS(ws)
    self.videoPermission = videoPermission;
    self.audioPermission = audioPermission;
    
    if(videoPermission == AVAuthorizationStatusAuthorized && audioPermission == AVAuthorizationStatusAuthorized) {
//    if(1) {
        [self addSubview:self.msgLabel];
        [_msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ws);
            make.height.mas_equalTo(CCGetRealFromPt(28));
            make.top.mas_equalTo(ws).offset(CCGetRealFromPt(40));
            make.width.mas_equalTo(ws);
        }];
        
        [self addSubview:self.requestLianmaiBtn];
        [_requestLianmaiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ws);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(180), CCGetRealFromPt(64)));
            make.bottom.mas_equalTo(ws).offset(-CCGetRealFromPt(40));
        }];
        
        [self addSubview:self.cancelLianmainBtn];
        [_cancelLianmainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.requestLianmaiBtn);
        }];
        self.cancelLianmainBtn.hidden = YES;

        [self addSubview:self.hungupLianmainBtn];
        [_hungupLianmainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.cancelLianmainBtn);
        }];
        self.hungupLianmainBtn.hidden = YES;
    } else {
        [self addSubview:self.msgLabel];
        self.msgLabel.text = @"连麦需要允许以下权限：";
        [_msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ws);
            make.height.mas_equalTo(CCGetRealFromPt(28));
            make.top.mas_equalTo(ws).offset(CCGetRealFromPt(40));
            make.width.mas_equalTo(ws);
        }];
        
        [self addSubview:self.cameraBgView];
        [_cameraBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws).offset(CCGetRealFromPt(30));
            make.top.mas_equalTo(ws.msgLabel.mas_bottom).offset(CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(318), CCGetRealFromPt(68)));
        }];
        
        [self addSubview:self.micBgView];
        [_micBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.cameraBgView);
            make.top.mas_equalTo(ws.cameraBgView.mas_bottom).offset(CCGetRealFromPt(10));
            make.size.mas_equalTo(ws.cameraBgView);
        }];
        
        [self.cameraBgView addSubview:self.cameraLabel];
        [_cameraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.cameraBgView).offset(CCGetRealFromPt(30));
            make.centerY.mas_equalTo(ws.cameraBgView);
            make.right.mas_equalTo(ws.cameraBgView);
            make.height.mas_equalTo(CCGetRealFromPt(26));
        }];
        
        [self.micBgView addSubview:self.micLabel];
        [_micLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.micBgView).offset(CCGetRealFromPt(30));
            make.centerY.mas_equalTo(ws.micBgView);
            make.right.mas_equalTo(ws.micBgView);
            make.height.mas_equalTo(CCGetRealFromPt(26));
        }];
        
        [self.cameraBgView addSubview:self.rightIconCamera];
        [_rightIconCamera mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.cameraBgView).offset(-CCGetRealFromPt(28));
            make.centerY.mas_equalTo(ws.cameraBgView);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(32), CCGetRealFromPt(22)));
        }];
        _rightIconCamera.hidden = YES;
        
        [self.micBgView addSubview:self.rightIconMic];
        [_rightIconMic mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.micBgView).offset(-CCGetRealFromPt(28));
            make.centerY.mas_equalTo(ws.micBgView);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(32), CCGetRealFromPt(22)));
        }];
        _rightIconMic.hidden = YES;
        
        if(videoPermission == AVAuthorizationStatusAuthorized) {
            _rightIconCamera.hidden = NO;
            _cameraLabel.textColor = CCRGBAColor(255, 255, 255, 0.4);
        }
        
        if(audioPermission == AVAuthorizationStatusAuthorized) {
            _rightIconMic.hidden = NO;
            _micLabel.textColor = CCRGBAColor(255, 255, 255, 0.4);
        }
    }
}

-(void)initialState {
    [self stopConnectTimer];
    self.requestLianmaiBtn.hidden = NO;
    self.cancelLianmainBtn.hidden = YES;
    self.hungupLianmainBtn.hidden = YES;
    if(self.isVideo) {
        self.msgLabel.text = @"与主播视频互动";
    } else {
        self.msgLabel.text = @"与主播语音互动";
    }
}

-(void)connectingToRTC {
    self.requestLianmaiBtn.hidden = YES;
    self.cancelLianmainBtn.hidden = NO;
    self.hungupLianmainBtn.hidden = YES;
    if(self.isVideo) {
        self.msgLabel.text = @"已申请与主播视频互动";
    } else {
        self.msgLabel.text = @"已申请与主播语音互动";
    }
}

-(void)hasNoNetWork {
    _msgLabel.hidden = YES;
    _requestLianmaiBtn.hidden = YES;
    _cancelLianmainBtn.hidden = YES;
    _hungupLianmainBtn.hidden = YES;
    _cameraBgView.hidden = YES;
    _micBgView.hidden = YES;
    _cameraLabel.hidden = YES;
    _micLabel.hidden = YES;
    _rightIconCamera.hidden = YES;
    _rightIconMic.hidden = YES;
    self.needToRemoveLianMaiView = YES;
    WS(ws)
    [self addSubview:self.icon];
    [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws).offset(CCGetRealFromPt(40));
        make.centerX.mas_equalTo(ws);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(70), CCGetRealFromPt(70)));
    }];
    
    [self addSubview:self.nonetwork];
    [_nonetwork mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(ws).offset(-CCGetRealFromPt(30));
        make.centerX.mas_equalTo(ws);
        make.height.mas_equalTo(CCGetRealFromPt(28));
        make.width.mas_equalTo(ws);
    }];
}

-(UIButton *)requestLianmaiBtn {
    if(!_requestLianmaiBtn) {
        _requestLianmaiBtn = [UIButton new];
        _requestLianmaiBtn.backgroundColor = CCRGBColor(255,102,51);

        [_requestLianmaiBtn setTitle:@"申请连麦" forState:UIControlStateNormal];
        [_requestLianmaiBtn.layer setMasksToBounds:YES];
        [_requestLianmaiBtn.layer setCornerRadius:CCGetRealFromPt(6)];
        [_requestLianmaiBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_30]];
        [_requestLianmaiBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_requestLianmaiBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_requestLianmaiBtn addTarget:self action:@selector(requestLianmaiBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _requestLianmaiBtn;
}

-(void)requestLianmaiBtnClicked {
    if([_delegate respondsToSelector:@selector(requestLianmaiBtnClicked)]) {
        [_delegate requestLianmaiBtnClicked];
    }
}

-(UIButton *)cancelLianmainBtn {
    if(!_cancelLianmainBtn) {
        _cancelLianmainBtn = [UIButton new];
        _cancelLianmainBtn.backgroundColor = CCRGBColor(255,102,51);
        
        [_cancelLianmainBtn setTitle:@"取消申请" forState:UIControlStateNormal];
        [_cancelLianmainBtn.layer setMasksToBounds:YES];
        [_cancelLianmainBtn.layer setCornerRadius:CCGetRealFromPt(6)];
        [_cancelLianmainBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_30]];
        [_cancelLianmainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelLianmainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_cancelLianmainBtn addTarget:self action:@selector(cancelLianmainBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelLianmainBtn;
}

-(void)cancelLianmainBtnClicked {
    if([_delegate respondsToSelector:@selector(cancelLianmainBtnClicked)]) {
        [_delegate cancelLianmainBtnClicked];
    }
}

-(UIButton *)hungupLianmainBtn {
    if(!_hungupLianmainBtn) {
        _hungupLianmainBtn = [UIButton new];
        _hungupLianmainBtn.backgroundColor = CCRGBColor(255,102,51);
        
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

-(void)hungupLianmainiBtnClicked {
    if([_delegate respondsToSelector:@selector(hungupLianmainiBtnClicked)]) {
        [_delegate hungupLianmainiBtnClicked];
    }
}

-(UILabel *)msgLabel {
    if(!_msgLabel) {
        _msgLabel = [UILabel new];
        if(_isVideo) {
            _msgLabel.text = @"与主播视频互动";
        } else {
            _msgLabel.text = @"与主播语音互动";
        }
        _msgLabel.backgroundColor = CCClearColor;
        _msgLabel.textColor = [UIColor whiteColor];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.font = [UIFont systemFontOfSize:FontSize_28];
    }
    return _msgLabel;
}

-(UILabel *)nonetwork {
    if(!_nonetwork) {
        _nonetwork = [UILabel new];
        _nonetwork.text = @"网络异常，连麦失败";
        _nonetwork.backgroundColor = CCClearColor;
        _nonetwork.textColor = [UIColor whiteColor];
        _nonetwork.textAlignment = NSTextAlignmentCenter;
        _nonetwork.font = [UIFont systemFontOfSize:FontSize_28];
    }
    return _nonetwork;
}

-(UILabel *)cameraLabel {
    if(!_cameraLabel) {
        _cameraLabel = [UILabel new];
        _cameraLabel.text = @"获取摄像头权限";
        _cameraLabel.backgroundColor = CCClearColor;
        _cameraLabel.userInteractionEnabled = NO;
        _cameraLabel.textColor = [UIColor whiteColor];
        _cameraLabel.textAlignment = NSTextAlignmentLeft;
        _cameraLabel.font = [UIFont systemFontOfSize:FontSize_26];
    }
    return _cameraLabel;
}

-(UILabel *)micLabel {
    if(!_micLabel) {
        _micLabel = [UILabel new];
        _micLabel.text = @"获取麦克风权限";
        _micLabel.backgroundColor = CCClearColor;
        _micLabel.userInteractionEnabled = NO;
        _micLabel.textColor = [UIColor whiteColor];
        _micLabel.textAlignment = NSTextAlignmentLeft;
        _micLabel.font = [UIFont systemFontOfSize:FontSize_26];
    }
    return _micLabel;
}

-(UIImageView *)rightIconCamera {
    if(!_rightIconCamera) {
        _rightIconCamera = [UIImageView new];
        _rightIconCamera.image = [UIImage imageNamed:@"qs_right_different"];
        _rightIconCamera.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _rightIconCamera;
}

-(UIImageView *)rightIconMic {
    if(!_rightIconMic) {
        _rightIconMic = [UIImageView new];
        _rightIconMic.image = [UIImage imageNamed:@"qs_right_different"];
        _rightIconMic.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _rightIconMic;
}

-(UIImageView *)icon {
    if(!_icon) {
        _icon = [UIImageView new];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
        _icon.image = [UIImage imageNamed:@"tips_pic_nonet"];
        _icon.backgroundColor = CCClearColor;
    }
    return _icon;
}

-(UIButton *)cameraBgView {
    if(!_cameraBgView) {
        _cameraBgView = [UIButton new];
        _cameraBgView.backgroundColor = CCRGBAColor(0,0,0,0.6);
        [_cameraBgView addTarget:self action:@selector(cameraBgViewClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraBgView;
}

-(void)cameraBgViewClicked {
    if(self.videoPermission == AVAuthorizationStatusAuthorized) return;
    
    if ([UIDevice currentDevice].systemVersion.floatValue <= 10.0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=com.cc.NewCCDemo&path=CAMERA"]];
    }else{
        // iOS10 之后, 比较特殊, 只能跳转到设置界面 , UIApplicationOpenSettingsURLString这个只支持iOS8之后.
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            // 还可以跳过success这个bool值进行更加精确的判断.
            //NSLog(@"跳转成功回调");
        }];
    }
}

-(UIButton *)micBgView {
    if(!_micBgView) {
        _micBgView = [UIButton new];
        _micBgView.backgroundColor = CCRGBAColor(0,0,0,0.6);
        [_micBgView addTarget:self action:@selector(micBgViewClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _micBgView;
}

-(void)micBgViewClicked {
    if(self.audioPermission == AVAuthorizationStatusAuthorized) return;
//    if ([UIDevice currentDevice].systemVersion.floatValue <= 10.0) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=com.cc.NewCCDemo&path=MICROPHONE"]];
//    }else{
        // iOS10 之后, 比较特殊, 只能跳转到设置界面 , UIApplicationOpenSettingsURLString这个只支持iOS8之后.
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            // 还可以跳过success这个bool值进行更加精确的判断.
            //NSLog(@"跳转成功回调");
        }];
//    }
}

@end
