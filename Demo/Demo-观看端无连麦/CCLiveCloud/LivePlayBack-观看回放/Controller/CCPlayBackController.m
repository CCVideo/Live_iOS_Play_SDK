//
//  CCPlayBackController.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/20.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCPlayBackController.h"
#import "CCPlayBackView.h"//视频视图
#import "CCSDK/RequestDataPlayBack.h"//sdk
#import <CCSDK/SaveLogUtil.h>//日志
#import "CCPlayBackInteractionView.h"//回放互动视图
//#ifdef LockView
#import "CCLockView.h"//锁屏
//#endif
#import <AVFoundation/AVFoundation.h>
#define kHDRecordHistory @"HDPlayBackRecordHistoryPlayTime"
/*
 *******************************************************
 *      去除锁屏界面功能步骤如下：                          *
 *  1。command+F搜索   #ifdef LockView                  *
 *                                                     *
 *  2.删除 #ifdef LockView 至 #endif之间的代码            *
 *******************************************************
 */

@interface CCPlayBackController ()<RequestDataPlayBackDelegate,UIScrollViewDelegate, CCPlayBackViewDelegate>

@property (nonatomic,strong)CCPlayBackInteractionView   * interactionView;//互动视图
@property (nonatomic,strong)CCPlayBackView              * playerView;//视频视图
@property (nonatomic,strong)RequestDataPlayBack         * requestDataPlayBack;//sdk
//#ifdef LockView
@property (nonatomic,strong)CCLockView                  * lockView;//锁屏视图
//#endif
@property (nonatomic,assign) BOOL                       pauseInBackGround;//后台是否暂停
@property (nonatomic,assign) BOOL                       enterBackGround;//是否进入后台
@property (nonatomic,copy)  NSString                    * groupId;//聊天分组
@property (nonatomic,copy)  NSString                    * roomName;//房间名

#pragma mark - 文档显示模式
@property (nonatomic,assign)BOOL                        isSmallDocView;//是否是文档小屏
@property (nonatomic,strong)UIView                      * onceDocView;//临时DocView(双击ppt进入横屏调用)
@property (nonatomic,strong)UIView                      * oncePlayerView;//临时playerView(双击ppt进入横屏调用)
@property (nonatomic,strong)UILabel                     *label;
@property (nonatomic,assign)CGFloat                        playTime;
@property (nonatomic,strong)HDMarqueeView               * marqueeView;//跑马灯
@property (nonatomic,strong)NSDictionary                * jsonDict;//跑马灯数据
   
@property (nonatomic, strong)PlayParameter              * toolParam;
/** 记录切换ppt缩放模式 */
@property (nonatomic, assign)NSInteger                  pptScaleMode;

@property (nonatomic, strong) PlayParameter             *parameter;

@property(nonatomic,strong)UILabel                      *currenMemoryLable;

/** 是否播放完成 */
@property (nonatomic, assign)BOOL                       isPlayDone;

/** 历史播放记录 记录器(连续播放5s才进行记录) */
@property (nonatomic, assign)int                        recordHistoryCount;
/** 历史播放记录时间 */
@property (nonatomic, assign)int                        recordHistoryTime;
/** 是否显示过历史播放记录 */
@property (nonatomic, assign)BOOL                       isShowRecordHistory;

@end

@implementation CCPlayBackController
- (PlayParameter *)toolParam {
    if (!_toolParam) {
        _toolParam = [[PlayParameter alloc] init];
    }
    return _toolParam;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化背景颜色，设置状态栏样式
    self.view.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    /*  设置后台是否暂停 ps:后台支持播放时将会开启锁屏播放器 */
    _pauseInBackGround = NO;
    _isSmallDocView = YES;
    
    _recordHistoryTime = 0;
    _recordHistoryCount = 0;
    _isShowRecordHistory = NO;
    
    [self setupUI];//设置UI布局 
    [self addObserver];//添加通知
    [self integrationSDK];//集成SDK
}
/**
 *    @brief   回放翻页数据列表
 *    @param   array [{  docName         //文档名
                        pageTitle       //页标题
                        time            //时间
                        url             //地址 }]
 */
- (void)pageChangeList:(NSMutableArray *)array {
    
}
- (void)publish_stream {
//    NSLog(@"可播放时间%f",_requestDataPlayBack.ijkPlayer.playableDuration);
}

/**
 *    @brief    翻页同步之前的文档展示模式
 */
- (void)onPageChange:(NSDictionary *)dictionary {
    
}

- (void)videoStateChangeWithString:(NSString *)result {
//    NSLog(@"---状态是%@",result);
}

/**
 切换回放,需要重新配置参数
 ps:切换频率不能过快
 */
- (void)changeVideo {
        [self deleteData];
        _pauseInBackGround = YES;
        _isSmallDocView = YES;
        [self setupUI];//设置UI布局
        [self addObserver];//添加通知
        UIView *docView = _isSmallDocView ? _playerView.smallVideoView : _interactionView.docView;
        PlayParameter *parameter = [[PlayParameter alloc] init];
        parameter.userId = @"";//userId
        parameter.roomId = @"";//roomId
        parameter.liveId = @"";//liveId
        parameter.recordId = @"";//回放Id
        parameter.viewerName = @"";//用户名
        parameter.token = @"";//密码
        parameter.docParent = docView;//文档小窗
        parameter.docFrame = CGRectMake(0, 0,self.playerView.frame.size.width, self.playerView.frame.size.height);//视频位置,ps:起始位置为视频视图坐标
        parameter.playerParent = self.playerView;//视频视图
        parameter.playerFrame = CGRectMake(0, 0, docView.frame.size.width, docView.frame.size.height);//文档小窗大小
        parameter.security = YES;//是否开启https,建议开启
        parameter.PPTScalingMode = 4;//ppt展示模式,建议值为4
        parameter.pauseInBackGround = _pauseInBackGround;//后台是否暂停
        parameter.defaultColor = [UIColor whiteColor];//ppt默认底色，不写默认为白色
        parameter.scalingMode = 1;//屏幕适配方式
//        parameter.pptInteractionEnabled = !_isSmallDocView;//是否开启ppt滚动
        parameter.pptInteractionEnabled = YES;
    //        parameter.groupid = self.groupId;//用户的groupId
        _requestDataPlayBack = [[RequestDataPlayBack alloc] initWithParameter:parameter];
        _requestDataPlayBack.delegate = self;
        _pptScaleMode = parameter.PPTScalingMode;
        /* 设置playerView */
        [self.playerView showLoadingView];//显示视频加载中提示
}
- (void)deleteData {
    [self.playerView.smallVideoView removeFromSuperview];
    if (_requestDataPlayBack) {
        [_requestDataPlayBack requestCancel];
        _requestDataPlayBack = nil;
    }
    [self removeObserver];
    [self.playerView removeFromSuperview];
    [self.interactionView removeData];
    [self.interactionView removeFromSuperview];
}

//集成SDK
- (void)integrationSDK {

    UIView *docView = _isSmallDocView ? _playerView.smallVideoView : _interactionView.docView;
    _parameter = [[PlayParameter alloc] init];
    _parameter.userId = GetFromUserDefaults(PLAYBACK_USERID);//userId
    _parameter.roomId = GetFromUserDefaults(PLAYBACK_ROOMID);//roomId
    _parameter.liveId = GetFromUserDefaults(PLAYBACK_LIVEID);//liveId
    _parameter.recordId = GetFromUserDefaults(PLAYBACK_RECORDID);//回放Id
    _parameter.viewerName = GetFromUserDefaults(PLAYBACK_USERNAME);//用户名
    _parameter.token = GetFromUserDefaults(PLAYBACK_PASSWORD);//密码
    _parameter.playerParent = docView;//视频视图
    // 1.默认视频小窗显示
    _parameter.playerFrame = CGRectMake(0, 0, docView.frame.size.width, docView.frame.size.height);//文档小窗大小
    _parameter.docParent = self.playerView;//文档小窗
    // 2.默认文档大窗显示
    _parameter.docFrame = CGRectMake(0, 0,self.playerView.frame.size.width, self.playerView.frame.size.height);//视频位置,ps:起始位置为视频视图坐标
    _parameter.security = YES;//是否开启https,建议开启
    _parameter.PPTScalingMode = 4;//ppt展示模式,建议值为4
    _parameter.pauseInBackGround = _pauseInBackGround;//后台是否暂停
    _parameter.defaultColor = [UIColor whiteColor];//ppt默认底色，不写默认为白色
    _parameter.scalingMode = 1;//屏幕适配方式
//    parameter.pptInteractionEnabled = !_isSmallDocView;//是否开启ppt滚动
    _parameter.pptInteractionEnabled = YES;
//        parameter.groupid = self.groupId;//用户的groupId
    _requestDataPlayBack = [[RequestDataPlayBack alloc] initWithParameter:_parameter];
    _requestDataPlayBack.delegate = self;
    
    _pptScaleMode = _parameter.PPTScalingMode;
    /* 设置playerView */
    [self.playerView showLoadingView];//显示视频加载中提示
}
#pragma mark- 必须实现的代理方法

/**
 *    @brief    请求成功
 */
-(void)requestSucceed {
    //    NSLog(@"请求成功！");
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
    //  NSLog(@"请求失败:%@", message);
    NSArray *subviews = [APPDelegate.window subviews];
    
    // 如果没有子视图就直接返回
    if ([subviews count] == 0) return;
    
    for (UIView *subview in subviews) {
        if ([[subview class] isEqual:[CCAlertView class]]) {
            [subview removeFromSuperview];
        }
        
    }
    CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:message sureAction:@"好的" cancelAction:nil sureBlock:nil];
    [APPDelegate.window addSubview:alertView];
}

#pragma mark-----------------------功能代理方法 用哪个实现哪个-------------------------------
/**
 *    @brief    视频状态改变
 *    @param    state
 *              HDMoviePlaybackStateStopped          播放停止
 *              HDMoviePlaybackStatePlaying          开始播放
 *              HDMoviePlaybackStatePaused           暂停播放
 *              HDMoviePlaybackStateInterrupted      播放间断
 *              HDMoviePlaybackStateSeekingForward   播放快进
 *              HDMoviePlaybackStateSeekingBackward  播放后退
 */
- (void)HDMoviePlayBackStateDidChange:(HDMoviePlaybackState)state
{
    switch (state)
    {
        case HDMoviePlaybackStateStopped: {
            self.playerView.playDone = YES;
            break;
        }
        case HDMoviePlaybackStatePlaying:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{            
                if (_isShowRecordHistory == NO) {
                    int time = [self readRecordHistoryPlayTime];
                    if (time > 0) {
                        [self.playerView showRecordHistoryPlayViewWithRecordHistoryTime:time];
                        _isShowRecordHistory = YES;
                    }
                }
            });
        }
        case HDMoviePlaybackStatePaused: {

            if(self.playerView.pauseButton.selected == YES && [_requestDataPlayBack isPlaying]) {
                [_requestDataPlayBack pausePlayer];
            }
            if(self.playerView.loadingView && ![self.playerView.timer isValid]) {
                //#ifdef LockView
                if (_pauseInBackGround == NO) {//后台支持播放
                    [self setLockView];//设置锁屏界面
                }
                //#endif
                [self.playerView removeLoadingView];//移除加载视图
                /* 当视频被打断时，重新开启视频需要校对时间 */
                if (_playerView.slider.value != 0) {
                    _requestDataPlayBack.currentPlaybackTime = _playerView.slider.value;
                    //开启playerView的定时器,在timerfunc中去校对SDK中播放器相关数据
                    //[self.playerView startTimer];
                    return;
                }
                //开启playerView的定时器,在timerfunc中去校对SDK中播放器相关数据
                //[self.playerView startTimer];
            }
            break;
        }
        case HDMoviePlaybackStateInterrupted:
            break;
        case HDMoviePlaybackStateSeekingForward:
            break;
        case HDMoviePlaybackStateSeekingBackward:
            break;
        default:
            break;
    }
}
/**
 *    @brief    视频加载状态
 *    @param    state   播放状态
 *              HDMovieLoadStateUnknown         未知状态
 *              HDMovieLoadStatePlayable        视频未完成全部缓存，但已缓存的数据可以进行播放
 *              HDMovieLoadStatePlaythroughOK   完成缓存
 *              HDMovieLoadStateStalled         数据缓存已经停止，播放将暂停
 */
- (void)HDMovieLoadStateDidChange:(HDMovieLoadState)state
{
    switch (state)
    {
        case HDMovieLoadStateUnknown:
            break;
        case HDMovieLoadStatePlayable:
            break;
        case HDMovieLoadStatePlaythroughOK:
            break;
        case HDMovieLoadStateStalled:
            break;
        default:
            break;
    }
}
/**
 *    @brief    视频播放完成原因
 *    @param    reason  原因
 *              HDMovieFinishReasonPlaybackEnded    自然播放结束
 *              HDMovieFinishReasonUserExited       用户人为结束
 *              HDMovieFinishReasonPlaybackError    发生错误崩溃结束
 */
- (void)HDMoviePlayerPlaybackDidFinish:(HDMovieFinishReason)reason
{
    switch (reason) {
        case HDMovieFinishReasonPlaybackEnded:
            break;
        case HDMovieFinishReasonUserExited:
            break;
        case HDMovieFinishReasonPlaybackError:
            break;
        default:
            break;
    }
}

/**
 *    @brief    读取历史播放记录
 */
- (int)readRecordHistoryPlayTime
{
    int time = 0;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [userDefaults objectForKey:kHDRecordHistory];
    // 1.本地有历史播放记录
    if (![dict isKindOfClass:[NSNull class]]) {
        // 2.是同一个回放
        if ([_parameter.recordId isEqualToString:dict[@"recordId"]]) {
            time = [dict[@"time"] intValue];
        }
    }
    return time;
}

/**
 *    @brief    存储历史播放记录
 */
- (void)saveRecordHistoryPlayTime
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *saveDict = [NSMutableDictionary dictionary];
    NSDictionary *dict = [userDefaults objectForKey:kHDRecordHistory];
    // 1.本地有历史播放记录
    if (![dict isKindOfClass:[NSNull class]]) {
        // 2.是同一个回放
        if ([_parameter.recordId isEqualToString:dict[@"recordId"]]) {
            saveDict[@"time"] = @(self.recordHistoryTime);
            saveDict[@"recordId"] = dict[@"recordId"];
        }else {
            //2.不是同一个回放
            saveDict[@"recordId"] = _parameter.recordId;
            saveDict[@"time"] = @(self.recordHistoryTime);
        }
    }else {
        //1.本地无历史播放记录数据
        saveDict[@"recordId"] = _parameter.recordId;
        saveDict[@"time"] = @(self.recordHistoryTime);
    }
    [userDefaults setObject:saveDict forKey:kHDRecordHistory];
    [userDefaults synchronize];
}

#pragma mark - 播放器时间
/**
 *    @brief    播放器时间
 *    @param    currentTime   当前时间
 *    @param    totalTime     总时间
 */
- (void)HDPlayerCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime
{
    if([_requestDataPlayBack isPlaying]) {
        [self.playerView removeLoadingView];
    }
    
    if (self.recordHistoryTime < currentTime - 5 || self.recordHistoryTime - 5 > currentTime) {
        self.recordHistoryCount = 0;
        self.recordHistoryTime = currentTime;
    }else {
        if (currentTime != 0) {
            self.recordHistoryCount++;
        }
    }
    //持续播放5s进行记录并存储
    if (self.recordHistoryCount == 5) {
        self.recordHistoryTime = currentTime;
        [self saveRecordHistoryPlayTime];
        self.recordHistoryCount = 0;
    }
        dispatch_async(dispatch_get_main_queue(), ^{
            //获取当前播放时间和视频总时长
            NSTimeInterval position = (int)round(currentTime);
            NSTimeInterval duration = (int)round(totalTime);
            //存在播放器最后一点不播放的情况，所以把进度条的数据对到和最后一秒想同就可以了
            if(duration - position == 1 && (self.playerView.sliderValue == position || self.playerView.sliderValue == duration)) {
                position = duration;
            }
            //设置plaerView的滑块和右侧时间Label
            self.playerView.slider.maximumValue = (int)duration;
            self.playerView.rightTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(duration / 60), (int)(duration) % 60];
            
            self.playTime = currentTime;
            //校对SDK当前播放时间
            if(position == 0 && self.playerView.sliderValue != 0) {
                self.requestDataPlayBack.currentPlaybackTime = self.playerView.sliderValue;
                //            position = self.playerView.sliderValue;
                self.playerView.slider.value = self.playerView.sliderValue;
                //        } else if(fabs(position - self.playerView.slider.value) > 10) {
                //            self.requestDataPlayBack.currentPlaybackTime = self.playerView.slider.value;
                ////            position = self.playerView.slider.value;
                //            self.playerView.sliderValue = self.playerView.slider.value;
            } else {
                self.playerView.slider.value = position;
                self.playerView.sliderValue = self.playerView.slider.value;
            }
            
            //校对本地显示速率和播放器播放速率
            if(self.requestDataPlayBack.ijkPlayer.playbackRate != self.playerView.playBackRate) {
                self.requestDataPlayBack.ijkPlayer.playbackRate = self.playerView.playBackRate;
                //#ifdef LockView
                //校对锁屏播放器播放速率
                [_lockView updatePlayBackRate:self.requestDataPlayBack.ijkPlayer.playbackRate];
                //#endif
                //[self.playerView startTimer];
            }
            if(self.playerView.pauseButton.selected == NO && self.requestDataPlayBack.ijkPlayer.playbackState == IJKMPMoviePlaybackStatePaused) {
                //开启播放视频
                [self.requestDataPlayBack startPlayer];
            }
            
            /*  加载聊天数据 */
            [self parseChatOnTime:(int)self.playerView.sliderValue];
            //更新左侧label
            self.playerView.leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(self.playerView.sliderValue / 60), (int)(self.playerView.sliderValue) % 60];
            //#ifdef LockView
            /*  校对锁屏播放器进度 */
            [_lockView updateCurrentDurtion:_requestDataPlayBack.currentPlaybackTime];
            //#endif
        });
}

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
/**
 *    @brief     双击ppt
 */
- (void)doubleCllickPPTView {
    if (_playerView.quanpingButton.selected) {//如果是横屏状态下
        /* 横屏转竖屏 */
        _playerView.quanpingButton.selected = NO;
        [_playerView turnPortrait];
        _interactionView.hidden = NO;
        [_playerView backBtnClickWithTag:2];
    }else{
        /* 竖屏转横屏 */
        _playerView.quanpingButton.selected = YES;
        [_playerView turnRight];
        _interactionView.hidden = YES;
        [_playerView quanpingBtnClick];
    }
}
#pragma mark- 房间信息
/**
 *    @brief  获取房间信息，主要是要获取直播间模版来类型，根据直播间模版类型来确定界面布局
 *    房间简介：dic[@"desc"];
 *    房间名称：dic[@"name"];
 *    房间模版类型：[dic[@"templateType"] integerValue];
 *    模版类型为1: 聊天互动： 无 直播文档： 无 直播问答： 无
 *    模版类型为2: 聊天互动： 有 直播文档： 无 直播问答： 有
 *    模版类型为3: 聊天互动： 有 直播文档： 无 直播问答： 无
 *    模版类型为4: 聊天互动： 有 直播文档： 有 直播问答： 无
 *    模版类型为5: 聊天互动： 有 直播文档： 有 直播问答： 有
 *    模版类型为6: 聊天互动： 无 直播文档： 无 直播问答： 有
 */
-(void)roomInfo:(NSDictionary *)dic {
    _roomName = dic[@"baseRecordInfo"][@"title"];
    
//    [self.playerView addSmallView];
    NSInteger type = [dic[@"templateType"] integerValue];
    if (type == 4 || type == 5) {
        [self.playerView addSmallView];
        self.playerView.isOnlyVideoMode = NO;
    }else {
        [self changeBtnClicked:1];
        self.playerView.isOnlyVideoMode = YES;
    }
    _roomName = dic[@"name"];
    //设置房间标题
    self.playerView.titleLabel.text = _roomName;
    //配置互动视图的信息
    [self.interactionView roomInfo:dic playerView:self.playerView];
}
#pragma mark - 跑马灯
- (void)receivedMarqueeInfo:(NSDictionary *)dic {
    if (dic == nil) {
        return;
    }
    self.jsonDict = dic;
    {

        CGFloat width = 0.0;
        CGFloat height = 0.0;
        self.marqueeView = [[HDMarqueeView alloc]init];
        HDMarqueeViewStyle style = [[self.jsonDict objectForKey:@"type"] isEqualToString:@"text"] ? HDMarqueeViewStyleTitle : HDMarqueeViewStyleImage;
        self.marqueeView.style = style;
        self.marqueeView.repeatCount = [[self.jsonDict objectForKey:@"loop"] integerValue];
        if (style == HDMarqueeViewStyleTitle) {
            NSDictionary * textDict = [self.jsonDict objectForKey:@"text"];
            NSString * text = [textDict objectForKey:@"content"];
            UIColor * textColor = [UIColor colorWithHexString:[textDict objectForKey:@"color"] alpha:1.0f];
            UIFont * textFont = [UIFont systemFontOfSize:[[textDict objectForKey:@"font_size"] floatValue]];
            
            self.marqueeView.text = text;
            self.marqueeView.textAttributed = @{NSFontAttributeName:textFont,NSForegroundColorAttributeName:textColor};
            CGSize textSize = [self.marqueeView.text calculateRectWithSize:CGSizeMake(SCREEN_WIDTH, SCREENH_HEIGHT) Font:textFont WithLineSpace:0];
            width = textSize.width;
            height = textSize.height;
            
        }else{
            NSDictionary * imageDict = [self.jsonDict objectForKey:@"image"];
            NSURL * imageURL = [NSURL URLWithString:[imageDict objectForKey:@"image_url"]];
            self.marqueeView.imageURL = imageURL;
            width = [[imageDict objectForKey:@"width"] floatValue];
            height = [[imageDict objectForKey:@"height"] floatValue];

        }
        self.marqueeView.frame = CGRectMake(0, 0, width, height);
        //处理action
        NSArray * setActionsArray = [self.jsonDict objectForKey:@"action"];
        
        NSMutableArray <HDMarqueeAction *> * actions = [NSMutableArray array];
        for (int i = 0; i < setActionsArray.count; i++) {
            NSDictionary * actionDict = [setActionsArray objectAtIndex:i];
            CGFloat duration = [[actionDict objectForKey:@"duration"] floatValue];
            NSDictionary * startDict = [actionDict objectForKey:@"start"];
            NSDictionary * endDict = [actionDict objectForKey:@"end"];

            HDMarqueeAction * marqueeAction = [[HDMarqueeAction alloc]init];
            marqueeAction.duration = duration;
            marqueeAction.startPostion.alpha = [[startDict objectForKey:@"alpha"] floatValue];
            marqueeAction.startPostion.pos = CGPointMake([[startDict objectForKey:@"xpos"] floatValue], [[startDict objectForKey:@"ypos"] floatValue]);
            marqueeAction.endPostion.alpha = [[endDict objectForKey:@"alpha"] floatValue];
            marqueeAction.endPostion.pos = CGPointMake([[endDict objectForKey:@"xpos"] floatValue], [[endDict objectForKey:@"ypos"] floatValue]);
            
            [actions addObject:marqueeAction];
        }
        
        self.marqueeView.actions = actions;
        self.marqueeView.fatherView = self.playerView;
        self.playerView.layer.masksToBounds = YES;
    }
}
#pragma  mark - 文档加载状态
-(void)docLoadCompleteWithIndex:(NSInteger)index {
//    NSLog(@"文档状态%ld",(long)index);
    if (index == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.playerView addSubview:self.marqueeView];
            [self.marqueeView startMarquee];
        });
    }
}
#pragma mark- 回放的开始时间和结束时间
/**
 *  @brief 回放的开始时间和结束时间
 *  @param dic {endTime     //结束时间
                startTime   //开始时间 }
 */
-(void)liveInfo:(NSDictionary *)dic {
//    NSLog(@"%@",dic);
     SaveToUserDefaults(LIVE_STARTTIME, dic[@"startTime"]);
}
#pragma mark - 缓存速度
- (void)onBufferSpeed:(NSString *)speed
{
    self.playerView.bufferSpeed = speed;
}
#pragma mark- 聊天
/**
 *    @brief    解析本房间的历史聊天数据
 */
-(void)onParserChat:(NSArray *)chatArr {
    if ([chatArr count] == 0) {
        return;
    }
    //解析历史聊天
    [self.interactionView onParserChat:chatArr];
}
#pragma mark- 问答
/**
 *    @brief  收到提问&回答
 */
- (void)onParserQuestionArr:(NSArray *)questionArr onParserAnswerArr:(NSArray *)answerArr
{
    //    NSLog(@"questionArr = %@,answerArr = %@",questionArr,answerArr);
    [self.interactionView onParserQuestionArr:questionArr onParserAnswerArr:answerArr];
}
//移除通知
- (void)dealloc {
//    NSLog(@"%s", __func__);
    /*      自动登录情况下，会存在移除控制器但是SDK没有销毁的情况 */
    if (_requestDataPlayBack) {
        [_requestDataPlayBack requestCancel];
        _requestDataPlayBack = nil;
    }
    [self removeObserver];
    [self.interactionView removeData];
}
#pragma mark - 设置UI
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
 创建UI
 */
- (void)setupUI {
    //添加视频播放视图
    _playerView = [[CCPlayBackView alloc] initWithFrame:CGRectZero docViewType:_isSmallDocView];
    _playerView.delegate = self;
    
    //退出直播间回调
    WS(weakSelf)
    _playerView.exitCallBack = ^{
        [weakSelf.requestDataPlayBack requestCancel];
        weakSelf.requestDataPlayBack = nil;
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    //滑块滑动完成回调
    _playerView.sliderCallBack = ^(int duration) {
        weakSelf.requestDataPlayBack.currentPlaybackTime = duration;
//#ifdef LockView
        /*  校对锁屏播放器进度 */
        [weakSelf.lockView updateCurrentDurtion:weakSelf.requestDataPlayBack.currentPlaybackTime];
//#endif
        if (weakSelf.requestDataPlayBack.ijkPlayer.playbackState != IJKMPMoviePlaybackStatePlaying) {
            [weakSelf.requestDataPlayBack startPlayer];
            //[weakSelf.playerView startTimer];
        }
        //隐藏历史播放记录view
        [weakSelf.playerView hiddenRecordHistoryPlayView];
    };
    //滑块移动回调
    _playerView.sliderMoving = ^{
        if (weakSelf.requestDataPlayBack.ijkPlayer.playbackState != IJKMPMoviePlaybackStatePaused) {
            [weakSelf.requestDataPlayBack pausePlayer];
//            [weakSelf.playerView stopTimer];
        }
    };
    //更改播放器速率回调
    _playerView.changeRate = ^(float rate) {
        weakSelf.requestDataPlayBack.ijkPlayer.playbackRate = rate;
    };
    //暂停/开始播放回调
    _playerView.pausePlayer = ^(BOOL pause) {
        if (pause) {
            //[weakSelf.playerView stopTimer];
            [weakSelf.requestDataPlayBack pausePlayer];
        }else{
            //[weakSelf.playerView startTimer];
            [weakSelf.requestDataPlayBack startPlayer];
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
    _lockView = [[CCLockView alloc] initWithRoomName:_roomName duration:_requestDataPlayBack.ijkPlayer.duration];
    [self.view addSubview:_lockView];
    [_requestDataPlayBack.ijkPlayer setPauseInBackground:self.pauseInBackGround];
    WS(weakSelf)
    /*     播放/暂停回调     */
    _lockView.pauseCallBack = ^(BOOL pause) {
        weakSelf.playerView.pauseButton.selected = pause;
        if (pause) {
            //[weakSelf.playerView stopTimer];
            [weakSelf.requestDataPlayBack.ijkPlayer pause];
        }else{
            //[weakSelf.playerView startTimer];
            [weakSelf.requestDataPlayBack.ijkPlayer play];
        }
    };
    /*     快进/快退回调     */
    _lockView.progressBlock = ^(int time) {
//        NSLog(@"---playBack快进/快退至%d秒", time);
        weakSelf.requestDataPlayBack.currentPlaybackTime = time;
        weakSelf.playerView.slider.value = time;
        weakSelf.playerView.sliderValue = weakSelf.playerView.slider.value;
    };
}
//#endif
#pragma mark - playViewDelegate
/**
 全屏按钮点击代理
 
 @param tag 1视频为主，2文档为主
 */
-(void)quanpingBtnClicked:(NSInteger)tag{
    if (tag == 1) {
        [_requestDataPlayBack changePlayerFrame:self.view.frame];
    } else {
        [_requestDataPlayBack changeDocFrame:self.view.frame];
    }
    //隐藏互动视图
    [self hiddenInteractionView:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.marqueeView startMarquee];
    });
}
/**
 返回按钮点击代理
 
 @param tag 1.视频为主，2.文档为主
 */
-(void)backBtnClicked:(NSInteger)tag{
    if (tag == 1) {
        [_requestDataPlayBack changePlayerFrame:CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462))];
    } else {
        [_requestDataPlayBack changeDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462))];
    }
    //显示互动视图
    [self hiddenInteractionView:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.marqueeView startMarquee];
    });
}
/**
 切换视频/文档按钮点击回调
 
 @param tag changeBtn的tag值
 */
-(void)changeBtnClicked:(NSInteger)tag{
    if (tag == 2) {
        
        [_requestDataPlayBack changeDocParent:self.playerView];
        [_requestDataPlayBack changePlayerParent:self.playerView.smallVideoView];
        [_requestDataPlayBack changeDocFrame:CGRectMake(0, 0,self.playerView.frame.size.width, self.playerView.frame.size.height)];
        [_requestDataPlayBack changePlayerFrame:CGRectMake(0, 0, self.playerView.smallVideoView.frame.size.width, self.playerView.smallVideoView.frame.size.height)];
    }else{
        [_requestDataPlayBack changeDocParent:self.playerView.smallVideoView];
        [_requestDataPlayBack changePlayerParent:self.playerView];
        [_requestDataPlayBack changePlayerFrame:CGRectMake(0, 0,self.playerView.frame.size.width, self.playerView.frame.size.height)];
        [_requestDataPlayBack changeDocFrame:CGRectMake(0, 0, self.playerView.smallVideoView.frame.size.width, self.playerView.smallVideoView.frame.size.height)];
    }
    [self.playerView bringSubviewToFront:self.marqueeView];
}
/**
 隐藏互动视图

 @param hidden 是否隐藏
 */
-(void)hiddenInteractionView:(BOOL)hidden{
    self.interactionView.hidden = hidden;
}

/**
 *    @brief    播放完成
 */
- (void)playDone
{
    self.isPlayDone = YES;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
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
    if (!self.requestDataPlayBack.ijkPlayer.playbackState && self.isPlayDone != YES) {
        [self.requestDataPlayBack replayPlayer];
        [self.lockView updateLockView];
    }
//#endif
    if (self.playerView.pauseButton.selected == NO && self.isPlayDone != YES) {
        //[self.playerView startTimer];
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
//    [self.playerView stopTimer];
}

/**
 程序从后台激活
 */
- (void)applicationDidBecomeActiveNotification {
    if (_enterBackGround == NO && ![_requestDataPlayBack isPlaying]) {
        /*  如果当前视频不处于播放状态，重新进行播放,初始化播放状态 */
        [_requestDataPlayBack replayPlayer];
//        [_playerView stopTimer];
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
- (BOOL)shouldAutorotate {
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
    if (self.playerView.isScreenLandScape == YES) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersHomeIndicatorAutoHidden {

    return  YES;
}
@end
