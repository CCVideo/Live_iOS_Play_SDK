//
//  CCPlayBackView.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/20.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCPlayBackView.h"
#import "Utility.h"
#import "InformationShowView.h"



@interface CCPlayBackView()<UITextFieldDelegate>

@property (nonatomic, strong)NSTimer                    * playerTimer;//隐藏导航定时器
@property (nonatomic, strong)InformationShowView        * informationViewPop;//提示视图

@end

@implementation CCPlayBackView

//初始化视图
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self setupUI];
    }
    return self;
}

-(void)dealloc {
    [self stopPlayerTimer];
}

//滑动事件
- (void) UIControlEventTouchDown:(UISlider *)sender {
    UIImage *image = [UIImage imageNamed:@"progressBar"];//图片模式，不设置的话会被压缩
    [_slider setThumbImage:image forState:UIControlStateNormal];//设置图片
}

- (void) durationSliderDone:(UISlider *)sender
{
    UIImage *image2 = [UIImage imageNamed:@"progressBar"];//图片模式，不设置的话会被压缩
    [_slider setThumbImage:image2 forState:UIControlStateNormal];//设置图片
    _pauseButton.selected = NO;
    int duration = (int)sender.value;
    _leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", duration / 60, duration % 60];
    _slider.value = duration;
    if(duration == 0) {
        _sliderValue = 0;
    }
    self.sliderCallBack(duration);

}

- (void) durationSliderMoving:(UISlider *)sender
{
    _pauseButton.selected = NO;
    int duration = (int)sender.value;
    _leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", duration / 60, duration % 60];
    _slider.value = duration;
    self.sliderMoving();
}


//隐藏导航
- (void)LatencyHiding {

    if (self.bottomShadowView.hidden == NO) {
        self.bottomShadowView.hidden = YES;
        self.topShadowView.hidden = YES;
    }
}
//隐藏导航
- (void)doTapChange:(UITapGestureRecognizer*) recognizer {
    
    if (self.bottomShadowView.hidden == YES) {
        self.bottomShadowView.hidden = NO;
        self.topShadowView.hidden = NO;
        [self.topShadowView becomeFirstResponder];
        [self bringSubviewToFront:self.topShadowView];
        [self bringSubviewToFront:self.bottomShadowView];
    } else {
        self.bottomShadowView.hidden = YES;
        self.topShadowView.hidden = YES;
        [self.topShadowView resignFirstResponder];
    }
    [self endEditing:NO];
    
}

/**
 创建UI
 */
- (void)setupUI {
    //上面阴影
    self.topShadowView =[[UIView alloc] init];
    UIImageView *topShadow = [[UIImageView alloc] init];
    topShadow.image = [UIImage imageNamed:@"playerBar_against"];
    [self addSubview:self.topShadowView];
    [self.topShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(CCGetRealFromPt(88));
    }];
    [self.topShadowView layoutIfNeeded];
    [self.topShadowView addSubview:topShadow];
    [topShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.topShadowView);
    }];
    //返回按钮
    self.backButton = [[UIButton alloc] init];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"nav_ic_back_nor_white"] forState:UIControlStateNormal];
    self.backButton.tag = 1;

    [self.topShadowView addSubview:_backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topShadowView).offset(CCGetRealFromPt(20));
        make.top.equalTo(self.topShadowView).offset(CCGetRealFromPt(26));
        make.width.height.mas_equalTo(30);
    }];
    [self.backButton layoutIfNeeded];

    //房间标题
    UILabel * titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:FontSize_30];
    [self.topShadowView addSubview:titleLabel];

    //切换视频
    self.changeButton = [[UIButton alloc] init];
    self.changeButton.titleLabel.textColor = [UIColor whiteColor];
    self.changeButton.titleLabel.font = [UIFont systemFontOfSize:FontSize_30];
    self.changeButton.tag = 1;
    [self.changeButton setTitle:@"切换文档" forState:UIControlStateNormal];
    [self.topShadowView addSubview:_changeButton];
    [self.changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topShadowView).offset(CCGetRealFromPt(-20));
        make.centerY.equalTo(self.backButton);
        make.height.mas_equalTo(CCGetRealFromPt(30));
        make.width.mas_equalTo(CCGetRealFromPt(140));
    }];
    [self.changeButton layoutIfNeeded];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.left.equalTo(self.backButton.mas_right).offset(-10);
        make.width.mas_equalTo(SCREEN_WIDTH - CCGetRealFromPt(250));
    }];
    [titleLabel layoutIfNeeded];

    //下面阴影
    self.bottomShadowView =[[UIView alloc] init];
    UIImageView *bottomShadow = [[UIImageView alloc] init];
    bottomShadow.image = [UIImage imageNamed:@"playerBar"];
    [self addSubview:self.bottomShadowView];
    [self.bottomShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(CCGetRealFromPt(60));
    }];
    [self.bottomShadowView layoutIfNeeded];
    [self.bottomShadowView addSubview:bottomShadow];
    [bottomShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bottomShadowView);
    }];

    //暂停按钮
    self.pauseButton = [[UIButton alloc] init];
    self.pauseButton.backgroundColor = CCClearColor;
    [self.pauseButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
    [self.pauseButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
    self.pauseButton.contentMode = UIViewContentModeScaleAspectFit;
    [self.bottomShadowView addSubview:_pauseButton];
    [self.pauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomShadowView);
        make.left.equalTo(self.bottomShadowView).offset(CCGetRealFromPt(20));
        make.width.height.mas_equalTo(CCGetRealFromPt(60));
    }];
    [self.pauseButton layoutIfNeeded];

    //当前播放时间
    _leftTimeLabel = [[UILabel alloc] init];
    _leftTimeLabel.text = @"00:00";
    _leftTimeLabel.userInteractionEnabled = NO;
    _leftTimeLabel.textColor = [UIColor whiteColor];
    _leftTimeLabel.font = [UIFont systemFontOfSize:FontSize_24];
    _leftTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomShadowView addSubview:_leftTimeLabel];
    [self.leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.pauseButton);
        make.left.equalTo(self.pauseButton.mas_right).offset(CCGetRealFromPt(10));
        make.width.mas_equalTo(CCGetRealFromPt(90));
    }];
    [self.leftTimeLabel layoutIfNeeded];
    //时间中间的/
    UILabel * placeholder = [[UILabel alloc] init];
    placeholder.text = @"/";
    placeholder.textColor = [UIColor whiteColor];
    placeholder.font = [UIFont systemFontOfSize:FontSize_24];
    placeholder.textAlignment = NSTextAlignmentCenter;
    [self.bottomShadowView addSubview:placeholder];
    [placeholder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.leftTimeLabel);
        make.left.equalTo(self.leftTimeLabel.mas_right);
    }];
    //总时长
    _rightTimeLabel = [[UILabel alloc] init];
    _rightTimeLabel.text = @"--:--";
    _rightTimeLabel.userInteractionEnabled = NO;
    _rightTimeLabel.textColor = [UIColor whiteColor];
    _rightTimeLabel.font = [UIFont systemFontOfSize:FontSize_24];
    _rightTimeLabel.alpha = 0.6f;
    _rightTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomShadowView addSubview:_rightTimeLabel];
    [self.rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftTimeLabel.mas_right).offset(CCGetRealFromPt(10));
        make.centerY.equalTo(self.leftTimeLabel);
        make.width.mas_equalTo(CCGetRealFromPt(90));

    }];
    [self.rightTimeLabel layoutIfNeeded];

    //滑动条
    _slider = [[MySlider alloc] init];
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
    [_slider setThumbImage:[UIImage imageNamed:@"progressBar"] forState:UIControlStateNormal];
    //对滑动条添加事件函数
    [_slider addTarget:self action:@selector(durationSliderMoving:) forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(durationSliderDone:) forControlEvents:UIControlEventTouchUpInside];
    [_slider addTarget:self action:@selector(UIControlEventTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.bottomShadowView addSubview:_slider];

    //全屏按钮
    self.quanpingButton = [[UIButton alloc] init];
    [self.quanpingButton setImage:[UIImage imageNamed:@"video_expand"] forState:UIControlStateNormal];
    [self.quanpingButton setImage:[UIImage imageNamed:@"video_shrink"] forState:UIControlStateSelected];
    self.quanpingButton.tag = 1;
    [self.bottomShadowView addSubview:_quanpingButton];
    [self.quanpingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomShadowView);
        make.right.equalTo(self.bottomShadowView).offset(CCGetRealFromPt(-20));
        make.width.height.mas_equalTo(CCGetRealFromPt(60));
    }];
    [self.quanpingButton layoutIfNeeded];

    //倍速按钮
    self.speedButton = [[UIButton alloc] init];
    [self.speedButton setTitle:@"1.0x" forState:UIControlStateNormal];
    self.speedButton.titleLabel.font = [UIFont systemFontOfSize:FontSize_28];
    [self.bottomShadowView addSubview:_speedButton];
    [self.speedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomShadowView);
        make.right.equalTo(self.quanpingButton.mas_left).offset(CCGetRealFromPt(-10));
        make.width.mas_equalTo(CCGetRealFromPt(70));
        make.height.mas_equalTo(CCGetRealFromPt(56));
    }];
    [self.speedButton layoutIfNeeded];

    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.rightTimeLabel.mas_right).offset(CCGetRealFromPt(10));
//        make.right.equalTo(self.speedButton.mas_left).offset(CCGetRealFromPt(-20));
        make.top.mas_equalTo(self.rightTimeLabel.mas_centerY).offset(-2);
        make.height.mas_equalTo(CCGetRealFromPt(34));
        make.width.mas_equalTo(SCREEN_WIDTH - CCGetRealFromPt(460));
    }];
    [self.slider layoutIfNeeded];

//    //已结束
//    self.liveUnStart = [[UIImageView alloc] init];
//    self.liveUnStart.image = [UIImage imageNamed:@"live_streaming_unstart_bg"];
//    [self addSubview:self.liveUnStart];
//    [self.liveUnStart mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self);
//    }];
//    [self.liveUnStart layoutIfNeeded];
//    self.liveUnStart.hidden = YES;
//
//    UIImageView * alarmClock = [[UIImageView alloc] init];
//    alarmClock.image = [UIImage imageNamed:@"live_streaming_unstart"];
//    [self.liveUnStart addSubview:alarmClock];
//    [alarmClock mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.liveUnStart);
//        make.height.width.mas_equalTo(CCGetRealFromPt(64));
//        make.centerY.equalTo(self.liveUnStart.mas_centerY).offset(-10);
//    }];
//
//    UILabel * unStart = [[UILabel alloc] init];
//    unStart.textColor = [UIColor whiteColor];
//    unStart.alpha = 0.6f;
//    unStart.font = [UIFont systemFontOfSize:FontSize_30];
//    unStart.text = @"已结束";
//    [self.liveUnStart addSubview:unStart];
//    [unStart mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(alarmClock);
//        make.top.equalTo(alarmClock.mas_bottom).offset(CCGetRealFromPt(10));
//    }];
//    [unStart layoutIfNeeded];
    
    //单击手势
    UITapGestureRecognizer *TapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTapChange:)];
    TapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:TapGesture];

    //隐藏导航
    [self stopPlayerTimer];
    self.playerTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(LatencyHiding) userInfo:nil repeats:YES];
    
}

/**
 切换横竖屏

 @param screenLandScape 横竖屏
 */
- (void)layouUI:(BOOL)screenLandScape {
    if (screenLandScape == YES) {//横屏
        self.quanpingButton.selected = YES;
        NSInteger barHeight = IS_IPHONE_X?180:128;
        [self.bottomShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(IS_IPHONE_X ? 44:0);
            make.height.mas_equalTo(CCGetRealFromPt(barHeight));
            make.right.equalTo(self).offset(IS_IPHONE_X? (-44):0);
        }];
        [self.topShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(IS_IPHONE_X ? 44:0);
            make.right.equalTo(self).offset(IS_IPHONE_X? (-44):0);
        }];
        [self.backButton layoutIfNeeded];
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.backButton);
            make.left.equalTo(self.backButton.mas_right).offset(-10);
            make.right.equalTo(self.changeButton.mas_left).offset(-60);
        }];
        [self.titleLabel layoutIfNeeded];
        [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH - CCGetRealFromPt(460)-(IS_IPHONE_X?88:0));
        }];
        [self.slider layoutIfNeeded];
    } else {//竖屏
        self.quanpingButton.selected = NO;
        [self.bottomShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(CCGetRealFromPt(60));
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
        [self.topShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
        [self.backButton layoutIfNeeded];
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.backButton);
            make.left.equalTo(self.backButton.mas_right).offset(-10);
            make.right.equalTo(self.changeButton.mas_left).offset(-5);
        }];
        [self.titleLabel layoutIfNeeded];
        [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH - CCGetRealFromPt(460));
        }];
        [self.slider layoutIfNeeded];
    }
}
//移除提示信息
-(void)removeInformationViewPop {
    [_informationViewPop removeFromSuperview];
    _informationViewPop = nil;
}
//移除定时器
-(void)stopPlayerTimer {
    if([self.playerTimer isValid]) {
        [self.playerTimer invalidate];
        self.playerTimer = nil;
    }
}




@end
