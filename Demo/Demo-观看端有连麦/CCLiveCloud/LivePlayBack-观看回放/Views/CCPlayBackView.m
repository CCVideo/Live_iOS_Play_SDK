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

@property (nonatomic, strong)NSTimer                    * playerTimer;//隐藏导航定时器
@property (nonatomic, strong)InformationShowView        * informationViewPop;//提示视图
@property (nonatomic, assign)BOOL                       isSmallDocView;//是否是文档小窗

@property (nonatomic, strong)UILabel                    * unStart;//重新播放

@property (nonatomic, assign)NSInteger                  showShadowCountFlag;
// 新增控制阴影View
@property (nonatomic, assign)BOOL                       isShowShadowView;

@end

@implementation CCPlayBackView

//初始化视图
- (instancetype)initWithFrame:(CGRect)frame docViewType:(BOOL)isSmallDocView{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        _sliderValue = 0;//初始化滑动条进度
        _playBackRate = 1.0;//初始化回放速率
        _isSmallDocView = isSmallDocView;//是否是文档小窗
        [self setupUI];
    }
    return self;
}

/**
 视图销毁时去掉timer
 */
-(void)dealloc {
//    NSLog(@"%s", __func__);
}

//滑动事件
- (void) UIControlEventTouchDown:(UISlider *)sender {
    UIImage *image = [UIImage imageNamed:@"progressBar"];//图片模式，不设置的话会被压缩
    [_slider setThumbImage:image forState:UIControlStateNormal];//设置图片
}
//滑动完成
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
    //滑块完成回调
    self.sliderCallBack(duration);
}
//滑块正在移动时
- (void) durationSliderMoving:(UISlider *)sender
{
    _pauseButton.selected = NO;
    int duration = (int)sender.value;
    _leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", duration / 60, duration % 60];
    _slider.value = duration;
    //滑块移动回调
    self.sliderMoving();
}

/**
 隐藏导航
 */
- (void)LatencyHiding {
//    if (self.bottomShadowView.hidden == NO) {
//        self.bottomShadowView.hidden = YES;
//        self.topShadowView.hidden = YES;
//    }
    [self showOrHiddenShadowView];
}

/**
 隐藏导航

 @param recognizer 手势
 */
- (void)doTapChange:(UITapGestureRecognizer*) recognizer {
    
//    if (self.bottomShadowView.hidden == YES) {
//        self.bottomShadowView.hidden = NO;
//        self.topShadowView.hidden = NO;
//        [self.topShadowView becomeFirstResponder];
//        [self bringSubviewToFront:self.topShadowView];
//        [self bringSubviewToFront:self.bottomShadowView];
//    } else {
//        self.bottomShadowView.hidden = YES;
//        self.topShadowView.hidden = YES;
//        [self.topShadowView resignFirstResponder];
//    }
//    [self endEditing:NO];
    [self showOrHiddenShadowView];
    
}

/**
*  @brief  隐藏导航
*/
- (void)showOrHiddenShadowView
{
    if (_isShowShadowView == NO) {

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
}

/**
 创建UI
 */
- (void)setupUI {
    
    _isShowShadowView = YES;
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
        make.left.equalTo(self.topShadowView).offset(CCGetRealFromPt(10));
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
    [self.changeButton setTitle:PLAY_CHANGEDOC forState:UIControlStateNormal];
    [self.topShadowView addSubview:self.changeButton];
    [self.changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topShadowView).offset(CCGetRealFromPt(-20));
        make.centerY.equalTo(self.backButton);
        make.height.mas_equalTo(CCGetRealFromPt(50));
        make.width.mas_equalTo(CCGetRealFromPt(180));
    }];
    [self.changeButton layoutIfNeeded];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.left.equalTo(self.backButton.mas_right);
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
    [_slider addTarget:self action:@selector(durationSliderDone:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
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
        make.top.mas_equalTo(self.rightTimeLabel.mas_centerY).offset(-2);
        make.height.mas_equalTo(CCGetRealFromPt(34));
        make.width.mas_equalTo(SCREEN_WIDTH - CCGetRealFromPt(460));
    }];
    [self.slider layoutIfNeeded];
    
    //单击手势
    UITapGestureRecognizer *TapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTapChange:)];
    TapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:TapGesture];

    //隐藏导航
    [self stopPlayerTimer];
    
    CCProxy *weakObject = [CCProxy proxyWithWeakObject:self];
    self.playerTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:weakObject selector:@selector(LatencyHiding) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_playerTimer forMode:NSRunLoopCommonModes];
    
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
    __weak typeof(self)weakSelf = self;
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
        make.centerX.equalTo(self.liveEnd);
        make.height.width.mas_equalTo(CCGetRealFromPt(64));
        make.centerY.equalTo(self.liveEnd.mas_centerY).offset(-10);
    }];
    
    self.unStart = [[UILabel alloc] init];
    self.unStart.textColor = [UIColor whiteColor];
    self.unStart.alpha = 0.6f;
    self.unStart.textAlignment = NSTextAlignmentCenter;
    self.unStart.font = [UIFont systemFontOfSize:FontSize_30];
    self.unStart.text = PLAY_END;
    [self.liveEnd addSubview:self.unStart];
    self.unStart.frame = CGRectMake(SCREEN_WIDTH/2-50, CCGetRealFromPt(271), 100, 30);
    
    
}
- (void)addSmallView {
    [APPDelegate.window addSubview:_smallVideoView];
}
#pragma mark - btn点击事件

/**
 点击切换倍速按钮
 */
-(void)playbackRateBtnClicked {
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
 点击暂停和继续
 */
- (void)pauseButtonClick {
    if (self.pauseButton.selected == NO) {
        self.pauseButton.selected = YES;
        self.pausePlayer(YES);
    } else if (self.pauseButton.selected == YES){
        self.pauseButton.selected = NO;
        self.pausePlayer(NO);
    }
}
//强制转屏
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation{
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
 点击全屏按钮

 @param sender sender
 */
- (void)quanpingButtonClick:(UIButton *)sender {
    UIView *view = [self superview];
    if (!sender.selected) {
        sender.selected = YES;
        sender.tag = 2;
        self.backButton.tag = 2;
//        self.isScreenLandScape = YES;
//        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
//        self.isScreenLandScape = NO;
//        [UIApplication sharedApplication].statusBarHidden = YES;
        [self turnRight];
        if (self.delegate) {
            [self.delegate quanpingBtnClicked:_changeButton.tag];
        }
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(view);
            make.height.mas_equalTo(SCREENH_HEIGHT);
        }];
        [self layoutIfNeeded];//
        [self layouUI:YES];
        CGRect rect = view.frame;
        [self.smallVideoView setFrame:CGRectMake(rect.size.width -CCGetRealFromPt(220), CCGetRealFromPt(332), CCGetRealFromPt(200), CCGetRealFromPt(150))];
    } else {
        sender.selected = NO;
        [self backButtonClick:sender];
        sender.tag = 1;
    }
}
//切换视频和文档
- (void)changeButtonClick:(UIButton *)sender {
    if (_smallVideoView.hidden) {
        NSString *title = _changeButton.tag == 1 ? PLAY_CHANGEDOC : PLAY_CHANGEVIDEO;
        [_changeButton setTitle:title forState:UIControlStateNormal];
        _smallVideoView.hidden = NO;
        return;
    }
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
    [self bringSubviewToFront:self.topShadowView];
    [self bringSubviewToFront:self.bottomShadowView];
}
//结束直播和退出全屏
- (void)backButtonClick:(UIButton *)sender {
    UIView *view = [self superview];
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
            make.left.right.equalTo(view);
            make.height.mas_equalTo(CCGetRealFromPt(462));
            make.top.equalTo(view).offset(SCREEN_STATUS);
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
    if (point.y > 0 && point.y <= CCGetRealFromPt(88)) { //过滤掉顶部shadowView
        _showShadowCountFlag = 0;
        return [super hitTest:point withEvent:event];
    }else if (point.y >= selfH - CCGetRealFromPt(60) && point.y <= selfH) { ////过滤掉底部shadowView
        _showShadowCountFlag = 0;
        return [super  hitTest:point withEvent:event];
    }else {
        if (_showShadowCountFlag == 2) {
            _isShowShadowView = _isShowShadowView == YES ? NO : YES;
            [self showOrHiddenShadowView];
            _showShadowCountFlag = 0;
        }
        return [super hitTest:point withEvent:event];
    }
}

//创建提示窗
-(void)creatAlertController_alert {
    //设置提示弹窗
    WS(weakSelf)
    CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:ALERT_EXITPLAYBACK sureAction:SURE cancelAction:CANCEL sureBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf exitPlayBack];
        });
    }];
    [APPDelegate.window addSubview:alertView];
}
//退出直播回放
-(void)exitPlayBack{
    [self.smallVideoView removeFromSuperview];
    [self stopTimer];
    [self stopPlayerTimer];
//    NSLog(@"退出直播回放");
    if (self.exitCallBack) {
        self.exitCallBack();//退出回放回调
    }
}
#pragma mark - 播放和根据时间添加数据
//播放和根据时间添加数据
- (void)timerfunc
{
    if (self.delegate) {
        [self.delegate timerfunc];
    }
}
//开始播放
-(void)startTimer {
    [self stopTimer];
    CCProxy *weakObject = [CCProxy proxyWithWeakObject:self];
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / _playBackRate) target:weakObject selector:@selector(timerfunc) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_timer forMode:NSRunLoopCommonModes];
}
//停止播放
-(void) stopTimer {
    if([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

/**
 显示视频加载中样式
 */
-(void)showLoadingView{
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
 移除视频加载中样式
 */
-(void)removeLoadingView{
    if(_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
}
#pragma mark - 切换横竖屏
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
//        [self.backButton layoutIfNeeded];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.backButton);
            make.left.equalTo(self.backButton.mas_right);
            make.right.equalTo(self.changeButton.mas_left).offset(-60);
        }];
//        [self.titleLabel layoutIfNeeded];
        [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH - CCGetRealFromPt(460)-(IS_IPHONE_X?88:0));
        }];
        [self.slider layoutIfNeeded];
        self.liveEnd.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT);
        self.unStart.frame = CGRectMake(SCREEN_WIDTH/2-50, CCGetRealFromPt(400), 100, 30);
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
//        [self.backButton layoutIfNeeded];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.backButton);
            make.left.equalTo(self.backButton.mas_right);
            make.right.equalTo(self.changeButton.mas_left).offset(-5);
        }];
//        [self.titleLabel layoutIfNeeded];
        [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH - CCGetRealFromPt(460));
        }];
        [self.slider layoutIfNeeded];
        self.liveEnd.frame = CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462));
        self.unStart.frame = CGRectMake(SCREEN_WIDTH/2-50, CCGetRealFromPt(271), 100, 30);
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

#pragma mark - 隐藏视频小窗
//隐藏小窗视图
-(void)hiddenSmallVideoview{
    _smallVideoView.hidden = YES;
    NSString *title = self.changeButton.tag == 1 ? PLAY_SHOWDOC : PLAY_SHOWVIDEO;
    [self.changeButton setTitle:title forState:UIControlStateNormal];
}
#pragma mark - 横竖屏旋转
//转为横屏
-(void)turnRight{
    self.isScreenLandScape = YES;
    [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    self.isScreenLandScape = NO;
    [UIApplication sharedApplication].statusBarHidden = YES;
}
//转为竖屏
-(void)turnPortrait{
    self.isScreenLandScape = YES;
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.isScreenLandScape = NO;
}
@end
