//
//  CCPlayerController.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/22.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCPlayerController.h"
#import "CCSDK/RequestData.h"//SDK
#import "CCPlayerView.h"//视频
#import "CCIntroductionView.h"//简介
#import "CCQuestionView.h"//问答
#import "Dialogue.h"//模型
#import "ChatView.h"//聊天
#import "LoadingView.h"//加载
#import "CCSDK/SaveLogUtil.h"//日志

@interface CCPlayerController ()<RequestDataDelegate,UIScrollViewDelegate,UITextFieldDelegate>


@property(nonatomic,copy)  NSString                 *viewerId;


@property (nonatomic,strong)UIView                   * shadowView;//滚动条
@property (nonatomic,strong)UIView                   * pptView;//文档视图
@property (nonatomic,strong)UIView                   * smallVideoView;//文档或者小图
@property(nonatomic,strong)NSTimer                   * userCountTimer;
@property (nonatomic,assign)NSInteger                  templateType;//房间类型
@property (nonatomic, strong)NSString                * roomName;//房间名
@property (nonatomic,strong)RequestData              * requestData;//sdk
@property (nonatomic,strong)UIScrollView             * scrollView;//文档聊天等视图
@property (nonatomic,strong)CCPlayerView             * playerView;//视频视图
@property (nonatomic,strong)UISegmentedControl       * segment;//功能切换,文档,聊天等
@property (nonatomic,strong)CCIntroductionView       * introductionView;//简介视图

@property (nonatomic,strong)CCQuestionView           * questionChatView;//问答视图
@property (strong, nonatomic) NSMutableArray         * keysArrAll;//问答数组
@property (nonatomic,strong)NSMutableDictionary      * QADic;//问答字典

@property (nonatomic,strong)ChatView                 * chatView;//聊天
@property (nonatomic,strong)NSMutableArray           * publicChatArray;//公聊
@property (nonatomic,strong)NSMutableDictionary      * userDic;//聊天字典
@property (nonatomic,strong)NSMutableDictionary      * dataPrivateDic;//私聊

@property (nonatomic,assign)BOOL                     isScreenLandScape;//是否横屏
@property (nonatomic,assign)BOOL                     screenLandScape;//横屏
@property (nonatomic,assign)BOOL                     isHomeIndicatorHidden;//隐藏home条
@property (nonatomic,assign)BOOL                     endNormal;//是否直播结束
@property (nonatomic,strong)UIView                   * lineView;//分割线
@property (nonatomic,strong)UIView                   * line;//分割线
@property (nonatomic,strong)UIButton                 * changeButton;//切换窗口
@property (nonatomic,assign)NSInteger                firRoadNum;//房间线路
@property (nonatomic,strong)LoadingView              * loadingView;//加载视图
@property (nonatomic,strong)NSMutableArray           * secRoadKeyArray;//清晰度数组





@end

@implementation CCPlayerController
//初始化
- (instancetype)initWithRoomName:(NSString *)roomName {
    self = [super init];
    if(self) {
        self.roomName = roomName;
    }
    return self;
}
//启动
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self setupUI];//创建UI
    
    [self integrationSDK];//集成SDK
    [self addObserver];//添加通知

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObserver];//移除通知
}


/**
 集成sdk
 */
- (void)integrationSDK {
    PlayParameter *parameter = [[PlayParameter alloc] init];
    parameter.userId = GetFromUserDefaults(WATCH_USERID);//userId
    parameter.roomId = GetFromUserDefaults(WATCH_ROOMID);//roomId
    parameter.viewerName = GetFromUserDefaults(WATCH_USERNAME);//用户名
    parameter.token = GetFromUserDefaults(WATCH_PASSWORD);//密码
    parameter.playerParent = self.playerView;//视频视图
    parameter.playerFrame = CGRectMake(0,0,self.playerView.frame.size.width, self.playerView.frame.size.height);//视频位置,ps:起始位置为视频视图坐标
    parameter.docParent = self.smallVideoView;//文档小窗
    parameter.docFrame = CGRectMake(0,0,self.smallVideoView.frame.size.width, self.smallVideoView.frame.size.height);//文档位置,ps:起始位置为文档视图坐标
    parameter.security = YES;//是否开启https,建议开启
    parameter.PPTScalingMode = 4;//ppt展示模式,建议值为4
    parameter.defaultColor = [UIColor whiteColor];//ppt默认底色，不写默认为白色
    parameter.scalingMode = 1;//屏幕适配方式
    parameter.pauseInBackGround = YES;//后台是否继续播放
    parameter.viewerCustomua = @"viewercustomua";//自定义参数,没有的话这么写就可以
    parameter.pptInteractionEnabled = NO;//是否开启ppt滚动
    parameter.DocModeType = 0;//设置当前的文档模式
    _requestData = [[RequestData alloc] initWithParameter:parameter];
    _requestData.delegate = self;
    
    _loadingView = [[LoadingView alloc] initWithLabel:@"视频加载中" centerY:YES];
    [self.playerView addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];

}

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
    
    if(rodIndex >self.firRoadNum) {
        [_requestData switchToPlayUrlWithFirIndex:0 key:@""];
    } else {
        [_requestData switchToPlayUrlWithFirIndex:rodIndex-1 key:[self.secRoadKeyArray firstObject]];
    }
    
}

/**
 切换清晰度

 @param rodIndex 线路
 @param secIndex 清晰度
 */
- (void)selectedRodWidthIndex:(NSInteger)rodIndex secIndex:(NSInteger)secIndex {
    [_requestData switchToPlayUrlWithFirIndex:rodIndex-1 key:[_secRoadKeyArray objectAtIndex:secIndex]];
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
    return UIInterfaceOrientationMaskAllButUpsideDown;
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

/**
 点击全屏按钮
 */
- (void)quanpingButtonClick {
    [self.view endEditing:YES];
    self.screenLandScape = YES;
    [self.chatView resignFirstResponder];
    self.isScreenLandScape = YES;
    self.playerView.backButton.tag = 2;
    [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    self.isScreenLandScape = NO;
    [UIApplication sharedApplication].statusBarHidden = YES;
    if (_changeButton.tag == 1) {
        [_requestData changePlayerFrame:self.view.frame];
    } else {
        [_requestData changeDocFrame:self.view.frame];
    }
    [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(SCREENH_HEIGHT);
    }];
    [self.playerView layoutIfNeeded];//
    self.segment.hidden = YES;
    self.shadowView.hidden = YES;
    self.scrollView.hidden = YES;
    self.line.hidden = YES;
    self.lineView.hidden = YES;
    [self.playerView layouUI:YES];
    CGRect rect = self.view.frame;
    [self.smallVideoView setFrame:CGRectMake(rect.size.width -CCGetRealFromPt(220), CCGetRealFromPt(332), CCGetRealFromPt(200), CCGetRealFromPt(150))];
}

/**
 切换视频和文档

 @param sender 切换
 */
- (void)changeButtonClick:(UIButton *)sender {
    if (sender.tag == 1) {//切换文档大屏
        sender.tag = 2;
        [sender setTitle:@"切换视频" forState:UIControlStateNormal];
        [_requestData changeDocParent:self.playerView];
        [_requestData changePlayerParent:self.smallVideoView];
        [_requestData changeDocFrame:CGRectMake(0, 0,self.playerView.frame.size.width, self.playerView.frame.size.height)];
        [_requestData changePlayerFrame:CGRectMake(0, 0, self.smallVideoView.frame.size.width, self.smallVideoView.frame.size.height)];
    } else {//切换文档小屏
        sender.tag = 1;
        [sender setTitle:@"切换文档" forState:UIControlStateNormal];
        [_requestData changeDocParent:self.smallVideoView];
        [_requestData changePlayerParent:self.playerView];
        [_requestData changePlayerFrame:CGRectMake(0, 0,self.playerView.frame.size.width, self.playerView.frame.size.height)];
        [_requestData changeDocFrame:CGRectMake(0, 0, self.smallVideoView.frame.size.width, self.smallVideoView.frame.size.height)];
    }
    [self.playerView bringSubviewToFront:self.playerView.topShadowView];
    [self.playerView bringSubviewToFront:self.playerView.bottomShadowView];
}

/**
 //结束直播和退出全屏

 @param sender 点击按钮
 */
- (void)backButtonClick:(UIButton *)sender {
    if (sender.tag == 2) {//横屏返回竖屏
        self.isScreenLandScape = YES;
        self.screenLandScape = NO;
        self.playerView.selectedIndexView.hidden = YES;
        sender.tag = 1;
        [self.playerView endEditing:NO];
        self.playerView.contentView.hidden = YES;
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
        [UIApplication sharedApplication].statusBarHidden = NO;
        self.isScreenLandScape = NO;
        if (_changeButton.tag == 1) {
            
            [_requestData changePlayerFrame:CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462))];
        } else {
            [_requestData changeDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462))];
        }
        [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(CCGetRealFromPt(462));
            make.top.equalTo(self.view).offset(SCREEN_STATUS);
        }];
        [self.playerView layoutIfNeeded];//
        self.segment.hidden = NO;
        self.shadowView.hidden = NO;
        self.scrollView.hidden = NO;
        self.line.hidden = NO;
        self.lineView.hidden = NO;
        CGRect rect = self.view.frame;
        [self.smallVideoView setFrame:CGRectMake(rect.size.width -CCGetRealFromPt(220), CCGetRealFromPt(462)+CCGetRealFromPt(82)+(IS_IPHONE_X? 44:20), CCGetRealFromPt(200), CCGetRealFromPt(150))];
        [self.playerView layouUI:NO];
    }else if( sender.tag == 1){//结束直播
        [self creatAlertController_alert];
      
    }
}
//创建提示窗
-(void)creatAlertController_alert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您确认结束观看直播吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self stopTimer];
        [self.requestData requestCancel];
        self.requestData = nil;
        [self.smallVideoView removeFromSuperview];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

/**
 创建UI
 */
- (void)setupUI {
   
    _endNormal = YES;//是否直播结束
    //视频视图
    self.playerView = [[CCPlayerView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(CCGetRealFromPt(462));
        make.top.equalTo(self.view).offset(SCREEN_STATUS);
    }];
    [self.playerView layoutIfNeeded];//
    [self.playerView.backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.playerView.changeButton addTarget:self action:@selector(changeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _changeButton = self.playerView.changeButton;
    [self.playerView.quanpingButton addTarget:self action:@selector(quanpingButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    WS(ws)
    //切换线路
    self.playerView.selectedRod = ^(NSInteger selectedRod) {
        [ws selectedRodWidthIndex:selectedRod];
    };
    //切换清晰度
    self.playerView.selectedIndex = ^(NSInteger selectedRod,NSInteger selectedIndex) {
        [ws selectedRodWidthIndex:selectedRod secIndex:selectedIndex];
    };
    //发送聊天
    self.playerView.sendChatMessage = ^(NSString * sendChatMessage) {
        [ws sendChatMessageWithStr:sendChatMessage];
    };
    
    //文档小窗
    CGRect rect = self.view.frame;
    CGRect smallVideoRect = CGRectMake(rect.size.width -CCGetRealFromPt(220), CCGetRealFromPt(462)+CCGetRealFromPt(82)+(IS_IPHONE_X? 44:20), CCGetRealFromPt(202), CCGetRealFromPt(152));
    self.smallVideoView = [[UIView alloc] initWithFrame:smallVideoRect];
    self.smallVideoView.backgroundColor = [UIColor lightGrayColor];
    self.smallVideoView.layer.borderWidth = 0.5;
    self.smallVideoView.layer.borderColor = [UIColor colorWithHexString:@"dddddd" alpha:1.0f].CGColor;
    // 阴影颜色
    self.smallVideoView.layer.shadowColor = [UIColor colorWithHexString:@"dddddd" alpha:1.0f].CGColor;
    // 阴影偏移，默认(0, -3)
    self.smallVideoView.layer.shadowOffset = CGSizeMake(0,3);
    // 阴影透明度，默认0
    self.smallVideoView.layer.shadowOpacity = 0.7f;
    // 阴影半径，默认3
    self.smallVideoView.layer.shadowRadius = 3;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handlePan:)];
    [self.smallVideoView addGestureRecognizer:panGestureRecognizer];
    [APPDelegate.window addSubview:self.smallVideoView];
    
    
    //UISegmentedControl,功能控制,聊天文档等
    [self.view addSubview:self.segment];
    self.segment.frame = CGRectMake(0, CCGetRealFromPt(462)+SCREEN_STATUS, SCREEN_WIDTH, CCGetRealFromPt(82));
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = CCRGBColor(232,232,232);
    [self.view addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.segment);
        make.height.mas_equalTo(1);
    }];
    
    [self.view addSubview:self.shadowView];
    self.line = [[UIView alloc] init];
    self.line.backgroundColor = [UIColor colorWithHexString:@"#dddddd" alpha:1.0f];
    [self.view addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.segment);
        make.height.mas_equalTo(0.5f);
        make.bottom.equalTo(self.shadowView);
    }];
    //UIScrollView分块,聊天,问答,简介均添加在这里
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CCGetRealFromPt(462) + CCGetRealFromPt(82)+SCREEN_STATUS, self.view.frame.size.width , self.view.frame.size.height - (CCGetRealFromPt(462) + CCGetRealFromPt(80))-SCREEN_STATUS)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollEnabled = NO;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 3, _scrollView.frame.size.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    //添加聊天
    [_scrollView addSubview:self.chatView];
    self.chatView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    
    //添加
    [_scrollView addSubview:self.questionChatView];
    self.questionChatView.frame = CGRectMake(_scrollView.frame.size.width * 1, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);

    //添加简介
    [_scrollView addSubview:self.introductionView];
    self.introductionView.frame = CGRectMake(_scrollView.frame.size.width * 2, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    
    
}
- (void)timerfunc {
    // (已废弃)获取在线房间人数，当登录成功后即可调用此接口，登录不成功或者退出登录后就不可以调用了，如果要求实时性比较强的话，可以写一个定时器，不断调用此接口，几秒钟发一次就可以，然后在代理回调函数中，处理返回的数据
    //最新注释:该接口默认最短响应时间为15秒,获取在线房间人数，当登录成功后即可调用此接口，登录不成功或者退出登录后就不可以调用了，如果要求实时性比较强的话，可以写一个定时器，不断调用此接口，然后在代理回调函数中，处理返回的数据
    [_requestData roomUserCount];
}

#pragma mark- 必须实现的代理方法

/**
 *    @brief    请求成功
 */
-(void)requestSucceed {
    //    NSLog(@"请求成功！");
    [self stopTimer];
    _userCountTimer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(timerfunc) userInfo:nil repeats:YES];
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
}

#pragma mark-----------------------功能代理方法 用哪个实现哪个-------------------------------
#pragma mark- 房间信息
//房间信息
-(void)roomInfo:(NSDictionary *)dic {
    _roomName = dic[@"name"];
    self.playerView.titleLabel.text = _roomName;
    NSArray *array = [_introductionView subviews];
    for(UIView *view in array) {
        [view removeFromSuperview];
    }
    self.introductionView.roomDesc = dic[@"desc"];
    if(!StrNotEmpty(dic[@"desc"])) {
        self.introductionView.roomDesc = @"暂无简介";
    }
    self.introductionView.roomName = dic[@"name"];
    
    CGFloat shadowViewY = self.segment.frame.origin.y+self.segment.frame.size.height-2;
    _templateType = [dic[@"templateType"] integerValue];
    //    @"文档",@"聊天",@"问答",@"简介"
    if (_templateType == 1) {
        //聊天互动： 无 直播文档： 无 直播问答： 无
        [_segment setWidth:0.0f forSegmentAtIndex:0];
        [_segment setWidth:0.0f forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width forSegmentAtIndex:2];
        _segment.selectedSegmentIndex = 2;
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0] + [self.segment widthForSegmentAtIndex:1]+[self.segment widthForSegmentAtIndex:2]/4, shadowViewY, [self.segment widthForSegmentAtIndex:2]/2, 2);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(self.view.frame.size.width * 2, py)];
        [self.smallVideoView removeFromSuperview];
        self.playerView.changeButton.hidden = YES;
        [self.playerView.contentView removeFromSuperview];
    } else if (_templateType == 2) {
        //聊天互动： 有 直播文档： 无 直播问答： 有
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:0];
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:2];
        _segment.selectedSegmentIndex = 0;
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0]/4, shadowViewY, [self.segment widthForSegmentAtIndex:1]/2, 2);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(self.view.frame.size.width*0, py)];
        [self.smallVideoView removeFromSuperview];
        self.playerView.changeButton.hidden = YES;

    } else if (_templateType == 3) {
        //聊天互动： 有 直播文档： 无 直播问答： 无
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:0];
        [_segment setWidth:0.0f forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:2];
        _segment.selectedSegmentIndex = 0;
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0]/4, shadowViewY, [self.segment widthForSegmentAtIndex:1]/2, 2);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(self.view.frame.size.width*0, py)];
        [self.smallVideoView removeFromSuperview];
        self.playerView.changeButton.hidden = YES;

    } else if (_templateType == 4) {
        //聊天互动： 有 直播文档： 有 直播问答： 无
        _segment.selectedSegmentIndex = 0;
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:0];
        [_segment setWidth:0.0f forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:2];
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0]/4, shadowViewY, [self.segment widthForSegmentAtIndex:0]/2, 2);
    } else if (_templateType == 5) {
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:0];
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:2];
        _segment.selectedSegmentIndex = 0;
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0]/4, shadowViewY, [self.segment widthForSegmentAtIndex:0]/2, 2);
        //聊天互动： 有 直播文档： 有 直播问答： 有
    }else if(_templateType == 6) {
        //聊天互动： 无 直播文档： 无 直播问答： 有
        _segment.selectedSegmentIndex = 1;
        [_segment setWidth:0.0f forSegmentAtIndex:0];
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:2];
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0]+[self.segment widthForSegmentAtIndex:1]/4, shadowViewY, [self.segment widthForSegmentAtIndex:1]/2, 2);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(self.view.frame.size.width * 1, py)];
        [self.smallVideoView removeFromSuperview];
        self.playerView.changeButton.hidden = YES;
        [self.playerView.contentView removeFromSuperview];

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
}

#pragma mark- 收到在线人数
/**
 *    @brief    收到在线人数
 */
- (void)onUserCount:(NSString *)count {
//    WS(ws)
//    _roomUserCount = count;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playerView.userCountLabel.text = count;
    });
}
#pragma mark- 服务器端给自己设置的UserId也就是viewerId
/**
 *    @brief    服务器端给自己设置的UserId
 */
-(void)setMyViewerId:(NSString *)viewerId {
    _viewerId = viewerId;
}
#pragma mark- 聊天
/**
 *    @brief    收到私聊信息
 */
- (void)OnPrivateChat:(NSDictionary *)dic {

    if(dic[@"fromuserid"] && dic[@"fromusername"] && [self.userDic objectForKey:dic[@"fromuserid"]] == nil) {
        [self.userDic setObject:dic[@"fromusername"] forKey:dic[@"fromuserid"]];
    }
    if(dic[@"touserid"] && dic[@"tousername"] && [self.userDic objectForKey:dic[@"touserid"]] == nil) {
        [self.userDic setObject:dic[@"tousername"] forKey:dic[@"touserid"]];
    }
    Dialogue *dialogue = [[Dialogue alloc] init];
    dialogue.userid = dic[@"fromuserid"];
    dialogue.fromuserid = dic[@"fromuserid"];
    dialogue.username = dic[@"fromusername"];
    dialogue.fromusername = dic[@"fromusername"];
    dialogue.fromuserrole = dic[@"fromuserrole"];
    dialogue.useravatar = dic[@"useravatar"];
    dialogue.touserid = dic[@"touserid"];
    dialogue.msg = dic[@"msg"];
    dialogue.time = dic[@"time"];
    dialogue.tousername = self.userDic[dialogue.touserid];
    dialogue.myViwerId = _viewerId;
    
    NSString *anteName = nil;
    NSString *anteid = nil;
    if([dialogue.fromuserid isEqualToString:self.viewerId]) {
        anteid = dialogue.touserid;
        anteName = dialogue.tousername;
    } else {
        anteid = dialogue.fromuserid;
        anteName = dialogue.fromusername;
    }
    NSMutableArray *array = [self.dataPrivateDic objectForKey:anteid];
    if(!array) {
        array = [[NSMutableArray alloc] init];
        [self.dataPrivateDic setValue:array forKey:anteid];
    }
    [array addObject:dialogue];
    [self.chatView reloadPrivateChatDict:self.dataPrivateDic anteName:anteName anteid:anteid];
}
/**
 *    @brief  历史聊天数据
 */
- (void)onChatLog:(NSArray *)chatLogArr {
    
    [self.userDic removeAllObjects];
    [self.publicChatArray removeAllObjects];
    
    for(NSDictionary *dic in chatLogArr) {
        Dialogue *dialogue = [[Dialogue alloc] init];
        dialogue.userid = dic[@"userId"];
        dialogue.fromuserid = dic[@"userId"];
        dialogue.username = dic[@"userName"];
        dialogue.fromusername = dic[@"userName"];
        dialogue.userrole = dic[@"userRole"];
        dialogue.fromuserrole = dic[@"userRole"];
        dialogue.msg = dic[@"content"];
        dialogue.useravatar = dic[@"userAvatar"];
        dialogue.time = dic[@"time"];
        dialogue.myViwerId = _viewerId;
        
        if([self.userDic objectForKey:dialogue.userid] == nil) {
            [self.userDic setObject:dic[@"userName"] forKey:dialogue.userid];
        }
        
        [self.publicChatArray addObject:dialogue];
    }
    [self.chatView reloadPublicChatArray:self.publicChatArray];
}
/**
 *    @brief  收到公聊消息
 */
- (void)onPublicChatMessage:(NSDictionary *)dic {
    
    [self.playerView insertDanmuString:dic[@"msg"]];
    Dialogue *dialogue = [[Dialogue alloc] init];
    dialogue.userid = dic[@"userid"];
    dialogue.fromuserid = dic[@"userid"];
    dialogue.username = dic[@"username"];
    dialogue.fromusername = dic[@"username"];
    dialogue.userrole = dic[@"userrole"];
    dialogue.fromuserrole = dic[@"userrole"];
    dialogue.msg = dic[@"msg"];
    dialogue.useravatar = dic[@"useravatar"];
    dialogue.time = dic[@"time"];
    dialogue.myViwerId = _viewerId;
    
    if([self.userDic objectForKey:dialogue.userid] == nil) {
        [self.userDic setObject:dic[@"username"] forKey:dialogue.userid];
    }
    [self.publicChatArray addObject:dialogue];
    [self.chatView reloadPublicChatArray:self.publicChatArray];
}
/**
 *  @brief  接收到发送的广播
 */
- (void)broadcast_msg:(NSDictionary *)dic {
    
    Dialogue *dialogue = [[Dialogue alloc] init];
    dialogue.msg = [NSString stringWithFormat:@"系统消息：%@",dic[@"value"][@"content"]];
    [self.publicChatArray addObject:dialogue];
    [self.chatView reloadPublicChatArray:self.publicChatArray];
}
/*
 *  @brief  收到自己的禁言消息，如果你被禁言了，你发出的消息只有你自己能看到，其他人看不到
 */
- (void)onSilenceUserChatMessage:(NSDictionary *)message {
    [self onPublicChatMessage:message];
}

/**
 *    @brief    当主讲全体禁言时，你再发消息，会出发此代理方法，information是禁言提示信息
 */
- (void)information:(NSString *)information {
    NSString *str = @"讲师暂停了问答，请专心看直播吧";
    if(_segment.selectedSegmentIndex == 0) {
        str = @"讲师暂停了文字聊天，请专心看直播吧";
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:str preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark- 问答
//发布问题的id
-(void)publish_question:(NSString *)publishId {
    for(NSString *encryptId in self.keysArrAll) {
        NSMutableArray *arr = [self.QADic objectForKey:encryptId];
        Dialogue *dialogue = [arr objectAtIndex:0];
        if(dialogue.dataType == NS_CONTENT_TYPE_QA_QUESTION && [dialogue.encryptId isEqualToString:publishId]) {
            dialogue.isPublish = YES;
        }
    }
    [self.questionChatView reloadQADic:self.QADic keysArrAll:self.keysArrAll];
}
/**
 *    @brief  收到提问，用户观看时和主讲的互动问答信息
 */
- (void)onQuestionDic:(NSDictionary *)questionDic
{
    
    if ([questionDic count] == 0) return ;
    if (questionDic) {
        Dialogue *dialog = [[Dialogue alloc] init];
        dialog.msg = questionDic[@"value"][@"content"];
        dialog.username = questionDic[@"value"][@"userName"];
        dialog.fromuserid = questionDic[@"value"][@"userId"];
        dialog.myViwerId = _viewerId;
        dialog.time = questionDic[@"time"];
        NSString *encryptId = questionDic[@"value"][@"id"];
        if([encryptId isEqualToString:@"-1"]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            NSString *dateTime = [formatter stringFromDate:[NSDate date]];
            encryptId = [NSString stringWithFormat:@"%@[%@]",encryptId,dateTime];
        }
        dialog.encryptId = encryptId;
        dialog.useravatar = questionDic[@"useravatar"];
        dialog.dataType = NS_CONTENT_TYPE_QA_QUESTION;
        dialog.isPublish = NO;
        NSMutableArray *arr = [self.QADic objectForKey:dialog.encryptId];
        if (arr == nil) {
            arr = [[NSMutableArray alloc] init];
            [self.QADic setObject:arr forKey:dialog.encryptId];
        }
        if(![self.keysArrAll containsObject:dialog.encryptId]) {
            [self.keysArrAll addObject:dialog.encryptId];
        }
        [arr addObject:dialog];
        [self.questionChatView reloadQADic:self.QADic keysArrAll:self.keysArrAll];
    }
}
/**
 *    @brief  收到回答
 */
- (void)onAnswerDic:(NSDictionary *)answerDic
{
    
    if ([answerDic count] == 0) answerDic = nil ;
    
    if (answerDic) {
        Dialogue *dialog = [[Dialogue alloc] init];
        dialog.msg = answerDic[@"value"][@"content"];
        dialog.username = answerDic[@"value"][@"userName"];
        dialog.fromuserid = answerDic[@"value"][@"questionUserId"];
        dialog.myViwerId = _viewerId;
        dialog.time = answerDic[@"time"];
        dialog.encryptId = answerDic[@"value"][@"questionId"];
        dialog.useravatar = answerDic[@"useravatar"];
        dialog.dataType = NS_CONTENT_TYPE_QA_ANSWER;
        dialog.isPrivate = [answerDic[@"value"][@"isPrivate"] boolValue];
        
        NSMutableArray *arr = [self.QADic objectForKey:dialog.encryptId];
        if (arr == nil) {
            arr = [[NSMutableArray alloc] init];
            [self.QADic setObject:arr forKey:dialog.encryptId];
        } else if (dialog.isPrivate == NO && [arr count] > 0) {
            Dialogue *firstDialogue = [arr objectAtIndex:0];
            if(firstDialogue.isPublish == NO && firstDialogue.dataType == NS_CONTENT_TYPE_QA_QUESTION) {
                firstDialogue.isPublish = YES;
            }
        }
        [arr addObject:dialog];
        [self.questionChatView reloadQADic:self.QADic keysArrAll:self.keysArrAll];
    }
}
/**
 *    @brief  收到提问&回答
 */
- (void)onQuestionArr:(NSArray *)questionArr onAnswerArr:(NSArray *)answerArr
{
    
    if ([questionArr count] == 0 && [answerArr count] == 0) {
        return;
    }
    
    [self.QADic removeAllObjects];
    
    for (NSDictionary *dic in questionArr) {
        Dialogue *dialog = [[Dialogue alloc] init];
        dialog.msg = dic[@"content"];
        dialog.username = dic[@"questionUserName"];
        dialog.fromuserid = dic[@"questionUserId"];
        dialog.myViwerId = _viewerId;
        dialog.time = dic[@"time"];
        dialog.encryptId = dic[@"encryptId"];
        dialog.useravatar = dic[@"useravatar"];
        dialog.dataType = NS_CONTENT_TYPE_QA_QUESTION;
        dialog.isPublish = [dic[@"isPublish"] boolValue];
        NSMutableArray *arr = [self.QADic objectForKey:dialog.encryptId];
        if (arr == nil) {
            arr = [[NSMutableArray alloc] init];
            [self.QADic setObject:arr forKey:dialog.encryptId];
        }
        if(![self.keysArrAll containsObject:dialog.encryptId]) {
            [self.keysArrAll addObject:dialog.encryptId];
        }
        
        [arr addObject:dialog];
    }
    
    for (NSDictionary *dic in answerArr) {
        Dialogue *dialog = [[Dialogue alloc] init];
        dialog.msg = dic[@"content"];
        dialog.username = dic[@"answerUserName"];
        dialog.fromuserid = dic[@"answerUserId"];
        dialog.myViwerId = _viewerId;
        dialog.encryptId = dic[@"encryptId"];
        dialog.useravatar = dic[@"useravatar"];
        dialog.dataType = NS_CONTENT_TYPE_QA_ANSWER;
        dialog.isPrivate = [dic[@"isPrivate"] boolValue];
        NSMutableArray *arr = [self.QADic objectForKey:dialog.encryptId];
        if (arr != nil) {
            [arr addObject:dialog];
        }
    }
    
    [self.questionChatView reloadQADic:self.QADic keysArrAll:self.keysArrAll];
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

    NSLog(@"firRoadNum = %d,secRoadKeyArray = %@",(int)firRoadNum,secRoadKeyArray);
}
#pragma mark- 直播未开始和开始
/**
 *    @brief  收到播放直播状态 0直播 1未直播
 */
- (void)getPlayStatue:(NSInteger)status {
    if(status == 1) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
        self.playerView.liveUnStart.hidden = NO;
        self.smallVideoView.hidden = YES;
        self.playerView.changeButton.hidden = YES;
        self.playerView.unStart.text = @"直播未开始";
        _endNormal = YES;
        self.playerView.quanpingButton.hidden = YES;
    } else {
        _endNormal = NO;
    }
}

/**
 *    @brief  主讲开始推流
 */
- (void)onLiveStatusChangeStart {
    _endNormal = NO;
    [_loadingView removeFromSuperview];
    _loadingView = nil;
    self.playerView.liveUnStart.hidden = YES;
    if (_templateType == 4 || _templateType == 5) {
        self.smallVideoView.hidden = NO;
        self.playerView.changeButton.hidden = NO;
    }
    if (_endNormal == NO) {
        _loadingView = [[LoadingView alloc] initWithLabel:@"视频加载中" centerY:YES];
        [self.playerView addSubview:_loadingView];
        [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(50, 0, 0, 0));
        }];
        [_loadingView layoutIfNeeded];
        if (self.screenLandScape == NO) {
            self.playerView.quanpingButton.hidden = NO;
        }
    }
}
/**
 *    @brief  停止直播，endNormal表示是否停止推流
 */
- (void)onLiveStatusChangeEnd:(BOOL)endNormal {
    _endNormal = endNormal;
    self.playerView.liveUnStart.hidden = NO;
    self.smallVideoView.hidden = YES;
    self.playerView.changeButton.hidden = YES;
    self.playerView.unStart.text = @"直播已结束";
    self.playerView.quanpingButton.hidden = YES;

}
#pragma mark- 加载视频失败
/**
 *  @brief  加载视频失败
 */
- (void)play_loadVideoFail {
    _loadingView = [[LoadingView alloc] initWithLabel:@"视频加载中" centerY:YES];
    [self.playerView addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(50, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
}
#pragma mark- 视频或者文档大窗
/**
 *  @brief  视频或者文档大窗(The new method)
 *  isMain 1为视频为主,0为文档为主"
 */
- (void)onSwitchVideoDoc:(BOOL)isMain {
    if (isMain || _templateType == 1 || _templateType == 2|| _templateType == 3||_templateType == 6) {
        self.changeButton.tag = 2;
    } else {
        self.changeButton.tag = 1;
        [self.playerView.changeButton setTitle:@"切换文档" forState:UIControlStateNormal];

    }
    [self changeButtonClick:self.changeButton];

}

-(void)addObserver {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
//
    [[NSNotificationCenter defaultCenter] addObserver:self                  selector:@selector(moviePlayBackStateDidChange:)                                                name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieLoadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieNaturalSizeAvailableNotification:) name:IJKMPMovieNaturalSizeAvailableNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(removeLotteryView:)
//                                                 name:@"remove_lotteryView"
//                                               object:nil];
}
-(void)removeObserver {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IJKMPMovieNaturalSizeAvailableNotification
                                                  object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"remove_lotteryView"
//                                                  object:nil];
}

/**
 视频播放状态

 @param notification 接收到通知
 */
-(void)movieNaturalSizeAvailableNotification:(NSNotification *)notification {
    //    NSLog(@"player.naturalSize = %@",NSStringFromCGSize(_requestData.ijkPlayer.naturalSize));
}

/**
 视频状态改变

 @param notification 接收到通知
 */
- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    IJKMPMoviePlaybackStateStopped,
    //    IJKMPMoviePlaybackStatePlaying,
    //    IJKMPMoviePlaybackStatePaused,
    //    IJKMPMoviePlaybackStateInterrupted,
    //    IJKMPMoviePlaybackStateSeekingForward,
    //    IJKMPMoviePlaybackStateSeekingBackward
    //    NSLog(@"_requestData.ijkPlayer.playbackState = %ld",_requestData.ijkPlayer.playbackState);

    switch (_requestData.ijkPlayer.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            break;
        }
        case IJKMPMoviePlaybackStatePlaying:{
            [_loadingView removeFromSuperview];
            _loadingView = nil;
            [[SaveLogUtil sharedInstance] saveLog:@"" action:@"视频加载成功或开始播放，多次调用，不必关心"];
            
            break;
        }
        case IJKMPMoviePlaybackStatePaused:{
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

/**
 视屏加载状态改变

 @param notification 接收到d通知
 */
-(void)movieLoadStateDidChange:(NSNotification*)notification
{
    switch (_requestData.ijkPlayer.loadState)
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

//切换底部功能 如聊天,问答,简介等
- (void)segmentAction:(UISegmentedControl *)segment
{
    NSInteger index = segment.selectedSegmentIndex;
    int py = _scrollView.contentOffset.y;
    [self.view endEditing:YES];
    CGFloat width0 = [segment widthForSegmentAtIndex:0];
    CGFloat width1 = [segment widthForSegmentAtIndex:1];
    CGFloat width2 = [segment widthForSegmentAtIndex:2];
    CGFloat shadowViewY = segment.frame.origin.y + segment.frame.size.height - 2;
    switch(index){
        case 0: {
            //#ifdef LIANMAI_WEBRTC
//            _isAudioVideo = NO;
            //#endif
            [UIView animateWithDuration:0.25 animations:^{
                self.shadowView.frame = CGRectMake(width0/4, shadowViewY, width0/2, 2);
            }];
        }
            [self.scrollView setContentOffset:CGPointMake(0, py)];
            break;
        case 1: {
//            //#ifdef LIANMAI_WEBRTC
//            _isAudioVideo = NO;
//            //#endif
            [UIView animateWithDuration:0.25 animations:^{
                self.shadowView.frame = CGRectMake(width0+width1/4, shadowViewY, width1/2, 2);
            }];
        }
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, py)];
            [self.questionChatView becomeFirstResponder];
            break;
        case 2: {
//            //#ifdef LIANMAI_WEBRTC
//            _isAudioVideo = NO;
//            //#endif
            [UIView animateWithDuration:0.25 animations:^{
                self.shadowView.frame = CGRectMake(width0 + width1+width2/4, shadowViewY, width2/2, 2);
            }];
        }
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 2, py)];
            break;
        case 3: {
//            //#ifdef LIANMAI_WEBRTC
//            _isAudioVideo = YES;
//            //#endif
//            [UIView animateWithDuration:0.25 animations:^{
//                ws.shadowView.frame = CGRectMake(width0 + width1 + width2, shadowViewY, width3, 4);
//            }];
        }
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 3, py)];
            break;
        default:
            break;
    }

}

//拖拽小屏
- (void) handlePan:(UIPanGestureRecognizer*) recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [recognizer translationInView:APPDelegate.window];
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                                 recognizer.view.center.y + translation.y);
            [recognizer setTranslation:CGPointZero inView:APPDelegate.window];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGRect smallVideoRect = self.smallVideoView.frame;
            
            CGFloat x = smallVideoRect.origin.x < self.view.frame.origin.x ? 0 : smallVideoRect.origin.x;
            
            CGFloat y = smallVideoRect.origin.y < self.view.frame.origin.y ? 0 : smallVideoRect.origin.y;
            
            x = (x + smallVideoRect.size.width) > (self.view.frame.origin.x + self.view.frame.size.width) ? (self.view.frame.origin.x + self.view.frame.size.width - smallVideoRect.size.width) : x;
            
            y = (y + smallVideoRect.size.height) > (self.view.frame.origin.y + self.view.frame.size.height) ? (self.view.frame.origin.y + self.view.frame.size.height - smallVideoRect.size.height) : y;
            
            [UIView animateWithDuration:0.25f animations:^{
                [self.smallVideoView setFrame:CGRectMake(x, y, smallVideoRect.size.width, smallVideoRect.size.height)];
            } completion:^(BOOL finished) {
            }];
        }
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateFailed:
            break;
        default:
            break;
    }
}
//创建聊天问答等功能选择
-(UISegmentedControl *)segment {
    if(!_segment) {
        NSArray *segmentedArray = [[NSArray alloc] initWithObjects:@"聊天",@"问答",@"简介", nil];
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
//创建文档视图
-(UIView *)pptView {
    if(!_pptView) {
        _pptView = [[UIView alloc] init];
        _pptView.backgroundColor = CCRGBColor(250,250,250);
    }
    return _pptView;
}
//创建简介视图
-(CCIntroductionView *)introductionView {
    if(!_introductionView) {
        _introductionView = [[CCIntroductionView alloc] init];
        _introductionView.backgroundColor = CCRGBColor(250,250,250);
    }
    return _introductionView;
}
//创建问答视图
-(CCQuestionView *)questionChatView {
    if(!_questionChatView) {
        _questionChatView = [[CCQuestionView alloc] initWithQuestionBlock:^(NSString *message) {
            [self question:message];
        } input:YES];
        _questionChatView.backgroundColor = [UIColor grayColor];
    }
    return _questionChatView;
}
//问答相关
-(NSMutableArray *)keysArrAll {
    if(_keysArrAll==nil || [_keysArrAll count] == 0) {
        _keysArrAll = [[NSMutableArray alloc]init];
    }
    return _keysArrAll;
}
-(NSMutableDictionary *)QADic {
    if(!_QADic) {
        _QADic = [[NSMutableDictionary alloc] init];
    }
    return _QADic;
}
//创建聊天视图
-(ChatView *)chatView {
    if(!_chatView) {
        _chatView = [[ChatView alloc] initWithPublicChatBlock:^(NSString *msg) {
            // 发送公聊信息
            [self.requestData chatMessage:msg];
            //            NSArray * arr = @[@"唐僧",@"孙悟空",@"猪八戒",@"沙僧"];
            //            int r = arc4random() % [arr count];
            //            [ws.requestData changeNickName:arr[r]];
        } PrivateChatBlock:^(NSString *anteid, NSString *msg) {
            // 发送私聊信息
            [self.requestData privateChatWithTouserid:anteid msg:msg];
        } input:YES];
        _chatView.backgroundColor = CCRGBColor(250,250,250);
    }
    return _chatView;
}
//聊天相关
-(NSMutableDictionary *)userDic {
    if(!_userDic) {
        _userDic = [[NSMutableDictionary alloc] init];
    }
    return _userDic;
}
-(NSDictionary *)dataPrivateDic {
    if(!_dataPrivateDic) {
        _dataPrivateDic = [[NSMutableDictionary alloc] init];
    }
    return _dataPrivateDic;
}
-(NSMutableArray *)publicChatArray {
    if(!_publicChatArray) {
        _publicChatArray = [[NSMutableArray alloc] init];
    }
    return _publicChatArray;
}
//滚动条
-(UIView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[UIView alloc] init];
        _shadowView.backgroundColor = CCRGBColor(255,102,51);
    }
    return _shadowView;
}
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


@end
