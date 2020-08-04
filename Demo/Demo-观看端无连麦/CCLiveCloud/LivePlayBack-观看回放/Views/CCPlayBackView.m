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
#import "CCAlertView.h"//提示框
#import "CCProxy.h"

@interface CCPlayBackView()<UITextFieldDelegate>

/** 隐藏导航定时器 */
@property (nonatomic, strong)NSTimer                    *playerTimer;
/** 提示视图 */
@property (nonatomic, strong)InformationShowView        *informationViewPop;
/** 是否是文档小窗 */
@property (nonatomic, assign)BOOL                       isSmallDocView;
/** 重新播放 */
@property (nonatomic, strong)UILabel                    *unStart;

/** 手势回调次数标识 */
@property (nonatomic, assign)NSInteger                  showShadowCountFlag;
/** 是否隐藏顶底部工具栏 */
@property (nonatomic, assign)BOOL                       isHiddenShadowView;
/** 顶底部工具栏是否接受用户事件 是 定时器不触发隐藏事件 否 定时器正常触发隐藏事件 */
@property (nonatomic, assign)BOOL                       isUserTouching;

/** 拖动时间 */
@property (nonatomic, assign)int                        dragTime;
/** 拖动时间显示 */
@property (nonatomic, strong)UILabel                    *dragTimeLabel;
/** 正在拖动 */
@property (nonatomic, assign)BOOL                       isDragging;
/** 添加滑动遮罩层 */
@property (nonatomic, strong)UIView                     *draggingShadowView;
/** 是否允许拖动 */
@property (nonatomic, assign)BOOL                       isAllowDragging;

/** 重播 */
@property (nonatomic, strong)UIButton                   * replayBtn;
/** 重播提示 */
@property (nonatomic, strong)UILabel                    * replayTipLabel;
/** 重播shadowView */
@property (nonatomic, strong)UIView                     * replayView;

@end

@implementation CCPlayBackView

/**
 *    @brief    初始化视图
 */
- (instancetype)initWithFrame:(CGRect)frame docViewType:(BOOL)isSmallDocView{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        _sliderValue = 0;//初始化滑动条进度
        _playBackRate = 1.0;//初始化回放速率
        _isSmallDocView = isSmallDocView;//是否是文档小窗
        _isUserTouching = NO; //用户是否点击工具栏
        _isDragging = NO; //是否正在拖动
        [self setupUI];
    }
    return self;
}

/**
 *    @brief    滑动事件
 */
- (void)UIControlEventTouchDown:(UISlider *)sender {
    _isUserTouching = YES;
    UIImage *image = [UIImage imageNamed:@"progressBar"];//图片模式，不设置的话会被压缩
    [_slider setThumbImage:image forState:UIControlStateNormal];//设置图片
}
/**
 *    @brief    滑动完成
 */
- (void)durationSliderDone:(UISlider *)sender
{
    UIImage *image2 = [UIImage imageNamed:@"progressBar"];//图片模式，不设置的话会被压缩
    [_slider setThumbImage:image2 forState:UIControlStateNormal];//设置图片
    
    //更新当前播放时间
    int duration = (int)sender.value;
    _leftTimeLabel.text = [NSString stringWithFormat:@"%@",[self timeFormatted:duration]];
//    NSLog(@"---滑动后时间1:%@",_leftTimeLabel.text);
    _slider.value = duration;
    if(duration == 0) {
        _sliderValue = 0;
    }
    
    //滑块完成回调
    self.sliderCallBack(duration);
    
    //更新播放按钮状态
    _pauseButton.selected = NO;
    [_pauseButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
    
    _isUserTouching = NO; //拖拽结束 用户移除点击事件
    [self resetReplayState];//重置重播状态
    [self showOrHiddenShadowView];
}
/**
 *    @brief    滑块正在移动时
 */
- (void)durationSliderMoving:(UISlider *)sender
{
    //当前有用户触摸事件
    _isUserTouching = YES;
    //重置重播状态
    [self resetReplayState];
    //更新当前时间
    int duration = (int)sender.value;
    _leftTimeLabel.text = [NSString stringWithFormat:@"%@",[self timeFormatted:duration]];
//    NSLog(@"---滑动中时间:%@",_leftTimeLabel.text);
    //更新播放按钮状态
    _pauseButton.selected = YES;
    [_pauseButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
    
    _slider.value = duration;
    //滑块移动回调
    self.sliderMoving();
}
/**
 *    @brief    开始倒计时
 */
- (void)beginTimer
{
    [self stopPlayerTimer];
    CCProxy *weakObject = [CCProxy proxyWithWeakObject:self];
    self.playerTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:weakObject selector:@selector(LatencyHiding) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_playerTimer forMode:NSRunLoopCommonModes];
}

/**
 *    @brief    定时器回调
 */
- (void)LatencyHiding
{
    if (_isDragging == YES) return; //拖动动 不回调
    if (_isUserTouching == YES) return;//用户点击顶底部工具栏 不回调
    [self stopPlayerTimer];
    self.bottomShadowView.hidden = YES;
    self.topShadowView.hidden = YES;
    self.isHiddenShadowView = YES;
}

/**
 *  @brief  显示/隐藏 顶底部工具栏
 */
- (void)showOrHiddenShadowView
{
    //滑动时间中也需要一直显示
    if (_isHiddenShadowView == NO || _isDragging == YES) {
        if (_isUserTouching == NO && _isDragging == NO) {
            [self beginTimer];
        }
        self.bottomShadowView.hidden = NO;
        self.topShadowView.hidden = NO;
        [self bringSubviewToFront:self.topShadowView];
        [self bringSubviewToFront:self.bottomShadowView];
        
    }else {
        [self stopPlayerTimer];
        self.bottomShadowView.hidden = YES;
        self.topShadowView.hidden = YES;
        self.isHiddenShadowView = YES;
    }
}

/**
 创建UI
 */
- (void)setupUI {
    
    _isHiddenShadowView = YES;
    //上面阴影
    self.topShadowView = [[UIView alloc] init];
    UIImageView *topShadow = [[UIImageView alloc] init];
    topShadow.image = [UIImage imageNamed:@"playerBar_against"];
    [self addSubview:self.topShadowView];
    [self.topShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.height.mas_equalTo(CCGetRealFromPt(88));
    }];
    [self.topShadowView layoutIfNeeded];
    [self.topShadowView addSubview:topShadow];
    [topShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.topShadowView);
    }];
    //返回按钮
    self.backButton = [[CCButton alloc] init];
    [self.backButton setImage:[UIImage imageNamed:@"nav_ic_back_nor_white"] forState:UIControlStateNormal];
    self.backButton.tag = 1;

    [self.topShadowView addSubview:_backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.topShadowView);
        make.centerY.mas_equalTo(self.topShadowView);
        make.width.height.mas_equalTo(CCGetRealFromPt(88));
    }];
    [self.backButton layoutIfNeeded];
    WS(weakSelf)
    self.backButton.endTouchBlock = ^(NSString * _Nonnull sting) {
        weakSelf.isUserTouching = NO;
        [weakSelf showOrHiddenShadowView];
    };

    //房间标题
    UILabel * titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:FontSize_30];
    [self.topShadowView addSubview:titleLabel];

    //切换视频
    self.changeButton = [[CCButton alloc] init];
    self.changeButton.titleLabel.textColor = [UIColor whiteColor];
    self.changeButton.titleLabel.font = [UIFont systemFontOfSize:FontSize_30];
    self.changeButton.tag = 1;
    [self.changeButton setTitle:PLAY_CHANGEDOC forState:UIControlStateNormal];
    [self.topShadowView addSubview:self.changeButton];
    [self.changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.topShadowView).offset(CCGetRealFromPt(-20));
        make.centerY.mas_equalTo(self.backButton);
        make.height.mas_equalTo(CCGetRealFromPt(60));
        make.width.mas_equalTo(CCGetRealFromPt(180));
    }];
    [self.changeButton layoutIfNeeded];
    //结束点击的回调
    self.changeButton.endTouchBlock = ^(NSString * _Nonnull sting) {
        weakSelf.isUserTouching = NO;
        [weakSelf showOrHiddenShadowView];
    };
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backButton);
        make.left.mas_equalTo(self.backButton.mas_right);
        make.width.mas_equalTo(SCREEN_WIDTH - CCGetRealFromPt(250));
    }];
    [titleLabel layoutIfNeeded];

    //下面阴影
    self.bottomShadowView =[[UIView alloc] init];
    UIImageView *bottomShadow = [[UIImageView alloc] init];
    bottomShadow.userInteractionEnabled = YES;
    bottomShadow.image = [UIImage imageNamed:@"playerBar"];
    [self addSubview:self.bottomShadowView];
    [self.bottomShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(CCGetRealFromPt(80));
    }];
    [self.bottomShadowView layoutIfNeeded];
    [self.bottomShadowView addSubview:bottomShadow];
    [bottomShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bottomShadowView);
    }];

    //暂停按钮
    self.pauseButton = [[CCButton alloc] init];
    self.pauseButton.backgroundColor = CCClearColor;
    [self.pauseButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
    [self.pauseButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
    self.pauseButton.contentMode = UIViewContentModeScaleAspectFit;
    [self.bottomShadowView addSubview:_pauseButton];
    [self.pauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomShadowView);
        make.left.mas_equalTo(self.bottomShadowView).offset(CCGetRealFromPt(10));
        make.width.height.mas_equalTo(CCGetRealFromPt(80));
    }];
    [self.pauseButton layoutIfNeeded];
    self.pauseButton.endTouchBlock = ^(NSString * _Nonnull sting) {
        weakSelf.isUserTouching = NO;
        [weakSelf showOrHiddenShadowView];
    };

    //当前播放时间
    _leftTimeLabel = [[UILabel alloc] init];
    _leftTimeLabel.text = @"00:00";
    _leftTimeLabel.userInteractionEnabled = NO;
    _leftTimeLabel.textColor = [UIColor whiteColor];
    _leftTimeLabel.font = [UIFont systemFontOfSize:FontSize_24];
    _leftTimeLabel.textAlignment = NSTextAlignmentRight;
    [self.bottomShadowView addSubview:_leftTimeLabel];
    [self.leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.pauseButton);
        make.left.mas_equalTo(self.pauseButton.mas_right).offset(CCGetRealFromPt(10));
        make.width.mas_equalTo(CCGetRealFromPt(96));
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
        make.centerY.mas_equalTo(self.leftTimeLabel);
        make.left.mas_equalTo(self.leftTimeLabel.mas_right);
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
        make.left.mas_equalTo(placeholder.mas_right).offset(CCGetRealFromPt(10));
        make.centerY.mas_equalTo(self.leftTimeLabel);
//        make.width.mas_equalTo(CCGetRealFromPt(90));
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
    [_slider addTarget:self action:@selector(durationSliderDone:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    [_slider addTarget:self action:@selector(UIControlEventTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.bottomShadowView addSubview:_slider];

    //全屏按钮
    self.quanpingButton = [[CCButton alloc] init];
    [self.quanpingButton setImage:[UIImage imageNamed:@"video_expand"] forState:UIControlStateNormal];
    [self.quanpingButton setImage:[UIImage imageNamed:@"video_shrink"] forState:UIControlStateSelected];
    self.quanpingButton.tag = 1;
    [self.bottomShadowView addSubview:_quanpingButton];
    [self.quanpingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.pauseButton);
        make.right.mas_equalTo(self.bottomShadowView).offset(CCGetRealFromPt(-20));
        make.width.height.mas_equalTo(CCGetRealFromPt(88));
    }];
    [self.quanpingButton layoutIfNeeded];
    self.quanpingButton.endTouchBlock = ^(NSString * _Nonnull sting) {
        weakSelf.isUserTouching = NO;
        [weakSelf showOrHiddenShadowView];
    };

    //倍速按钮
    self.speedButton = [[CCButton alloc] init];
    [self.speedButton setTitle:@"1.0x" forState:UIControlStateNormal];
    self.speedButton.titleLabel.font = [UIFont systemFontOfSize:FontSize_28];
    [self.bottomShadowView addSubview:_speedButton];
    [self.speedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.pauseButton);
        make.right.mas_equalTo(self.quanpingButton.mas_left).offset(CCGetRealFromPt(-10));
        make.width.mas_equalTo(CCGetRealFromPt(80));
        make.height.mas_equalTo(CCGetRealFromPt(60));
    }];
    [self.speedButton layoutIfNeeded];
    self.speedButton.endTouchBlock = ^(NSString * _Nonnull sting) {
        weakSelf.isUserTouching = NO;
        [weakSelf showOrHiddenShadowView];
    };

    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.rightTimeLabel.mas_centerY).offset(-2);
        make.left.mas_equalTo(self.rightTimeLabel.mas_right).offset(CCGetRealFromPt(10));
        make.right.mas_equalTo(self.speedButton.mas_left).offset(CCGetRealFromPt(-10));
        make.height.mas_equalTo(CCGetRealFromPt(34));
//        make.width.mas_equalTo(SCREEN_WIDTH - CCGetRealFromPt(500));
    }];

    //隐藏导航
    [self beginTimer];
    
    //新加属性
    [self.backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.changeButton addTarget:self action:@selector(changeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.quanpingButton addTarget:self action:@selector(quanpingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.speedButton addTarget:self action:@selector(playbackRateBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    //添加文档小窗
    //小窗
//    CGRect rect = [UIScreen mainScreen].bounds;
//    CGRect smallVideoRect = CGRectMake(rect.size.width -CCGetRealFromPt(220), CCGetRealFromPt(462)+CCGetRealFromPt(82)+(IS_IPHONE_X? 44:20), CCGetRealFromPt(202), CCGetRealFromPt(152));
    _smallVideoView = [[CCDocView alloc] initWithType:_isSmallDocView];
//    __weak typeof(self)weakSelf = self;
    _smallVideoView.hiddenSmallVideoBlock = ^{
        [weakSelf hiddenSmallVideoview];
    };
    
    //直播未开始
    self.liveEnd = [[UIImageView alloc] init];
    self.liveEnd.image = [UIImage imageNamed:@"live_streaming_unstart_bg"];
    [self addSubview:self.liveEnd];
    self.liveEnd.frame = CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462));
    self.liveEnd.hidden = YES;
    //直播未开始图片
    UIImageView * alarmClock = [[UIImageView alloc] init];
    alarmClock.image = [UIImage imageNamed:@"live_streaming_unstart"];
    [self.liveEnd addSubview:alarmClock];
    [alarmClock mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.liveEnd);
        make.height.width.mas_equalTo(CCGetRealFromPt(64));
        make.centerY.mas_equalTo(self.liveEnd.mas_centerY).offset(-10);
    }];
    
    self.unStart = [[UILabel alloc] init];
    self.unStart.textColor = [UIColor whiteColor];
    self.unStart.alpha = 0.6f;
    self.unStart.textAlignment = NSTextAlignmentCenter;
    self.unStart.font = [UIFont systemFontOfSize:FontSize_30];
    self.unStart.text = PLAY_END;
    [self.liveEnd addSubview:self.unStart];
    self.unStart.frame = CGRectMake(SCREEN_WIDTH/2-50, CCGetRealFromPt(271), 100, 30);
    
    self.draggingShadowView = [[UIView alloc]init];
    self.draggingShadowView.backgroundColor = CCRGBAColor(0, 0, 0, 0.3);
    self.draggingShadowView.hidden = YES;
    self.draggingShadowView.userInteractionEnabled = NO;
    [self addSubview:self.draggingShadowView];
    [self bringSubviewToFront:self.draggingShadowView];
    [self.draggingShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(self);
    }];
    
    self.dragTimeLabel = [[UILabel alloc]init];
    self.dragTimeLabel.textColor = [UIColor whiteColor];
    self.dragTimeLabel.font = [UIFont systemFontOfSize:FontSize_40];
    self.dragTimeLabel.hidden = YES;
    self.dragTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.dragTimeLabel];
    [self.dragTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.mas_equalTo(self);
    }];
    
    //添加拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAction:)];
    [self addGestureRecognizer:pan];
    
    _replayView = [[UIView alloc]init];
    _replayView.backgroundColor = CCRGBAColor(0, 0, 0, 0.3);
    _replayView.hidden = YES;
    [self addSubview:_replayView];
    [_replayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(self);
    }];
    
    _replayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_replayBtn setImage:[UIImage imageNamed:@"video_replay"] forState:UIControlStateNormal];
    [_replayBtn addTarget:self action:@selector(replayBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_replayView addSubview:_replayBtn];
    [_replayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_replayView);
        make.centerY.mas_equalTo(_replayView).offset(-10);
        make.width.height.mas_equalTo(50);
    }];
    
    _replayTipLabel = [[UILabel alloc]init];
    _replayTipLabel.text = @"重播";
    _replayTipLabel.textColor = [UIColor whiteColor];
    _replayTipLabel.font = [UIFont systemFontOfSize:13];
    _replayTipLabel.textAlignment = NSTextAlignmentCenter;
    [_replayView addSubview:_replayTipLabel];
    [_replayTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_replayBtn);
        make.top.mas_equalTo(_replayBtn.mas_bottom).offset(-10);
    }];
    
}

#pragma mark - 重播
/**
 *    @brief    播放完成
 *    @param    playDone   playDone 播放完成
 */
- (void)setPlayDone:(BOOL)playDone
{
    _playDone = playDone;
    if (_replayView.hidden == YES && playDone == YES) {
        // 播放完成回调控制器 已播放完成
        if ([self.delegate respondsToSelector:@selector(playDone)]) {
            [self.delegate playDone];
        }
        [_pauseButton setImage:[UIImage imageNamed:@"video_replay1"] forState:UIControlStateNormal];
        _replayView.hidden = NO;
        [self bringSubviewToFront:_replayView];
        [self bringSubviewToFront:_topShadowView];
        [self bringSubviewToFront:_bottomShadowView];
    }
}
/**
 *    @brief    重播按钮点击事件
 */
- (void)replayBtnClick
{
    _dragTime = 0;
    _slider.value = _dragTime;
    if(_dragTime == 0) {
        _sliderValue = _dragTime;
    }
    
    //滑块完成回调
    self.sliderCallBack(_dragTime);
    [_pauseButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
    //重置重播状态
    [self resetReplayState];
}
/**
 *    @brief    重置重播状态
 */
- (void)resetReplayState
{
    _replayView.hidden = YES;
    _replayView.hidden = YES;
    [_pauseButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
    _playDone = NO;
}

#pragma mark - 拖动手势操作
- (void)dragAction:(UIPanGestureRecognizer *)pan
{
    //播放完成禁止拖动
    if (_playDone == YES) {
        _draggingShadowView.hidden = _draggingShadowView.hidden == NO ? YES : YES;
        return;
    }
    //是否允许拖动
    if (_isAllowDragging == NO) return;
    
    CGPoint velocity = [pan velocityInView:pan.view];
    //滑动滚动开始
    if (pan.state == UIGestureRecognizerStateBegan) {
        _isDragging = YES;
        [self showOrHiddenShadowView];
        if (_draggingShadowView) {
            _draggingShadowView.hidden = YES;
        }
        
        //当前播放时间(秒)
        self.dragTime = [self secondWithTimeString:self.leftTimeLabel.text];
        self.draggingShadowView.alpha = 1;
        self.draggingShadowView.hidden = NO;
        [self bringSubviewToFront:self.draggingShadowView];
        self.dragTimeLabel.hidden = NO;
        [self bringSubviewToFront:self.dragTimeLabel];
        
    //滑动滚动中
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        
        //跳转时间 根据滑动 水平方向滑动速度 / 40 计算
        _dragTime += velocity.x / 40;
        if (_dragTime < 0) {
            _dragTime = 0;
        }
        //获取总时间(秒)
        int totalTime = [self secondWithTimeString:self.rightTimeLabel.text];
        if (totalTime == 0) {
            _draggingShadowView.alpha = 0;
            _draggingShadowView.hidden = YES;
            _leftTimeLabel.text = @"00:00";
            return;
        }
            
        if (self.dragTime > totalTime) self.dragTime = totalTime;
        //根据移动速度的方向判断是否是 横向滑动
        CGFloat x = fabs(velocity.x);
        CGFloat y = fabs(velocity.y);
        if (x < y) return;
        //拖动中 shadowView(阴影)时间显示
        NSString *seekTimeStr = [self timeFormatted:_dragTime];
        NSString *totalTimeStr = self.rightTimeLabel.text;
        NSString *showSeekString = [NSString stringWithFormat:@"%@/%@",seekTimeStr,totalTimeStr];
        NSRange range = [showSeekString rangeOfString:@"/"];
        //获取"/"之前的 当前时间 范围
        NSRange range1 = NSMakeRange(0, range.location);
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]initWithString:showSeekString];
        [attributedText addAttribute:NSForegroundColorAttributeName value:CCRGBColor(255,102,51) range:range1];
        _dragTimeLabel.attributedText = attributedText;
        
        //更新底部工具栏当前显示时间
        _leftTimeLabel.text = [NSString stringWithFormat:@"%@",seekTimeStr];
//        NSLog(@"---推动中时间:%@",_leftTimeLabel.text);
        //重设暂停按钮状态
        _pauseButton.selected = YES;
        [_pauseButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
        
        _slider.value = _dragTime;
        //滑块移动回调
        self.sliderMoving();
    
    //滑动滚动结束
    }else if (pan.state == UIGestureRecognizerStateEnded) {
        
        //隐藏拖动蒙版view
        if (_draggingShadowView) {
            self.dragTimeLabel.hidden = YES;
            [UIView animateWithDuration:0.5 animations:^{
                self.draggingShadowView.alpha = 0;
                self.draggingShadowView.hidden = YES;
            }];
        }
        //更新当前播放时间
        NSString *seekTimeStr = [self timeFormatted:_dragTime];
        _leftTimeLabel.text = [NSString stringWithFormat:@"%@",seekTimeStr];
//        NSLog(@"---推动结束时间:%@",_leftTimeLabel.text);
        
        _slider.value = _dragTime;
        if(_dragTime == 0) {
            _sliderValue = 0;
        }
        //滑块完成回调
        self.sliderCallBack(_dragTime);
        _dragTime = 0;
        
        _isDragging = NO;
        //重设暂停按钮状态
        _pauseButton.selected = NO;
        [_pauseButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
        [self showOrHiddenShadowView];
    }
}

/**
 *    @brief    将时间字符串转成秒
 *    @param    timeStr    时间字符串  例:@"01:00:
 */
- (int)secondWithTimeString:(NSString *)timeStr
{
    if ([timeStr rangeOfString:@":"].length == 0) {
        return 0;
    }
    int second = 0;
    NSRange range = [timeStr rangeOfString:@":"];
    int minute = [[timeStr substringToIndex:range.location] intValue];
    int sec = [[timeStr substringFromIndex:range.location + 1] intValue];
    second = minute * 60 + sec;
    return second;
}

/**
 *    @brief    秒转分秒字符串
 *    @param    totalSeconds   秒数
 */
- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = totalSeconds / 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (void)addSmallView {
    [APPDelegate.window addSubview:_smallVideoView];
}
#pragma mark - btn点击事件
/**
 *    @brief    点击切换倍速按钮
 */
- (void)playbackRateBtnClicked {
    _isUserTouching = YES;
    NSString *title = self.speedButton.titleLabel.text;
    if([title isEqualToString:@"1.0x"]) {
        [self.speedButton setTitle:@"1.5x" forState:UIControlStateNormal];
        _playBackRate = 1.5;
        self.changeRate(_playBackRate);
    } else if([title isEqualToString:@"1.5x"]) {
        [self.speedButton setTitle:@"0.5x" forState:UIControlStateNormal];
        _playBackRate = 0.5;
        self.changeRate(_playBackRate);
    } else if([title isEqualToString:@"0.5x"]) {
        [self.speedButton setTitle:@"1.0x" forState:UIControlStateNormal];
        _playBackRate = 1.0;
        self.changeRate(_playBackRate);
    }
    
    [self stopTimer];
    CCProxy *weakObject = [CCProxy proxyWithWeakObject:self];
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / _playBackRate) target:weakObject selector:@selector(timerfunc) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_timer forMode:NSRunLoopCommonModes];
}

/**
 *    @brief    点击暂停和继续
 */
- (void)pauseButtonClick {

    _isUserTouching = YES;
    if (_playDone == YES) {
        [self replayBtnClick];
    }else {
        if (self.pauseButton.selected == NO) {
            self.pauseButton.selected = YES;
            self.pausePlayer(YES);
        } else if (self.pauseButton.selected == YES){
            self.pauseButton.selected = NO;
            self.pausePlayer(NO);
        }
    }
}
/**
 *    @brief    强制转屏
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

/**
 *    @brief    点击全屏按钮
 */
- (void)quanpingButtonClick:(UIButton *)sender {

    if (!sender.selected) {
        sender.selected = YES;
        sender.tag = 2;
        self.isScreenLandScape = YES;
        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        self.isScreenLandScape = NO;
        [UIApplication sharedApplication].statusBarHidden = YES;
        [self turnRight];
        [self quanpingBtnClick];
    } else {
        sender.selected = NO;
        [self backButtonClick:sender];
        sender.tag = 1;
    }
}

/**
 *    @brief    双击文档模拟点击返回按钮
 *    @param    tag   按钮的标签==2 是退出全屏操作
 */
- (void)backBtnClickWithTag:(NSInteger)tag
{
    UIButton *sender = [UIButton buttonWithType:UIButtonTypeCustom];
    sender.tag = tag;
    [self backButtonClick:sender];
}

/**
 *    @brief    双击文档模拟点击全屏按钮
 */
- (void)quanpingBtnClick
{
    _isUserTouching = YES;
    self.backButton.tag = 2;
    //全屏按钮代理
    if (self.delegate) {
        [self.delegate quanpingBtnClicked:_changeButton.tag];
    }
    CGRect frame = [UIScreen mainScreen].bounds;
    self.backButton.tag = 2;
    [UIApplication sharedApplication].statusBarHidden = YES;
    UIView *view = [self superview];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(view);
        make.height.mas_equalTo(SCREENH_HEIGHT);
    }];
    [self layoutIfNeeded];
    //隐藏其他视图
    [self layouUI:YES];
    //smallVideoView
    if (_isSmallDocView) {
        [self.smallVideoView setFrame:CGRectMake(frame.size.width -CCGetRealFromPt(220), CCGetRealFromPt(332), CCGetRealFromPt(200), CCGetRealFromPt(150))];
    }
}

/**
 *    @brief    切换视频和文档
 */
- (void)changeButtonClick:(UIButton *)sender {
    if (_smallVideoView.hidden) {
        NSString *title = _changeButton.tag == 1 ? PLAY_CHANGEDOC : PLAY_CHANGEVIDEO;
        [_changeButton setTitle:title forState:UIControlStateNormal];
        _smallVideoView.hidden = NO;
        return;
    }
    _isUserTouching = YES;
    if (sender.tag == 1) {//切换文档大屏
        sender.tag = 2;
        [sender setTitle:PLAY_CHANGEVIDEO forState:UIControlStateNormal];
    } else {//切换文档小屏
        sender.tag = 1;
        [sender setTitle:PLAY_CHANGEDOC forState:UIControlStateNormal];
    }
    if (self.delegate) {
        [self.delegate changeBtnClicked:sender.tag];
    }
    if (self.playDone == YES) {
        [self bringSubviewToFront:_replayView];
    }
    [self bringSubviewToFront:self.topShadowView];
    [self bringSubviewToFront:self.bottomShadowView];
}
/**
 *    @brief    结束直播和退出全屏
 */
- (void)backButtonClick:(UIButton *)sender {
    UIView *view = [self superview];
    _isUserTouching = YES;
    if (sender.tag == 2) {//横屏返回竖屏
        sender.tag = 1;
        [self endEditing:NO];
//        self.isScreenLandScape = YES;
//        [self interfaceOrientation:UIInterfaceOrientationPortrait];
//        [UIApplication sharedApplication].statusBarHidden = NO;
//        self.isScreenLandScape = NO;
        [self turnPortrait];
        if (self.delegate) {
            [self.delegate backBtnClicked:_changeButton.tag];
        }
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(view);
            make.height.mas_equalTo(CCGetRealFromPt(462));
            make.top.mas_equalTo(view).offset(SCREEN_STATUS);
        }];
        [self layoutIfNeeded];//
        CGRect rect = view.frame;
        [self.smallVideoView setFrame:CGRectMake(rect.size.width -CCGetRealFromPt(220), CCGetRealFromPt(462)+CCGetRealFromPt(82)+(IS_IPHONE_X? 44:20), CCGetRealFromPt(200), CCGetRealFromPt(150))];
        [self layouUI:NO];
    }else if( sender.tag == 1){//结束直播
        [self creatAlertController_alert];
    }
}

/**
 *    @brief    playerView 触摸事件 （直播文档模式，文档手势冲突）
 *    @param    point   触碰当前区域的点
 */
- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event
{
    // 每次触摸事件 此方法会进行两次回调，_showShadowCountFlag 标记第二次回调处理事件
    _showShadowCountFlag++;
    CGFloat selfH = self.frame.size.height;
    
    if (point.y > 0 && point.y <= self.topShadowView.size.height) { //过滤掉顶部shadowView
        _isAllowDragging = NO;//禁止拖动
        _showShadowCountFlag = 0;
        return [super hitTest:point withEvent:event];
    }else if (point.y >= selfH - self.bottomShadowView.size.height && point.y <= selfH) { //过滤掉底部shadowView
        _isAllowDragging = NO;//禁止拖动
        _showShadowCountFlag = 0;
        return [super  hitTest:point withEvent:event];
    }else {
        if (_showShadowCountFlag == 2) {
            _isAllowDragging = YES;//允许拖动
            if (_isDragging == YES) {
                _isHiddenShadowView = NO;
            }else {
                _isHiddenShadowView = _isHiddenShadowView == NO ? YES : NO;
            }
            [self showOrHiddenShadowView];
            _showShadowCountFlag = 0;
        }
        return [super hitTest:point withEvent:event];
    }
}


/**
 *    @brief    创建提示窗
 */
- (void)creatAlertController_alert {
    //设置提示弹窗
    WS(weakSelf)
    CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:ALERT_EXITPLAYBACK sureAction:SURE cancelAction:CANCEL sureBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf exitPlayBack];
        });
    }];
    [APPDelegate.window addSubview:alertView];
}
/**
 *    @brief    退出直播回放
 */
- (void)exitPlayBack {
    if (self.smallVideoView) {
        [self.smallVideoView removeFromSuperview];
    }
    [self stopTimer];
    [self stopPlayerTimer];
//    NSLog(@"退出直播回放");
    if (self.exitCallBack) {
        self.exitCallBack();//退出回放回调
    }
}
#pragma mark - 播放和根据时间添加数据
/**
 *    @brief    播放和根据时间添加数据
 */
- (void)timerfunc
{
    if (self.delegate) {
        [self.delegate timerfunc];
    }
}
/**
 *    @brief    开始播放
 */
- (void)startTimer {
    [self stopTimer];
    CCProxy *weakObject = [CCProxy proxyWithWeakObject:self];
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / _playBackRate) target:weakObject selector:@selector(timerfunc) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_timer forMode:NSRunLoopCommonModes];
}
/**
 *    @brief    停止播放
 */
- (void)stopTimer {
    if([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

/**
 *    @brief    显示视频加载中样式
 */
- (void)showLoadingView {
    if (_loadingView) {
        return;
    }
    _loadingView = [[LoadingView alloc] initWithLabel:PLAY_LOADING centerY:YES];
    [self addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(50, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
}

/**
 *    @brief    移除视频加载中样式
 */
- (void)removeLoadingView {
    if(_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
}
#pragma mark - 切换横竖屏
/**
 *    @brief    切换横竖屏
 *    @param    screenLandScape   横竖屏
 */
- (void)layouUI:(BOOL)screenLandScape {
    if (screenLandScape == YES) {//横屏
        self.quanpingButton.selected = YES;
        NSInteger barHeight = IS_IPHONE_X?180:128;
        [self.bottomShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(IS_IPHONE_X ? 44:0);
            make.height.mas_equalTo(CCGetRealFromPt(barHeight));
            make.right.mas_equalTo(self).offset(IS_IPHONE_X? (-44):0);
        }];
        
        [self.pauseButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bottomShadowView).offset(10);
            make.left.mas_equalTo(self.bottomShadowView).offset(CCGetRealFromPt(10));
            make.width.height.mas_equalTo(CCGetRealFromPt(80));
        }];
        
        [self.topShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(IS_IPHONE_X ? 44:0);
            make.right.mas_equalTo(self).offset(IS_IPHONE_X? (-44):0);
        }];
        [self.backButton layoutIfNeeded];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.backButton);
            make.left.mas_equalTo(self.backButton.mas_right);
            make.right.mas_equalTo(self.changeButton.mas_left).offset(-60);
        }];
        [self.titleLabel layoutIfNeeded];
//        [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(SCREEN_WIDTH - CCGetRealFromPt(500)-(IS_IPHONE_X?88:0));
//        }];
//        [self.slider layoutIfNeeded];
        self.liveEnd.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT);
        self.unStart.frame = CGRectMake(SCREEN_WIDTH/2-50, CCGetRealFromPt(400), 100, 30);
    } else {//竖屏
        self.quanpingButton.selected = NO;
        [self.bottomShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(CCGetRealFromPt(80));
            make.left.mas_equalTo(self);
            make.right.mas_equalTo(self);
        }];
        [self.pauseButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bottomShadowView).offset(0);
            make.left.mas_equalTo(self.bottomShadowView).offset(CCGetRealFromPt(10));
            make.width.height.mas_equalTo(CCGetRealFromPt(80));
        }];
        [self.topShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self);
            make.right.mas_equalTo(self);
        }];
        [self.backButton layoutIfNeeded];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.backButton);
            make.left.mas_equalTo(self.backButton.mas_right);
            make.right.mas_equalTo(self.changeButton.mas_left).offset(-5);
        }];
        [self.titleLabel layoutIfNeeded];
//        [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(SCREEN_WIDTH - CCGetRealFromPt(500));
//        }];
//        [self.slider layoutIfNeeded];
        self.liveEnd.frame = CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462));
        self.unStart.frame = CGRectMake(SCREEN_WIDTH/2-50, CCGetRealFromPt(271), 100, 30);
    }
}
/**
 *    @brief    移除提示信息
 */
-(void)removeInformationViewPop {
    [_informationViewPop removeFromSuperview];
    _informationViewPop = nil;
}
/**
 *    @brief    移除定时器
 */
-(void)stopPlayerTimer {
    if([self.playerTimer isValid]) {
        [self.playerTimer invalidate];
        self.playerTimer = nil;
    }
}

#pragma mark - 隐藏视频小窗
/**
 *    @brief    隐藏小窗视图
 */
- (void)hiddenSmallVideoview {
    _smallVideoView.hidden = YES;
    NSString *title = self.changeButton.tag == 1 ? PLAY_SHOWDOC : PLAY_SHOWVIDEO;
    [self.changeButton setTitle:title forState:UIControlStateNormal];
}
#pragma mark - 横竖屏旋转
/**
 *    @brief    转为横屏
 */
- (void)turnRight {
    self.isScreenLandScape = YES;
    [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    self.isScreenLandScape = NO;
    [UIApplication sharedApplication].statusBarHidden = YES;
}
/**
 *    @brief    转为竖屏
 */
- (void)turnPortrait {
    self.isScreenLandScape = YES;
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.isScreenLandScape = NO;
}
@end
