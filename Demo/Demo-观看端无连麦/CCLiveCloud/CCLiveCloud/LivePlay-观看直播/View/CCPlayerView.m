//
//  CCPlayerView.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/31.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCPlayerView.h"
#import "Utility.h"
#import "InformationShowView.h"
#import "CCProxy.h"
#import "CCBarrage.h"
@interface CCPlayerView ()<UITextFieldDelegate

>

@property (nonatomic, assign)BOOL                       isSound;//是否是音频
@property (nonatomic, assign)BOOL                       shouldHidden;//键盘弹出隐藏导航
@property (nonatomic, assign)BOOL                       screenLandScape;//屏幕方向
@property (nonatomic, assign)CGRect                     keyboardRect;//表情位置
@property (nonatomic, copy)NSString                     * qingxiTitle;//清晰度tietle
@property (nonatomic, strong)UIView                     * secRoadview;//清晰度
@property (nonatomic, strong)UIView                     * emojiView;
@property (nonatomic, strong)UIView                     * soundview;//清晰度
@property (nonatomic, strong)NSTimer                    * playerTimer;//隐藏导航
@property (nonatomic, strong)NSArray                    * firRoadArr;//线路数组
@property (nonatomic, strong)NSArray                    * secRoadArr;//清晰度数组
@property (nonatomic, strong)UIButton                   * btn;//线路
@property (nonatomic, strong)UIButton                   * qingXiButton;//切换清晰度按钮
@property (nonatomic, strong)UIButton                   * secRoadButton;//选择清晰度
@property (nonatomic, strong)UIButton                   * rightView;//表情
@property (nonatomic, strong)UIButton                   * danMuButton;//弹幕
@property (nonatomic, assign)NSInteger                  firRoadNum;//线路数
@property (nonatomic, strong)UIImageView                * userCountLogo;//人数logo
@property (nonatomic, strong)UITapGestureRecognizer     * TapGesture;//单击手势
@property (nonatomic, strong)UIButton                   * smallCloseBtn;//小窗关闭按钮
@property (nonatomic, assign)BOOL                       isMain;//是否视频为主
@property (nonatomic, assign)BOOL                       isSmallDocView;//是否是文档小窗模式
@property (nonatomic, strong)CCBarrage                  *barrageView;//弹幕
@end

@implementation CCPlayerView

/**
 *  @brief  初始化
 */
- (instancetype)initWithFrame:(CGRect)frame docViewType:(BOOL)isSmallDocView{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        _isSmallDocView = isSmallDocView;
        [self setupUI];
        [self addObserver];
    }
    return self;
}
/**
 *  @brief  隐藏导航,用定时器控制,键盘弹出和隐藏的时候修改self.shouldHidden的值来控制是否隐藏
 */
- (void)LatencyHiding {

    if (self.bottomShadowView.hidden == NO && self.shouldHidden == NO) {
            self.bottomShadowView.hidden = YES;
            self.topShadowView.hidden = YES;
        }
}
/**
 *  @brief  隐藏导航,点击手势
 */
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
        [self.chatTextField resignFirstResponder];
    }
}

/**
 *  @brief  隐藏线路选择
 */
- (void)doTapChange1:(UITapGestureRecognizer*) recognizer {
    self.selectedIndexView.hidden = YES;
    self.qingXiButton.userInteractionEnabled = YES;
    [self endEditing:NO];
}

/**
 *  @brief  创建UI
 */
- (void)setupUI {
    _endNormal = YES;
    //上面阴影
    self.topShadowView =[[UIView alloc] init];
    UIImageView *topShadow = [[UIImageView alloc] init];
    topShadow.image = [UIImage imageNamed:@"playerBar_against"];
    [self addSubview:self.topShadowView];
    [self.topShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(CCGetRealFromPt(88));
    }];
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
    //点击事件
    [self.backButton addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    //房间标题
    UILabel * titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:FontSize_30];
    [self.topShadowView addSubview:titleLabel];

    //切换
    self.changeButton = [[UIButton alloc] init];
    self.changeButton.titleLabel.textColor = [UIColor whiteColor];
    self.changeButton.titleLabel.font = [UIFont systemFontOfSize:FontSize_30];
    self.changeButton.tag = 1;
    [self.changeButton setTitle:PLAY_CHANGEVIDEO forState:UIControlStateNormal];
    [self.topShadowView addSubview:_changeButton];
    [self.changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topShadowView).offset(CCGetRealFromPt(-20));
        make.centerY.equalTo(self.backButton);
        make.height.mas_equalTo(CCGetRealFromPt(50));
        make.width.mas_equalTo(CCGetRealFromPt(180));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.left.equalTo(self.backButton.mas_right);
        make.width.mas_equalTo(SCREEN_WIDTH - CCGetRealFromPt(250));
    }];
    //new method    点击事件
    [self.changeButton addTarget:self action:@selector(changeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //清晰度
    self.qingXiButton = [[UIButton alloc] init];
    self.qingXiButton.titleLabel.textColor = [UIColor whiteColor];
    self.qingXiButton.titleLabel.font = [UIFont systemFontOfSize:FontSize_30];
    self.qingXiButton.tag = 1;
    [self.qingXiButton setTitle:@"原画" forState:UIControlStateNormal];
    [self.topShadowView addSubview:_qingXiButton];
    [self.qingXiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.changeButton.mas_left).offset(CCGetRealFromPt(-100));
        make.centerY.equalTo(self.backButton);
        make.height.mas_equalTo(CCGetRealFromPt(30));
        make.width.mas_equalTo(CCGetRealFromPt(140));
    }];
    self.qingXiButton.backgroundColor = [UIColor redColor];
    self.qingXiButton.hidden = YES;
    self.qingXiButton.userInteractionEnabled = YES;
    [self.qingXiButton addTarget:self action:@selector(qingXiButtonClick) forControlEvents:UIControlEventTouchUpInside];

    //下面阴影
    self.bottomShadowView =[[UIView alloc] init];
    UIImageView *bottomShadow = [[UIImageView alloc] init];
    bottomShadow.image = [UIImage imageNamed:@"playerBar"];
    [self addSubview:self.bottomShadowView];
    [self.bottomShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(CCGetRealFromPt(60));
    }];
    [self.bottomShadowView addSubview:bottomShadow];
    [bottomShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bottomShadowView);
    }];
    //在线人数
    UIImageView * userCountLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_dis_people"]];
    _userCountLogo = userCountLogo;
    userCountLogo.contentMode = UIViewContentModeScaleAspectFit;
    [self.bottomShadowView addSubview:userCountLogo];
    [userCountLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backButton);
        make.centerY.equalTo(self.bottomShadowView);
        make.width.height.mas_equalTo(CCGetRealFromPt(24));
    }];
    //在线人数
    UILabel * userCountLabel = [[UILabel alloc] init];
    _userCountLabel = userCountLabel;
    userCountLabel.textColor = [UIColor whiteColor];
    userCountLabel.font = [UIFont systemFontOfSize:FontSize_24];
    [self.bottomShadowView addSubview:userCountLabel];
    [userCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(userCountLogo);
        make.left.equalTo(userCountLogo.mas_right).offset(CCGetRealFromPt(10));
    }];

    //全屏按钮
    self.quanpingButton = [[UIButton alloc] init];
    [self.quanpingButton setBackgroundImage:[UIImage imageNamed:@"quanping"] forState:UIControlStateNormal];
    [self.bottomShadowView addSubview:_quanpingButton];
    [self.quanpingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomShadowView);
        make.right.equalTo(self.bottomShadowView).offset(CCGetRealFromPt(-20));
        make.width.height.mas_equalTo(CCGetRealFromPt(60));
    }];
    //  btn点击事件
    [self.quanpingButton addTarget:self action:@selector(quanpingBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    //音频模式视图
    self.soundview =[[UIView alloc] init];
    [self addSubview:_soundview];
    [self.soundview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.soundview.hidden = YES;
    self.soundview.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:1.0f];
    //音频背景图片
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"audio_mode"];
    [_soundview addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.soundview);
        make.width.mas_equalTo(CCGetRealFromPt(746));
        make.height.mas_equalTo(CCGetRealFromPt(220));
    }];
    //音频模式
    UILabel * soundLabel = [[UILabel alloc] init];
    soundLabel.textColor = [UIColor whiteColor];
    soundLabel.text = PLAY_SOUND;
    soundLabel.alpha = 0.5f;
    soundLabel.font = [UIFont systemFontOfSize:FontSize_32];
    [self.soundview addSubview:soundLabel];
    [soundLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(imageView);
        make.top.equalTo(imageView.mas_bottom).offset(CCGetRealFromPt(50));
    }];

    //选择线路
    self.selectedIndexView =[[UIView alloc] init];
    self.selectedIndexView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.8f];
    [self addSubview:_selectedIndexView];
    [self.selectedIndexView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    UITapGestureRecognizer *TapGesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTapChange1:)];
    TapGesture1.numberOfTapsRequired = 1;
    [self.selectedIndexView addGestureRecognizer:TapGesture1];
    self.selectedIndexView.hidden = YES;

    //横屏聊天
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = CCRGBAColor(171,179,189,0.30);
    [self.bottomShadowView addSubview:_contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottomShadowView);
        make.height.mas_equalTo(CCGetRealFromPt(100));
        make.left.equalTo(self.bottomShadowView);
        make.right.equalTo(self.bottomShadowView);
    }];
    _contentView.hidden = YES;
    _contentView.alpha = 0.5;

    //弹幕按钮
    _danMuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_danMuButton setBackgroundImage:[UIImage imageNamed:@"barrage_fullscreen"] forState:UIControlStateNormal];
//    [_danMuButton setBackgroundImage:[UIImage imageNamed:@"video_btn_word_on"] forState:UIControlStateSelected];
    [_danMuButton addTarget:self action:@selector(hideDanMuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    [_danMuButton setSelected:YES];
    _danMuButton.tag = 0;
    [self.contentView addSubview:_danMuButton];
    [_danMuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(CCGetRealFromPt(20));
        make.width.mas_equalTo(CCGetRealFromPt(60));
    }];

    //表情按钮
    _rightView = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightView.frame = CGRectMake(0, 0, CCGetRealFromPt(48), CCGetRealFromPt(48));
    _rightView.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _rightView.backgroundColor = CCClearColor;
    [_rightView setImage:[UIImage imageNamed:@"face_nov"] forState:UIControlStateNormal];
    [_rightView setImage:[UIImage imageNamed:@"face_hov"] forState:UIControlStateSelected];
    [_rightView addTarget:self action:@selector(faceBoardClick) forControlEvents:UIControlEventTouchUpInside];

    //输入框
    _chatTextField = [[CustomTextField alloc] init];
    _chatTextField.delegate = self;
    _chatTextField.layer.cornerRadius = CCGetRealFromPt(45);
    [_chatTextField addTarget:self action:@selector(chatTextFieldChange) forControlEvents:UIControlEventEditingChanged];
    _chatTextField.rightView = self.rightView;
    [self.contentView addSubview:_chatTextField];
    [self.chatTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.danMuButton.mas_right).offset(CCGetRealFromPt(22));
        make.right.equalTo(self.contentView).offset(-CCGetRealFromPt(22));
        make.height.mas_equalTo(CCGetRealFromPt(90));
    }];

    //直播未开始
    self.liveUnStart = [[UIImageView alloc] init];
    self.liveUnStart.image = [UIImage imageNamed:@"live_streaming_unstart_bg"];
    [self addSubview:self.liveUnStart];
    self.liveUnStart.frame = CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462));
    self.liveUnStart.hidden = YES;
    //直播未开始图片
    UIImageView * alarmClock = [[UIImageView alloc] init];
    alarmClock.image = [UIImage imageNamed:@"live_streaming_unstart"];
    [self.liveUnStart addSubview:alarmClock];
    [alarmClock mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.liveUnStart);
        make.height.width.mas_equalTo(CCGetRealFromPt(64));
        make.centerY.equalTo(self.liveUnStart.mas_centerY).offset(-10);
    }];

    self.unStart = [[UILabel alloc] init];
    self.unStart.textColor = [UIColor whiteColor];
    self.unStart.alpha = 0.6f;
    self.unStart.textAlignment = NSTextAlignmentCenter;
    self.unStart.font = [UIFont systemFontOfSize:FontSize_30];
    self.unStart.text = PLAY_UNSTART;
    [self.liveUnStart addSubview:self.unStart];
    self.unStart.frame = CGRectMake(SCREEN_WIDTH/2-50, CCGetRealFromPt(271), 100, 30);
//单击手势
    _TapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTapChange:)];
    _TapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:_TapGesture];
//隐藏导航
    [self stopPlayerTimer];
    CCProxy *weakObject = [CCProxy proxyWithWeakObject:self];
    self.playerTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:weakObject selector:@selector(LatencyHiding) userInfo:nil repeats:YES];
    
    //   视频小窗
    [self setSmallVideoView];
    _loadingView = [[LoadingView alloc] initWithLabel:PLAY_LOADING centerY:YES];
    [self addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];

    //初始化弹幕
    self.barrageView = [[CCBarrage alloc] initWithVideoView:self barrageStyle:NomalBarrageStyle];
}


/**
 横竖屏切换

 @param screenLandScape 横竖屏
 */
- (void)layouUI:(BOOL)screenLandScape {
    _screenLandScape = screenLandScape;
    if (screenLandScape == YES) {
        /*  实现横屏状态下切换线路功能，将self.qingXiButton.hidden 设置为NO */
        self.qingXiButton.hidden = YES;
        self.quanpingButton.hidden = YES;
        self.contentView.hidden = NO;
        [self.bottomShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(IS_IPHONE_X ? 44:0);
            make.height.mas_equalTo(CCGetRealFromPt(128));
            make.right.equalTo(self).offset(IS_IPHONE_X? (-44):0);
        }];
        [self.userCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.changeButton.mas_left).offset(-10);
            make.centerY.equalTo(self.qingXiButton);
        }];
        [self.userCountLabel layoutIfNeeded];
        [self.userCountLogo mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.backButton);
            make.right.equalTo(self.userCountLabel.mas_left).offset(-5);
        }];
        [self.userCountLogo layoutIfNeeded];
        [self.barrageView barrageOpen];
        [self.topShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(CCGetRealFromPt(128));
            make.left.equalTo(self).offset(IS_IPHONE_X ? 44:0);
            make.right.equalTo(self).offset(IS_IPHONE_X? (-44):0);
        }];
        [self layoutIfNeeded];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.backButton);
            make.left.equalTo(self.backButton.mas_right);
            make.right.equalTo(self.changeButton.mas_left).offset(-60);
        }];
        [self.titleLabel layoutIfNeeded];
        self.liveUnStart.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT);
        self.unStart.frame = CGRectMake(SCREEN_WIDTH/2-50, CCGetRealFromPt(380), 100, 30);

    } else {
        self.qingXiButton.hidden = YES;
        self.quanpingButton.hidden = NO;
        [self.bottomShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(CCGetRealFromPt(60));
            make.left.right.equalTo(self);
        }];
        [self.userCountLogo mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backButton);
            make.centerY.equalTo(self.bottomShadowView);
            make.width.height.mas_equalTo(CCGetRealFromPt(24));
        }];
        [self.userCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.userCountLogo);
            make.left.equalTo(self.userCountLogo.mas_right).offset(CCGetRealFromPt(10));
        }];
        /*  关闭弹幕  */
        [self.barrageView barrageClose];
        [self.topShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(CCGetRealFromPt(88));
            make.left.right.equalTo(self);
        }];
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.backButton);
            make.left.equalTo(self.backButton.mas_right);
            make.right.equalTo(self.changeButton.mas_left).offset(-5);
        }];
        [self.titleLabel layoutIfNeeded];
        self.liveUnStart.frame = CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462));
        self.unStart.frame = CGRectMake(SCREEN_WIDTH/2-50, CCGetRealFromPt(271), 100, 30);
    }
    
}

/**
 线路选择视图

 @param firRoadNum 线路
 @param secRoadKeyArray 清晰度
 */
- (void)SelectLinesWithFirRoad:(NSInteger)firRoadNum secRoadKeyArray:(NSArray *)secRoadKeyArray {
//
//    if (firRoadNum >3) {
//        firRoadNum = 3;
//    }
    /*
     ps:此处注释的代码为线路切换功能,默认隐藏了切换清晰度的btn(self.qingXiButton),如果想要打开线路切换功能，解开这个方法的注释,并且在- (void)layouUI:(BOOL)screenLandScape;方法中,将_qingXiButton.hidden = NO;
        默认只有横屏状态下显示清晰度切换按钮.
     */
//    self.firRoadNum = firRoadNum;
//    self.secRoadArr = secRoadKeyArray;
//    switch (firRoadNum) {
//        case 1:
//            _firRoadArr = @[@"主线路",@"仅听音频"];
//            break;
//        case 2:
//            _firRoadArr = @[@"主线路",@"备用线路1",@"仅听音频"];
//            break;
//        case 3:
//            _firRoadArr = @[@"主线路",@"备用线路1",@"备用线路2",@"仅听音频"];
//            break;
//
//        default:
//            break;
//    }
//    //线路
//    UILabel * lineLabel = [[UILabel alloc] init];
//    lineLabel.text = @"线路:";
//    lineLabel.textColor = [UIColor colorWithHexString:@"#ffffff" alpha:0.69f];
//    lineLabel.font = [UIFont systemFontOfSize:FontSize_30];
//    [self.selectedIndexView addSubview:lineLabel];
//    [lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.selectedIndexView).offset(IS_IPHONE_X?CCGetRealFromPt(242*1.5):CCGetRealFromPt(242));
//        make.top.equalTo(self.selectedIndexView).offset(CCGetRealFromPt(290));
//    }];
//    //清晰度
//    UILabel * clarityLabel = [[UILabel alloc] init];
//    clarityLabel.text = @"清晰度:";
//    clarityLabel.textColor = [UIColor colorWithHexString:@"#ffffff" alpha:0.69f];
//    clarityLabel.font = [UIFont systemFontOfSize:FontSize_30];
//    [self.selectedIndexView addSubview:clarityLabel];
//    [clarityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(lineLabel);
//        make.top.equalTo(lineLabel.mas_bottom).offset(CCGetRealFromPt(89));
//    }];
//
//    for (int i = 0; i<= firRoadNum; i++) {
//        UIButton * btn = [[UIButton alloc] init];
//        [btn setTitle:_firRoadArr[i] forState:UIControlStateNormal];
//        btn.titleLabel.textColor = [UIColor whiteColor];
//        btn.titleLabel.font = [UIFont systemFontOfSize:FontSize_30];
//        btn.tag = i+1;
//        [self.selectedIndexView addSubview:btn];
//        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(lineLabel.mas_right).offset(40+140*i);
//            make.centerY.equalTo(lineLabel);
//            make.width.mas_equalTo(CCGetRealFromPt(174));
//            make.height.mas_equalTo(CCGetRealFromPt(50));
//        }];
//        btn.layer.borderColor = [UIColor colorWithHexString:@"#f89e0f" alpha:1.0f].CGColor;
//        btn.layer.cornerRadius = CCGetRealFromPt(25);
//        [btn layoutIfNeeded];
//        if (btn.tag == 1) {
//            _btn = btn;
//            btn.layer.borderWidth = 1.0f;
//            [btn setTitleColor:[UIColor colorWithHexString:@"#f89e0f" alpha:1.0f] forState:UIControlStateNormal];
//        }
//        [btn addTarget:self action:@selector(firRoadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    UIView *secRoadview = [[UIView alloc] init];
//    _secRoadview = secRoadview;
//    secRoadview.backgroundColor = [UIColor clearColor];
//    [self.selectedIndexView addSubview:secRoadview];
//    [secRoadview mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(clarityLabel.mas_right);
//        make.right.equalTo(self.selectedIndexView);
//        make.height.mas_equalTo(CCGetRealFromPt(51));
//        make.centerY.equalTo(clarityLabel);
//    }];
//    for (int i = 0; i < secRoadKeyArray.count; i++) {
//        UIButton * btn = [[UIButton alloc] init];
//        [btn setTitle:secRoadKeyArray[i] forState:UIControlStateNormal];
//        btn.titleLabel.textColor = [UIColor whiteColor];
//        btn.titleLabel.font = [UIFont systemFontOfSize:FontSize_30];
//        btn.tag = i+1;
//        [secRoadview addSubview:btn];
//        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(secRoadview).offset(40+140*i);
//            make.centerY.equalTo(secRoadview);
//            make.width.mas_equalTo(CCGetRealFromPt(174));
//            make.height.mas_equalTo(CCGetRealFromPt(50));
//        }];
//        btn.layer.borderColor = [UIColor colorWithHexString:@"#f89e0f" alpha:1.0f].CGColor;
//        btn.layer.cornerRadius = CCGetRealFromPt(25);
//        [btn layoutIfNeeded];
//        if (btn.tag == 1) {
//            _secRoadButton = btn;
//            btn.layer.borderWidth = 1.0f;
//            self.qingxiTitle = secRoadKeyArray[0];
//            [btn setTitleColor:[UIColor colorWithHexString:@"#f89e0f" alpha:1.0f] forState:UIControlStateNormal];
//        }
//        [btn addTarget:self action:@selector(secRoadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
    
}
#pragma mark - 切换线路相关
/**
 点击清晰度
 */
- (void)qingXiButtonClick {
    [self bringSubviewToFront:self.selectedIndexView];
    self.selectedIndexView.hidden = NO;
    _TapGesture = nil;
    [self.selectedIndexView becomeFirstResponder];
    self.qingXiButton.userInteractionEnabled = NO;
}

/**
 线路选择

 @param sender 点击的按钮
 */
- (void)firRoadBtnClick:(UIButton *)sender {
    self.selectedIndexView.hidden = YES;
    self.qingXiButton.userInteractionEnabled = YES;
    [sender setTitleColor:[UIColor colorWithHexString:@"#f89e0f" alpha:1.0f] forState:UIControlStateNormal];
    sender.layer.borderWidth = 1.0f;
    _btn.layer.borderWidth = 0;
    [_btn setTitleColor:[UIColor colorWithHexString:@"#ffffff" alpha:1.0f] forState:UIControlStateNormal];
    self.soundview.hidden = YES;
    if (sender.tag == _btn.tag) {
        return;
    }
    sender.layer.borderWidth = 1.0f;
    _btn = sender;
    if (self.isSound) {
        self.secRoadview.hidden = NO;
        [self.qingXiButton setTitle:self.qingxiTitle forState:UIControlStateNormal];
        self.isSound = NO;
    }
    if (sender.tag > self.firRoadNum) {
        [self.qingXiButton setTitle:PLAY_ONLYSOUND forState:UIControlStateNormal];
        self.secRoadview.hidden = YES;
        self.isSound = YES;
        self.soundview.hidden = NO;
    }
    self.selectedRod(sender.tag);

}

/**
 选择的清晰度

 @param sender 点击的按钮
 */
- (void)secRoadBtnClick:(UIButton *)sender {
    self.selectedIndexView.hidden = YES;
    self.qingXiButton.userInteractionEnabled = YES;
    _secRoadButton.layer.borderWidth = 0;
    [_secRoadButton setTitleColor:[UIColor colorWithHexString:@"#ffffff" alpha:1.0f] forState:UIControlStateNormal];
    [sender setTitleColor:[UIColor colorWithHexString:@"#f89e0f" alpha:1.0f] forState:UIControlStateNormal];
    sender.layer.borderWidth = 1.0f;
    if (sender.tag == _secRoadButton.tag) {
        return;
    }
    [self.qingXiButton setTitle:_secRoadArr[sender.tag - 1] forState:UIControlStateNormal];
    self.qingxiTitle = _secRoadArr[sender.tag - 1];
    _secRoadButton = sender;
    self.selectedIndex(_btn.tag,sender.tag-1);
}
#pragma mark - 点击表情按钮
/**
 表情按钮点击事件
 */
- (void)faceBoardClick {
    BOOL selected = !_rightView.selected;
    _rightView.selected = selected;
    
    if(selected) {
        [_chatTextField setInputView:self.emojiView];
    } else {
        [_chatTextField setInputView:nil];
    }
    
    [_chatTextField becomeFirstResponder];
    [_chatTextField reloadInputViews];
}

#pragma mark - 新增的共有点击事件方法
//点击全屏按钮
-(void)quanpingBtnClick{
    //全屏按钮代理
    [self.delegate quanpingButtonClick:_changeButton.tag];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    self.backButton.tag = 2;
    [UIApplication sharedApplication].statusBarHidden = YES;
    UIView *view = [self superview];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(view);
        make.height.mas_equalTo(SCREENH_HEIGHT);
    }];
    [self layoutIfNeeded];//
   
    
    //隐藏其他视图
    [self layouUI:YES];
    //smallVideoView
    if (_isSmallDocView) {
        [self.smallVideoView setFrame:CGRectMake(frame.size.width -CCGetRealFromPt(220), CCGetRealFromPt(332), CCGetRealFromPt(200), CCGetRealFromPt(150))];
    }

}
/**
//结束直播和退出全屏

@param sender 点击按钮
*/
-(void)backBtnClick:(UIButton *)sender{
    [self endEditing:YES];
    //返回按钮代理
    [self.delegate backButtonClick:sender changeBtnTag:_changeButton.tag];
    if (sender.tag == 2) {
        sender.tag = 1;
        [UIApplication sharedApplication].statusBarHidden = NO;
        self.selectedIndexView.hidden = YES;
//        [self endEditing:NO];
        self.contentView.hidden = YES;
        UIView *view = [self superview];
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(view);
            make.height.mas_equalTo(CCGetRealFromPt(462));
            make.top.equalTo(view).offset(SCREEN_STATUS);
        }];
        [self layoutIfNeeded];
        
        CGRect rect = [UIScreen mainScreen].bounds;
        if (_isSmallDocView) {
            [self.smallVideoView setFrame:CGRectMake(rect.size.width -CCGetRealFromPt(220), CCGetRealFromPt(462)+CCGetRealFromPt(82)+(IS_IPHONE_X? 44:20), CCGetRealFromPt(200), CCGetRealFromPt(150))];
        }
        [self layouUI:NO];

    }
}
/**
 切换视频和文档
 
 @param sender 切换
 */
-(void)changeBtnClick:(UIButton *)sender{
    [self endEditing:YES];
    if (_smallVideoView.hidden && !_changeButton.hidden && _isSmallDocView) {
        NSString *title = _changeButton.tag == 1 ? PLAY_CHANGEDOC : PLAY_CHANGEVIDEO;
        [_changeButton setTitle:title forState:UIControlStateNormal];
        _smallVideoView.hidden = NO;
        return;
    }
    if (sender.tag == 1) {//切换文档大屏
        sender.tag = 2;
        [sender setTitle:PLAY_CHANGEVIDEO forState:UIControlStateNormal];
        //切换视频时remote的视图大小

    } else {//切换文档小屏
        sender.tag = 1;
        [sender setTitle:PLAY_CHANGEDOC forState:UIControlStateNormal];

    }
    if (self.delegate) {//changeBtn按钮点击代理
        [self.delegate changeBtnClicked:sender.tag];
    }
    [self bringSubviewToFront:self.topShadowView];
    [self bringSubviewToFront:self.bottomShadowView];
}

#pragma mark - 懒加载
/**
 表情视图

 @return 懒加载表情视图
 */
-(UIView *)emojiView {
    if(!_emojiView) {
        if(_keyboardRect.size.width == 0 || _keyboardRect.size.height ==0) {
            _keyboardRect = CGRectMake(0, 0, 736, 194);
        }
        
        _emojiView = [[UIView alloc] initWithFrame:_keyboardRect];
        _emojiView.backgroundColor = CCRGBColor(242,239,237);
        
        CGFloat faceIconSize = CCGetRealFromPt(60);
        CGFloat xspace = (_keyboardRect.size.width - FACE_COUNT_CLU * faceIconSize) / (FACE_COUNT_CLU + 1);
        CGFloat yspace = (_keyboardRect.size.height - 26 - FACE_COUNT_ROW * faceIconSize) / (FACE_COUNT_ROW + 1);
        
        for (int i = 0; i < FACE_COUNT_ALL; i++) {
            UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            faceButton.tag = i + 1;
            
            [faceButton addTarget:self action:@selector(faceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            //            计算每一个表情按钮的坐标和在哪一屏
            CGFloat x = (i % FACE_COUNT_CLU + 1) * xspace + (i % FACE_COUNT_CLU) * faceIconSize;
            CGFloat y = (i / FACE_COUNT_CLU + 1) * yspace + (i / FACE_COUNT_CLU) * faceIconSize;
            
            faceButton.frame = CGRectMake(x, y, faceIconSize, faceIconSize);
            faceButton.backgroundColor = CCClearColor;
            [faceButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%02d", i+1]]
                        forState:UIControlStateNormal];
            faceButton.contentMode = UIViewContentModeScaleAspectFit;
            [_emojiView addSubview:faceButton];
        }
        //删除键
        UIButton *button14 = (UIButton *)[_emojiView viewWithTag:14];
        UIButton *button20 = (UIButton *)[_emojiView viewWithTag:20];
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        back.contentMode = UIViewContentModeScaleAspectFit;
        [back setImage:[UIImage imageNamed:@"chat_btn_facedel"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
        [_emojiView addSubview:back];
        
        [back mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(button14);
            make.centerY.mas_equalTo(button20);
        }];
    }
    return _emojiView;
}

/**
 选择表情

 @param sender 点解表情
 */
- (void)faceButtonClicked:(id)sender {
    [self.chatTextField becomeFirstResponder];
    NSInteger i = ((UIButton*)sender).tag;
    NSMutableString *faceString = [[NSMutableString alloc]initWithString:_chatTextField.text];
    [faceString appendString:[NSString stringWithFormat:@"[em2_%02d]",(int)i]];
    _chatTextField.text = faceString;
    [self chatTextFieldChange];
}

/**
 删除表情
 */
- (void)backFace {
    NSString *inputString = _chatTextField.text;
    if ( [inputString length] > 0) {
        NSString *string = nil;
        NSInteger stringLength = [inputString length];
        if (stringLength >= FACE_NAME_LEN) {
            string = [inputString substringFromIndex:stringLength - FACE_NAME_LEN];
            NSRange range = [string rangeOfString:FACE_NAME_HEAD];
            if ( range.location == 0 ) {
                string = [inputString substringToIndex:[inputString rangeOfString:FACE_NAME_HEAD options:NSBackwardsSearch].location];
            } else {
                string = [inputString substringToIndex:stringLength - 1];
            }
        }
        else {
            string = [inputString substringToIndex:stringLength - 1];
        }
        _chatTextField.text = string;
    }
}

/**
 输入文字
 */
-(void)chatTextFieldChange {
    if(_chatTextField.text.length > 300) {
        //        [self.view endEditing:YES];
        _chatTextField.text = [_chatTextField.text substringToIndex:300];
        [_informationViewPop removeFromSuperview];
        _informationViewPop = [[InformationShowView alloc] initWithLabel:ALERT_INPUTLIMITATION];
        [APPDelegate.window addSubview:_informationViewPop];
        [_informationViewPop mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];

        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationViewPop) userInfo:nil repeats:NO];
    }
}

/**
 移除加载
 */
-(void)removeInformationViewPop {
    [_informationViewPop removeFromSuperview];
//    _informationViewPop = nil;
}

/**
 弹幕开关
 */
-(void)hideDanMuBtnClicked {
    if (_danMuButton.tag == 0) {//开启半屏模式
        [_danMuButton setImage:[UIImage imageNamed:@"barrage_top"] forState:UIControlStateNormal];
        _danMuButton.tag = 1;
        [_barrageView changeRenderViewStyle:RenderViewTop];
    }else if (_danMuButton.tag == 1){//关闭弹幕
        [_danMuButton setImage:[UIImage imageNamed:@"barrage_close"] forState:UIControlStateNormal];
        _danMuButton.tag = 2;
        [self.barrageView barrageClose];
    }else if (_danMuButton.tag == 2){//开启全屏弹幕
        [_danMuButton setImage:[UIImage imageNamed:@"barrage_fullscreen"] forState:UIControlStateNormal];
        _danMuButton.tag = 0;
        [self.barrageView barrageOpen];
        [self.barrageView changeRenderViewStyle:RenderViewFullScreen];
    }
}

/**
 发送聊天
 */
-(void)sendBtnClicked {
    if(!StrNotEmpty([_chatTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]])) {
        [_informationViewPop removeFromSuperview];
        _informationViewPop = [[InformationShowView alloc] initWithLabel:ALERT_EMPTYMESSAGE];
        [APPDelegate.window addSubview:_informationViewPop];
        [_informationViewPop mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(APPDelegate.window);
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(50);
        }];

        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationViewPop) userInfo:nil repeats:NO];
        return;
    }
    [self chatSendMessage];
}

/**
 横屏发送聊天
 */
-(void)chatSendMessage {
    NSString *str = _chatTextField.text;
    if(str == nil || str.length == 0) {
        return;
    }
    // 发送公聊信息
    self.sendChatMessage(str);
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
}

/**
 弹幕

 @param model 弹幕数据模型
 */
- (void)insertDanmuModel:(CCPublicChatModel *)model {
    [self.barrageView insertBarrageMessage:model];
}

#pragma mark keyboard notification
- (void)keyboardWillShow:(NSNotification *)notif {
    if(![self.chatTextField isFirstResponder]) {
        return;
    }
    self.shouldHidden = YES;
    [self.chatTextField becomeFirstResponder];
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardRect = [aValue CGRectValue];
    CGFloat y = _keyboardRect.size.height;
    if ([self.chatTextField isFirstResponder]) {
        [self.bottomShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(CCGetRealFromPt(128));
            make.left.equalTo(self.bottomShadowView).offset(IS_IPHONE_X?40:0);
            make.right.equalTo(self.bottomShadowView);
            make.bottom.mas_equalTo(self).offset(-y);
        }];
        
        [UIView animateWithDuration:0.25f animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    self.shouldHidden = NO;
    [self.bottomShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(self.screenLandScape?CCGetRealFromPt(128):CCGetRealFromPt(60));
        make.left.equalTo(self.bottomShadowView).offset(IS_IPHONE_X?40:0);
        make.right.equalTo(self.bottomShadowView);
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendBtnClicked];
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
    return YES;
}

-(void)dealloc {

    [self removeObserver];
    [self stopPlayerTimer];
}
-(void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


/**
 关闭播放计时器
 */
-(void)stopPlayerTimer {
    if([self.playerTimer isValid]) {
        [self.playerTimer invalidate];
        self.playerTimer = nil;
    }
}


#pragma mark - 小窗视图

/**
 设置小窗视图
 */
-(void)setSmallVideoView{
    if (_isSmallDocView) {
        _smallVideoView = [[CCDocView alloc] initWithType:_isSmallDocView];
        __weak typeof(self)weakSelf = self;
        _smallVideoView.hiddenSmallVideoBlock = ^{
            [weakSelf hiddenSmallVideoview];
        };
        [APPDelegate.window addSubview:_smallVideoView];
    }
}
-(void)hiddenSmallVideoview{
    _smallVideoView.hidden = YES;
    NSString *title = _changeButton.tag == 1 ? PLAY_SHOWDOC : PLAY_SHOWVIDEO;
    [_changeButton setTitle:title forState:UIControlStateNormal];
}
#pragma mark - 直播状态相关代理
/**
 *    @brief  收到播放直播状态 0直播 1未直播
 */
- (void)getPlayStatue:(NSInteger)status{
    if(status == 1) {
        self.liveUnStart.hidden = NO;
        self.smallVideoView.hidden = YES;
        self.changeButton.hidden = YES;
        self.unStart.text = PLAY_UNSTART;
        _endNormal = YES;
        self.quanpingButton.hidden = YES;
    } else {
        _endNormal = NO;
        [self switchVideoDoc:_isMain];
    }
    [_loadingView removeFromSuperview];
//    _loadingView = nil;
}
/**
 *    @brief  主讲开始推流
 */
- (void)onLiveStatusChangeStart{
    _endNormal = NO;
    [_loadingView removeFromSuperview];
//    _loadingView = nil;
    self.liveUnStart.hidden = YES;
    if ((_templateType == 4 || _templateType == 5) && _isSmallDocView) {
        self.smallVideoView.hidden = NO;
        self.changeButton.hidden = NO;
    }
    if (_endNormal == NO) {
        _loadingView = [[LoadingView alloc] initWithLabel:PLAY_LOADING centerY:YES];
        [self addSubview:_loadingView];
        [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(50, 0, 0, 0));
        }];
//        [_loadingView layoutIfNeeded];
        if (self.screenLandScape == NO) {
            self.quanpingButton.hidden = NO;
        }
    }
}
/**
 *    @brief  停止直播，endNormal表示是否停止推流
 */
- (void)onLiveStatusChangeEnd:(BOOL)endNormal{
    _endNormal = endNormal;
    self.liveUnStart.hidden = NO;
    self.smallVideoView.hidden = YES;
    self.changeButton.hidden = YES;
    self.unStart.text = PLAY_OVER;
    self.quanpingButton.hidden = YES;
    [self bringSubviewToFront:_liveUnStart];
    [_loadingView removeFromSuperview];
//    _loadingView = nil;
}
/**
 *  @brief  加载视频失败
 */
- (void)play_loadVideoFail{
    [_loadingView removeFromSuperview];
//    _loadingView = nil;
    _loadingView = [[LoadingView alloc] initWithLabel:PLAY_LOADING centerY:YES];
    [self addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(50, 0, 0, 0));
    }];
//    [_loadingView layoutIfNeeded];
}
#pragma mark- 视频或者文档大窗
/**
 *  @brief  视频或者文档大窗(The new method)
 *  isMain 1为视频为主,0为文档为主"
 */
- (void)onSwitchVideoDoc:(BOOL)isMain{
    _isMain = isMain;
    [self switchVideoDoc:_isMain];
    if (_endNormal) {
        _smallVideoView.hidden = YES;
    }else{
        _smallVideoView.hidden = NO;
    }
}
#pragma mark - 初始化直播间状态（私有调用方法)
//当第一次进入和收到直播状态的时候需要调用此方法
//todo 关闭连麦时会走这个方法，导致崩溃。
-(void)switchVideoDoc:(BOOL)isMain{
    if (!_isSmallDocView) {
        return;
    }
    /* 当房间类型不支持文档时，隐藏changeButton */
    if (_templateType == 1 || _templateType == 2|| _templateType == 3||_templateType == 6) {
        _changeButton.hidden = YES;
        return;
    }
    /* 根据视频或者文档大窗参数布局视频和文档 */
//    _changeButton.hidden = NO;
    if (isMain) {//视频为主
        self.changeButton.tag = 2;
    } else {//文档为主
        self.changeButton.tag = 1;
        [self.changeButton setTitle:PLAY_CHANGEDOC forState:UIControlStateNormal];
    }
    [self changeBtnClick:self.changeButton];
}

@end
