//
//  PlayForPCVC.m
//  NewCCDemo
//
//  Created by cc on 2016/12/27.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "OfflinePlayBackVC.h"
#import "CCPublicTableViewCell.h"
#import "Dialogue.h"
#import "ModelView.h"
#import "CCSDK/OfflinePlayBack.h"
#import "LoadingView.h"
#import "InformationShowView.h"
#import "Utility.h"
#import "ChatView.h"
#import "QuestionView.h"
#import "Dialogue.h"
#import <AVFoundation/AVFoundation.h>
#import "MySlider.h"
#import "ChatView.h"
#import "QuestionView.h"

@interface OfflinePlayBackVC ()<OfflinePlayBackDelegate,UIScrollViewDelegate>
/*
 * 是否横屏模式
 */
@property(nonatomic,assign)Boolean                  isScreenLandScape;
@property(nonatomic,strong)UIButton                 *leftButton;
@property(nonatomic,strong)UILabel                  *leftLabel;
@property(nonatomic,copy) NSString                  *leftLabelText;
@property(nonatomic,assign)CGRect                   videoRect;
@property(nonatomic,strong)ModelView                *modelView;
@property(nonatomic,strong)UIView                   *modeoCenterView;
@property(nonatomic,strong)UILabel                  *modeoCenterLabel;
@property(nonatomic,strong)UIButton                 *cancelBtn;
@property(nonatomic,strong)UIButton                 *sureBtn;
@property(nonatomic,strong)NSTimer                  *timer;
@property(nonatomic,strong)NSTimer                  *hiddenTimer;
@property(nonatomic,assign)NSTimeInterval           hiddenTime;
@property(nonatomic,strong)OfflinePlayBack          *offlinePlayBack;
@property(nonatomic,strong)LoadingView              *loadingView;
@property(nonatomic,strong)UIView                   *videoView;
@property(nonatomic,strong)UIView                   *barView;
@property(nonatomic,strong)UIButton                 *quanPingBtn;
@property(nonatomic,strong)UIButton                 *playbackRateBtn;
@property(nonatomic,strong)UIScrollView             *scrollView;
@property(nonatomic,strong)UISegmentedControl       *segment;
@property(nonatomic,strong)UIView                   *shadowView;
@property(nonatomic,strong)UIView                   *pptView;
@property(nonatomic,strong)ChatView                 *chatView;
@property(nonatomic,strong)QuestionView             *questionChatView;
@property(nonatomic,strong)UIImageView              *huifangDot;
@property(nonatomic,copy)  NSString                 *roomName;
@property(nonatomic,strong)NSMutableDictionary      *QADic;
@property(nonatomic,strong)NSMutableArray           *keysArr;
@property(nonatomic,strong)NSMutableArray           *publicChatArray;

@property(nonatomic,strong)UIButton                 *suspendButton;
@property(nonatomic,strong)UILabel                  *leftTimeLabel;
@property(nonatomic,strong)UILabel                  *rightTimeLabel;
@property(nonatomic,strong)MySlider                 *slider;

@property(nonatomic,assign)NSInteger                templateType;
@property(nonatomic,  copy)NSString                 *destination;
@property(nonatomic,assign)NSInteger                sliderValue;
@property(nonatomic,assign)BOOL                     autoRotate;
//@property(nonatomic,strong)UILabel                  *playRateLabel;
@property(nonatomic,assign)float                    playBackRate;

@property(assign,nonatomic)int                      currentChatTime;
@property(assign,nonatomic)int                      currentChatIndex;

@end

@implementation OfflinePlayBackVC

-(instancetype)initWithDestination:(NSString *)destination {
    self = [super init];
    if (self) {
        self.destination = destination;
    }
    return self;
}

-(UILabel *)leftTimeLabel {
    if(!_leftTimeLabel) {
        _leftTimeLabel = [UILabel new];
        _leftTimeLabel.text = @"00:00";
        _leftTimeLabel.userInteractionEnabled = NO;
        _leftTimeLabel.textColor = [UIColor whiteColor];
        _leftTimeLabel.font = [UIFont systemFontOfSize:FontSize_24];
        _leftTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _leftTimeLabel;
}

-(UILabel *)rightTimeLabel {
    if(!_rightTimeLabel) {
        _rightTimeLabel = [UILabel new];
        _rightTimeLabel.text = @"--:--";
        _rightTimeLabel.userInteractionEnabled = NO;
        _rightTimeLabel.textColor = [UIColor whiteColor];
        _rightTimeLabel.font = [UIFont systemFontOfSize:FontSize_24];
        _rightTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _rightTimeLabel;
}

-(UISlider *)slider {
    if(!_slider) {
    _slider = [MySlider new];
    //设置滑动条最大值
    _slider.maximumValue=0;
    //设置滑动条的最小值，可以为负值
    _slider.minimumValue=0;
    //设置滑动条的滑块位置float值
    _slider.value=[GetFromUserDefaults(SET_BITRATE) integerValue];
    //左侧滑条背景颜色
    _slider.minimumTrackTintColor = CCRGBColor(255,102,51);
    //右侧滑条背景颜色
    _slider.maximumTrackTintColor = CCRGBColor(153, 153, 153);
    //设置滑块的颜色
    [_slider setThumbImage:[UIImage imageNamed:@"return_btn_playplan_nor"] forState:UIControlStateNormal];
    [_slider setThumbImage:[UIImage imageNamed:@"return_btn_playplan_hov"] forState:UIControlStateSelected];
    //对滑动条添加事件函数
    [_slider addTarget:self action:@selector(durationSliderMoving:) forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(durationSliderDone:) forControlEvents:UIControlEventTouchUpInside];
    [_slider addTarget:self action:@selector(UIControlEventTouchDown:) forControlEvents:UIControlEventTouchDown];
    }
    return _slider;
}

- (void) UIControlEventTouchDown:(UISlider *)sender {
//    NSLog(@"--------------------------UIControlEvent  TouchDown");
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageNamed:@"return_btn_playplan_hov"];//图片模式，不设置的话会被压缩
        [_slider setThumbImage:image forState:UIControlStateNormal];//设置图片
    });
}

- (void) durationSliderDone:(UISlider *)sender
{
    self.hiddenTime = 5.0f;
//    NSLog(@"--------------------------durationSlider  Done");
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image2 = [UIImage imageNamed:@"return_btn_playplan_nor"];//图片模式，不设置的话会被压缩
        [_slider setThumbImage:image2 forState:UIControlStateNormal];//设置图片
        _suspendButton.selected = NO;
        int duration = (int)sender.value;
        _leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", duration / 60, duration % 60];
        _offlinePlayBack.currentPlaybackTime = duration;
        _slider.value = duration;
        
        if(duration == 0) {
            _sliderValue = 0;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (_offlinePlayBack.ijkPlayer.playbackState != IJKMPMoviePlaybackStatePlaying) {
                [_offlinePlayBack startPlayer];
            }
        });
    });
}

- (void) durationSliderMoving:(UISlider *)sender
{
    self.hiddenTime = 5.0f;
//    NSLog(@"--------------------------durationSlider  Moving");
    dispatch_async(dispatch_get_main_queue(), ^{
        _suspendButton.selected = NO;
        int duration = (int)sender.value;
        _leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", duration / 60, duration % 60];
        _slider.value = duration;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (_offlinePlayBack.ijkPlayer.playbackState != IJKMPMoviePlaybackStatePaused) {
                [_offlinePlayBack pausePlayer];
            }
        });
    });
}

//-(UILabel *)playRateLabel {
//    if(!_playRateLabel) {
//        _playRateLabel = [UILabel new];
//        _playRateLabel.font = [UIFont systemFontOfSize:FontSize_28];
//        _playRateLabel.textAlignment = NSTextAlignmentCenter;
//        _playRateLabel.textColor = CCRGBAColor(255,255,255,0.8);
//        _playRateLabel.text = @"1.0x";
//    }
//    return _playRateLabel;
//}

- (void)timerfunc
{
    if([_offlinePlayBack isPlaying]) {
        if(_loadingView) {
            [_loadingView removeFromSuperview];
            _loadingView = nil;
        }
    }
   
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval position = (int)round(_offlinePlayBack.currentPlaybackTime);
        NSTimeInterval duration = (int)round(_offlinePlayBack.playerDuration);
        //存在播放器最后一点不播放的情况，所以把进度条的数据对到和最后一秒想同就可以了
        if(duration - position == 1 && (_sliderValue == position || _sliderValue == duration)) {
            position = duration;
        }
        //            NSLog(@"%f---%f",_requestDataPlayBack.currentPlaybackTime,_requestDataPlayBack.currentPlaybackTime);
        _slider.maximumValue = (int)duration;
        _rightTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(duration / 60), (int)(duration) % 60];
        if(position == 0 && _sliderValue != 0) {
            _offlinePlayBack.currentPlaybackTime = _sliderValue;
            position = _sliderValue;
            _slider.value = _sliderValue;
        } else if(fabs(position - _slider.value) > 10) {
            _offlinePlayBack.currentPlaybackTime = _slider.value;
            position = _slider.value;
            _sliderValue = _slider.value;
        } else {
            _slider.value = position;
            _sliderValue = _slider.value;
        }
        
        if(_offlinePlayBack.ijkPlayer.playbackRate != _playBackRate) {
            _offlinePlayBack.ijkPlayer.playbackRate = _playBackRate;
            [self startTimer];
        }
        if(_suspendButton.selected == NO && _offlinePlayBack.ijkPlayer.playbackState == IJKMPMoviePlaybackStatePaused) {
            [_offlinePlayBack startPlayer];
        }
        [_offlinePlayBack continueFromTheTime:_sliderValue];
        [self parseChatOnTime:(int)_sliderValue];
        _leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(_sliderValue / 60), (int)(_sliderValue) % 60];
    });
//    }
}

-(void)startTimer {
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / _playBackRate) target:self selector:@selector(timerfunc) userInfo:nil repeats:YES];
}

-(NSMutableDictionary *)QADic {
    if(!_QADic) {
        _QADic = [[NSMutableDictionary alloc] init];
    }
    return _QADic;
}

-(NSMutableArray *)keysArr {
    if(!_keysArr) {
        _keysArr = [[NSMutableArray alloc] init];
    }
    return _keysArr;
}

-(NSMutableArray *)publicChatArray {
    if(!_publicChatArray) {
        _publicChatArray = [[NSMutableArray alloc] init];
    }
    return _publicChatArray;
}

-(UIView *)shadowView {
    if(!_shadowView) {
        _shadowView = [UIView new];
        _shadowView.backgroundColor = CCRGBColor(255,102,51);
    }
    return _shadowView;
}

-(UISegmentedControl *)segment {
    if(!_segment) {
        NSArray *segmentedArray = [[NSArray alloc] initWithObjects:@"文档",@"聊天记录",@"问答", nil];
        _segment = [[UISegmentedControl alloc] initWithItems:segmentedArray];
        //文字设置
        NSMutableDictionary *attDicNormal = [NSMutableDictionary dictionary];
        attDicNormal[NSFontAttributeName] = [UIFont systemFontOfSize:FontSize_30];
        attDicNormal[NSForegroundColorAttributeName] = CCRGBColor(51,51,51);
        NSMutableDictionary *attDicSelected = [NSMutableDictionary dictionary];
        attDicSelected[NSFontAttributeName] = [UIFont systemFontOfSize:FontSize_30];
        attDicSelected[NSForegroundColorAttributeName] = CCRGBColor(51,51,51);
        [_segment setTitleTextAttributes:attDicNormal forState:UIControlStateNormal];
        [_segment setTitleTextAttributes:attDicSelected forState:UIControlStateSelected];
        _segment.selectedSegmentIndex = 0;
        _segment.backgroundColor = [UIColor whiteColor];
        
        _segment.tintColor = [UIColor whiteColor];
        _segment.momentary = NO;
        [_segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _segment;
}

-(UIImageView *)huifangDot
{
    if(!_huifangDot) {
        _huifangDot = [UIImageView new];
        _huifangDot.image = [UIImage imageNamed:@"nav_msg_returnvideo"];
        _huifangDot.backgroundColor = CCClearColor;
        _huifangDot.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _huifangDot;
}

- (void)segmentAction:(UISegmentedControl *)segment
{
    WS(ws)
    NSInteger index = segment.selectedSegmentIndex;
    int py = _scrollView.contentOffset.y;
    [self.view endEditing:YES];
    CGFloat width0 = [segment widthForSegmentAtIndex:0];
    CGFloat width1 = [segment widthForSegmentAtIndex:1];
    CGFloat width2 = [segment widthForSegmentAtIndex:2];
//    CGFloat width3 = [segment widthForSegmentAtIndex:3];
    CGFloat shadowViewY = segment.frame.origin.y + segment.frame.size.height - 4;
    switch(index){
        case 0: {
            [UIView animateWithDuration:0.25 animations:^{
                ws.shadowView.frame = CGRectMake(0, shadowViewY, width0, 4);
            }];
        }
            [ws.scrollView setContentOffset:CGPointMake(0, py)];
            break;
        case 1: {
            [UIView animateWithDuration:0.25 animations:^{
                ws.shadowView.frame = CGRectMake(width0, shadowViewY, width1, 4);
            }];
        }
            [ws.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, py)];
            break;
        case 2: {
            [UIView animateWithDuration:0.25 animations:^{
                ws.shadowView.frame = CGRectMake(width0 + width1, shadowViewY, width2, 4);
            }];
        }
            [ws.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 2, py)];
            break;
        default:
            break;
    }
}

-(UIView *)videoView {
    if(!_videoView) {
        _videoView = [UIView new];
        _videoView.backgroundColor = [UIColor blackColor];
    }
    return _videoView;
}

-(UIView *)barView {
    if(!_barView) {
        _barView = [UIView new];
        _barView.backgroundColor = CCRGBAColor(0, 0, 0, 0.69);
    }
    return _barView;
}

//设置样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//设置隐藏动画
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

-(void)hiddenAll {
    if(_loadingView) return;
    if(_hiddenTime > 0.0f) {
        _hiddenTime -= 1.0f;
    }
    if(_hiddenTime == 0) {
        _leftButton.hidden = YES;
        _leftLabel.hidden = YES;
        _barView.hidden = YES;
    }
}

-(void)hiddenAllBtns {
    if(_loadingView) return;
    _huifangDot.hidden = NO;
    _leftButton.hidden = YES;
    _leftLabel.hidden = YES;
    _barView.hidden = YES;
}

-(void)showAll {
    _hiddenTime = 5.0f;
    _huifangDot.hidden = YES;
    _leftButton.hidden = NO;
    _leftLabel.hidden = NO;
    _barView.hidden = NO;
}

-(void)startHiddenTimer {
    [self stopHiddenTimer];
    self.hiddenTime = 5.0f;
    self.hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(hiddenAll) userInfo:nil repeats:YES];
}

-(void)stopHiddenTimer {
    if([self.hiddenTimer isValid]) {
        [self.hiddenTimer invalidate];
        self.hiddenTimer = nil;
    }
}

-(UIButton *)playbackRateBtn {
    if(!_playbackRateBtn) {
        _playbackRateBtn = [UIButton new];
        _playbackRateBtn.backgroundColor = CCClearColor;
        [_playbackRateBtn setBackgroundImage:[UIImage imageNamed:@"playback_rate_hor"] forState:UIControlStateNormal];
        [_playbackRateBtn setBackgroundImage:[UIImage imageNamed:@"playback_rate_nor"] forState:UIControlStateSelected];
        _playbackRateBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_playbackRateBtn setTitle:@"1.0x" forState:UIControlStateNormal];
        [_playbackRateBtn setTitleColor:CCRGBAColor(255,255,255,0.8) forState:UIControlStateNormal];
        _playbackRateBtn.titleLabel.font = [UIFont systemFontOfSize:FontSize_28];
        [_playbackRateBtn addTarget:self action:@selector(playbackRateBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playbackRateBtn;
}

-(void)playbackRateBtnClicked {
    NSString *title = self.playbackRateBtn.titleLabel.text;
    if([title isEqualToString:@"1.0x"]) {
        [_playbackRateBtn setTitle:@"1.5x" forState:UIControlStateNormal];
        _playBackRate = 1.5;
        _offlinePlayBack.ijkPlayer.playbackRate = 1.5;
    } else if([title isEqualToString:@"1.5x"]) {
        [_playbackRateBtn setTitle:@"0.5x" forState:UIControlStateNormal];
        _playBackRate = 0.5;
        _offlinePlayBack.ijkPlayer.playbackRate = 0.5;
    } else if([title isEqualToString:@"0.5x"]) {
        [_playbackRateBtn setTitle:@"1.0x" forState:UIControlStateNormal];
        _playBackRate = 1.0;
        _offlinePlayBack.ijkPlayer.playbackRate = 1.0;
    }
    
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / _playBackRate) target:self selector:@selector(timerfunc) userInfo:nil repeats:YES];
}

-(UIButton *)quanPingBtn {
    if(!_quanPingBtn) {
        _quanPingBtn = [UIButton new];
        _quanPingBtn.backgroundColor = CCClearColor;
        [_quanPingBtn setImage:[UIImage imageNamed:@"return_ic_full_nor"] forState:UIControlStateNormal];
        [_quanPingBtn setImage:[UIImage imageNamed:@"return_ic_narrow_nor"] forState:UIControlStateSelected];
        _quanPingBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_quanPingBtn addTarget:self action:@selector(quanPingBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _quanPingBtn;
}

-(UIButton *)suspendButton {
    if(!_suspendButton) {
        _suspendButton = [UIButton new];
        _suspendButton.backgroundColor = CCClearColor;
        [_suspendButton setImage:[UIImage imageNamed:@"return_ic_playon"] forState:UIControlStateNormal];
        [_suspendButton setImage:[UIImage imageNamed:@"return_ic_playoff"] forState:UIControlStateSelected];
        _suspendButton.contentMode = UIViewContentModeScaleAspectFit;
        [_suspendButton addTarget:self action:@selector(suspendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _suspendButton;
}

-(void)suspendBtnClicked {
    self.hiddenTime = 5.0f;
    if (_suspendButton.selected == NO) {
        _suspendButton.selected = YES;
        [_offlinePlayBack pausePlayer];
    } else if (_suspendButton.selected == YES){
        _suspendButton.selected = NO;
        [_offlinePlayBack startPlayer];
    }
}

-(void)quanPingBtnClicked {
    self.hiddenTime = 5.0f;
    BOOL selected = _quanPingBtn.isSelected;
    _quanPingBtn.selected = !selected;
    
    WS(ws)
    if (!self.isScreenLandScape) {
        self.isScreenLandScape = YES;
        self.autoRotate = YES;
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
        [UIApplication sharedApplication].statusBarHidden = YES;
        [_offlinePlayBack changePlayerFrame:self.view.frame];
        [_videoView setFrame:self.view.frame];
        
        [_leftButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.videoView).offset(CCGetRealFromPt(20));
            make.top.mas_equalTo(ws.videoView);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80), CCGetRealFromPt(80)));
        }];
        
        [_leftLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.leftButton.mas_right).offset(CCGetRealFromPt(14));
            make.centerY.mas_equalTo(ws.leftButton);
            make.size.mas_equalTo(CGSizeMake(ws.view.frame.size.width * 0.5, CCGetRealFromPt(30)));
        }];
        
        [_huifangDot mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.videoView).mas_offset(-CCGetRealFromPt(30));
            make.centerY.mas_equalTo(ws.leftButton);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(115), CCGetRealFromPt(52)));
        }];
    } else {
        self.isScreenLandScape = NO;
        self.autoRotate = YES;
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        [UIApplication sharedApplication].statusBarHidden = NO;
        [_offlinePlayBack changePlayerFrame:_videoRect];
        [_videoView setFrame:_videoRect];
        
        [_leftButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.videoView).offset(CCGetRealFromPt(20));
            make.top.mas_equalTo(ws.videoView).offset(CCGetRealFromPt(46));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80), CCGetRealFromPt(80)));
        }];
        
        [_leftLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.leftButton.mas_right).offset(CCGetRealFromPt(14));
            make.centerY.mas_equalTo(ws.leftButton);
            make.size.mas_equalTo(CGSizeMake(ws.view.frame.size.width * 0.5, CCGetRealFromPt(30)));
        }];
        
        [_huifangDot mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.videoView).mas_offset(-CCGetRealFromPt(30));
            make.centerY.mas_equalTo(ws.leftButton);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(115), CCGetRealFromPt(52)));
        }];
    }
    [UIView animateWithDuration:0.25f animations:^{
        [ws.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    self.autoRotate = NO;
}

-(void)initUI {
    WS(ws)
    [self.view addSubview:self.videoView];
    _videoRect = CGRectMake(0, 0, self.view.frame.size.width, CCGetRealFromPt(462));
    [self.videoView setFrame:_videoRect];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleTap:)];
    [self.videoView addGestureRecognizer:singleTap];

    [self.videoView addSubview:self.leftButton];
    [_leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.videoView).offset(CCGetRealFromPt(20));
        make.top.mas_equalTo(ws.videoView).offset(CCGetRealFromPt(46));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80), CCGetRealFromPt(80)));
    }];

    [self.videoView addSubview:self.leftLabel];
    [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.leftButton.mas_right).offset(CCGetRealFromPt(14));
        make.centerY.mas_equalTo(ws.leftButton);
        make.size.mas_equalTo(CGSizeMake(ws.view.frame.size.width * 0.5, CCGetRealFromPt(30)));
    }];
    
    [self.videoView addSubview:self.huifangDot];
    [_huifangDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.videoView).mas_offset(-CCGetRealFromPt(30));
        make.centerY.mas_equalTo(ws.leftButton);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(115), CCGetRealFromPt(52)));
    }];
    _huifangDot.hidden = YES;
    
    [self.videoView addSubview:self.barView];
    [_barView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.bottom.and.left.mas_equalTo(ws.videoView);
        make.height.mas_equalTo(CCGetRealFromPt(88));
    }];
    
    [self.barView addSubview:self.suspendButton];
    [_suspendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.barView).offset(CCGetRealFromPt(24));
        make.centerY.mas_equalTo(ws.barView);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(60), CCGetRealFromPt(60)));
    }];
    
    [self.barView addSubview:self.quanPingBtn];
    [_quanPingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.barView).offset(-CCGetRealFromPt(24));
        make.centerY.mas_equalTo(ws.barView);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(60), CCGetRealFromPt(60)));
    }];
    
    [self.barView addSubview:self.leftTimeLabel];
    [_leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.suspendButton.mas_right);
        make.width.mas_equalTo(CCGetRealFromPt(125));
        make.centerY.mas_equalTo(ws.barView);
        make.height.mas_equalTo(ws.barView);
    }];
    
    [self.barView addSubview:self.playbackRateBtn];
    [_playbackRateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.quanPingBtn.mas_left).offset(-CCGetRealFromPt(20));
        make.width.mas_equalTo(CCGetRealFromPt(96));
        make.centerY.mas_equalTo(ws.barView);
        make.height.mas_equalTo(CCGetRealFromPt(46));
    }];
    
//    [self.barView addSubview:self.playRateLabel];
//    [_playRateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(ws.playRateLabel);
//    }];
    
    [self.barView addSubview:self.rightTimeLabel];
    [_rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.playbackRateBtn.mas_left);
        make.width.mas_equalTo(CCGetRealFromPt(125));
        make.centerY.mas_equalTo(ws.barView);
        make.height.mas_equalTo(ws.barView);
    }];
    
    [self.barView addSubview:self.slider];
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.leftTimeLabel.mas_right).offset(15);
        make.right.mas_equalTo(ws.rightTimeLabel.mas_left).offset(-15);
        make.top.mas_equalTo(ws.barView.mas_centerY).offset(-2);
        make.height.mas_equalTo(CCGetRealFromPt(34));
    }];
    
    [self.view addSubview:self.segment];
    [_segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.videoView.mas_bottom);
        make.height.mas_equalTo(CCGetRealFromPt(80));
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = CCRGBColor(232,232,232);
    [self.segment addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(ws.segment);
        make.height.mas_equalTo(1);
    }];
    
    [self.view addSubview:self.shadowView];
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CCGetRealFromPt(462) + CCGetRealFromPt(80), self.view.frame.size.width , self.view.frame.size.height - (CCGetRealFromPt(462) + CCGetRealFromPt(80)))];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollEnabled = NO;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 3, _scrollView.frame.size.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    [_scrollView addSubview:self.pptView];
    self.pptView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"document_bg"]];
//    [self.pptView addSubview:imageView];
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(ws.pptView).offset(CCGetRealFromPt(180));
//        make.centerX.mas_equalTo(ws.pptView);
//        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(140), CCGetRealFromPt(131)));
//    }];
//    
//    UILabel *noTextLabel = [UILabel new];
//    noTextLabel.font = [UIFont systemFontOfSize:FontSize_28];
//    noTextLabel.textAlignment = NSTextAlignmentCenter;
//    noTextLabel.textColor = CCRGBColor(153,153,153);
//    noTextLabel.text = @"暂无文档";
//    [self.pptView addSubview:noTextLabel];
//    [noTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(imageView.mas_bottom).offset(CCGetRealFromPt(30));
//        make.centerX.mas_equalTo(ws.pptView);
//        make.height.mas_equalTo(CCGetRealFromPt(28));
//        make.width.mas_equalTo(imageView);
//    }];
    
    [_scrollView addSubview:self.chatView];
    self.chatView.frame = CGRectMake(_scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    
    [_scrollView addSubview:self.questionChatView];
    self.questionChatView.frame = CGRectMake(_scrollView.frame.size.width * 2, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    
    [self.view bringSubviewToFront:self.videoView];
    [self.barView bringSubviewToFront:self.slider];
    
    [self.view layoutIfNeeded];
}

-(UIView *)pptView {
    if(!_pptView) {
        _pptView = [UIView new];
        _pptView.backgroundColor = CCRGBColor(250,250,250);
    }
    return _pptView;
}

-(void)closeBtnClicked {
    [self.view addSubview:self.modelView];
    WS(ws)
    [_modelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    [_modelView addSubview:self.modeoCenterView];
    [_modeoCenterView mas_makeConstraints:^(MASConstraintMaker *make) {
        if(!ws.isScreenLandScape) {
            make.top.mas_equalTo(ws.modelView).offset(CCGetRealFromPt(390));
        } else {
            make.centerY.mas_equalTo(ws.modelView.mas_centerY);
        }
        make.centerX.mas_equalTo(ws.modelView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(500), CCGetRealFromPt(250)));
    }];
    [_modeoCenterView addSubview:self.cancelBtn];
    [_modeoCenterView addSubview:self.sureBtn];
    
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.mas_equalTo(ws.modeoCenterView);
        make.height.mas_equalTo(CCGetRealFromPt(100));
        make.right.mas_equalTo(ws.sureBtn.mas_left);
        make.width.mas_equalTo(ws.sureBtn.mas_width);
    }];
    
    [_sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.bottom.mas_equalTo(ws.modeoCenterView);
        make.height.mas_equalTo(ws.cancelBtn);
        make.left.mas_equalTo(ws.cancelBtn.mas_right);
        make.width.mas_equalTo(ws.cancelBtn.mas_width);
    }];
    
    [_modelView addSubview:self.modeoCenterLabel];
    [_modeoCenterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.mas_equalTo(ws.modeoCenterView);
        make.bottom.mas_equalTo(ws.sureBtn.mas_top);
    }];
    
    UIView *lineCross = [UIView new];
    lineCross.backgroundColor = CCRGBColor(221,221,221);
    [_modeoCenterView addSubview:lineCross];
    [lineCross mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.modeoCenterView);
        make.bottom.mas_equalTo(ws.cancelBtn.mas_top);
        make.height.mas_equalTo(1);
    }];
    
    UIView *lineVertical = [UIView new];
    lineVertical.backgroundColor = CCRGBColor(221,221,221);
    [_modeoCenterView addSubview:lineVertical];
    [lineVertical mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.cancelBtn.mas_right);
        make.top.mas_equalTo(lineCross.mas_bottom);
        make.bottom.mas_equalTo(ws.cancelBtn.mas_bottom);
        make.width.mas_equalTo(1);
    }];
}

-(void)sureBtnClicked {
    [self.modelView removeFromSuperview];
    [self hiddenAllBtns];
    [self stopTimer];
    [self stopHiddenTimer];
    [self removeObserver];
    [_offlinePlayBack requestCancel];
    _offlinePlayBack = nil;
    [self dismissViewControllerAnimated:YES completion:^ {
    }];
}

-(void) stopTimer {
    if([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)cancelBtnClicked {
    [self.modelView removeFromSuperview];
}

-(UILabel *)modeoCenterLabel {
    if(!_modeoCenterLabel) {
        _modeoCenterLabel = [UILabel new];
        _modeoCenterLabel.font = [UIFont systemFontOfSize:FontSize_30];
        _modeoCenterLabel.textAlignment = NSTextAlignmentCenter;
        _modeoCenterLabel.textColor = CCRGBColor(51,51,51);
        _modeoCenterLabel.text = @"您确认结束观看回放吗？";
    }
    return _modeoCenterLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self initUI];
    [self addObserver];
    [self startHiddenTimer];
    _autoRotate = NO;
    _sliderValue = 0;
    _playBackRate = 1.0;
    _currentChatTime = 0;
    _currentChatIndex = -1;
    
    PlayParameter *parameter = [[PlayParameter alloc] init];
    parameter.userId = GetFromUserDefaults(PLAYBACK_USERID);
    parameter.roomId = GetFromUserDefaults(PLAYBACK_ROOMID);
    parameter.liveId = GetFromUserDefaults(PLAYBACK_LIVEID);
    parameter.viewerName = GetFromUserDefaults(PLAYBACK_USERNAME);
    parameter.token = GetFromUserDefaults(PLAYBACK_PASSWORD);
    parameter.docParent = self.pptView;
    parameter.docFrame = self.pptView.frame;
    parameter.playerParent = self.videoView;
    parameter.playerFrame = _videoRect;
    parameter.security = NO;
    parameter.PPTScalingMode = 2;
    parameter.pauseInBackGround = NO;
    parameter.defaultColor = [UIColor whiteColor];
    parameter.scalingMode = 1;
    parameter.destination = self.destination;
    _offlinePlayBack = [[OfflinePlayBack alloc] initWithParameter:parameter];
    _offlinePlayBack.delegate = self;
    [_offlinePlayBack startPlayAndDecompress];
    
    _loadingView = [[LoadingView alloc] initWithLabel:@"视频加载中" centerY:YES];
    [self.videoView addSubview:_loadingView];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(50, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=NO;
}

-(void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackStateDidChange)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieLoadStateDidChange)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
}

-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:nil];
}

- (void)dealSingleTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self.view];
    if (_barView.hidden == NO && CGRectContainsPoint(_barView.frame, point)) {
        return;
    }
    if(_barView.hidden == YES) {
        self.hiddenTime = 5.0f;
        [self showAll];
    } else {
        self.hiddenTime = 0.0f;
        [self hiddenAllBtns];
    }
}

-(UILabel *)leftLabel {
    if(!_leftLabel) {
        _leftLabel = [UILabel new];
        _leftLabel.text = _leftLabelText;
        _leftLabel.textColor = [UIColor whiteColor];
        _leftLabel.font = [UIFont systemFontOfSize:FontSize_30];
        _leftLabel.shadowOffset = CGSizeMake(0, 1);
        _leftLabel.shadowColor = CCRGBAColor(102, 102, 102, 0.5);
        _leftLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _leftLabel;
}

-(UIButton *)leftButton {
    if(!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.backgroundColor = CCClearColor;
        [_leftButton addTarget:self action:@selector(onSelectVC) forControlEvents:UIControlEventTouchUpInside];
        UIImage *aimage = [UIImage imageNamed:@"navreturn_ic_back_nor"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_leftButton setImage:image forState:UIControlStateNormal];
        _leftButton.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _leftButton;
}

-(ModelView *)modelView {
    if(!_modelView) {
        _modelView = [ModelView new];
        _modelView.backgroundColor = CCClearColor;
    }
    return _modelView;
}

-(UIView *)modeoCenterView {
    if(!_modeoCenterView) {
        _modeoCenterView = [UIView new];
        _modeoCenterView.backgroundColor = [UIColor whiteColor];
        _modeoCenterView.layer.borderWidth = 1;
        _modeoCenterView.layer.borderColor = [CCRGBColor(187, 187, 187) CGColor];
        _modeoCenterView.layer.cornerRadius = CCGetRealFromPt(10);
        _modeoCenterView.layer.masksToBounds = YES;
    }
    return _modeoCenterView;
}

-(UIButton *)cancelBtn {
    if(!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.backgroundColor = [UIColor whiteColor];
        _cancelBtn.layer.cornerRadius = CCGetRealFromPt(10);
        _cancelBtn.layer.masksToBounds = YES;
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:CCRGBColor(51,51,51) forState:UIControlStateNormal];
        [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_30]];
        [_cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

-(UIButton *)sureBtn {
    if(!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.backgroundColor = [UIColor whiteColor];
        _sureBtn.layer.cornerRadius = CCGetRealFromPt(10);
        _sureBtn.layer.masksToBounds = YES;
        [_sureBtn setTitle:@"确认" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:CCRGBColor(51,51,51) forState:UIControlStateNormal];
        [_sureBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_30]];
        [_sureBtn addTarget:self action:@selector(sureBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

/**
 *	@brief	请求成功
 */
-(void)requestSucceed {
    NSLog(@"请求成功！");
}

/**
 *	@brief	登录请求失败
 */
-(void)requestFailed:(NSError *)error reason:(NSString *)reason {
    NSString *message = nil;
    if (reason == nil) {
        message = [error localizedDescription];
    } else {
        message = reason;
    }
    [_loadingView removeFromSuperview];
    _loadingView = nil;
    InformationShowView *informationView = [[InformationShowView alloc] initWithLabel:message];
    [self.view addSubview:informationView];
    [informationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0f repeats:NO block:^(NSTimer * _Nonnull timer) {
        [informationView removeFromSuperview];
    }];
}

-(void)onSelectVC {
    if(self.isScreenLandScape) {
        [self quanPingBtnClicked];
    } else {
        [self closeBtnClicked];
    }
}

/**
 *	@brief	收到本房间的历史提问&回答
 */
- (void)offline_onParserQuestionArr:(NSArray *)questionArr onParserAnswerArr:(NSArray *)answerArr {
//    NSLog(@"questionArr = %@,answerArr = %@",questionArr,answerArr);
    
    if ([questionArr count] == 0 && [answerArr count] == 0) {
        return;
    }
    
    [self.QADic removeAllObjects];
    [self.keysArr removeAllObjects];
    
    for (NSDictionary *dic in questionArr) {
        Dialogue *dialog = [[Dialogue alloc] init];
        dialog.msg = dic[@"content"];
        dialog.username = dic[@"questionUserName"];
        dialog.fromuserid = dic[@"questionUserId"];
        dialog.time = dic[@"time"];
        dialog.encryptId = dic[@"encryptId"];
        dialog.useravatar = dic[@"questionUserAvatar"];
        dialog.dataType = NS_CONTENT_TYPE_QA_QUESTION;
        NSMutableArray *arr = [self.QADic objectForKey:dialog.encryptId];
        if (arr == nil) {
            arr = [[NSMutableArray alloc] init];
            [self.QADic setObject:arr forKey:dialog.encryptId];
            [self.keysArr addObject:dialog.encryptId];
        }
        [arr addObject:dialog];
    }
    
    for (NSDictionary *dic in answerArr) {
        Dialogue *dialog = [[Dialogue alloc] init];
        dialog.msg = dic[@"content"];
        dialog.username = dic[@"answerUserName"];
        dialog.fromuserid = dic[@"answerUserId"];
        dialog.encryptId = dic[@"encryptId"];
        dialog.useravatar = dic[@"answerUserAvatar"];
        dialog.dataType = NS_CONTENT_TYPE_QA_ANSWER;
        
        BOOL isPrivate = [dic[@"isPrivate"] boolValue];
        if (isPrivate == 0) {
            NSMutableArray *arr = [self.QADic objectForKey:dialog.encryptId];
            if (arr != nil) {
                [arr addObject:dialog];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.questionChatView reloadQADic:self.QADic keysArrAll:self.keysArr];
    });
}
///**
// *    @brief    解析本房间的历史聊天数据
// */
//-(void)offline_onParserChat:(NSArray *)arr {
////    NSLog(@"聊天信息数组 = %@",arr);
//    if ([arr count] == 0) {
//        return;
//    }
//    for (NSDictionary *dic in arr) {
//        Dialogue *dialogue = [[Dialogue alloc] init];
//        dialogue.msg = dic[@"content"];
//        dialogue.username = dic[@"userName"];
//        dialogue.fromusername = dic[@"userName"];
//        dialogue.userid = dic[@"userId"];
//        dialogue.fromuserid = dic[@"userId"];
//        dialogue.useravatar = dic[@"userAvatar"];
//        dialogue.userrole = dic[@"userRole"];
//        dialogue.fromuserrole = dic[@"userRole"];
//        dialogue.time = dic[@"time"];
//        dialogue.dataType = NS_CONTENT_TYPE_CHAT;
//        [self.publicChatArray addObject:dialogue];
//    }
//
////    NSLog(@"---self.publicChatArray = %@",self.publicChatArray);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.chatView reloadPublicChatArray:self.publicChatArray];
//    });
//}

-(ChatView *)chatView {
    if(!_chatView) {
        _chatView = [[ChatView alloc] initWithPublicChatBlock:nil PrivateChatBlock:nil input:NO];
        _chatView.backgroundColor = CCRGBColor(250,250,250);;
    }
    return _chatView;
}

-(QuestionView *)questionChatView {
    if(!_questionChatView) {
        _questionChatView = [[QuestionView alloc] initWithQuestionBlock:nil input:NO];
        _questionChatView.backgroundColor = CCRGBColor(250,250,250);
    }
    return _questionChatView;
}

/**
 *	@brief  房间信息
 */
-(void)offline_roomInfo:(NSDictionary *)dic {
    _roomName = dic[@"name"];
    
    CGFloat shadowViewY = self.segment.frame.origin.y+self.segment.frame.size.height-4;
    
//    NSLog(@"templateType = %@",dic[@"templateType"]);
    
    _templateType = [dic[@"templateType"] integerValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.leftLabel.text = _roomName;
        //    @"文档",@"聊天",@"问答",@"简介"
        if (_templateType == 1) {
            //聊天互动： 无 直播文档： 无 直播问答： 无
            [_segment setHidden:YES];
            [_scrollView setHidden:YES];
        } else if (_templateType == 2) {
            //聊天互动： 有 直播文档： 无 直播问答： 有
            [_segment setWidth:0.0f forSegmentAtIndex:0];
            [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:1];
            [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:2];
            _segment.selectedSegmentIndex = 1;
            _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0], shadowViewY, [self.segment widthForSegmentAtIndex:1], 4);
            int py = _scrollView.contentOffset.y;
            [_scrollView setContentOffset:CGPointMake(self.view.frame.size.width, py)];
        } else if (_templateType == 3) {
            //聊天互动： 有 直播文档： 无 直播问答： 无
            [_segment setWidth:0.0f forSegmentAtIndex:0];
            [_segment setWidth:self.segment.frame.size.width forSegmentAtIndex:1];
            [_segment setWidth:0.0f forSegmentAtIndex:2];
            _segment.selectedSegmentIndex = 1;
            _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0], shadowViewY, [self.segment widthForSegmentAtIndex:1], 4);
            int py = _scrollView.contentOffset.y;
            [_scrollView setContentOffset:CGPointMake(self.view.frame.size.width, py)];
        } else if (_templateType == 4) {
            //聊天互动： 有 直播文档： 有 直播问答： 无
            _segment.selectedSegmentIndex = 0;
            [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:0];
            [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:1];
            [_segment setWidth:0.0f forSegmentAtIndex:2];
            _shadowView.frame = CGRectMake(0, shadowViewY, [self.segment widthForSegmentAtIndex:0], 4);
        } else if (_templateType == 5) {
            [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:0];
            [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:1];
            [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:2];
            _segment.selectedSegmentIndex = 0;
            _shadowView.frame = CGRectMake(0, shadowViewY, [self.segment widthForSegmentAtIndex:0], 4);
            //聊天互动： 有 直播文档： 有 直播问答： 有
        }else if(_templateType == 6) {
            //聊天互动： 无 直播文档： 无 直播问答： 有
            _segment.selectedSegmentIndex = 2;
            [_segment setWidth:0.0f forSegmentAtIndex:0];
            [_segment setWidth:0.0f forSegmentAtIndex:1];
            [_segment setWidth:self.segment.frame.size.width forSegmentAtIndex:2];
            _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0] + [self.segment widthForSegmentAtIndex:1], shadowViewY, [self.segment widthForSegmentAtIndex:2], 4);
            int py = _scrollView.contentOffset.y;
            [_scrollView setContentOffset:CGPointMake(self.view.frame.size.width * 2, py)];
        }
    });
}
/**
 *	@brief  获取文档内白板或者文档本身的宽高，来进行屏幕适配用的
 */
- (void)offline_getDocAspectRatioOfWidth:(CGFloat)width height:(CGFloat)height {
    
}

- (BOOL)shouldAutorotate{
//    NSLog(@"---self.autoRotate = %d",self.autoRotate);
    return self.autoRotate;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)appWillEnterForegroundNotification {
//    if (_offlinePlayBack.ijkPlayer.playbackState != IJKMPMoviePlaybackStatePlaying &&
//        _offlinePlayBack.ijkPlayer.playbackState != IJKMPMoviePlaybackStateStopped &&
//        _offlinePlayBack.ijkPlayer.playbackState != IJKMPMoviePlaybackStateInterrupted) {
//        [_offlinePlayBack startPlayer];
//    }
//    
//    [self startTimer];
}

- (void)appWillEnterBackgroundNotification {
//    UIApplication *app = [UIApplication sharedApplication];
//    UIBackgroundTaskIdentifier taskID;
//    taskID = [app beginBackgroundTaskWithExpirationHandler:^{
//        [app endBackgroundTask:taskID];
//    }];
//    if (taskID == UIBackgroundTaskInvalid) {
//        return;
//    }
//    if (_offlinePlayBack.ijkPlayer.playbackState != IJKMPMoviePlaybackStatePaused &&
//        _offlinePlayBack.ijkPlayer.playbackState != IJKMPMoviePlaybackStateStopped &&
//        _offlinePlayBack.ijkPlayer.playbackState != IJKMPMoviePlaybackStateInterrupted) {
//        [_offlinePlayBack pausePlayer];
//    }
//    
//    [self stopTimer];
}

- (void)offline_loadVideoFail {
    NSLog(@"播放器异常，加载失败");
}

- (void)moviePlayBackStateDidChange{
    switch (_offlinePlayBack.ijkPlayer.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            break;
        }
        case IJKMPMoviePlaybackStatePlaying:
        case IJKMPMoviePlaybackStatePaused: {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(_loadingView && ![_timer isValid]) {
                    [self startTimer];
                    [_loadingView removeFromSuperview];
                    _loadingView = nil;
                }
            });
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            break;
        }
        default: {
            break;
        }
    }
}

-(void)movieLoadStateDidChange
{
    switch (_offlinePlayBack.ijkPlayer.loadState)
    {
        case IJKMPMovieLoadStateStalled:
            break;
        case IJKMPMovieLoadStatePlayable:
            break;
        case IJKMPMovieLoadStatePlaythroughOK:
            break;
        default:
            break;
    }
}

- (void)pageChangeList:(NSMutableArray *)array {
//    NSLog(@"%@",array);
}
-(void)onPageChange:(NSDictionary *)dictionary {
    NSLog(@"翻页数据是%@",dictionary);
}

-(void)broadcastHistory_msg:(NSArray *)array {
    NSLog(@"历史广播%@",array);
}

/**
 *    @brief    解析本房间的历史聊天数据
 */
-(void)offline_onParserChat:(NSArray *)arr {
    //    NSLog(@"聊天信息数组 = %@",arr);
    if ([arr count] == 0) {
        return;
    }
    for (NSDictionary *dic in arr) {
        Dialogue *dialogue = [[Dialogue alloc] init];
        dialogue.msg = dic[@"content"];
        dialogue.username = dic[@"userName"];
        dialogue.fromusername = dic[@"userName"];
        dialogue.userid = dic[@"userId"];
        dialogue.fromuserid = dic[@"userId"];
        dialogue.useravatar = dic[@"userAvatar"];
        dialogue.userrole = dic[@"userRole"];
        dialogue.fromuserrole = dic[@"userRole"];
        dialogue.time = dic[@"time"];
        dialogue.dataType = NS_CONTENT_TYPE_CHAT;
        [self.publicChatArray addObject:dialogue];
    }
    
//    //    NSLog(@"---self.publicChatArray = %@",self.publicChatArray);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.chatView reloadPublicChatArray:self.publicChatArray];
//    });
}

/**
 *    @brief    通过传入时间获取聊天信息
 */
-(void)parseChatOnTime:(int)time {
    if ([self.publicChatArray count] == 0) {
        return;
    }
    long count = [self.publicChatArray count];
    int preIndex = self.currentChatIndex;
    if(time < self.currentChatTime) {
        for(int i = 0;i < count;i++) {
            Dialogue *dialogue = [self.publicChatArray objectAtIndex:i];
            if(i == 0 && [dialogue.time integerValue] > time) {
                _currentChatTime = 0;
                _currentChatIndex = -1;
            }
            if([dialogue.time integerValue] <= time) {
                self.currentChatIndex = i;
                if(self.currentChatIndex == count-1) {
                    NSArray *array = [self.publicChatArray subarrayWithRange:NSMakeRange(0, self.currentChatIndex + 1)];
                    [self.chatView reloadPublicChatArray:[NSMutableArray arrayWithArray:array]];
                    self.currentChatTime = time;
                }
            } else {
                NSArray *array = [self.publicChatArray subarrayWithRange:NSMakeRange(0, self.currentChatIndex + 1)];
                [self.chatView reloadPublicChatArray:[NSMutableArray arrayWithArray:array]];
                self.currentChatTime = time;
                break;
            }
        }
    } else if(time >= self.currentChatTime) {
        for(int i = preIndex + 1;i < count;i++) {
            Dialogue *dialogue = [self.publicChatArray objectAtIndex:i];
            if([dialogue.time integerValue] <= time) {
                self.currentChatIndex = i;
                if(self.currentChatIndex == count-1) {
                    NSArray *array = [self.publicChatArray subarrayWithRange:NSMakeRange(preIndex + 1, self.currentChatIndex - (preIndex + 1) + 1)];
                    [self.chatView addPublicChatArray:[NSMutableArray arrayWithArray:array]];
                    self.currentChatTime = time;
                }
            } else if(preIndex + 1 <= self.currentChatIndex){
                NSArray *array = [self.publicChatArray subarrayWithRange:NSMakeRange(preIndex + 1, self.currentChatIndex - (preIndex + 1) + 1)];
                [self.chatView addPublicChatArray:[NSMutableArray arrayWithArray:array]];
                self.currentChatTime = time;
                break;
            }
        }
    }
}


@end



