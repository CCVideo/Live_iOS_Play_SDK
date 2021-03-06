//
//  CCPlayerController.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/22.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCPlayerController.h"
#import "CCSDK/RequestData.h"//SDK
#import <CCSDK/SaveLogUtil.h>//日志
#import "LotteryView.h"//抽奖
#import "CCPlayerView.h"//视频
#import "CCInteractionView.h"//互动视图
#import "QuestionNaire.h"//第三方调查问卷
#import "QuestionnaireSurvey.h"//问卷和问卷统计
#import "QuestionnaireSurveyPopUp.h"//问卷弹窗
#import "RollcallView.h"//签到
#import "VoteView.h"//答题卡
#import "VoteViewResult.h"//答题结果
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "SelectMenuView.h"//更多菜单
#import "AnnouncementView.h"//公告
#import "CCAlertView.h"//提示框
#import "CCProxy.h"
#import "CCClassTestView.h"//随堂测
#import "CCCupView.h"//奖杯
#import "CCPunchView.h"
//#ifdef LockView
#import "CCLockView.h"//锁屏界面
//#endif
/*
*******************************************************
*      去除锁屏界面功能步骤如下：                          *
*  1。command+F搜索   #ifdef LockView                  *
*                                                     *
*  2.删除 #ifdef LockView 至 #endif之间的代码            *
*******************************************************
*/
@interface CCPlayerController ()<RequestDataDelegate,
UIScrollViewDelegate,UITextFieldDelegate,CCPlayerViewDelegate>
#pragma mark - 房间相关参数
@property (nonatomic,copy)  NSString                 * viewerId;//观看者的id
@property (nonatomic,strong)NSTimer                  * userCountTimer;//计算观看人数
@property (nonatomic,strong)NSString                 * roomName;//房间名
@property (nonatomic,strong)RequestData              * requestData;//sdk
#pragma mark - UI初始化
@property (nonatomic,strong)CCPlayerView             * playerView;//视频视图
@property (nonatomic,strong)CCInteractionView        * contentView;//互动视图
@property (nonatomic,strong)SelectMenuView           * menuView;//选择菜单视图
#pragma mark - 抽奖
@property (nonatomic,strong)LotteryView              * lotteryView;//抽奖
#pragma mark - 问卷
@property (nonatomic,assign)NSInteger                submitedAction;//提交事件
@property (nonatomic,strong)QuestionNaire            * questionNaire;//第三方调查问卷
@property (nonatomic,strong)QuestionnaireSurvey      * questionnaireSurvey;//问卷视图
@property (nonatomic,strong)QuestionnaireSurveyPopUp * questionnaireSurveyPopUp;//问卷弹窗
#pragma mark - 签到
@property (nonatomic,weak)  RollcallView             * rollcallView;//签到
@property (nonatomic,assign)NSInteger                duration;//签到时间
#pragma mark - 答题卡
@property(nonatomic,weak)  VoteView                  * voteView;//答题卡
@property(nonatomic,weak)  VoteViewResult            * voteViewResult;//答题结果
@property(nonatomic,assign)NSInteger                 mySelectIndex;//答题单选答案
@property(nonatomic,strong)NSMutableArray            * mySelectIndexArray;//答题多选答案
@property (nonatomic,strong)UIButton                 * cleanVoteBtn;//收起答题卡按钮
#pragma mark - 公告
@property(nonatomic,copy)  NSString                  * gongGaoStr;//公告内容
@property(nonatomic,strong)AnnouncementView          * announcementView;//公告视图

#pragma mark - 随堂测
@property(nonatomic,weak)CCClassTestView             * testView;//随堂测
@property (nonatomic,strong)UIButton                 * cleanTestBtn;//收起随堂测按钮
#pragma mark - 打卡视图
@property(nonatomic,strong)CCPunchView                 * punchView;//打卡
#pragma mark - 提示框
@property (nonatomic,strong)CCAlertView              * alertView;//消息弹窗
//#ifdef LockView
#pragma make - 锁屏界面
@property (nonatomic,strong)CCLockView               * lockView;//锁屏视图
//#endif LockView

@property (nonatomic,assign)BOOL                     isScreenLandScape;//是否横屏
@property (nonatomic,assign)BOOL                     screenLandScape;//横屏
@property (nonatomic,assign)BOOL                     isHomeIndicatorHidden;//隐藏home条
@property (nonatomic,assign)NSInteger                firRoadNum;//房间线路
@property (nonatomic,strong)NSMutableArray           *secRoadKeyArray;//清晰度数组
@property (nonatomic,assign)BOOL                     firstUnStart;//第一次进入未开始直播
@property (nonatomic,assign)BOOL                     pauseInBackGround;//后台播放是否暂停

#pragma mark - 文档显示模式
@property (nonatomic,assign)BOOL                     isSmallDocView;//是否是文档小窗模式
@property (nonatomic,strong)UIView                   *onceDocView;//临时DocView(双击ppt进入横屏调用)
@property (nonatomic,strong)UIView                   *oncePlayerView;//临时playerView(双击ppt进入横屏调用)
//@property (nonatomic,strong)UILabel                  *label;
@property (nonatomic, assign)BOOL                    openmarquee;//跑马灯开启
@property (nonatomic,strong)HDMarqueeView            * marqueeView;//跑马灯
@property (nonatomic,strong)NSDictionary             * jsonDict;//跑马灯数据
@property (nonatomic,assign)BOOL                     isLivePlay;//直播间是否已开启
/** 记录切换ppt缩放模式 */
@property (nonatomic, assign)NSInteger                    pptScaleMode;
/** 随堂测数据 */
@property (nonatomic, copy) NSMutableDictionary      *testDict;

@property (nonatomic, strong)InformationShowView  * informationView;//提示

@end
@implementation CCPlayerController
//初始化
- (instancetype)initWithRoomName:(NSString *)roomName{
    self = [super init];
    if(self) {
        self.roomName = roomName;
    }
    return self;
}
//启动
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    /*  设置后台是否暂停 ps:后台支持播放时将会开启锁屏播放器 */
    _pauseInBackGround = NO;
    _isLivePlay = NO;
    [self setupUI];//创建UI
    [self integrationSDK];//集成SDK
    [self addObserver];//添加通知
}

- (void)receivedDocsList:(NSDictionary *)listDic {
//    NSLog(@"%@",listDic);
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObserver];//移除通知
}
/**
 创建UI
 */
- (void)setupUI {
    /*   设置文档显示类型    YES:表示文档小窗模式   NO:文档在下模式  */
    _isSmallDocView = YES;
    //视频视图
    [self.view addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(CCGetRealFromPt(462));
        make.top.equalTo(self.view).offset(SCREEN_STATUS);
    }];
    
    //添加互动视图
    [self.view addSubview:self.contentView];
}
/**
 集成sdk
 */
- (void)integrationSDK {
    UIView *docView = _isSmallDocView ? self.playerView.smallVideoView : self.contentView.docView;
    PlayParameter *parameter = [[PlayParameter alloc] init];
    parameter.userId = GetFromUserDefaults(WATCH_USERID);//userId
    parameter.roomId = GetFromUserDefaults(WATCH_ROOMID);//roomId
    parameter.viewerName = GetFromUserDefaults(WATCH_USERNAME);//用户名
    parameter.token = GetFromUserDefaults(WATCH_PASSWORD);//密码
    // 1.默认视频小窗
    parameter.playerParent = docView;
    parameter.playerFrame = CGRectMake(0,0,docView.frame.size.width, docView.frame.size.height);//文档位置,ps:起始位置为文档视图坐标
    // 2.默认文档大窗
    parameter.docParent = self.playerView;//视频视图
    parameter.docFrame = CGRectMake(0,0,self.playerView.frame.size.width, self.playerView.frame.size.height);//视频位置,ps:起始位置为视频视图坐标
    parameter.security = YES;//是否开启https,建议开启
    parameter.PPTScalingMode = 4;//ppt展示模式,建议值为4
    
    parameter.defaultColor = [UIColor whiteColor];//ppt默认底色，不写默认为白色
    parameter.scalingMode = 1;//屏幕适配方式
    parameter.pauseInBackGround = _pauseInBackGround;//后台是否暂停
    parameter.viewerCustomua = @"viewercustomua";//自定义参数,没有的话这么写就可以
//    parameter.pptInteractionEnabled = !_isSmallDocView;//是否开启ppt滚动
    parameter.pptInteractionEnabled = YES;
    parameter.DocModeType = 0;//设置当前的文档模式
//    parameter.DocShowType = 1;
    parameter.groupid = _contentView.groupId;//用户的groupId
    _pptScaleMode = parameter.PPTScalingMode;
    _requestData = [[RequestData alloc] initWithParameter:parameter];
    _requestData.delegate = self;
}

#pragma mark - 私有方法
/**
 发送聊天

 @param str 聊天内容
 */
- (void)sendChatMessageWithStr:(NSString *)str {
    [_requestData chatMessage:str];
}
/**
 切换线路

 @param rodIndex 线路
 */
- (void)selectedRodWidthIndex:(NSInteger)rodIndex {
    if(rodIndex > self.firRoadNum) {
        [_requestData switchToPlayUrlWithFirIndex:0 key:@""];
    } else {
        [_requestData switchToPlayUrlWithFirIndex:rodIndex - 1 key:[self.secRoadKeyArray firstObject]];
    }
}
/**
 切换清晰度

 @param rodIndex 线路
 @param secIndex 清晰度
 */
- (void)selectedRodWidthIndex:(NSInteger)rodIndex secIndex:(NSInteger)secIndex {
    [_requestData switchToPlayUrlWithFirIndex:rodIndex - 1 key:[_secRoadKeyArray objectAtIndex:secIndex]];
}
/**
 旋转方向

 @return 是否允许转屏
 */
- (BOOL)shouldAutorotate {
    if (self.isScreenLandScape == YES) {
        return YES;
    }
    return NO;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskAllButUpsideDown;
    if (self.isScreenLandScape == YES) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}
/**
 强制转屏

 @param orientation 旋转方向
 */
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
#pragma mark - playViewDelegate 以及相关方法

/**
 点击切换视频/文档按钮

 @param tag 1为视频为主，2为文档为主
 */
-(void)changeBtnClicked:(NSInteger)tag{
    if (tag == 2) {
        
        [_requestData changeDocParent:self.playerView];
        [_requestData changePlayerParent:self.playerView.smallVideoView];
        [_requestData changePlayerFrame:CGRectMake(0, 0, self.playerView.smallVideoView.frame.size.width, self.playerView.smallVideoView.frame.size.height)];
        [_requestData changeDocFrame:CGRectMake(0, 0,self.playerView.frame.size.width, self.playerView.frame.size.height)];
    }else{
        
        [_requestData changeDocParent:self.playerView.smallVideoView];
        [_requestData changePlayerParent:self.playerView];
        [_requestData changePlayerFrame:CGRectMake(0, 0,self.playerView.frame.size.width, self.playerView.frame.size.height)];
        [_requestData changeDocFrame:CGRectMake(0, 0, self.playerView.smallVideoView.frame.size.width, self.playerView.smallVideoView.frame.size.height)];
    }
    [self.playerView bringSubviewToFront:self.marqueeView];
}
/**
 点击全屏按钮代理
 
 @param tag 1为视频为主，2为文档为主
 */
- (void)quanpingButtonClick:(NSInteger)tag {
    [self.view endEditing:YES];
    [APPDelegate.window endEditing:YES];
    [self.contentView.chatView resignFirstResponder];
    [self othersViewHidden:YES];
    if (tag == 1) {
        [_requestData changePlayerFrame:self.view.frame];
    } else {
        [_requestData changeDocFrame:self.view.frame];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.marqueeView startMarquee];
    });
    self.screenLandScape = YES;
    
    if (_cleanVoteBtn.hidden == YES) {
        // 1.收起状态下随堂测按钮重置布局
        [self.cleanTestBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view).offset(IS_IPHONE_X ? - 110 : -75);
            make.right.mas_equalTo(self.view).offset(IS_IPHONE_X ? -55 : -15);
            make.width.height.mas_equalTo(CCGetRealFromPt(70));
        }];
    }else {
        // 1.收起状态下随堂测按钮重置布局
        [self.cleanTestBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view).offset(IS_IPHONE_X ? - 110 : -75);
            make.right.mas_equalTo(self.view).offset(IS_IPHONE_X ? -95 : -55);
            make.width.height.mas_equalTo(CCGetRealFromPt(70));
        }];
    }
    // 2.重置随堂测布局
    [self.testView updataTestViewWithScreenlandscape:YES];
    
    // 1.收起状态下答题卡按钮布局
    if (_cleanTestBtn.hidden == YES) {
        [self.cleanVoteBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view).offset(IS_IPHONE_X ? - 110 : -75);
            make.right.mas_equalTo(self.view).offset(IS_IPHONE_X ? -55 : -15);
            make.width.height.mas_equalTo(CCGetRealFromPt(70));
        }];
    }else {
        [self.cleanVoteBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view).offset(IS_IPHONE_X ? - 110 : -75);
            make.right.mas_equalTo(self.view).offset(IS_IPHONE_X ? -95 : -55);
            make.width.height.mas_equalTo(CCGetRealFromPt(70));
        }];
    }
    [self.voteView updataUIWithScreenLandScape:YES];
}

/**
 *    @brief    点击退出按钮(返回竖屏或者结束直播)
 *    @param    sender backBtn
 *    @param tag changeBtn的标记，1为视频为主，2为文档为主
 */
- (void)backButtonClick:(UIButton *)sender changeBtnTag:(NSInteger)tag{
    if (sender.tag == 2) {//横屏返回竖屏
        self.screenLandScape = NO;
        // 1.重置收起随堂测按钮布局
        if (self.cleanVoteBtn.hidden == YES) {
            [self.cleanTestBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.view).offset(SCREEN_WIDTH - CCGetRealFromPt(190));
                make.top.mas_equalTo(self.view).offset(SCREENH_HEIGHT - CCGetRealFromPt(240) - kScreenBottom);
                make.width.height.mas_equalTo(CCGetRealFromPt(70));
            }];
        }else {
            [self.cleanTestBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.view).offset(SCREEN_WIDTH - CCGetRealFromPt(150));
                make.top.mas_equalTo(self.view).offset(SCREENH_HEIGHT - CCGetRealFromPt(240) - kScreenBottom);
                make.width.height.mas_equalTo(CCGetRealFromPt(70));
            }];
        }
        // 2.重置随堂测布局
        [self.testView updataTestViewWithScreenlandscape:NO];
        
        if (self.cleanTestBtn.hidden == YES) {
            [self.cleanVoteBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.view).offset(SCREEN_WIDTH - CCGetRealFromPt(190));
                make.top.mas_equalTo(self.view).offset(SCREENH_HEIGHT - CCGetRealFromPt(240) - kScreenBottom);
                make.width.height.mas_equalTo(CCGetRealFromPt(70));
            }];
        }else {
            [self.cleanVoteBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.view).offset(SCREEN_WIDTH - CCGetRealFromPt(150));
                make.top.mas_equalTo(self.view).offset(SCREENH_HEIGHT - CCGetRealFromPt(240) - kScreenBottom);
                make.width.height.mas_equalTo(CCGetRealFromPt(70));
            }];
        }
        [self.voteView updataUIWithScreenLandScape:NO];
        
        [self othersViewHidden:NO];
        if (tag == 1) {
            [_requestData changePlayerFrame:CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462))];
        } else {
            [_requestData changeDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462))];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.marqueeView startMarquee];
        });
    }else if( sender.tag == 1){//结束直播
        [self creatAlertController_alert];
//        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
//隐藏其他视图,当点击全屏和退出全屏时调用此方法
-(void)othersViewHidden:(BOOL)hidden{
    self.screenLandScape = hidden;//设置横竖屏
    self.contentView.chatView.ccPrivateChatView.hidden = hidden;//隐藏聊天视图
    self.isScreenLandScape = YES;//支持旋转
    [self interfaceOrientation:hidden? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait];
    if (hidden == NO) {
        self.isScreenLandScape = NO;//不支持旋转
    }
    self.contentView.hidden = hidden;//隐藏互动视图
//    self.menuView.hidden = hidden;//隐藏更多功能菜单
    [self.menuView hiddenMenuViews:hidden];
    self.announcementView.hidden = hidden;//隐藏公告视图
    if (!hidden) {//更新新消息
        [_menuView updateMessageFrame];
    }
}
//创建提示窗
-(void)creatAlertController_alert {
    //添加提示窗
    CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:ALERT_EXITPLAY sureAction:SURE cancelAction:CANCEL sureBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.lockView) {
                [self.lockView removeFromSuperview];
                self.lockView = nil;
            }
            [self exitPlayLive];
        });
    }];
    [APPDelegate.window addSubview:alertView];
}

/**
 退出直播
 */
-(void)exitPlayLive{
    [self stopTimer];
    [self.requestData requestCancel];
    self.requestData = nil;
    [self.playerView.smallVideoView removeFromSuperview];
    //移除聊天
    [self.contentView removeChatView];
    [_announcementView removeFromSuperview];
    //移除多功能菜单
    [self.menuView removeFromSuperview];
    [self.menuView removeAllInformationView];
    [self dismissViewControllerAnimated:YES completion:nil];
}
//- (void)timerfunc {
    // (已废弃)获取在线房间人数，当登录成功后即可调用此接口，登录不成功或者退出登录后就不可以调用了，如果要求实时性比较强的话，可以写一个定时器，不断调用此接口，几秒钟发一次就可以，然后在代理回调函数中，处理返回的数据
    //最新注释:该接口默认最短响应时间为15秒,获取在线房间人数，当登录成功后即可调用此接口，登录不成功或者退出登录后就不可以调用了，如果要求实时性比较强的话，可以写一个定时器，不断调用此接口，然后在代理回调函数中，处理返回的数据
//    [_requestData roomUserCount];
//}

/**
 *    @brief    翻页同步之前的文档展示模式
 */
- (void)onPageChange:(NSDictionary *) dictionary
{
  
}

#pragma mark- SDK 必须实现的代理方法
/**
 *    @brief    请求成功
 */
-(void)requestSucceed {
//        NSLog(@"请求成功！");
//    [self stopTimer];
//    CCProxy *weakObject = [CCProxy proxyWithWeakObject:self];
//    _userCountTimer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:weakObject selector:@selector(timerfunc) userInfo:nil repeats:YES];
   
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
    // 添加提示窗,提示message
//    [self addBanAlertView:message];
}

#pragma mark- 功能代理方法 用哪个实现哪个-----
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
            break;
        }
        case HDMoviePlaybackStatePlaying:{

            [_playerView.loadingView removeFromSuperview];
            [[SaveLogUtil sharedInstance] saveLog:@"" action:SAVELOG_ALERT];
            //#ifdef LockView
            if (_pauseInBackGround == NO) {//添加锁屏视图
                if (!_lockView) {
                    _lockView = [[CCLockView alloc] initWithRoomName:_roomName duration:_requestData.ijkPlayer.duration];
                    [self.view addSubview:_lockView];
                }else{
                    [_lockView updateLockView];
                }
            }
            //#endif
            break;
        }
        case HDMoviePlaybackStatePaused:{
            break;
        }
        case HDMoviePlaybackStateInterrupted: {
            break;
        }
        case HDMoviePlaybackStateSeekingForward:
        case HDMoviePlaybackStateSeekingBackward: {
            break;
        }
        default: {
            break;
        }
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
 *    @brief    双击PPT
 */
-(void)doubleCllickPPTView{
    if (_screenLandScape) {//如果是横屏状态下
        _screenLandScape = NO;
        _isScreenLandScape = YES;
        
        // 新增方法 --> 处理全屏双击PPT退出全屏操作，统一由PlayView管理
        // 注：该方法不影响连麦操作
        [_playerView backBtnClickWithTag:2];
        
//        [self interfaceOrientation:UIInterfaceOrientationPortrait];
//        [UIApplication sharedApplication].statusBarHidden = NO;
//        _isScreenLandScape = NO;
        
        /**    移除临时的_onceDocView和_oncePlayerView，并且显示互动视图和视频视图  */
//        _contentView.hidden = NO;
//        [_onceDocView removeFromSuperview];
//        _playerView.hidden = NO;
//        [_oncePlayerView removeFromSuperview];
//
//        [_requestData changePlayerParent:_playerView];
//        [_requestData changePlayerFrame:CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462))];
//
//        [_requestData changeDocParent:_contentView.docView];
//        [_requestData changeDocFrame:CGRectMake(0, 0, _contentView.docView.frame.size.width, _contentView.docView.frame.size.height)];
    }else{
        _screenLandScape = YES;
        _isScreenLandScape = YES;
        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        [UIApplication sharedApplication].statusBarHidden = YES;
        _isScreenLandScape = NO;
        
        // 新增方法 --> 处理双击PPT进入全屏操作，统一由PlayView管理
        // 注：该方法不影响连麦操作
        [_playerView quanpingBtnClick];
        
        
        /**    创建临时的_onceDocView和_oncePlayerView，并且隐藏互动视图和视频视图  */
//        _contentView.hidden = YES;
//        _playerView.hidden = YES;
//
//        // 临时文档View
//        _onceDocView = [[UIView alloc] init];
//        _onceDocView.frame = [UIScreen mainScreen].bounds;
//        [self.view addSubview:_onceDocView];
//
//        // 临时视频
//        _oncePlayerView = [[UIView alloc] init];
////        _oncePlayerView.frame = CGRectMake(0, 0, CCGetRealFromPt(202), CCGetRealFromPt(152));
//        // 新增修改
//        _oncePlayerView.frame = CGRectMake(self.view.frame.size.width -CCGetRealFromPt(220), CCGetRealFromPt(332), CCGetRealFromPt(200), CCGetRealFromPt(150));
//
//        [self.view addSubview:_oncePlayerView];
//
//        [_requestData changeDocParent:_onceDocView];
//        [_requestData changeDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT)];
//        [_requestData changePlayerParent:_oncePlayerView];
//        [_requestData changePlayerFrame:CGRectMake(0, 0, CCGetRealFromPt(202), CCGetRealFromPt(152))];
    }
}

/**
 *    @brief    历史广播数组
 *    @param    array   历史广播数组
 *              array [{
                           content         //广播内容
                           userid          //发布者ID
                           username        //发布者名字
                           userrole        //发布者角色
                           createTime      //绝对时间
                           time            //相对时间(相对直播)
                           id              //广播ID }]
 */
- (void)broadcastLast_msg:(NSArray *)array
{
    [_contentView broadcastLast_msg:array];
}

/**
*    @brief    删除广播
*    @param    dic   广播信息
*              dic {action             //操作 1.删除
                    id                 //广播ID }
*/
- (void)broadcast_delete:(NSDictionary *)dic
{
    [_contentView broadcast_delete:dic];
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
    _roomName = dic[@"name"];
    self.openmarquee = [dic[@"openMarquee"] boolValue];
    //添加更多菜单
    [APPDelegate.window addSubview:self.menuView];
    [self.playerView roominfo:dic];
    NSInteger type = [dic[@"templateType"] integerValue];
    if (type == 4 || type == 5) {
        [self.playerView addSmallView];
        self.playerView.isOnlyVideoMode = NO;
    }else {
        // 1.仅有视频模式下 视频显示大窗
        [self changeBtnClicked:1];
        self.playerView.isOnlyVideoMode = YES;
    }
    
    //设置房间信息
    [_contentView roomInfo:dic withPlayView:self.playerView smallView:self.playerView.smallVideoView];
    _playerView.templateType = type;
    if (type != 1) {//如果只有视频的版型，去除menuView;
        //设置视频视图和互动视图的相关属性
        _playerView.menuView = _menuView;
        [self.view addSubview:self.cleanTestBtn];
        [self.cleanTestBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).offset(SCREENH_HEIGHT - CCGetRealFromPt(240) - kScreenBottom);
            make.left.mas_equalTo(self.view).offset(SCREEN_WIDTH - CCGetRealFromPt(190));
            make.width.height.mas_equalTo(CCGetRealFromPt(70));
        }];
        
        [self.view addSubview:self.cleanVoteBtn];
        [self.cleanVoteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).offset(SCREENH_HEIGHT - CCGetRealFromPt(240) - kScreenBottom);
            make.left.mas_equalTo(self.view).offset(SCREEN_WIDTH - CCGetRealFromPt(190));
            make.width.height.mas_equalTo(CCGetRealFromPt(70));
        }];
    }
    if (type == 6) {//去除私聊按钮
        [_menuView hiddenPrivateBtn];
    }
}
#pragma mark- 获取直播开始时间和直播时长
/**
 *  @brief  获取直播开始时间和直播时长
 *  liveDuration 直播持续时间，单位（s），直播未开始返回-1"
 *  liveStartTime 新增开始直播时间（格式：yyyy-MM-dd HH:mm:ss），如果直播未开始，则返回空字符串
 */
- (void)startTimeAndDurationLiveBroadcast:(NSDictionary *)dataDic {
    SaveToUserDefaults(LIVE_STARTTIME, dataDic[@"liveStartTime"]);
    //当第一次进入时为未开始状态,设置此属性,在直播开始时给startTime赋值
    if ([dataDic[@"liveStartTime"] isEqualToString:@""] && !self.firstUnStart) {
        self.firstUnStart = YES;
    }
}

#pragma mark- 收到在线人数
/**
 *    @brief    收到在线人数
 */
- (void)onUserCount:(NSString *)count {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playerView.userCountLabel.text = count;
//        NSLog(@"在下按人数%@",count);
    });
}

#pragma mark - 打卡功能
//移除打卡视图
-(void)removePunchView {
    [_punchView removeFromSuperview];
    _punchView = nil;
}
/// 打卡功能
/// @param dic 打卡数据
- (void)hdReceivedStartPunchWithDict:(NSDictionary *)dic {
    
    if (_punchView) {
        [_punchView removeFromSuperview];
    }
    WS(weakSelf)
    self.punchView = [[CCPunchView alloc] initWithDict:dic punchBlock:^(NSString * punchid) {
        [weakSelf.requestData hdCommitPunchWithPunchId:punchid];
    } isScreenLandScape:self.isScreenLandScape];
    self.punchView.commitSuccess = ^(BOOL success) {
        [weakSelf removePunchView];
    };
    [APPDelegate.window addSubview:self.punchView];
    _punchView.frame = [UIScreen mainScreen].bounds;
    
    [self showRollCallView];
}
/**
 *    @brief    收到结束打卡
 *    dic{
     "punchId": "punchId"
 }
 */
-(void)hdReceivedEndPunchWithDict:(NSDictionary *)dic{
//    [self removePunchView];
    [self.punchView updateUIWithFinish:dic];
}
/**
 *    @brief    收到打卡提交结果
 *    dic{
     "success": true,
     "data": {
         "isRepeat": false//是否重复提交打卡
     }
 }
 */
-(void)hdReceivedPunchResultWithDict:(NSDictionary *)dic{
    [self.punchView updateUIWithDic:dic];
}

#pragma mark - 服务器端给自己设置的信息
/**
 *    @brief    服务器端给自己设置的信息(The new method)
 *    viewerId 服务器端给自己设置的UserId
 *    groupId 分组id
 *    name 用户名
 */
-(void)setMyViewerInfo:(NSDictionary *) infoDic{
    _viewerId = infoDic[@"viewerId"];
    [_contentView setMyViewerInfo:infoDic];
//        self.label = [[UILabel alloc] init];
//        [self.view addSubview:self.label];
//        self.label.frame = CGRectMake(30, 100, 400, 100);
//    self.label.text = infoDic[@"estimateStartTime"];
//    self.label.textColor = UIColor.blueColor;
//    NSLog(@"结果是%@",infoDic);
}
#pragma mark - 聊天管理
/**
 *    @brief    聊天管理(The new method)
 *    status    聊天消息的状态 0 显示 1 不显示
 *    chatIds   聊天消息的id列列表
 */
-(void)chatLogManage:(NSDictionary *) manageDic{
    [_contentView chatLogManage:manageDic];
}
#pragma mark- 聊天
/**
 *    @brief    收到私聊信息
 */
- (void)OnPrivateChat:(NSDictionary *)dic {
    [_contentView OnPrivateChat:dic withMsgBlock:^{
        [self.menuView showInformationViewWithTitle:NewPrivateMessage];
    }];
}
/**
 *    @brief  历史聊天数据
 */
- (void)onChatLog:(NSArray *)chatLogArr {
    [_contentView onChatLog:chatLogArr];
}
/**
 *    @brief  收到公聊消息
 */
- (void)onPublicChatMessage:(NSDictionary *)dic {
    [_contentView onPublicChatMessage:dic];
//    NSLog(@"收到公聊%@",dic);
}
/**
 *  @brief  接收到发送的广播
 */
- (void)broadcast_msg:(NSDictionary *)dic {
    [_contentView broadcast_msg:dic];
}
/*
 *  @brief  收到自己的禁言消息，如果你被禁言了，你发出的消息只有你自己能看到，其他人看不到
 */
- (void)onSilenceUserChatMessage:(NSDictionary *)message {
    [_contentView onSilenceUserChatMessage:message];
}

/**
 *    @brief    当主讲全体禁言时，你再发消息，会出发此代理方法，information是禁言提示信息
 */
- (void)information:(NSString *)information {
    //添加提示窗
    [self addBanAlertView:information];
}
/**
 *    @brief  收到踢出消息，停止推流并退出播放（被主播踢出）(change)
 kick_out_type
 10 在允许重复登录前提下，后进入者会登录会踢出先前登录者
 20 讲师、助教、主持人通过页面踢出按钮踢出用户
 */
- (void)onKickOut:(NSDictionary *)dictionary{
    if ([_viewerId isEqualToString:dictionary[@"viewerid"]]) {
        WS(weakSelf)
        CCAlertView *alert = [[CCAlertView alloc] initWithAlertTitle:ALERT_KICKOUT sureAction:SURE cancelAction:nil sureBlock:^{
            [weakSelf exitPlayLive];
        }];
        [APPDelegate.window addSubview:alert];
    }
}

#pragma mark- 问答
//发布问题的id
-(void)publish_question:(NSString *)publishId {
    [_contentView publish_question:publishId];
}
/**
 *    @brief  收到提问，用户观看时和主讲的互动问答信息
 */
- (void)onQuestionDic:(NSDictionary *)questionDic{
    [_contentView onQuestionDic:questionDic];
}
/**
 *    @brief  收到回答
 */
- (void)onAnswerDic:(NSDictionary *)answerDic{
    [_contentView onAnswerDic:answerDic];
}
/**
 *    @brief  收到提问&回答
 */
- (void)onQuestionArr:(NSArray *)questionArr onAnswerArr:(NSArray *)answerArr{
    [_contentView onQuestionArr:questionArr onAnswerArr:answerArr];
}

//主动调用方法
/**
 *    @brief    提问
 *    @param     message 提问内容
 */
- (void)question:(NSString *)message {
    //提问
    [_requestData question:message];
}
#pragma mark- 视频线路和清晰度
/*
 *  @brief 切换源，firRoadNum表示一共有几个源，secRoadKeyArray表示每
 *  个源的描述数组
 */
- (void)firRoad:(NSInteger)firRoadNum secRoadKeyArray:(NSArray *)secRoadKeyArray {
    _secRoadKeyArray = [secRoadKeyArray mutableCopy];
    _firRoadNum = firRoadNum;
    [self.playerView SelectLinesWithFirRoad:_firRoadNum secRoadKeyArray:_secRoadKeyArray];

}
#pragma mark- 直播未开始和开始
/**
 *    @brief  收到播放直播状态 0直播 1未直播
 */
- (void)getPlayStatue:(NSInteger)status {
    [_playerView getPlayStatue:status];
    //直播状态
    _isLivePlay = status == 0 ? YES : NO;
    if (status == 0 && self.firstUnStart) {
        NSDate *date = [NSDate date];// 获得时间对象
        NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
        [forMatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateStr = [forMatter stringFromDate:date];
        SaveToUserDefaults(LIVE_STARTTIME, dateStr);
        
    }
    if (status == 0) {
        // 收到播放直播状态后重新获取随堂测(断网重连后需要重新获取)
        [_requestData getPracticeInformation:@""];
        /**
         if (!_testView) {//如果已经存在随堂测视图，避免断网重连
         [_requestData getPracticeInformation:@""];
         }
         */
        if (!_punchView) {
            [_requestData hdInquirePunchInformation];
        }
    } else {
        self.playerView.smallVideoView.hidden = YES;
//        [self.playerView.smallVideoView removeFromSuperview];
    }
}
/**
 *    @brief  主讲开始推流
 */
- (void)onLiveStatusChangeStart {
    [_playerView onLiveStatusChangeStart];
    if (_playerView.templateType == 4 || _playerView.templateType == 5) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playerView addSmallView];
        });
    }
}
/**
 *    @brief  停止直播，endNormal表示是否停止推流
 */
- (void)onLiveStatusChangeEnd:(BOOL)endNormal {
    _isLivePlay = NO; //直播停止
    if (self.punchView) {
        [self removePunchView];
    }
    [_playerView onLiveStatusChangeEnd:endNormal];
}
#pragma mark- 加载视频失败
/**
 *  @brief  加载视频失败
 */
- (void)play_loadVideoFail {
    [_playerView play_loadVideoFail];
}
#pragma mark- 聊天禁言
/**
 *    @brief    收到聊天禁言(The new method)
 *    mode 禁言类型 1：个人禁言  2：全员禁言
 */
-(void)onBanChat:(NSDictionary *) modeDic{
    NSInteger mode = [modeDic[@"mode"] integerValue];
    NSString *str = ALERT_BANCHAT(mode == 1);
    //添加禁言弹窗
    [self addBanAlertView:str];
}
-(void)onBanDeleteChat:(NSDictionary *)viewerDic {
//    NSDictionary * dict = [[NSDictionary alloc]initWithObjectsAndKeys:
//                                @"30b7184b53194374bb9c8f69d3851323",@"viewerId",
//                                nil];
    [_contentView onBanDeleteChatMessage:viewerDic];

//    NSLog(@"结果是%@",dict);
}
/**
 *    @brief    收到解除禁言事件(The new method)
 *    mode 禁言类型 1：个人禁言  2：全员禁言
 */
-(void)onUnBanChat:(NSDictionary *) modeDic{
    NSInteger mode = [modeDic[@"mode"] integerValue];
    NSString *str = ALERT_UNBANCHAT(mode == 1);
    //添加禁言弹窗
    [self addBanAlertView:str];
}

#pragma mark - 进出直播间提示
- (void)HDUserRemindWithModel:(RemindModel *)model
{
    NSArray *array = model.clientType;
    if ([array containsObject:@(4)]) {
        [self.contentView HDUserRemindWithModel:model];
    }
}

#pragma mark - 聊天禁言提示
- (void)HDBanChatBroadcastWithModel:(BanChatModel *)model
{
    NSString *tipStr = [[NSString alloc]initWithFormat:@"用户:%@%@",model.userName,@"被禁言"];
    [_informationView removeFromSuperview];
    _informationView = [[InformationShowView alloc] initWithLabel:tipStr];
    [self.view addSubview:_informationView];
    [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
}

#pragma mark - 移除提示信息
-(void)removeInformationView {
    [_informationView removeFromSuperview];
    _informationView = nil;
}

#pragma mark- 视频或者文档大窗
/**
 *  @brief  视频或者文档大窗(The new method)
 *  isMain 1为视频为主,0为文档为主"
 */
- (void)onSwitchVideoDoc:(BOOL)isMain {
    if (_isSmallDocView) {
        [_playerView onSwitchVideoDoc:isMain];
    }
}
#pragma mark - 抽奖
/**
 *  @brief  开始抽奖
 */
- (void)start_lottery {
    if (_lotteryView) {
        [_lotteryView removeFromSuperview];
    }
    self.lotteryView = [[LotteryView alloc] initIsScreenLandScape:self.screenLandScape clearColor:NO];
    [APPDelegate.window addSubview:self.lotteryView];
    _lotteryView.frame = [UIScreen mainScreen].bounds;
    [self showRollCallView];
}
/**
 *  @brief  抽奖结果
 *  remainNum   剩余奖品数
 */
- (void)lottery_resultWithCode:(NSString *)code
                        myself:(BOOL)myself
                    winnerName:(NSString *)winnerName
                     remainNum:(NSInteger)remainNum {
    [_lotteryView lottery_resultWithCode:code myself:myself winnerName:winnerName remainNum:remainNum IsScreenLandScape:self.screenLandScape];
}
/**
 *  @brief  退出抽奖
 */
- (void)stop_lottery {
    [self.lotteryView remove];
}
#pragma mark - 问卷及问卷统计
/**
 *  @brief  问卷功能
 */
- (void)questionnaireWithTitle:(NSString *)title url:(NSString *)url {
    //问卷横屏输入事件(区分横屏聊天键盘事件)
    self.playerView.isQuestionnaireSurveyKeyBoardAction = YES;
    //初始化第三方问卷视图
    [self.questionNaire removeFromSuperview];
    self.questionNaire = nil;
    [self.view endEditing:YES];
    self.questionNaire = [[QuestionNaire alloc] initWithTitle:title url:url isScreenLandScape:self.screenLandScape];
//添加第三方问卷视图
    [self addAlerView:self.questionNaire];
}
/**
 *  @brief  提交问卷结果（成功，失败）
 */
- (void)commitQuestionnaireResult:(BOOL)success {
    WS(ws)
    //问卷横屏输入事件(区分横屏聊天键盘事件)
    self.playerView.isQuestionnaireSurveyKeyBoardAction = NO;
    [self.questionnaireSurvey commitSuccess:success];
    if(success &&self.submitedAction != 1) {
        [NSTimer scheduledTimerWithTimeInterval:3.0f target:ws selector:@selector(removeQuestionnaireSurvey) userInfo:nil repeats:NO];
    }
}
/**
 *  @brief  发布问卷
 */
- (void)questionnaire_publish {
    [self removeQuestionnaireSurvey];
}
/**
 *  @brief  获取问卷详细内容
 *  @param  detailDic {
            forcibly               //1就是强制答卷，0为非强制答卷
            id                     //问卷主键ID
            subjects               //包含的项目
            submitedAction         //1提交后查看答案，0为提交后不查看答案
            title                  //标题 }
 */
- (void)questionnaireDetailInformation:(NSDictionary *)detailDic {
    [self.view endEditing:YES];
    self.submitedAction     = [detailDic[@"submitedAction"] integerValue];
    //问卷横屏输入事件(区分横屏聊天键盘事件)
    self.playerView.isQuestionnaireSurveyKeyBoardAction = YES;
    //初始化问卷详情页面
    self.questionnaireSurvey = [[QuestionnaireSurvey alloc] initWithCloseBlock:^{
        [self removeQuestionnaireSurvey];
    } CommitBlock:^(NSDictionary *dic) {
        //提交问卷结果
        [self.requestData commitQuestionnaire:dic];
    } questionnaireDic:detailDic isScreenLandScape:self.screenLandScape isStastic:NO];
    //添加问卷详情
    [self addAlerView:self.questionnaireSurvey];
}
/**
 *  @brief  结束发布问卷
 */
- (void)questionnaire_publish_stop{
    WS(ws)
    //问卷横屏输入事件(区分横屏聊天键盘事件)
    self.playerView.isQuestionnaireSurveyKeyBoardAction = NO;
    [self.questionnaireSurveyPopUp removeFromSuperview];
    self.questionnaireSurveyPopUp = nil;
    if(self.questionnaireSurvey == nil) return;//如果已经结束发布问卷，不需要加载弹窗
    //结束编辑状态
    [self.view endEditing:YES];
    [self.questionnaireSurvey endEditing:YES];
    //初始化结束问卷弹窗
    self.questionnaireSurveyPopUp = [[QuestionnaireSurveyPopUp alloc] initIsScreenLandScape:self.screenLandScape SureBtnBlock:^{
        [ws removeQuestionnaireSurvey];
    }];
    //添加问卷弹窗
    [self addAlerView:self.questionnaireSurveyPopUp];
}
/**
 *  @brief  获取问卷统计
 *  @param  staticsDic {
            forcibly               //1就是强制答卷，0为非强制答卷
            id                     //问卷主键ID
            subjects               //包含的项目
            submitedAction         //1提交后查看答案，0为提交后不查看答案
            title                  //标题 }
 */
- (void)questionnaireStaticsInformation:(NSDictionary *)staticsDic {
    [self.view endEditing:YES];
    if (self.questionnaireSurvey != nil) {
        [self.questionnaireSurvey removeFromSuperview];
        self.questionnaireSurvey = nil;
    }
    //初始化问卷统计视图
    self.questionnaireSurvey = [[QuestionnaireSurvey alloc] initWithCloseBlock:^{
        [self removeQuestionnaireSurvey];
    } CommitBlock:nil questionnaireDic:staticsDic isScreenLandScape:self.screenLandScape isStastic:YES];
    //添加问卷统计视图
    [self addAlerView:self.questionnaireSurvey];
}
#pragma mark - 签到
/**
  *  @brief  开始签到
  */
- (void)start_rollcall:(NSInteger)duration{
    [self removeRollCallView];
    [self.view endEditing:YES];
    self.duration = duration;
    //添加签到视图
    [self addAlerView:self.rollcallView];
    [APPDelegate.window bringSubviewToFront:self.rollcallView];
}
#pragma mark - 答题卡
/**
  *  @brief  开始答题
  */
- (void)start_vote:(NSInteger)count singleSelection:(BOOL)single{
    [self removeVoteView];
    self.mySelectIndex = -1;
    [self.mySelectIndexArray removeAllObjects];
    WS(ws)
    VoteView *voteView = [[VoteView alloc] initWithCount:count singleSelection:single voteSingleBlock:^(NSInteger index) {
        //答单选题
        [ws.requestData reply_vote_single:index];
        ws.mySelectIndex = index;
    } voteMultipleBlock:^(NSMutableArray *indexArray) {
        //答多选题
        [ws.requestData reply_vote_multiple:indexArray];
        ws.mySelectIndexArray = [indexArray mutableCopy];
    } singleNOSubmit:^(NSInteger index) {
//        ws.mySelectIndex = index;
    } multipleNOSubmit:^(NSMutableArray *indexArray) {
//        ws.mySelectIndexArray = [indexArray mutableCopy];
    } isScreenLandScape:self.screenLandScape];
    
    voteView.cleanBlock = ^(BOOL result) {
        ws.cleanVoteBtn.hidden = NO;
    };
    
    //避免强引用 weak指针指向局部变量
    self.voteView = voteView;
    
    //添加voteView
    [self addAlerView:self.voteView];
}
/**
  *  @brief  结束答题
  */
- (void)stop_vote{
    if (_cleanVoteBtn.hidden == NO) {
        _cleanVoteBtn.hidden = YES;
    }
    [self removeVoteView];
}
/**
  *  @brief  答题结果
  *  @param  resultDic {answerCount         //参与回答人数
                        correctOption       //正确答案 (单选字符串，多选字符串数组)
                        statisics[{         //统计数组
                                    count   //选择当前选项人数
                                    option  //选项序号
                                    percent //正确率
                                    }]
                        voteCount           //题目数量
                        voteId              //题目ID
                        voteType            //题目类型}
  */
- (void)vote_result:(NSDictionary *)resultDic{
    if (_cleanVoteBtn.hidden == NO) {
        _cleanVoteBtn.hidden = YES;
    }
    [self removeVoteView];
    VoteViewResult *voteViewResult = [[VoteViewResult alloc] initWithResultDic:resultDic mySelectIndex:self.mySelectIndex mySelectIndexArray:self.mySelectIndexArray isScreenLandScape:self.screenLandScape];
    _voteViewResult = voteViewResult;
    //添加答题结果
    [self addAlerView:self.voteViewResult];
}
#pragma mark - 跑马灯
/**
 *    @brief    跑马灯
 *    @param    dic action  [{                      //事件
                                duration            //执行时间
                                end {               //结束位置
                                        alpha       //透明度
                                        xpos        //x坐标
                                        ypos        //y坐标 },
                                start {             //开始位置
                                        alpha       //透明度
                                        xpos        //x坐标
                                        ypos        //y坐标}]
                    image {                         //包含图片
                                height              //图片高度
                                image_url           //地址
                                width               //图片宽度}
                    loop                            //循环次数 -1 无限循环
                    text   {                        //文字信息
                                 color              //文字颜色
                                 content            //文字内容
                                 font_size          //字体大小}
                    type                            //当前类型 text 文本 image 图片
 */
- (void)receivedMarqueeInfo:(NSDictionary *)dic {
    if (dic == nil || self.openmarquee == NO) {
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
     if (index == 0) {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self.playerView addSubview:self.marqueeView];
                 [self.marqueeView startMarquee];
             });
        }
}
#pragma mark - 公告
/**
 *  @brief  公告
 */
- (void)announcement:(NSString *)str{
    //刚进入时的公告消息
    _gongGaoStr = StrNotEmpty(str) ? str : @"";
}
/**
 *  @brief  监听到有公告消息
 *  @dict   {action         //action 返回release 取出公告内容，action 返回remove 删除公告
             announcement   //公告内容}
 */
- (void)on_announcement:(NSDictionary *)dict{
    //如果当前不在公告页面,提示有新公告
    if (!_announcementView || _announcementView.hidden || _announcementView.frame.origin.y == SCREENH_HEIGHT ) {
        ///收到删除消息的时候不提示
        if([dict[@"action"] isEqualToString:@"release"]) {
            [_menuView showInformationViewWithTitle:NewAnnouncementMessage];
        }
    }
    if([dict[@"action"] isEqualToString:@"release"]) {
        _gongGaoStr = dict[@"announcement"];
    } else if([dict[@"action"] isEqualToString:@"remove"]) {
        _gongGaoStr = @"";
    }
    if(_announcementView) {
        [_announcementView updateViews:self.gongGaoStr];
    }
}
#pragma mark - 缓存速度
- (void)onBufferSpeed:(NSString *)speed
{
    self.playerView.bufferSpeed = speed;
}

#pragma mark - 随堂测
/**
 *    @brief       接收到随堂测 (3.10更改)
 *    rseultDic    随堂测内容
      resultDic    {
                   isExist                        //是否存在正在发布的随堂测 1 存在 0 不存在
                   practice{
                            id                    //随堂测ID
                            isAnswered            //是否已答题 true: 已答题, false: 未答题
                            options               //选项数组
                            ({
                                  id              //选项ID
                                  index           //选项索引
                            })
                            publishTime           //随堂测发布时间
                            status                //随堂测状态: 1 发布中 2 停止发布 3 已关闭
                            type                  //随堂测类型: 0 判断 1 单选 2 多选
                            submitRecord          //如果已答题，返回该学员答题记录，如果未答题，服务端不返回该字段
                            ({
                                optionId          //选项ID
                                optionIndex       //选项索引
                            })
                          }
                   serverTime                     //分发时间
                  }
 *
 */
- (void)receivePracticeWithDic:(NSDictionary *) resultDic
{
    // 1.是否存在正在发布的随堂测 或 随堂测的状态为已关闭
    if ([resultDic[@"isExist"] intValue] == 0 || [resultDic[@"practice"][@"status"] intValue] == 3) {
        _cleanTestBtn.hidden = YES;
        if (_testView) {
            [_testView removeFromSuperview];
            _testView = nil;
        }
        return;//如果不存在随堂测，返回。
    }
    // 2.随堂测是否已答题 或 随堂测已停止
    if ([resultDic[@"practice"][@"isAnswered"] boolValue] == YES || [resultDic[@"practice"][@"status"] intValue] == 2) {
        // practiceId 随堂测ID
        NSString *practiceId = resultDic[@"practice"][@"id"];
        [_requestData getPracticeStatisWithPracticeId:practiceId];
        _cleanTestBtn.hidden = YES;
    }
    // 3.随堂测未答题显示答题选项
    NSMutableDictionary *dict = [resultDic mutableCopy];
    [dict setObject:@[] forKey:@"answer"];
    self.testDict = dict;
    [self showTestViewIsScreenLandScape:self.screenLandScape];
}



/**
 *    @brief    展示随堂测
 *    @param    isScreenLandScape   NO 竖屏 YES 横屏
 */
- (void)showTestViewIsScreenLandScape:(NSInteger)isScreenLandScape
{
    if (_testView) {
       [_testView removeFromSuperview];
       [_testView stopTimer];
        _testView = nil;
    }
    [self.view endEditing:YES];
    [APPDelegate.window endEditing:YES];
    //初始化随堂测视图
    CCClassTestView *testView = [[CCClassTestView alloc] initWithTestDic:_testDict isScreenLandScape:self.screenLandScape];
    [APPDelegate.window addSubview:testView];
    self.testView = testView;
    WS(weakSelf)
    self.testView.CommitBlock = ^(NSArray * _Nonnull arr) {//提交答案回调
       [weakSelf.requestData commitPracticeWithPracticeId:_testDict[@"practice"][@"id"] options:arr];
    };
    _testView.StaticBlock = ^(NSString * _Nonnull practiceId) {//获取统计回调
       [weakSelf.requestData getPracticeStatisWithPracticeId:practiceId];
    };
    // 随堂测收起操作
    _testView.cleanBlock = ^(NSMutableDictionary * _Nonnull result) {
        self.testDict = result;
        weakSelf.cleanTestBtn.hidden = NO;
    };
}


/**
 *    @brief    随堂测提交结果(3.10更改)
 *    rseultDic    提交结果,调用commitPracticeWithPracticeId:(NSString *)practiceId options:(NSArray *)options后执行
 *
      resultDic {datas {practice                                 //随堂测
                             { answerResult                      //回答是否正确 1 正确 0 错误
                               id                                //随堂测ID
                               isRepeatAnswered                  //是否重复答题 true: 重复答题, false: 第一次答题
                               options ({  count                 //参与人数
                                             id                  //选项主键ID
                                             index               //选项序号
                                             isCorrect           //是否正确
                                             percent             //选项占比})
                               submitRecord 如果重复答题，则返回该学员第一次提交的记录，否则，返回该学员当前提交记录
                                            ({ optionId          //提交记录 提交选项ID
                                               optionIndex       //提交选项序号})
                               type                              //随堂测类型: 0 判断 1 单选 2 多选}}}
 */
-(void)practiceSubmitResultsWithDic:(NSDictionary *) resultDic{
    [_testView practiceSubmitResultsWithDic:resultDic];
    
}
/**
 *    @brief    随堂测统计结果(3.10更改)
 *    rseultDic    统计结果,调用getPracticeStatisWithPracticeId:(NSString *)practiceId后执行
      resultDic  {practice {                                //随堂测
                            answerPersonNum                 //回答该随堂测的人数
                            correctPersonNum                //回答正确的人数
                            correctRate                     //正确率
                            id                              //随堂测ID
                            options ({                      //选项数组
                                        count               //选择该选项的人数
                                        id                  //选项ID
                                        index               //选项序号
                                        isCorrect           //是否为正确选项 1 正确 0 错误
                                        percent             //选择该选项的百分比})
                            status                          //随堂测状态  1 发布中 2 停止发布
                            type                            //随堂测类型: 0 判断 1 单选 2 多选}}
 */
- (void)practiceStatisResultsWithDic:(NSDictionary *) resultDic
{
    if (_cleanTestBtn.hidden == NO) {
        _cleanTestBtn.hidden = YES;
    }
    if (_testView) {
        [self.view endEditing:YES];
        [APPDelegate.window endEditing:YES];
    }
    [_testView getPracticeStatisWithResultDic:resultDic isScreen:self.screenLandScape];
}
/**
 *    @brief    停止随堂测(The new method)
 *    rseultDic    结果
 *    resultDic {practiceId //随堂测主键ID}
 */
-(void)practiceStopWithDic:(NSDictionary *) resultDic{
    if (_cleanTestBtn.hidden == NO) {
        _cleanTestBtn.hidden = YES;
    }
    [_testView stopTest];
    [self.requestData getPracticeRankWithPracticeId:resultDic[@"practiceId"]];
}
/**
 *    @brief    关闭随堂测(The new method)
 *    rseultDic    结果
 *    resultDic {practiceId //随堂测主键ID}
 */
-(void)practiceCloseWithDic:(NSDictionary *) resultDic{
    if (_cleanTestBtn.hidden == NO) {
        _cleanTestBtn.hidden = YES;
    }
    //移除随堂测视图
    [_testView removeFromSuperview];
    _testView = nil;
}
/**
 *    @brief    收到奖杯(The new method)
 *    dic       结果
 *    "type":  1 奖杯 2 其他
 *    "viewerName": 获奖用户名
 *    "viewerId": 获奖用户ID
 */
-(void)prize_sendWithDict:(NSDictionary *)dic{
    NSString *name = @"";
    [self.view endEditing:YES];
    [APPDelegate.window endEditing:YES];
    if (![dic[@"viewerId"] isEqualToString:self.viewerId]) {
        name = dic[@"viewerName"];
    }
    CCCupView *cupView = [[CCCupView alloc] initWithWinnerName:name isScreen:self.screenLandScape];
    [APPDelegate.window addSubview:cupView];
}
#pragma mark - 添加通知
-(void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
}
-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}
/**
 APP将要进入后台
 */
- (void)appWillEnterBackgroundNotification {
//#ifdef LockView
    if (_pauseInBackGround == NO) {
        [_lockView updateLockView];
    }
//#endif
}
/**
 APP将要进入前台
 */
- (void)appWillEnterForegroundNotification {
    if (_requestData.ijkPlayer.playbackState == IJKMPMoviePlaybackStatePaused) {
        [_requestData.ijkPlayer play];
    }
}


#pragma mark - 添加弹窗类事件
-(void)addAlerView:(UIView *)view{
    [APPDelegate.window addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self showRollCallView];
}
#pragma mark - 禁言弹窗
-(void)addBanAlertView:(NSString *)str{
    [_alertView removeFromSuperview];
    _alertView = nil;
    _alertView = [[CCAlertView alloc] initWithAlertTitle:str sureAction:@"好的" cancelAction:nil sureBlock:nil];
    [APPDelegate.window addSubview:_alertView];
}
#pragma mark - 移除答题卡视图
-(void)removeVoteView{
    [_voteView removeFromSuperview];
    _voteView = nil;
    [_voteViewResult removeFromSuperview];
    _voteViewResult = nil;
    [self.view endEditing:YES];
}
#pragma mark - 懒加载
//playView
-(CCPlayerView *)playerView{
    if (!_playerView) {
        //视频视图
        _playerView = [[CCPlayerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462)) docViewType:_isSmallDocView];
        _playerView.delegate = self;
        WS(weakSelf)
        //切换线路
        _playerView.selectedRod = ^(NSInteger selectedRod) {
            [weakSelf selectedRodWidthIndex:selectedRod];
        };
        //切换清晰度
        _playerView.selectedIndex = ^(NSInteger selectedRod,NSInteger selectedIndex) {
            [weakSelf selectedRodWidthIndex:selectedRod secIndex:selectedIndex];
        };
        //发送聊天
        _playerView.sendChatMessage = ^(NSString * sendChatMessage) {
            [weakSelf sendChatMessageWithStr:sendChatMessage];
        };
    }
    return _playerView;
}
//contentView
-(CCInteractionView *)contentView{
    if (!_contentView) {
        WS(ws)
        _contentView = [[CCInteractionView alloc] initWithFrame:CGRectMake(0, CCGetRealFromPt(462)+SCREEN_STATUS, SCREEN_WIDTH,IS_IPHONE_X ? CCGetRealFromPt(835) + 90:CCGetRealFromPt(835)) hiddenMenuView:^{
            [ws hiddenMenuView];
        } chatBlock:^(NSString * _Nonnull msg) {
            [ws.requestData chatMessage:msg];
//            [ws.requestData sendChatMessage:msg completion:^(BOOL success) {
//                        NSString * str;
//                        if (success == YES) {
//                //            NSLog(@"发送成功");
//                            str =@"发送成功";
//                        } else {
//                //            NSLog(@"发送失败");
//                             str =@"发送失败";
//                        }
//                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
//
//                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//
//                        }];
//                        [alertController addAction:okAction];
//                        [self presentViewController:alertController animated:YES completion:nil];
//            }];
        } privateChatBlock:^(NSString * _Nonnull anteid, NSString * _Nonnull msg) {
            [ws.requestData privateChatWithTouserid:anteid msg:msg];
        } questionBlock:^(NSString * _Nonnull message) {
            if (_isLivePlay == NO) {
                [self addBanAlertView:@"直播未开始，无法提问"];
                return;
            }
            [ws.requestData question:message];
        } docViewType:_isSmallDocView];
        _contentView.playerView = self.playerView;
    }
    return _contentView;
}
//竖屏模式下点击空白退出键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.screenLandScape == NO) {
        [self.view endEditing:YES];
    }
}

//隐藏home条
- (BOOL)prefersHomeIndicatorAutoHidden {
    return  YES;
}
-(void) stopTimer {
    if([_userCountTimer isValid]) {
        [_userCountTimer invalidate];
        _userCountTimer = nil;
    }
}
//问卷和问卷统计
//移除问卷视图
-(void)removeQuestionnaireSurvey {
    [_questionnaireSurvey removeFromSuperview];
    _questionnaireSurvey = nil;
    [_questionnaireSurveyPopUp removeFromSuperview];
    _questionnaireSurveyPopUp = nil;
}
//签到
-(RollcallView *)rollcallView {
    if(!_rollcallView) {
        RollcallView *rollcallView = [[RollcallView alloc] initWithDuration:self.duration lotteryblock:^{
            [self.requestData answer_rollcall];//签到
        } isScreenLandScape:self.screenLandScape];
        _rollcallView = rollcallView;
    }
    return _rollcallView;
}
//移除签到视图
-(void)removeRollCallView {
    [_rollcallView removeFromSuperview];
    _rollcallView = nil;
}
//显示签到视图
-(void)showRollCallView{
    if (_rollcallView) {
        [APPDelegate.window bringSubviewToFront:_rollcallView];
    }
}
/**
 *    @brief    收起状态下 随堂测按钮
 */
- (UIButton *)cleanTestBtn
{
    if (!_cleanTestBtn) {
        _cleanTestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cleanTestBtn setImage:[UIImage imageNamed:@"clean_testView"] forState:UIControlStateNormal];
        _cleanTestBtn.hidden = YES;
        [_cleanTestBtn addTarget:self action:@selector(cleanTestBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanTestBtn;
}
/**
 *    @brief    收起状态下随堂测按钮点击事件
 */
- (void)cleanTestBtnClick
{
    self.cleanTestBtn.hidden = YES;
    [self.testView show];
}
/**
 *    @brief    收起状态下 答题卡按钮
 */
- (UIButton *)cleanVoteBtn
{
    if (!_cleanVoteBtn) {
        _cleanVoteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cleanVoteBtn setImage:[UIImage imageNamed:@"clean_voteView"] forState:UIControlStateNormal];
        _cleanVoteBtn.hidden = YES;
        [_cleanVoteBtn addTarget:self action:@selector(cleanVoteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanVoteBtn;
}
/**
 *    @brief    收起状态下随堂测按钮点击事件
 */
- (void)cleanVoteBtnClick
{
    self.cleanVoteBtn.hidden = YES;
    [self.voteView show];
}
/**
 *    @brief    随堂测数据
 */
- (NSMutableDictionary *)testDict
{
    if (!_testDict) {
        _testDict = [NSMutableDictionary dictionary];
    }
    return _testDict;
}


//更多菜单
-(SelectMenuView *)menuView{
    if (!_menuView) {
        WS(ws)
        _menuView = [[SelectMenuView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - CCGetRealFromPt(100), SCREENH_HEIGHT - CCGetRealFromPt(240) - kScreenBottom, CCGetRealFromPt(70), CCGetRealFromPt(70))];
        //私聊按钮回调
        _menuView.privateBlock = ^{
            [ws.contentView.chatView privateChatBtnClicked];
            [APPDelegate.window bringSubviewToFront:ws.contentView.chatView.ccPrivateChatView];
        };
        //公告按钮回调
        _menuView.announcementBlock = ^{
            [ws announcementBtnClicked];
            [APPDelegate.window bringSubviewToFront:ws.announcementView];
        };
    }
    return _menuView;
}
//收回菜单
-(void)hiddenMenuView{

}

//公告
-(AnnouncementView *)announcementView{
    if (!_announcementView) {
        _announcementView = [[AnnouncementView alloc] initWithAnnouncementStr:_gongGaoStr];
        _announcementView.frame = CGRectMake(0, SCREENH_HEIGHT, SCREEN_WIDTH, CCGetRealFromPt(835));
    }
    return _announcementView;
}
//点击公告按钮
-(void)announcementBtnClicked{
    [APPDelegate.window addSubview:self.announcementView];
    [UIView animateWithDuration:0.3 animations:^{
       _announcementView.frame = CGRectMake(0, CCGetRealFromPt(462)+SCREEN_STATUS, SCREEN_WIDTH,IS_IPHONE_X ? CCGetRealFromPt(835) + 90:CCGetRealFromPt(835));
    }];
}
-(void)dealloc{
//    NSLog(@"%s", __func__);
    /*      自动登录情况下，会存在移除控制器但是SDK没有销毁的情况 */
    if (_requestData) {
        [_requestData requestCancel];
        _requestData = nil;
    }
}
@end
