//
//  OfflinePlayBackViewController.m
//  CCOffline
//
//  Created by 何龙 on 2019/5/14.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "OfflinePlayBackViewController.h"
#import "CCPlayBackView.h"//视频视图
#import "CCSDK/SaveLogUtil.h"//日志
#import "CCPlayBackInteractionView.h"//回放互动视图
#import "CCSDK/OfflinePlayBack.h"//离线下载
//#ifdef LockView
#import "CCLockView.h"//锁屏
//#endif
#import <AVFoundation/AVFoundation.h>
/*
 *******************************************************
 *      去除锁屏界面功能步骤如下：                          *
 *  1。command+F搜索   #ifdef LockView                  *
 *                                                     *
 *  2.删除 #ifdef LockView 至 #endif之间的代码            *
 *******************************************************
 */

@interface OfflinePlayBackViewController ()<OfflinePlayBackDelegate,UIScrollViewDelegate, CCPlayBackViewDelegate>

@property (nonatomic,strong)CCPlayBackInteractionView  * interactionView;//互动视图
@property (nonatomic,strong)CCPlayBackView              * playerView;//视频视图
@property (nonatomic,strong)OfflinePlayBack             * offlinePlayBack;
//#ifdef LockView
@property (nonatomic,strong)CCLockView                  * lockView;//锁屏视图
//#endif
@property (nonatomic,assign) BOOL                       pauseInBackGround;//后台是否暂停
@property (nonatomic,assign) BOOL                       enterBackGround;//是否进入后台
@property (nonatomic,copy)  NSString                    * groupId;//聊天分组
@property (nonatomic,copy)  NSString                    * roomName;//房间名
@property(nonatomic,  copy)NSString                 *destination;

#pragma mark - 文档显示模式
@property (nonatomic,assign)BOOL                        isSmallDocView;//是否是文档小屏
@property (nonatomic,strong)UIView                      * onceDocView;//临时DocView(双击ppt进入横屏调用)
@property (nonatomic,strong)UIView                      * oncePlayerView;//临时playerView(双击ppt进入横屏调用)
@property (nonatomic,strong)UILabel                  *label;

@end

@implementation OfflinePlayBackViewController

-(instancetype)initWithDestination:(NSString *)destination {
    self = [super init];
    if (self) {
        self.destination = destination;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化背景颜色，设置状态栏样式
    self.view.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    /*  设置后台是否暂停 ps:后台支持播放时将会开启锁屏播放器 */
    _pauseInBackGround = NO;
    _isSmallDocView = YES;
    [self setupUI];//设置UI布局
    [self addObserver];//添加通知
    [self integrationSDK];//集成SDK
    self.label = [[UILabel alloc] init];
    [self.view addSubview:self.label];
    self.label.frame = CGRectMake(100, 100, 200, 100);
//        UIButton *btn = [[UIButton alloc] init];
//        [btn setBackgroundColor:[UIColor redColor]];
//        [self.view addSubview:btn];
//        btn.frame = CGRectMake(100, 100, 100, 100);
//        [btn addTarget:self action:@selector(changedoc) forControlEvents:UIControlEventTouchUpInside];
}
- (void)changedoc {
    [self.offlinePlayBack requestCancel];
    self.offlinePlayBack = nil;
    _pauseInBackGround = NO;
    _isSmallDocView = YES;
     [self integrationSDK];//集成SDK
    [_offlinePlayBack continueFromTheTime:0];
    _offlinePlayBack.currentPlaybackTime = 0;
}
//集成SDK
- (void)integrationSDK {
    UIView *docView = _isSmallDocView ? _playerView.smallVideoView : _interactionView.docView;
    PlayParameter *parameter = [[PlayParameter alloc] init];
//    parameter.userId = GetFromUserDefaults(PLAYBACK_USERID);//userId
//    parameter.roomId = GetFromUserDefaults(PLAYBACK_ROOMID);//roomId
//    parameter.liveId = GetFromUserDefaults(PLAYBACK_LIVEID);//liveId
//    parameter.viewerName = GetFromUserDefaults(PLAYBACK_USERNAME);//用户名
//    parameter.token = GetFromUserDefaults(PLAYBACK_PASSWORD);//密码
    parameter.docParent = docView;//文档小窗
    parameter.docFrame = CGRectMake(0, 0, docView.frame.size.width, docView.frame.size.height);//文档小窗大小
    parameter.playerParent = self.playerView;//视频视图
    parameter.playerFrame = CGRectMake(0, 0,self.playerView.frame.size.width, self.playerView.frame.size.height);//视频位置,ps:起始位置为视频视图坐标
    parameter.security = NO;//是否开启https,建议开启
    parameter.PPTScalingMode = 2;//ppt展示模式,建议值为4
    parameter.pauseInBackGround = _pauseInBackGround;//后台是否暂停
    parameter.defaultColor = [UIColor blackColor];//ppt默认底色，不写默认为白色
    parameter.scalingMode = 1;//屏幕适配方式
//    parameter.pptInteractionEnabled = !_isSmallDocView;//是否开启ppt滚动
    parameter.pptInteractionEnabled = YES;
    parameter.destination = self.destination;
    
    
    _offlinePlayBack = [[OfflinePlayBack alloc] initWithParameter:parameter];
    _offlinePlayBack.delegate = self;
    [_offlinePlayBack startPlayAndDecompress];
    
    /* 设置playerView */
    [self.playerView showLoadingView];//显示视频加载中提示
}
#pragma mark- 必须实现的代理方法
/**
 *    @brief    请求成功
 */
-(void)requestSucceed {
    NSLog(@"请求成功！");
}

/**
 *    @brief    登录请求失败
 */
-(void)requestFailed:(NSError *)error reason:(NSString *)reason {
    NSString *message = nil;
    if (reason == nil) {
        message = [error localizedDescription];
    } else {
        message = reason;
    }
    NSLog(@"请求失败:%@", message);
    CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:message sureAction:@"好的" cancelAction:nil sureBlock:nil];
    [APPDelegate.window addSubview:alertView];
}

#pragma mark-----------------------功能代理方法 用哪个实现哪个-------------------------------
#pragma mark - 服务端给自己设置的信息
/**
 *    @brief    服务器端给自己设置的信息(The new method)
 *    groupId 分组id
 *    name 用户名
 */
-(void)setMyViewerInfo:(NSDictionary *) infoDic{
    //如果没有groupId这个字段,设置groupId为空(为空时默认显示所有聊天)
    //    if([[infoDic allKeys] containsObject:@"groupId"]){
    //        _groupId = infoDic[@"groupId"];
    //    }else{
    //        _groupId = @"";
    //    }
    _groupId = @"";
    _interactionView.groupId = _groupId;
}
#pragma mark- 房间信息
/**
 *    @brief  房间信息
 */
-(void)offline_roomInfo:(NSDictionary *)dic{
    _roomName = dic[@"name"];
    
    WS(weakSelf)
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSInteger type = [dic[@"templateType"] integerValue];
        if (type == 4 || type == 5) { ///离线回放添加小窗
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.playerView addSmallView];
            });
        }
        //设置房间标题
        weakSelf.playerView.titleLabel.text = dic[@"name"];
        //配置互动视图的信息
        [weakSelf.interactionView roomInfo:dic playerView:self.playerView];
    });
}
#pragma mark- 回放的开始时间和结束时间
/**
 *  @brief 回放的开始时间和结束时间
 */
-(void)liveInfo:(NSDictionary *)dic {
    //    NSLog(@"%@",dic);
    SaveToUserDefaults(LIVE_STARTTIME, dic[@"startTime"]);
}
#pragma mark- 聊天
/**
 *    @brief    解析本房间的历史聊天数据
 */
-(void)offline_onParserChat:(NSArray *)arr {
    if ([arr count] == 0) {
        return;
    }
    //解析历史聊天
    [self.interactionView onParserChat:arr];
}

- (void)offline_loadVideoFail {
    NSLog(@"播放器异常，加载失败");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"视频错误,请重新下载" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDestructive handler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)pageChangeList:(NSMutableArray *)array {
    //    NSLog(@"%@",array);
}
-(void)onPageChange:(NSDictionary *)dictionary {
    //    NSLog(@"翻页数据是%@",dictionary);
}

-(void)broadcastHistory_msg:(NSArray *)array {
    //    NSLog(@"历史广播%@",array);
}
#pragma mark- 问答
/**
 *    @brief    收到本房间的历史提问&回答
 */
- (void)offline_onParserQuestionArr:(NSArray *)questionArr onParserAnswerArr:(NSArray *)answerArr
{
    //    NSLog(@"questionArr = %@,answerArr = %@",questionArr,answerArr);
    [self.interactionView onParserQuestionArr:questionArr onParserAnswerArr:answerArr];
}
//监听播放状态
-(void)movieLoadStateDidChange:(NSNotification*)notification
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
//回放速率改变
- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    switch (_offlinePlayBack.ijkPlayer.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            break;
        }
        case IJKMPMoviePlaybackStatePlaying:
        case IJKMPMoviePlaybackStatePaused: {
            if(self.playerView.pauseButton.selected == YES && [_offlinePlayBack isPlaying]) {
                [_offlinePlayBack pausePlayer];
            }
            if(self.playerView.loadingView && ![self.playerView.timer isValid]) {
                //                NSLog(@"__test 重新开始播放视频, slider.value = %f", _playerView.slider.value);
                //#ifdef LockView
                if (_pauseInBackGround == NO) {//后台支持播放
                    [self setLockView];//设置锁屏界面
                }
                //#endif
                [self.playerView removeLoadingView];//移除加载视图
                /*      保存日志     */
                [[SaveLogUtil sharedInstance] saveLog:@"" action:SAVELOG_ALERT];
                
                
                /* 当视频被打断时，重新开启视频需要校对时间 */
                if (_playerView.slider.value != 0) {
                    _offlinePlayBack.currentPlaybackTime = _playerView.slider.value;
                    //开启playerView的定时器,在timerfunc中去校对SDK中播放器相关数据
                    [self.playerView startTimer];
                    return;
                }
                
                
                /*   从0秒开始加载文档  */
                [_offlinePlayBack continueFromTheTime:0];
                /*   Ps:从100秒开始加载视频  */
                //                [_requestDataPlayBack continueFromTheTime:100];
                //开启playerView的定时器,在timerfunc中去校对SDK中播放器相关数据
                [self.playerView startTimer];
            }
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
//移除通知
- (void)dealloc {
    //    NSLog(@"%s", __func__);
    /*      自动登录情况下，会存在移除控制器但是SDK没有销毁的情况 */
    if (_offlinePlayBack) {
        [_offlinePlayBack requestCancel];
        _offlinePlayBack = nil;
    }
    [self removeObserver];
    [self.interactionView removeData];
}
#pragma mark - 设置UI

/**
 创建UI
 */
- (void)setupUI {
    //添加视频播放视图
    _playerView = [[CCPlayBackView alloc] initWithFrame:CGRectZero docViewType:_isSmallDocView];
    _playerView.delegate = self;
    
    //退出直播间回调
    WS(weakSelf)
    _playerView.exitCallBack = ^{
        [weakSelf.offlinePlayBack requestCancel];
        weakSelf.offlinePlayBack = nil;
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    //滑块滑动完成回调
    _playerView.sliderCallBack = ^(int duration) {
        weakSelf.offlinePlayBack.currentPlaybackTime = duration;
        //#ifdef LockView
        /*  校对锁屏播放器进度 */
        [weakSelf.lockView updateCurrentDurtion:weakSelf.offlinePlayBack.currentPlaybackTime];
        //#endif
        if (weakSelf.offlinePlayBack.ijkPlayer.playbackState != IJKMPMoviePlaybackStatePlaying) {
            [weakSelf.offlinePlayBack startPlayer];
            [weakSelf.playerView startTimer];
        }
    };
    //滑块移动回调
    _playerView.sliderMoving = ^{
        if (weakSelf.offlinePlayBack.ijkPlayer.playbackState != IJKMPMoviePlaybackStatePaused) {
            [weakSelf.offlinePlayBack pausePlayer];
            [weakSelf.playerView stopTimer];
        }
    };
    //更改播放器速率回调
    _playerView.changeRate = ^(float rate) {
        weakSelf.offlinePlayBack.ijkPlayer.playbackRate = rate;
    };
    //暂停/开始播放回调
    _playerView.pausePlayer = ^(BOOL pause) {
        if (pause) {
            [weakSelf.playerView stopTimer];
            [weakSelf.offlinePlayBack pausePlayer];
        }else{
            [weakSelf.playerView startTimer];
            [weakSelf.offlinePlayBack startPlayer];
        }
    };
    [self.view addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(CCGetRealFromPt(462));
        make.top.equalTo(self.view).offset(SCREEN_STATUS);
    }];
    [self.playerView layoutIfNeeded];
    
    //添加互动视图
    self.interactionView = [[CCPlayBackInteractionView alloc] initWithFrame:CGRectMake(0, CCGetRealFromPt(462)+SCREEN_STATUS, SCREEN_WIDTH,IS_IPHONE_X ? CCGetRealFromPt(835) + 90:CCGetRealFromPt(835)) docViewType:_isSmallDocView];
    [self.view addSubview:self.interactionView];
}
//#ifdef LockView
/**
 设置锁屏播放器界面
 */
-(void)setLockView{
    if (_lockView) {//如果当前已经初始化，return;
        return;
    }
    _lockView = [[CCLockView alloc] initWithRoomName:_roomName duration:_offlinePlayBack.ijkPlayer.duration];
    [self.view addSubview:_lockView];
    [_offlinePlayBack.ijkPlayer setPauseInBackground:self.pauseInBackGround];
    WS(weakSelf)
    /*     播放/暂停回调     */
    _lockView.pauseCallBack = ^(BOOL pause) {
        weakSelf.playerView.pauseButton.selected = pause;
        if (pause) {
            [weakSelf.playerView stopTimer];
            [weakSelf.offlinePlayBack.ijkPlayer pause];
        }else{
            [weakSelf.playerView startTimer];
            [weakSelf.offlinePlayBack.ijkPlayer play];
        }
    };
    /*     快进/快退回调     */
    _lockView.progressBlock = ^(int time) {
        //        NSLog(@"---playBack快进/快退至%d秒", time);
        weakSelf.offlinePlayBack.currentPlaybackTime = time;
        weakSelf.playerView.slider.value = time;
        weakSelf.playerView.sliderValue = weakSelf.playerView.slider.value;
    };
}
//#endif
#pragma mark - playViewDelegate
/**
 开始播放时
 */
-(void)timerfunc{
    if([_offlinePlayBack isPlaying]) {
        [self.playerView removeLoadingView];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //获取当前播放时间和视频总时长
        NSTimeInterval position = (int)round(self.offlinePlayBack.currentPlaybackTime);
        NSTimeInterval duration = (int)round(self.offlinePlayBack.playerDuration);
        //存在播放器最后一点不播放的情况，所以把进度条的数据对到和最后一秒想同就可以了
        if(duration - position == 1 && (self.playerView.sliderValue == position || self.playerView.sliderValue == duration)) {
            position = duration;
        }
        //                            NSLog(@"__test --%f",_requestDataPlayBack.currentPlaybackTime);
        
        //设置plaerView的滑块和右侧时间Label
        self.playerView.slider.maximumValue = (int)duration;
        self.playerView.rightTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(duration / 60), (int)(duration) % 60];
        
        //校对SDK当前播放时间
        if(position == 0 && self.playerView.sliderValue != 0) {
            self.offlinePlayBack.currentPlaybackTime = self.playerView.sliderValue;
            self.playerView.slider.value = self.playerView.sliderValue;
        } else {
            self.playerView.slider.value = position;
            self.playerView.sliderValue = self.playerView.slider.value;
        }
        
        //校对本地显示速率和播放器播放速率
        if(self.offlinePlayBack.ijkPlayer.playbackRate != self.playerView.playBackRate) {
            self.offlinePlayBack.ijkPlayer.playbackRate = self.playerView.playBackRate;
            //#ifdef LockView
            //校对锁屏播放器播放速率
            [self.lockView updatePlayBackRate:self.offlinePlayBack.ijkPlayer.playbackRate];
            //#endif
            [self.playerView startTimer];
        }
        if(self.playerView.pauseButton.selected == NO && self.offlinePlayBack.ijkPlayer.playbackState == IJKMPMoviePlaybackStatePaused) {
            //开启播放视频
            [self.offlinePlayBack startPlayer];
        }
        /* 获取当前时间段的文档数据  time：从直播开始到现在的秒数，SDK会在画板上绘画出来相应的图形 */
        [self.offlinePlayBack continueFromTheTime:self.playerView.sliderValue];
        
        /*  加载聊天数据 */
        [self parseChatOnTime:(int)self.playerView.sliderValue];
        //更新左侧label
        self.playerView.leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(self.playerView.sliderValue / 60), (int)(self.playerView.sliderValue) % 60];
        //#ifdef LockView
        /*  校对锁屏播放器进度 */
        [self.lockView updateCurrentDurtion:_offlinePlayBack.currentPlaybackTime];
        //#endif
    });
}
/**
 全屏按钮点击代理
 
 @param tag 1视频为主，2文档为主
 */
-(void)quanpingBtnClicked:(NSInteger)tag{
    if (tag == 1) {
        [_offlinePlayBack changePlayerFrame:self.view.frame];
    } else {
        [_offlinePlayBack changeDocFrame:self.view.frame];
    }
    //隐藏互动视图
    [self hiddenInteractionView:YES];
}
/**
 返回按钮点击代理
 
 @param tag 1.视频为主，2.文档为主
 */
-(void)backBtnClicked:(NSInteger)tag{
    if (tag == 1) {
        [_offlinePlayBack changePlayerFrame:CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462))];
    } else {
        [_offlinePlayBack changeDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462))];
    }
    //显示互动视图
    [self hiddenInteractionView:NO];
}
/**
 切换视频/文档按钮点击回调
 
 @param tag changeBtn的tag值
 */
-(void)changeBtnClicked:(NSInteger)tag{
    if (tag == 2) {
        [_offlinePlayBack changeDocParent:self.playerView];
        [_offlinePlayBack changePlayerParent:self.playerView.smallVideoView];
        [_offlinePlayBack changeDocFrame:CGRectMake(0, 0,self.playerView.frame.size.width, self.playerView.frame.size.height)];
        [_offlinePlayBack changePlayerFrame:CGRectMake(0, 0, self.playerView.smallVideoView.frame.size.width, self.playerView.smallVideoView.frame.size.height)];
    }else{
        [_offlinePlayBack changeDocParent:self.playerView.smallVideoView];
        [_offlinePlayBack changePlayerParent:self.playerView];
        [_offlinePlayBack changePlayerFrame:CGRectMake(0, 0,self.playerView.frame.size.width, self.playerView.frame.size.height)];
        [_offlinePlayBack changeDocFrame:CGRectMake(0, 0, self.playerView.smallVideoView.frame.size.width, self.playerView.smallVideoView.frame.size.height)];
    }
}
/**
 隐藏互动视图
 
 @param hidden 是否隐藏
 */
-(void)hiddenInteractionView:(BOOL)hidden{
    self.interactionView.hidden = hidden;
}
/**
 通过传入时间获取聊天信息
 
 @param time 传入的时间
 */
-(void)parseChatOnTime:(int)time{
    [self.interactionView parseChatOnTime:time];
}
#pragma mark - 添加通知
//通知监听
-(void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieLoadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

//移除通知
-(void) removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}
/**
 APP将要进入前台
 */
- (void)appWillEnterForegroundNotification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _enterBackGround = NO;
    });
    //#ifdef LockView
    /*  当视频播放被打断时，重新加载视频  */
    if (!self.offlinePlayBack.ijkPlayer.playbackState) {
        [self.offlinePlayBack replayPlayer];
        [self.lockView updateLockView];
    }
    //#endif
    if (self.playerView.pauseButton.selected == NO) {
        [self.playerView startTimer];
    }
}

/**
 APP将要进入后台
 */
- (void)appWillEnterBackgroundNotification {
    _enterBackGround = YES;
    UIApplication *app = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier taskID = 0;
    taskID = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:taskID];
    }];
    if (taskID == UIBackgroundTaskInvalid) {
        return;
    }
    [self.playerView stopTimer];
}

/**
 程序从后台激活
 */
- (void)applicationDidBecomeActiveNotification {
    if (_enterBackGround == NO && ![_offlinePlayBack isPlaying]) {
        /*  如果当前视频不处于播放状态，重新进行播放,初始化播放状态 */
        [_offlinePlayBack replayPlayer];
        [_playerView stopTimer];
        [_playerView showLoadingView];
        //#ifdef LockView
        [_lockView updateLockView];
        //#endif
        //        NSLog(@"__test 视频被打断，重新播放视频");
        //        NSLog(@"__test 当前的播放时间为:%f", _playerView.slider.value);
    }
}
#pragma mark - 横竖屏旋转设置
//旋转方向
- (BOOL)shouldAutorotate{
    if (self.playerView.isScreenLandScape == YES) {
        return YES;
    }
    return NO;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    
    return  YES;
}

@end
