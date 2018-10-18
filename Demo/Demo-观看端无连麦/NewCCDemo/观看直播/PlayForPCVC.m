//
//  PlayForPCVC.m
//  NewCCDemo
//
//  Created by cc on 2016/12/27.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "PlayForPCVC.h"
#import "CustomTextField.h"
#import "CCPublicTableViewCell.h"
#import "CCPrivateChatView.h"
#import "ModelView.h"
#import "CCSDK/RequestData.h"
#import "LoadingView.h"
#import "InformationShowView.h"
#import "Utility.h"
#import "GongGaoView.h"
#import "ChatView.h"
#import "QuestionView.h"
#import "Dialogue.h"
#import "LianmaiView.h"
#import <AVFoundation/AVFoundation.h>
#import "LotteryView.h"
#import "RollcallView.h"
#import "VoteView.h"
#import "VoteViewResult.h"
#import "QuestionnaireSurvey.h"
#import "QuestionnaireSurveyPopUp.h"
#import "CCSDK/SaveLogUtil.h"
#import "QuestionNaire.h"
@interface PlayForPCVC ()<UITextFieldDelegate,RequestDataDelegate,UIScrollViewDelegate,LianMaiDelegate,UIAlertViewDelegate>
/*
 * 是否横屏模式
 */
@property(nonatomic,assign)Boolean                  isScreenLandScape;
@property(nonatomic,strong)UIImageView              *daohangView;
@property(nonatomic,strong)UIButton                 *leftButton;
@property(nonatomic,strong)UILabel                  *leftLabel;
@property(nonatomic,copy) NSString                  *leftLabelText;

@property(nonatomic,strong)UIImageView              *userCountLogo;
@property(nonatomic,copy)  NSString                 *userCount;
@property(nonatomic,strong)UILabel                  *userCountLabel;
@property(nonatomic,strong)UIButton                 *gongGaoBtn;
@property(nonatomic,strong)UIImageView              *gongGaoDot;

@property(nonatomic,strong)UIImageView              *soundBg;
@property(nonatomic,strong)UILabel                  *soundLabel;

@property(nonatomic,strong)CustomTextField          *chatTextField;
@property(nonatomic,strong)UIButton                 *danMuButton;
@property(nonatomic,strong)UIButton                 *sendButton;
@property(nonatomic,strong)UIView                   *contentView;
@property(nonatomic,strong)UIButton                 *rightView;

@property(nonatomic,strong)UIView                   *emojiView;
@property(nonatomic,strong)UIImageView              *contentBtnView;
@property(nonatomic,strong)NSMutableDictionary      *dataPrivateDic;
@property(nonatomic,strong)UIButton                 *soundVideoBtn;
@property(nonatomic,strong)UIButton                 *selectRoadBtn;
@property(nonatomic,strong)UIButton                 *hideDanMuBtn;
@property(nonatomic,assign)CGRect                   videoRect;

@property(nonatomic,strong)UIButton                 *yuanHuaBtn;
@property(nonatomic,strong)UIButton                 *qingXiBtn;
@property(nonatomic,strong)UIButton                 *liuChangBtn;
@property(nonatomic,strong)UIButton                 *qingXiDuBtn;

@property(nonatomic,strong)ModelView                *modelView;
@property(nonatomic,strong)UIView                   *modeoCenterView;
@property(nonatomic,strong)UILabel                  *modeoCenterLabel;
@property(nonatomic,strong)UIButton                 *cancelBtn;
@property(nonatomic,strong)UIButton                 *sureBtn;
@property(nonatomic,strong)NSTimer                  *timer;
@property(nonatomic,strong)NSTimer                  *danMuTimer;
@property(nonatomic,strong)NSTimer                  *hiddenTimer;
@property(nonatomic,assign)NSTimeInterval           hiddenTime;

@property(nonatomic,strong)RequestData              *requestData;
@property(nonatomic,strong)LoadingView              *loadingView;
@property(nonatomic,strong)UIView                   *informationView;

@property(nonatomic,assign)NSInteger                currentRoadNum;
@property(nonatomic,assign)NSInteger                currentSecRoadNum;
@property(nonatomic,strong)NSMutableArray           *secRoadKeyArray;

@property(nonatomic,strong)UIButton                 *mainRoad;
@property(nonatomic,strong)UIButton                 *secondRoad;

@property(nonatomic,copy)  NSString                 *viewerId;
@property(nonatomic,strong)NSMutableDictionary      *userDic;

@property(nonatomic,strong)NSMutableArray           *array;
@property(assign,nonatomic)NSInteger                secondToEnd;
@property(assign,nonatomic)NSInteger                lineLimit;
@property(assign,nonatomic)BOOL                     isKeyBoardShow;

@property(nonatomic,strong)GongGaoView              *gongGaoView;
@property(nonatomic,copy)  NSString                 *gongGaoStr;
@property(nonatomic,strong)UIView                   *videoView;
@property(nonatomic,strong)UIImageView              *barImageView;
@property(nonatomic,strong)UIButton                 *lianmaiBtn;
@property(nonatomic,strong)UIButton                 *quanPingBtn;
@property(nonatomic,strong)UIScrollView             *scrollView;
@property(nonatomic,strong)UISegmentedControl       *segment;
@property(nonatomic,strong)UIView                   *shadowView;
@property(nonatomic,strong)UIView                   *pptView;
@property(nonatomic,strong)ChatView                 *chatView;
@property(nonatomic,strong)QuestionView             *questionChatView;
@property(nonatomic,strong)UIView                   *introductionView;
@property(nonatomic,strong)UIImageView              *zhibozhongImage;

@property(nonatomic,copy)  NSString                 *roomDesc;
@property(nonatomic,copy)  NSString                 *roomName;

@property(nonatomic,strong)NSMutableDictionary      *QADic;
@property(nonatomic,strong)NSMutableArray           *publicChatArray;
@property(nonatomic,assign)BOOL                     newGongGao;
@property(nonatomic,assign)CGRect                   keyboardRect;

@property(nonatomic,strong)LianmaiView              *lianMaiView;

@property(copy,nonatomic)  NSString                 *videosizeStr;
@property(assign,nonatomic)BOOL                     isAllow;
@property(assign,nonatomic)BOOL                     needReloadLianMainView;
@property(nonatomic,strong)LotteryView              *lotteryView;
@property(nonatomic,strong)NSMutableArray           *lotteryViewTags;
@property(nonatomic,strong)RollcallView             *rollcallView;

@property(nonatomic,assign)NSInteger                duration;

@property(nonatomic,strong)VoteView                 *voteView;
@property(nonatomic,strong)QuestionNaire            *questionNaire;
@property(nonatomic,strong)VoteViewResult           *voteViewResult;
@property(nonatomic,assign)NSInteger                mySelectIndex;
@property(nonatomic,strong)NSMutableArray           *mySelectIndexArray;
@property(nonatomic,assign)NSInteger                templateType;

@property(nonatomic,assign)BOOL                     autoRotate;
@property(nonatomic,strong)UITapGestureRecognizer   *hideTextBoardTap1;
@property (strong, nonatomic) NSMutableArray        *keysArrAll;
@property(nonatomic,assign)BOOL                     lianMaiHidden;
@property(nonatomic,strong)QuestionnaireSurvey      *questionnaireSurvey;
@property(nonatomic,strong)QuestionnaireSurveyPopUp *questionnaireSurveyPopUp;
@property(nonatomic,copy  )NSString                 *roomUserCount;
@property(nonatomic,strong)InformationShowView      *informationViewPop;
@property(nonatomic,strong)UIView                   *smallVideoView;
@property(nonatomic, assign)NSInteger                submitedAction;


@end

@implementation PlayForPCVC

-(instancetype)initWithLeftLabelText:(NSString *)leftLabelText {
    self = [super init];
    if(self) {
        self.leftLabelText = leftLabelText;
        self.isScreenLandScape = NO;
    }
    return self;
}

-(NSMutableArray *)lotteryViewTags {
    if(!_lotteryViewTags) {
        _lotteryViewTags = [[NSMutableArray alloc]init];
    }
    return _lotteryViewTags;
}

-(void)dealSingleInformationTap {
    [self.view endEditing:YES];
}
/**
 *	@brief  收到播放直播状态 0直播 1未直播
 */
- (void)getPlayStatue:(NSInteger)status {
    if(status == 1) {
        [self loadInformationView:@"直播未开始"];
    }
}

/**
 *	@brief  主讲开始推流
 */
- (void)onLiveStatusChangeStart {
    [_loadingView removeFromSuperview];
    _loadingView = nil;
    [_informationView removeFromSuperview];
    _informationView = nil;
    
    _loadingView = [[LoadingView alloc] initWithLabel:@"视频加载中" centerY:YES];
    [self.videoView addSubview:_loadingView];
    UITapGestureRecognizer *hideTextBoardTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleInformationTap)];
    [_loadingView addGestureRecognizer:hideTextBoardTap];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(50, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
}

-(void)loadInformationView:(NSString *)informationStr {
    [_loadingView removeFromSuperview];
    _loadingView = nil;
    [_informationView removeFromSuperview];
    _informationView = nil;
    
    [self showAll];
    
    _informationView = [[UIView alloc] init];
    _informationView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *hideTextBoardTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleInformationTap)];
    [self.videoView addSubview:_informationView];
    if([informationStr isEqualToString:@"视频加载失败"]) {
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(50, 100, 0, 100));
        }];
 
    } else {
        [_informationView addGestureRecognizer:hideTextBoardTap];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.videoView);
        }];
        UIButton * titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        titleBtn.backgroundColor = CCClearColor;
        [titleBtn addTarget:self action:@selector(onSelectVC) forControlEvents:UIControlEventTouchUpInside];
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_back_nor"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [titleBtn setImage:image forState:UIControlStateNormal];
        titleBtn.contentMode = UIViewContentModeScaleAspectFit;
        [titleBtn addTarget:self action:@selector(onSelectVC) forControlEvents:UIControlEventTouchUpInside];
        [_informationView addSubview:titleBtn];
        WS(ws)
        [titleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.informationView).offset(10);
            make.top.mas_equalTo(ws.informationView).offset(14);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80), CCGetRealFromPt(80)));
        }];
        
    }
    UILabel *label = [UILabel new];
    label.backgroundColor = CCClearColor;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:FontSize_32];
    label.text = informationStr;
    [_informationView addSubview:label];
    WS(ws)
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.informationView);
    }];

}
/**
 *	@brief  停止直播，endNormal表示是否异常停止推流，这个参数对观看端影响不大
 */
- (void)onLiveStatusChangeEnd:(BOOL)endNormal {
    
    [self loadInformationView:@"直播已停止"];
}
/*
 *  开始答题
 */
- (void)start_vote:(NSInteger)count singleSelection:(BOOL)single {
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.voteViewResult removeFromSuperview];
        ws.voteViewResult = nil;
        [ws.voteView removeFromSuperview];
        ws.voteView = nil;
        ws.mySelectIndex = -1;
        [ws.mySelectIndexArray removeAllObjects];
        
        ws.voteView = [[VoteView alloc] initWithCount:count singleSelection:single closeblock:^{
            [ws.voteView removeFromSuperview];
            ws.voteView = nil;
        } voteSingleBlock:^(NSInteger index) {
//答单选题
            [ws.requestData reply_vote_single:index];
            ws.mySelectIndex = index;
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:ws selector:@selector(removeVoteView) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            [[NSRunLoop currentRunLoop] run];
        } voteMultipleBlock:^(NSMutableArray *indexArray) {
//答多选题
            [ws.requestData reply_vote_multiple:indexArray];
            ws.mySelectIndexArray = [indexArray mutableCopy];
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:ws selector:@selector(removeVoteView) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            [[NSRunLoop currentRunLoop] run];
        } singleNOSubmit:^(NSInteger index) {
            ws.mySelectIndex = index;
        } multipleNOSubmit:^(NSMutableArray *indexArray) {
            ws.mySelectIndexArray = [indexArray mutableCopy];
        } isScreenLandScape:self.isScreenLandScape];
        
        [APPDelegate.window addSubview:ws.voteView];
        [ws.voteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.view);
        }];
        
        if(ws.rollcallView) {
            [APPDelegate.window bringSubviewToFront:ws.rollcallView];
        }
        
        [ws.voteView layoutIfNeeded];
    });
}

-(void)removeVoteView {
    [_voteView removeFromSuperview];
    _voteView = nil;
}

/*
 *  问卷功能
 */
- (void)questionnaireWithTitle:(NSString *)title url:(NSString *)url {
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.questionNaire removeFromSuperview];
        ws.questionNaire = nil;
        
        ws.questionNaire = [[QuestionNaire alloc] initWithTitle:title url:url isScreenLandScape:self.isScreenLandScape closeblock:^{
            [ws.questionNaire removeFromSuperview];
            ws.questionNaire = nil;
        }];
        
        [APPDelegate.window addSubview:ws.questionNaire];
        [ws.questionNaire mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.view);
        }];
        
        if(ws.rollcallView) {
            [APPDelegate.window bringSubviewToFront:ws.rollcallView];
        }
        
        [ws.voteView layoutIfNeeded];
    });
}

/*
 *  结束答题
 */
- (void)stop_vote {
    if(_voteView) {
        [_voteView removeFromSuperview];
        _voteView = nil;
    }
}
/*
 *  答题结果
 */
- (void)vote_result:(NSDictionary *)resultDic {
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.voteViewResult removeFromSuperview];
        ws.voteViewResult = nil;
        [ws.voteView removeFromSuperview];
        ws.voteView = nil;
        ws.voteViewResult = [[VoteViewResult alloc] initWithResultDic:resultDic mySelectIndex:ws.mySelectIndex mySelectIndexArray:ws.mySelectIndexArray closeblock:^{
            [ws.voteViewResult removeFromSuperview];
            ws.voteViewResult = nil;
        } isScreenLandScape:ws.isScreenLandScape];
        
        [APPDelegate.window addSubview:ws.voteViewResult];
        [ws.voteViewResult mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.view);
        }];
        
        if(ws.rollcallView) {
            [APPDelegate.window bringSubviewToFront:ws.rollcallView];
        }
        
        [ws.voteViewResult layoutIfNeeded];
    });
}

/*
 *  开始抽奖
 */
- (void)start_lottery {
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.lotteryView removeFromSuperview];
        ws.lotteryView = nil;
        
        ws.lotteryView = [[LotteryView alloc] initIsScreenLandScape:ws.isScreenLandScape clearColor:NO];
        ws.lotteryView.tag = -1 + 1000;
        [ws.lotteryViewTags removeAllObjects];
        [ws.lotteryViewTags addObject:[NSString stringWithFormat:@"%ld",ws.lotteryView.tag]];
        
        [APPDelegate.window addSubview:ws.lotteryView];
        [ws.lotteryView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.view);
        }];
        
        if(ws.rollcallView) {
            [APPDelegate.window bringSubviewToFront:ws.rollcallView];
        }
        
        [ws.lotteryView layoutIfNeeded];
    });
}
/*
 *  抽奖结果
 */
- (void)lottery_resultWithCode:(NSString *)code myself:(BOOL)myself winnerName:(NSString *)winnerName remainNum:(NSInteger)remainNum {
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        if(ws.lotteryView == nil) {
            return;
        }
        
        LotteryView *lotteryView = [[LotteryView alloc] initIsScreenLandScape:ws.isScreenLandScape clearColor:remainNum == 0 ? NO : YES];
        lotteryView.tag = 1000 + remainNum;
        [ws.lotteryViewTags addObject:[NSString stringWithFormat:@"%ld",lotteryView.tag]];
        
        [APPDelegate.window insertSubview:lotteryView aboveSubview:ws.lotteryView];
        [lotteryView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.view);
        }];
        [lotteryView layoutIfNeeded];
        if(myself) {
            [lotteryView myselfWin:code];
        } else {
            [lotteryView otherWin:winnerName];
        }
        
        if(remainNum == 0) {
            [ws.lotteryView removeFromSuperview];
            ws.lotteryView = nil;
        }
        
        if(!myself) {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setObject:[NSNumber numberWithLong:lotteryView.tag] forKey:@"tag"];
            [NSTimer scheduledTimerWithTimeInterval:3.0f target:ws selector:@selector(postMessage:) userInfo:userInfo repeats:NO];
        }
        
        if(ws.rollcallView) {
            [APPDelegate.window bringSubviewToFront:ws.rollcallView];
        }
    });
}
    
-(void)postMessage:(NSTimer *)timer {
    NSMutableDictionary *dic = [timer userInfo];
    NSNumber *num = dic[@"tag"];
    dic[@"tag"] = [NSString stringWithFormat:@"%ld",num.longValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"remove_lotteryView" object:dic];
}

/*
 *  退出抽奖
 */
- (void)stop_lottery {
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:3.0f target:ws selector:@selector(closeLotteryView) userInfo:nil repeats:NO];
    });
}

-(void)closeLotteryView {
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        for(int i = 0;i < [ws.lotteryViewTags count];i++) {
            NSInteger tag = [ws.lotteryViewTags[i] integerValue];
            LotteryView *lotteryView = [APPDelegate.window viewWithTag:tag];
            if(lotteryView && lotteryView.type != 2) {
                [lotteryView removeFromSuperview];
                lotteryView = nil;
            }
        }
        [ws.lotteryViewTags removeAllObjects];
    });
}

-(RollcallView *)rollcallView {
    WS(ws)
    if(!_rollcallView) {
        _rollcallView = [[RollcallView alloc] initWithDuration:self.duration closeblock:^{
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:ws selector:@selector(removeRollCallView) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            [[NSRunLoop currentRunLoop] run];
        } lotteryblock:^{
//签到
            [ws.requestData answer_rollcall];
        } isScreenLandScape:self.isScreenLandScape];
    }
    return _rollcallView;
}

-(void)removeRollCallView {
    [_rollcallView removeFromSuperview];
    _rollcallView = nil;
}

- (void)commitQuestionnaireResult:(BOOL)success {
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.questionnaireSurvey commitSuccess:success];
        if(success &&self.submitedAction != 1) {
            [NSTimer scheduledTimerWithTimeInterval:3.0f target:ws selector:@selector(removeQuestionnaireSurvey) userInfo:nil repeats:NO];
            
        }
    });
}

-(void)removeQuestionnaireSurvey {
    [_questionnaireSurvey removeFromSuperview];
    _questionnaireSurvey = nil;
    [_questionnaireSurveyPopUp removeFromSuperview];
    _questionnaireSurveyPopUp = nil;
}

-(NSMutableArray *)keysArrAll {
    if(_keysArrAll==nil || [_keysArrAll count] == 0) {
        _keysArrAll = [[NSMutableArray alloc]init];
    }
    return _keysArrAll;
}

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

- (void)start_rollcall:(NSInteger)duration {
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.rollcallView removeFromSuperview];
        ws.rollcallView = nil;
        self.duration = duration;
        [APPDelegate.window addSubview:self.rollcallView];
        [ws.rollcallView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.view);
        }];
        [APPDelegate.window bringSubviewToFront:ws.rollcallView];
        [ws.rollcallView layoutIfNeeded];
    });
}

-(LianmaiView *)lianMaiView {
    if(!_lianMaiView) {
        _lianMaiView = [[LianmaiView alloc] init];
        _lianMaiView.delegate = self;
    }
    return _lianMaiView;
}

-(UIButton *)qingXiDuBtn {
    if(!_qingXiDuBtn) {
        _qingXiDuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_qingXiDuBtn setTitle:@"清晰度" forState:UIControlStateNormal];
        [_qingXiDuBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_28]];
        [_qingXiDuBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_qingXiDuBtn addTarget:self action:@selector(qingXiDuAction) forControlEvents:UIControlEventTouchUpInside];
        [_qingXiDuBtn setBackgroundColor:CCClearColor];
    }
    return _qingXiDuBtn;
}

-(UIButton *)yuanHuaBtn {
    if(!_yuanHuaBtn) {
        _yuanHuaBtn = [UIButton new];
        _yuanHuaBtn.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);
        _yuanHuaBtn.layer.shadowOffset = CGSizeMake(2, -2);
        _yuanHuaBtn.layer.shadowColor = [CCRGBAColor(0,0,0,0.6) CGColor];
        
        [_yuanHuaBtn setTitle:@"原画" forState:UIControlStateNormal];
        [_yuanHuaBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_30]];
        [_yuanHuaBtn setTitleColor:CCRGBColor(255, 255, 255) forState:UIControlStateNormal];
        [_yuanHuaBtn setTitleColor:CCRGBColor(255,102,51) forState:UIControlStateSelected];
        [_yuanHuaBtn addTarget:self action:@selector(yuanHuaBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _yuanHuaBtn;
}

-(UIButton *)qingXiBtn {
    if(!_qingXiBtn) {
        _qingXiBtn = [UIButton new];
        _qingXiBtn.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);
        _qingXiBtn.layer.shadowOffset = CGSizeMake(2, -2);
        _qingXiBtn.layer.shadowColor = [CCRGBAColor(0,0,0,0.6) CGColor];
        
        [_qingXiBtn setTitle:@"清晰" forState:UIControlStateNormal];
        [_qingXiBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_30]];
        [_qingXiBtn setTitleColor:CCRGBColor(255, 255, 255) forState:UIControlStateNormal];
        [_qingXiBtn setTitleColor:CCRGBColor(255,102,51) forState:UIControlStateSelected];
        [_qingXiBtn addTarget:self action:@selector(qingXiBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qingXiBtn;
}

-(UIButton *)liuChangBtn {
    if(!_liuChangBtn) {
        _liuChangBtn = [UIButton new];
        _liuChangBtn.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);
        _liuChangBtn.layer.shadowOffset = CGSizeMake(2, -2);
        _liuChangBtn.layer.shadowColor = [CCRGBAColor(0,0,0,0.6) CGColor];
        
        [_liuChangBtn setTitle:@"流畅" forState:UIControlStateNormal];
        [_liuChangBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_30]];
        [_liuChangBtn setTitleColor:CCRGBColor(255, 255, 255) forState:UIControlStateNormal];
        [_liuChangBtn setTitleColor:CCRGBColor(255,102,51) forState:UIControlStateSelected];
        [_liuChangBtn addTarget:self action:@selector(liuChangBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _liuChangBtn;
}

-(BOOL)hasViewOnTheScreen:(BOOL)allowConnectingClick {
    if([_lianMaiView isConnecting] && !allowConnectingClick) {
        return YES;
    } else if(_lianMaiView && _lianMaiView.hidden == NO) {
        if(_lianMaiView.needToRemoveLianMaiView) {
            [_lianMaiView removeFromSuperview];
            _lianMaiView = nil;
        } else {
            _lianMaiView.hidden = YES;
        }
        if([_lianMaiView isConnecting]) {
            _lianmaiBtn.selected = YES;
        }
        return YES;
    } else if(_yuanHuaBtn.hidden == NO) {
        _yuanHuaBtn.hidden = YES;
        _qingXiBtn.hidden = YES;
        _liuChangBtn.hidden = YES;
        return YES;
    } else if(_mainRoad.hidden == NO) {
        _mainRoad.hidden = YES;
        _secondRoad.hidden = YES;
//        _thirdRoad.hidden = YES;
        return YES;
    }
    return NO;
}

-(void)qingXiDuAction {
    self.hiddenTime = 5;
    
    if([self hasViewOnTheScreen:NO]) return;
    
    BOOL hidden = self.yuanHuaBtn.hidden;
    if(self.yuanHuaBtn.hidden) {
        if([_secRoadKeyArray count] == 1) {
            _yuanHuaBtn.hidden = !hidden;
        } else {
            _yuanHuaBtn.hidden = !hidden;
            _qingXiBtn.hidden = !hidden;
            _liuChangBtn.hidden = !hidden;
        }
    }
}

-(void)yuanHuaBtnClicked {
    self.hiddenTime = 5;
    _yuanHuaBtn.selected = YES;
    _qingXiBtn.selected = NO;
    _liuChangBtn.selected = NO;
    
    _yuanHuaBtn.hidden = YES;
    _qingXiBtn.hidden = YES;
    _liuChangBtn.hidden = YES;
    
    if(_currentSecRoadNum == 0) {
        return;
    }
    _currentSecRoadNum = 0;
    
    
    if(self.soundVideoBtn.selected) {
//切换音视频
        [_requestData switchToPlayUrlWithFirIndex:_currentRoadNum key:@""];
    } else {
//切换清晰度
        [_requestData switchToPlayUrlWithFirIndex:_currentRoadNum key:[_secRoadKeyArray objectAtIndex:_currentSecRoadNum]];
    }
}

-(void)qingXiBtnClicked {
    self.hiddenTime = 5;
    _yuanHuaBtn.selected = NO;
    _qingXiBtn.selected = YES;
    _liuChangBtn.selected = NO;
    
    _yuanHuaBtn.hidden = YES;
    _qingXiBtn.hidden = YES;
    _liuChangBtn.hidden = YES;
    
    if(_currentSecRoadNum == 1) {
        return;
    }
    _currentSecRoadNum = 1;
    
    if(self.soundVideoBtn.selected) {
//切换线路
        [_requestData switchToPlayUrlWithFirIndex:_currentRoadNum key:@""];
    } else {
        [_requestData switchToPlayUrlWithFirIndex:_currentRoadNum key:[_secRoadKeyArray objectAtIndex:_currentSecRoadNum]];
    }
}

-(void)liuChangBtnClicked {
    self.hiddenTime = 5;
    _yuanHuaBtn.selected = NO;
    _qingXiBtn.selected = NO;
    _liuChangBtn.selected = YES;
    
    _yuanHuaBtn.hidden = YES;
    _qingXiBtn.hidden = YES;
    _liuChangBtn.hidden = YES;
    
    if(_currentSecRoadNum == 2) {
        return;
    }
    _currentSecRoadNum = 2;
//切换清晰度
    if(self.soundVideoBtn.selected) {
        [_requestData switchToPlayUrlWithFirIndex:_currentRoadNum key:@""];
    } else {
        [_requestData switchToPlayUrlWithFirIndex:_currentRoadNum key:[_secRoadKeyArray objectAtIndex:_currentSecRoadNum]];
    }
}

-(NSMutableDictionary *)QADic {
    if(!_QADic) {
        _QADic = [[NSMutableDictionary alloc] init];
    }
    return _QADic;
}

/*
 *  发布问卷
 */
- (void)questionnaire_publish {
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.questionnaireSurvey removeFromSuperview];
        ws.questionnaireSurvey = nil;
        [ws.questionnaireSurveyPopUp removeFromSuperview];
        ws.questionnaireSurveyPopUp = nil;
    });
}
/*
 *  结束发布问卷
 */
- (void)questionnaire_publish_stop{
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.questionnaireSurveyPopUp removeFromSuperview];
        ws.questionnaireSurveyPopUp = nil;
        
        if(ws.questionnaireSurvey == nil) return;
        
        ws.questionnaireSurveyPopUp = [[QuestionnaireSurveyPopUp alloc] initIsScreenLandScape:self.isScreenLandScape SureBtnBlock:^{
            [ws.questionnaireSurvey removeFromSuperview];
            ws.questionnaireSurvey = nil;
            [ws.questionnaireSurveyPopUp removeFromSuperview];
            ws.questionnaireSurveyPopUp = nil;
        }];
        
        [APPDelegate.window addSubview:ws.questionnaireSurveyPopUp];
        [ws.questionnaireSurveyPopUp mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.view);
        }];
        [ws.questionnaireSurveyPopUp layoutIfNeeded];
        
        if(ws.rollcallView) {
            [APPDelegate.window bringSubviewToFront:ws.rollcallView];
        }
    });
}
/*
 *  获取问卷统计
 */
- (void)questionnaireStaticsInformation:(NSDictionary *)staticsDic {
    
    if (self.questionnaireSurvey != nil) {
        [self.questionnaireSurvey removeFromSuperview];
        self.questionnaireSurvey = nil;
    }
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        ws.questionnaireSurvey = [[QuestionnaireSurvey alloc] initWithCloseBlock:^{
            [ws.questionnaireSurvey removeFromSuperview];
            ws.questionnaireSurvey = nil;
            [ws.questionnaireSurveyPopUp removeFromSuperview];
            ws.questionnaireSurveyPopUp = nil;
        } CommitBlock:^(NSDictionary *dic) {

        } questionnaireDic:staticsDic isScreenLandScape:ws.isScreenLandScape isStastic:YES];

        [APPDelegate.window addSubview:ws.questionnaireSurvey];
        [ws.questionnaireSurvey mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.view);
        }];
        
        [ws.questionnaireSurvey layoutIfNeeded];
    
        if(ws.rollcallView) {
            [APPDelegate.window bringSubviewToFront:ws.rollcallView];
        }
    });
}
/*
 *  获取问卷详细内容
 */
- (void)questionnaireDetailInformation:(NSDictionary *)detailDic {
   
    self.submitedAction     = [detailDic[@"submitedAction"] integerValue];
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        ws.questionnaireSurvey = [[QuestionnaireSurvey alloc] initWithCloseBlock:^{
            [ws.questionnaireSurvey removeFromSuperview];
            ws.questionnaireSurvey = nil;
            [ws.questionnaireSurveyPopUp removeFromSuperview];
            ws.questionnaireSurveyPopUp = nil;
        } CommitBlock:^(NSDictionary *dic) {
            //提交问卷结果
            [ws.requestData commitQuestionnaire:dic];
        } questionnaireDic:detailDic isScreenLandScape:ws.isScreenLandScape isStastic:NO];
        [APPDelegate.window addSubview:ws.questionnaireSurvey];
        [ws.questionnaireSurvey mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.view);
        }];
        
        [ws.questionnaireSurvey layoutIfNeeded];
        
        if(ws.rollcallView) {
            [APPDelegate.window bringSubviewToFront:ws.rollcallView];
        }
    });
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
        NSArray *segmentedArray = [[NSArray alloc] initWithObjects:@"文档",@"聊天",@"问答",@"简介", nil];
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

-(UIImageView *)zhibozhongImage {
    if(!_zhibozhongImage) {
        _zhibozhongImage = [UIImageView new];
        _zhibozhongImage.image = [UIImage imageNamed:@"nav_msg_living_dis"];
        _zhibozhongImage.backgroundColor = CCClearColor;
        _zhibozhongImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _zhibozhongImage;
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
    CGFloat width3 = [segment widthForSegmentAtIndex:3];
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
        case 3: {
            [UIView animateWithDuration:0.25 animations:^{
                ws.shadowView.frame = CGRectMake(width0 + width1 + width2, shadowViewY, width3, 4);
            }];
        }
            [ws.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 3, py)];
            break;
        default:
            break;
    }
}

-(void)tapGesture:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

-(UIView *)videoView {
    if(!_videoView) {
        _videoView = [UIView new];
        _videoView.backgroundColor = [UIColor blackColor];
    }
    return _videoView;
}

-(UIImageView *)barImageView {
    if(!_barImageView) {
        _barImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Bar"]];
        _barImageView.contentMode = UIViewContentModeScaleAspectFit;
        //        _barImageView.backgroundColor = CCRGBAColor(0, 0, 0, 0.69);
    }
    return _barImageView;
}

-(NSMutableDictionary *)userDic {
    if(!_userDic) {
        _userDic = [[NSMutableDictionary alloc] init];
    }
    return _userDic;
}

-(UILabel *)userCountLabel {
    if(!_userCountLabel) {
        _userCountLabel = [UILabel new];
        _userCountLabel.text = _roomUserCount;
        _userCountLabel.textColor = [UIColor whiteColor];
        _userCountLabel.textAlignment = NSTextAlignmentLeft;
        _userCountLabel.font = [UIFont systemFontOfSize:FontSize_24];
        _userCountLabel.shadowOffset = CGSizeMake(0, 1);
        _userCountLabel.shadowColor = CCRGBAColor(102, 102, 102, 0.5);
    }
    return _userCountLabel;
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
    if((_isScreenLandScape == YES && _isKeyBoardShow == YES) || _yuanHuaBtn.hidden == NO || self.mainRoad.hidden == NO || (_lianMaiView && _lianMaiView.hidden == NO) || _loadingView || _informationView) {
        _hiddenTime = 5.0f;
        return;
    }
    if(_hiddenTime > 0.0f) {
        _hiddenTime -= 1.0f;
    }
    if(_hiddenTime == 0) {
        _daohangView.hidden = YES;
        
        _barImageView.hidden = YES;
        _contentView.hidden = YES;
        
        _lianmaiBtn.hidden = YES;
        _selectRoadBtn.hidden = YES;
        
        _soundVideoBtn.hidden = YES;
        _hideDanMuBtn.hidden = YES;
        _quanPingBtn.hidden = YES;
        
        _qingXiDuBtn.hidden = YES;
        _yuanHuaBtn.hidden = YES;
        _qingXiBtn.hidden = YES;
        _liuChangBtn.hidden = YES;
        _mainRoad.hidden = YES;
        _secondRoad.hidden = YES;
//        _thirdRoad.hidden = YES;
        _zhibozhongImage.hidden = NO;
        
        if(_lianMaiView.needToRemoveLianMaiView) {
            [_lianMaiView removeFromSuperview];
            _lianMaiView = nil;
        } else {
            _lianMaiView.hidden = YES;
        }
    }
}

-(void)hiddenAllBtns {
    if(_isScreenLandScape == YES && _isKeyBoardShow == YES) {
        _hiddenTime = 5.0f;
        return;
    }
    _gongGaoDot.hidden = !_newGongGao;
    
    _daohangView.hidden = YES;
    _barImageView.hidden = YES;
    _lianmaiBtn.hidden = YES;
    _selectRoadBtn.hidden = YES;
    _soundVideoBtn.hidden = YES;
    _mainRoad.hidden = YES;
    _secondRoad.hidden = YES;
//    _thirdRoad.hidden = YES;
    _qingXiDuBtn.hidden = YES;
    _contentView.hidden = YES;
    _hideDanMuBtn.hidden = YES;
    _quanPingBtn.hidden = YES;
    _yuanHuaBtn.hidden = YES;
    _qingXiBtn.hidden = YES;
    _liuChangBtn.hidden = YES;
    _zhibozhongImage.hidden = NO;
    
    if(_lianMaiView.needToRemoveLianMaiView) {
        [_lianMaiView removeFromSuperview];
        _lianMaiView = nil;
    } else {
        _lianMaiView.hidden = YES;
    }
}

-(void)showAll {
    _hiddenTime = 5.0f;
    _daohangView.hidden = NO;
    _barImageView.hidden = NO;
    _lianmaiBtn.hidden = NO;
    _selectRoadBtn.hidden = NO;
    _soundVideoBtn.hidden = NO;
    
    _mainRoad.hidden = YES;
    _secondRoad.hidden = YES;
//    _thirdRoad.hidden = YES;
    _zhibozhongImage.hidden = YES;
    
    if(_isScreenLandScape) {
        _qingXiDuBtn.hidden = NO;
        _contentView.hidden = NO;
        _hideDanMuBtn.hidden = YES;
        _quanPingBtn.hidden = YES;
    } else {
        _qingXiDuBtn.hidden = YES;
        _contentView.hidden = YES;
        _hideDanMuBtn.hidden = NO;
        _quanPingBtn.hidden = NO;
    }
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

-(UIButton *)lianmaiBtn {
    if(!_lianmaiBtn) {
        _lianmaiBtn = [UIButton new];
        _lianmaiBtn.backgroundColor = CCClearColor;
        [_lianmaiBtn setImage:[UIImage imageNamed:@"video_ic_lianmai_nor"] forState:UIControlStateNormal];
        [_lianmaiBtn setImage:[UIImage imageNamed:@"video_ic_lianmai_hov"] forState:UIControlStateSelected];
        _lianmaiBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_lianmaiBtn addTarget:self action:@selector(lianmaiBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lianmaiBtn;
}

-(UIButton *)quanPingBtn {
    if(!_quanPingBtn) {
        _quanPingBtn = [UIButton new];
        _quanPingBtn.backgroundColor = CCClearColor;
        [_quanPingBtn setImage:[UIImage imageNamed:@"video_ic_full_nor"] forState:UIControlStateNormal];
        _quanPingBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_quanPingBtn addTarget:self action:@selector(quanPingBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _quanPingBtn;
}

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
                
                CGFloat x = smallVideoRect.origin.x < self.pptView.frame.origin.x ? 0 : smallVideoRect.origin.x;

                CGFloat y = smallVideoRect.origin.y < self.pptView.frame.origin.y ? 0 : smallVideoRect.origin.y;

                x = (x + smallVideoRect.size.width) > (self.pptView.frame.origin.x + self.pptView.frame.size.width) ? (self.pptView.frame.origin.x + self.pptView.frame.size.width - smallVideoRect.size.width) : x;

                y = (y + smallVideoRect.size.height) > (self.pptView.frame.origin.y + self.pptView.frame.size.height) ? (self.pptView.frame.origin.y + self.pptView.frame.size.height - smallVideoRect.size.height) : y;

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

-(void)dealPPTViewDoubleTap {
    if(_pptView == nil) return;
    WS(ws)
    [self.view endEditing:YES];
    if (!self.isScreenLandScape) {
        self.isScreenLandScape = YES;
        self.autoRotate = YES;
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
        [UIApplication sharedApplication].statusBarHidden = YES;
        [_pptView removeFromSuperview];
        [self.view addSubview:_pptView];
        [self.view bringSubviewToFront:_pptView];
        CGRect rect = self.view.frame;
        [UIView animateWithDuration:0.25f animations:^{
            [ws.pptView setFrame:rect];
//改变文档区域大小,主要用在文档生成后改变文档窗口的frame
            [ws.requestData changeDocFrame:rect];
        } completion:^(BOOL finished) {
            
        }];
        if(_soundVideoBtn.selected == NO) {
            CGRect smallVideoRect = CGRectMake(0, 0, rect.size.width / 4, rect.size.height / 4);
            self.smallVideoView = [[UIView alloc] initWithFrame:smallVideoRect];
            self.smallVideoView.backgroundColor = [UIColor blackColor];
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                            initWithTarget:self
                                                            action:@selector(handlePan:)];
            [self.smallVideoView addGestureRecognizer:panGestureRecognizer];
            
            [APPDelegate.window addSubview:self.smallVideoView];
// 改变播放器父窗口
            [self.requestData.ijkPlayer.view removeFromSuperview];
            [self.requestData changePlayerParent:self.smallVideoView];
            [self.smallVideoView insertSubview:self.requestData.ijkPlayer.view atIndex:0];
// 改变播放器frame
            [self.requestData changePlayerFrame:CGRectMake(0, 0, self.smallVideoView.frame.size.width, self.smallVideoView.frame.size.height)];
        }
    } else {
        self.isScreenLandScape = NO;
        self.autoRotate = YES;
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        [UIApplication sharedApplication].statusBarHidden = NO;
        [_pptView removeFromSuperview];
        [_scrollView addSubview:_pptView];
        CGRect rect = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);

        [UIView animateWithDuration:0.25f animations:^{
            [ws.pptView setFrame:rect];
// 改变文档区域大小,主要用在文档生成后改变文档窗口的frame
            [ws.requestData changeDocFrame:rect];
        } completion:^(BOOL finished) {
        }];
        if(_soundVideoBtn.selected == NO) {
// 改变播放器父窗口
            [self.requestData.ijkPlayer.view removeFromSuperview];
            [self.requestData changePlayerParent:self.videoView];
            [self.videoView insertSubview:self.requestData.ijkPlayer.view atIndex:0];
// 改变播放器frame
            [self.requestData changePlayerFrame:CGRectMake(0, 0, self.videoView.frame.size.width, self.videoView.frame.size.height)];
            
            [self.smallVideoView removeFromSuperview];
            self.smallVideoView = nil;
        }

        
    }

    self.autoRotate = NO;
}

-(void)quanPingBtnClicked {
    self.hiddenTime = 5.0f;
    if([self hasViewOnTheScreen:YES]) return;
    WS(ws)
    [self.view endEditing:YES];
    if (!self.isScreenLandScape) {
        self.isScreenLandScape = YES;
        self.autoRotate = YES;
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
        [UIApplication sharedApplication].statusBarHidden = YES;
// 改变播放器frame
        [_requestData changePlayerFrame:self.view.frame];
        [self.videoView setFrame:self.view.frame];
        
        [_daohangView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.top.and.right.mas_equalTo(ws.view);
            make.height.mas_equalTo(64);
        }];
        
        [_leftButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.daohangView).offset(10);
            make.top.mas_equalTo(ws.daohangView);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80), CCGetRealFromPt(80)));
        }];
        
        [_leftLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.leftButton.mas_right);//.offset(CCGetRealFromPt(10));
            make.centerY.mas_equalTo(ws.leftButton);
            make.size.mas_equalTo(CGSizeMake(ws.view.frame.size.width * 0.5, CCGetRealFromPt(30)));
        }];

        [_zhibozhongImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.daohangView).mas_offset(-CCGetRealFromPt(30));
            make.centerY.mas_equalTo(ws.leftButton).offset(8);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(115), CCGetRealFromPt(52)));
        }];
        
        [_gongGaoBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.daohangView).offset(-CCGetRealFromPt(43));
            make.bottom.mas_equalTo(ws.leftLabel.mas_bottom).offset(2);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(67), CCGetRealFromPt(38)));
        }];
        
        [_qingXiDuBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.gongGaoBtn.mas_left).offset(-CCGetRealFromPt(52));
            make.bottom.mas_equalTo(ws.gongGaoBtn).offset(-3);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(86), CCGetRealFromPt(28)));
        }];
        
        [_userCountLogo removeFromSuperview];
        _userCountLogo = nil;
        [_daohangView addSubview:self.userCountLogo];
        [_userCountLogo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.daohangView).offset(-CCGetRealFromPt(358));
            make.bottom.mas_equalTo(ws.qingXiDuBtn);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(36), CCGetRealFromPt(36)));
        }];
        
        [_userCountLabel removeFromSuperview];
        _userCountLabel = nil;
        [_daohangView addSubview:self.userCountLabel];
        [_userCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.userCountLogo.mas_right).offset(CCGetRealFromPt(6));
            make.right.mas_equalTo(ws.qingXiDuBtn.mas_left);
            make.top.mas_equalTo(ws.userCountLogo);
            make.bottom.mas_equalTo(ws.userCountLogo);
        }];

        [_soundVideoBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.videoView).offset(-CCGetRealFromPt(30));
            make.top.mas_equalTo(ws.daohangView.mas_bottom).offset(CCGetRealFromPt(212));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(70),CCGetRealFromPt(70)));
        }];

        [_lianmaiBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.videoView).offset(CCGetRealFromPt(30));
            make.top.mas_equalTo(ws.daohangView.mas_bottom).offset(CCGetRealFromPt(142));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(70), CCGetRealFromPt(70)));
        }];
        
        [_selectRoadBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.lianmaiBtn);
            make.top.mas_equalTo(ws.lianmaiBtn.mas_bottom).offset(CCGetRealFromPt(56));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(70),CCGetRealFromPt(70)));
        }];

        [_mainRoad mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.selectRoadBtn.mas_right).offset(CCGetRealFromPt(14));
            make.top.mas_equalTo(ws.selectRoadBtn);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(190), CCGetRealFromPt(70)));
        }];
        
        [_secondRoad mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.mainRoad);
            make.top.mas_equalTo(ws.mainRoad.mas_bottom);
            make.size.mas_equalTo(ws.mainRoad);
        }];
        
        [_soundBg mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.videoView).offset(CCGetRealFromPt(294));
            make.right.mas_equalTo(ws.videoView).offset(-CCGetRealFromPt(294));
            make.top.mas_equalTo(ws.daohangView.mas_bottom).offset(CCGetRealFromPt(111));
            make.height.mas_equalTo(CCGetRealFromPt(220));
        }];
        
        [_soundLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.soundBg.mas_bottom).offset(CCGetRealFromPt(20));
            make.centerX.mas_equalTo(ws.videoView);
            make.size.mas_equalTo(CGSizeMake(300, CCGetRealFromPt(32)));
        }];
        
        if(_lianMaiView) {
            _lianMaiView.frame = CGRectMake(CCGetRealFromPt(114), CCGetRealFromPt(270),_lianMaiView.frame.size.width,_lianMaiView.frame.size.height);
        }
        
        self.yuanHuaBtn.hidden = YES;
        self.qingXiBtn.hidden = YES;
        self.liuChangBtn.hidden = YES;
        self.qingXiDuBtn.hidden = NO;
        self.contentView.hidden = NO;
        self.hideDanMuBtn.hidden = YES;
        self.quanPingBtn.hidden = YES;
        self.mainRoad.hidden = YES;
        self.secondRoad.hidden = YES;
//        self.thirdRoad.hidden = YES;

        [UIView animateWithDuration:0.25f animations:^{
            [ws.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    } else {
        self.isScreenLandScape = NO;
        self.autoRotate = YES;
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        [UIApplication sharedApplication].statusBarHidden = NO;
// 改变播放器frame
        [_requestData changePlayerFrame:_videoRect];
        [_videoView setFrame:_videoRect];

        [_zhibozhongImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.videoView).offset(CCGetRealFromPt(58));
            make.right.mas_equalTo(ws.videoView).mas_offset(-CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(115), CCGetRealFromPt(52)));
        }];
        
        [_daohangView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.mas_equalTo(ws.view);
            make.height.mas_equalTo(CCGetRealFromPt(108));
        }];

        [_leftButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.daohangView);
            make.bottom.mas_equalTo(ws.daohangView);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80), CCGetRealFromPt(80)));
        }];

        [_leftLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.leftButton.mas_right).offset(CCGetRealFromPt(10));
            make.centerY.mas_equalTo(ws.leftButton);
            make.size.mas_equalTo(CGSizeMake(ws.view.frame.size.width * 0.5, CCGetRealFromPt(30)));
        }];

        [_gongGaoBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.daohangView).offset(-CCGetRealFromPt(35));
            make.bottom.mas_equalTo(ws.leftLabel.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(67), CCGetRealFromPt(38)));
        }];
        
        [_qingXiDuBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.gongGaoBtn.mas_left).offset(-CCGetRealFromPt(52));
            make.bottom.mas_equalTo(ws.gongGaoBtn);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(86), CCGetRealFromPt(28)));
        }];
        
        [_barImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.and.bottom.and.left.mas_equalTo(ws.videoView);
            make.height.mas_equalTo(CCGetRealFromPt(60));
        }];
        
        [_userCountLogo removeFromSuperview];
        _userCountLogo = nil;
        [_barImageView addSubview:self.userCountLogo];
        [_userCountLogo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.barImageView).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.barImageView).offset(-CCGetRealFromPt(12));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(36), CCGetRealFromPt(36)));
        }];
        
        [_userCountLabel removeFromSuperview];
        _userCountLabel = nil;
        [_barImageView addSubview:self.userCountLabel];
        [_userCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.userCountLogo.mas_right).offset(CCGetRealFromPt(6));
            make.centerY.mas_equalTo(ws.userCountLogo);
            make.height.mas_equalTo(ws.userCountLogo);
            make.width.mas_equalTo(300);
        }];
        
        [_lianmaiBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.videoView).offset(CCGetRealFromPt(28));
            make.top.mas_equalTo(ws.daohangView.mas_bottom).offset(CCGetRealFromPt(68));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(70), CCGetRealFromPt(70)));
        }];
        
        [_selectRoadBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.lianmaiBtn);
            make.top.mas_equalTo(ws.lianmaiBtn.mas_bottom).offset(CCGetRealFromPt(20));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(70),CCGetRealFromPt(70)));
        }];
        
        [_soundVideoBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.videoView).offset(-CCGetRealFromPt(28));
            make.top.mas_equalTo(ws.daohangView.mas_bottom).offset(CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(70),CCGetRealFromPt(70)));
        }];
        
        [_mainRoad mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.selectRoadBtn.mas_right).offset(CCGetRealFromPt(14));
            make.top.mas_equalTo(ws.selectRoadBtn);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(190), CCGetRealFromPt(70)));
        }];

        [_secondRoad mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.mainRoad);
            make.top.mas_equalTo(ws.mainRoad.mas_bottom);
            make.size.mas_equalTo(ws.mainRoad);
        }];

//        [_thirdRoad mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(ws.mainRoad);
//            make.top.mas_equalTo(ws.secondRoad.mas_bottom);
//            make.size.mas_equalTo(ws.mainRoad);
//        }];
        
        [_hideDanMuBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.soundVideoBtn);
            make.top.mas_equalTo(ws.soundVideoBtn.mas_bottom).offset(CCGetRealFromPt(20));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(70),CCGetRealFromPt(70)));
        }];
        
        [_quanPingBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.hideDanMuBtn);
            make.top.mas_equalTo(ws.hideDanMuBtn.mas_bottom).offset(CCGetRealFromPt(20));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(70),CCGetRealFromPt(70)));
        }];
        
        [_soundBg mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.videoView);
            make.top.mas_equalTo(ws.daohangView.mas_bottom).offset(CCGetRealFromPt(30));
            make.height.mas_equalTo(CCGetRealFromPt(220));
        }];
        
        [_soundLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.soundBg.mas_bottom).offset(CCGetRealFromPt(20));
            make.centerX.mas_equalTo(ws.videoView);
            make.size.mas_equalTo(CGSizeMake(300, CCGetRealFromPt(32)));
        }];
        
        if(_lianMaiView) {
            _lianMaiView.frame = CGRectMake(CCGetRealFromPt(114), CCGetRealFromPt(176),_lianMaiView.frame.size.width,_lianMaiView.frame.size.height);
        }
        
        self.yuanHuaBtn.hidden = YES;
        self.qingXiBtn.hidden = YES;
        self.liuChangBtn.hidden = YES;
        self.qingXiDuBtn.hidden = YES;
        self.contentView.hidden = YES;
        self.hideDanMuBtn.hidden = NO;
        self.quanPingBtn.hidden = NO;
        self.mainRoad.hidden = YES;
        self.secondRoad.hidden = YES;
//        self.thirdRoad.hidden = YES;
        
        [UIView animateWithDuration:0.25f animations:^{
            [ws.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }

    self.autoRotate = NO;
}

-(void)removeInformationViewPop {
    [_informationViewPop removeFromSuperview];
    _informationViewPop = nil;
}

-(void)lianmaiBtnClicked {
    if(!_isAllow) {
        [_informationViewPop removeFromSuperview];
        _informationViewPop = [[InformationShowView alloc] initWithLabel:@"主播未开启连麦功能"];
        [self.view addSubview:_informationViewPop];
        [_informationViewPop mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationViewPop) userInfo:nil repeats:NO];
        
        [_lianMaiView removeFromSuperview];
        _lianMaiView = nil;
        return;
    }
    
    if(_yuanHuaBtn.hidden == NO) {
        _yuanHuaBtn.hidden = YES;
        _qingXiBtn.hidden = YES;
        _liuChangBtn.hidden = YES;
    } else if(_mainRoad.hidden == NO) {
        _mainRoad.hidden = YES;
        _secondRoad.hidden = YES;
//        _thirdRoad.hidden = YES;
    }

    self.hiddenTime = 5.0f;
    if(!_lianMaiView) {
        [self.videoView addSubview:self.lianMaiView];
        
        WS(ws)
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
                [ws judgeLianMaiLocationWithVideoPermission:statusVideo AudioPermission:statusAudio];
                [ws.lianMaiView initUIWithVideoPermission:statusVideo AudioPermission:statusAudio];
            });
        }];
    } else if(_lianMaiView && _lianMaiView.hidden == NO && _lianMaiView.needToRemoveLianMaiView == YES) {
        [_lianMaiView removeFromSuperview];
        _lianMaiView = nil;
    } else {
        BOOL hidden = self.lianMaiView.hidden;
        self.lianMaiView.hidden = !hidden;
        
        if([_lianMaiView isConnecting]) {
            _lianmaiBtn.selected = _lianMaiView.hidden;
        }
    }
}

-(void)judgeLianMaiLocationWithVideoPermission:(AVAuthorizationStatus)statusVideo AudioPermission:(AVAuthorizationStatus)statusAudio {

    if(_isScreenLandScape) {
        if (statusVideo == AVAuthorizationStatusAuthorized && statusAudio == AVAuthorizationStatusAuthorized) {
            _lianMaiView.frame = CGRectMake(CCGetRealFromPt(114), CCGetRealFromPt(270), CCGetRealFromPt(330), CCGetRealFromPt(210));
        } else {
            _lianMaiView.frame = CGRectMake(CCGetRealFromPt(114), CCGetRealFromPt(270), CCGetRealFromPt(390), CCGetRealFromPt(280));
        }
    } else {
        if (statusVideo == AVAuthorizationStatusAuthorized && statusAudio == AVAuthorizationStatusAuthorized) {
//        if(1) {
        _lianMaiView.frame = CGRectMake(CCGetRealFromPt(114), CCGetRealFromPt(176), CCGetRealFromPt(330), CCGetRealFromPt(210));
        } else {
            _lianMaiView.frame = CGRectMake(CCGetRealFromPt(114), CCGetRealFromPt(176), CCGetRealFromPt(390), CCGetRealFromPt(280));
        }
    }
}

-(void)initUI {
    if(!self.isScreenLandScape) {
        WS(ws)
        //直播
        [self.view addSubview:self.videoView];
        _videoRect = CGRectMake(0, 0, self.view.frame.size.width, CCGetRealFromPt(462));
        [self.videoView setFrame:_videoRect];
        //导航
        [self.videoView addSubview:self.daohangView];
        [_daohangView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.mas_equalTo(ws.view);
            make.height.mas_equalTo(CCGetRealFromPt(108));
        }];
        //返回按钮
        [self.daohangView addSubview:self.leftButton];
        [_leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.daohangView).offset(10);
            make.bottom.mas_equalTo(ws.daohangView);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80), CCGetRealFromPt(80)));
        }];
        
        [self.daohangView addSubview:self.leftLabel];
        [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.leftButton.mas_right);//.offset(CCGetRealFromPt(10));
            make.centerY.mas_equalTo(ws.leftButton);
            make.size.mas_equalTo(CGSizeMake(ws.view.frame.size.width * 0.5, CCGetRealFromPt(30)));
        }];
        //公告
        [self.daohangView addSubview:self.gongGaoBtn];
        [_gongGaoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.daohangView).offset(-CCGetRealFromPt(35));
            make.bottom.mas_equalTo(ws.leftLabel.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(67), CCGetRealFromPt(38)));
        }];
        //清晰度
        [self.daohangView addSubview:self.qingXiDuBtn];
        [_qingXiDuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.gongGaoBtn.mas_left).offset(-CCGetRealFromPt(52));
            make.bottom.mas_equalTo(ws.gongGaoBtn);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(86), CCGetRealFromPt(28)));
        }];
        self.qingXiDuBtn.hidden = YES;
        //直播中图片
        [self.videoView addSubview:self.zhibozhongImage];
        [_zhibozhongImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.daohangView).mas_offset(-CCGetRealFromPt(30));
            make.centerY.mas_equalTo(ws.leftButton);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(115), CCGetRealFromPt(52)));
        }];
        self.newGongGao = NO;
        self.zhibozhongImage.hidden = YES;
        //原画
        [self.videoView addSubview:self.yuanHuaBtn];
        [_yuanHuaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ws.qingXiDuBtn);
            make.top.mas_equalTo(ws.qingXiDuBtn.mas_bottom).offset(10);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(166),CCGetRealFromPt(80)));
        }];
        _yuanHuaBtn.selected = YES;
        self.yuanHuaBtn.hidden = YES;
        //清晰
        [self.videoView addSubview:self.qingXiBtn];
        [_qingXiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ws.yuanHuaBtn);
            make.top.mas_equalTo(ws.yuanHuaBtn.mas_bottom);
            make.size.mas_equalTo(ws.yuanHuaBtn);
        }];
        self.qingXiBtn.hidden = YES;
        //流畅
        [self.videoView addSubview:self.liuChangBtn];
        [_liuChangBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ws.qingXiBtn);
            make.top.mas_equalTo(ws.qingXiBtn.mas_bottom);
            make.size.mas_equalTo(ws.qingXiBtn);
        }];
        self.liuChangBtn.hidden = YES;
        
        [self.videoView addSubview:self.barImageView];
        [_barImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.and.bottom.and.left.mas_equalTo(ws.videoView);
            make.height.mas_equalTo(CCGetRealFromPt(60));
        }];
        //用户人数图片
        [self.barImageView addSubview:self.userCountLogo];
        [_userCountLogo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.barImageView).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.barImageView).offset(-CCGetRealFromPt(12));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(36), CCGetRealFromPt(36)));
        }];
        //用户人数
        [self.barImageView addSubview:self.userCountLabel];
        [_userCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.userCountLogo.mas_right).offset(CCGetRealFromPt(6));
            make.centerY.mas_equalTo(ws.userCountLogo);
            make.height.mas_equalTo(ws.userCountLogo);
            make.width.mas_equalTo(300);
        }];
        //连麦按钮
        [self.videoView addSubview:self.lianmaiBtn];
        [_lianmaiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.videoView).offset(CCGetRealFromPt(28));
            make.top.mas_equalTo(ws.daohangView.mas_bottom).offset(CCGetRealFromPt(68));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(70), CCGetRealFromPt(70)));
        }];
        //线路选择
        [self.videoView addSubview:self.selectRoadBtn];
        [_selectRoadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.lianmaiBtn);
            make.top.mas_equalTo(ws.lianmaiBtn.mas_bottom).offset(CCGetRealFromPt(20));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(70),CCGetRealFromPt(70)));
        }];
        //声频按钮
        [self.videoView addSubview:self.soundVideoBtn];
        [_soundVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.videoView).offset(-CCGetRealFromPt(28));
            make.top.mas_equalTo(ws.daohangView.mas_bottom).offset(CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(70),CCGetRealFromPt(70)));
        }];
        //主线路
        [self.videoView addSubview:self.mainRoad];
        [_mainRoad mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.selectRoadBtn.mas_right).offset(CCGetRealFromPt(14));
            make.top.mas_equalTo(ws.selectRoadBtn);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(190), CCGetRealFromPt(70)));
        }];
        _mainRoad.hidden = YES;
        UIImageView *imageRight1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_btn_select"]];
        imageRight1.contentMode = UIViewContentModeScaleAspectFit;
        imageRight1.tag = 1;
        [self.mainRoad addSubview:imageRight1];
        [imageRight1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.mainRoad).offset(-CCGetRealFromPt(20));
            make.centerY.mas_equalTo(ws.mainRoad);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(31), CCGetRealFromPt(22)));
        }];
        //备用线路一
        [self.videoView addSubview:self.secondRoad];
        [_secondRoad mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.mainRoad);
            make.top.mas_equalTo(ws.mainRoad.mas_bottom);
            make.size.mas_equalTo(ws.mainRoad);
        }];
        
        UIImageView *imageRight2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_btn_select"]];
        imageRight2.contentMode = UIViewContentModeScaleAspectFit;
        imageRight2.tag = 1;
        [self.secondRoad addSubview:imageRight2];
        [imageRight2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.secondRoad).offset(-CCGetRealFromPt(20));
            make.centerY.mas_equalTo(ws.secondRoad);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(31), CCGetRealFromPt(22)));
        }];
        imageRight2.hidden = YES;
        _secondRoad.hidden = YES;
        //弹幕开关
        [self.videoView addSubview:self.hideDanMuBtn];
        [_hideDanMuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.soundVideoBtn);
            make.top.mas_equalTo(ws.soundVideoBtn.mas_bottom).offset(CCGetRealFromPt(20));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(70),CCGetRealFromPt(70)));
        }];
        //全屏
        [self.videoView addSubview:self.quanPingBtn];
        [_quanPingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.hideDanMuBtn);
            make.top.mas_equalTo(ws.hideDanMuBtn.mas_bottom).offset(CCGetRealFromPt(20));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(70),CCGetRealFromPt(70)));
        }];
        //声频背景
        [self.videoView addSubview:self.soundBg];
        [_soundBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.videoView);
            make.top.mas_equalTo(ws.daohangView.mas_bottom).offset(CCGetRealFromPt(30));
            make.height.mas_equalTo(CCGetRealFromPt(220));
        }];
        //声音背景
        [self.videoView addSubview:self.soundLabel];
        [_soundLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.soundBg.mas_bottom).offset(CCGetRealFromPt(20));
            make.centerX.mas_equalTo(ws.videoView);
            make.size.mas_equalTo(CGSizeMake(300, CCGetRealFromPt(32)));
        }];
        self.soundBg.hidden = YES;
        self.soundLabel.hidden = YES;
        
        [self.daohangView addSubview:self.gongGaoDot];
        [_gongGaoDot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.gongGaoBtn.mas_right);
            make.top.mas_equalTo(ws.gongGaoBtn);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(12), CCGetRealFromPt(12)));
        }];
        self.newGongGao = NO;
        _gongGaoDot.hidden = !self.newGongGao;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleTap:)];
        [self.videoView addGestureRecognizer:singleTap];
        
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
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 4, _scrollView.frame.size.height);
        _scrollView.showsHorizontalScrollIndicator = NO;
    
        

        [self.view addSubview:self.scrollView];
        
        //ppt文档
        [_scrollView addSubview:self.pptView];
        self.pptView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"document_bg"]];
//        [self.pptView addSubview:imageView];
//        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(ws.pptView).offset(CCGetRealFromPt(180));
//            make.centerX.mas_equalTo(ws.pptView);
//            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(140), CCGetRealFromPt(131)));
//        }];
//        
//        UILabel *noTextLabel = [UILabel new];
//        noTextLabel.font = [UIFont systemFontOfSize:FontSize_28];
//        noTextLabel.textAlignment = NSTextAlignmentCenter;
//        noTextLabel.textColor = CCRGBColor(153,153,153);
//        noTextLabel.text = @"暂无文档";
//        [self.pptView addSubview:noTextLabel];
//        [noTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(imageView.mas_bottom).offset(CCGetRealFromPt(30));
//            make.centerX.mas_equalTo(ws.pptView);
//            make.height.mas_equalTo(CCGetRealFromPt(28));
//            make.width.mas_equalTo(imageView);
//        }];
        
        self.hideTextBoardTap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleInformationTap)];
        UITapGestureRecognizer *hideTextBoardTap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleInformationTap)];
        //聊天
        [_scrollView addSubview:self.chatView];
        self.chatView.frame = CGRectMake(_scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        [_chatView addGestureRecognizer:self.hideTextBoardTap1];
        //问答
        [_scrollView addSubview:self.questionChatView];
        self.questionChatView.frame = CGRectMake(_scrollView.frame.size.width * 2, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        [_questionChatView addGestureRecognizer:hideTextBoardTap2];
        //简介
        [_scrollView addSubview:self.introductionView];
        self.introductionView.frame = CGRectMake(_scrollView.frame.size.width * 3, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        
        [self.view bringSubviewToFront:self.videoView];
        
        [self.videoView addSubview:self.contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.mas_equalTo(ws.view);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];
        self.contentView.hidden = YES;
        
        [self.contentView addSubview:self.danMuButton];
        [_danMuButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.left.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(90), CCGetRealFromPt(50)));
        }];
        
        [self.contentView addSubview:self.chatTextField];
        [_chatTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.left.mas_equalTo(ws.danMuButton.mas_right).offset(CCGetRealFromPt(22));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(1024), CCGetRealFromPt(84)));
        }];
        
        [self.contentView addSubview:self.sendButton];
        [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.left.mas_equalTo(ws.chatTextField.mas_right).offset(CCGetRealFromPt(20));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(120), CCGetRealFromPt(84)));
        }];
    }
    [self.view layoutIfNeeded];
}
/**
 *    @brief     双击ppt(The new method)
 */
- (void)doubleCllickPPTView {
    [self dealPPTViewDoubleTap];
}

-(UIView *)pptView {
    if(!_pptView) {
        _pptView = [UIView new];
        _pptView.backgroundColor = CCRGBColor(250,250,250);
    }
    return _pptView;
}

-(ChatView *)chatView {
    WS(ws)
    if(!_chatView) {
        _chatView = [[ChatView alloc] initWithPublicChatBlock:^(NSString *msg) {
// 发送公聊信息
            [ws.requestData chatMessage:msg];
            NSArray * arr = @[@"唐僧",@"孙悟空",@"猪八戒",@"沙僧"];
            int r = arc4random() % [arr count];
            [ws.requestData changeNickName:arr[r]];
        } PrivateChatBlock:^(NSString *anteid, NSString *msg) {
// 发送私聊信息
            [ws.requestData privateChatWithTouserid:anteid msg:msg];
        } input:YES];
        _chatView.backgroundColor = CCRGBColor(250,250,250);
    }
    return _chatView;
}

-(QuestionView *)questionChatView {
    WS(ws)
    if(!_questionChatView) {
        _questionChatView = [[QuestionView alloc] initWithQuestionBlock:^(NSString *message) {
            [ws question:message];
        } input:YES];
        _questionChatView.backgroundColor = CCRGBColor(250,250,250);
    }
    return _questionChatView;
}

-(UIView *)introductionView {
    if(!_introductionView) {
        _introductionView = [UIView new];
        _introductionView.backgroundColor = CCRGBColor(250,250,250);
    }
    return _introductionView;
}

-(UIButton *)hideDanMuBtn {
    if(!_hideDanMuBtn) {
        _hideDanMuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hideDanMuBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_hideDanMuBtn setBackgroundImage:[UIImage imageNamed:@"video_ic_barrage_nor"] forState:UIControlStateNormal];
        [_hideDanMuBtn setBackgroundImage:[UIImage imageNamed:@"video_ic_barrage_ban"] forState:UIControlStateSelected];
        [_hideDanMuBtn addTarget:self action:@selector(hideDanMuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hideDanMuBtn;
}

-(UIButton *)danMuButton {
    if(!_danMuButton) {
        _danMuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_danMuButton setBackgroundImage:[UIImage imageNamed:@"video_btn_word_on"] forState:UIControlStateNormal];
        [_danMuButton setBackgroundImage:[UIImage imageNamed:@"video_btn_word_off"] forState:UIControlStateSelected];
        [_danMuButton addTarget:self action:@selector(hideDanMuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _danMuButton;
}

//弹幕开关
-(void)hideDanMuBtnClicked {
    
    if([self hasViewOnTheScreen:NO]) return;
    
    _hiddenTime = 5.0f;
    BOOL selected = _danMuButton.selected;
    _danMuButton.selected = !selected;
    _hideDanMuBtn.selected = !selected;
//    NSLog(@"selected = %d",selected);
}

//退出直播
-(void)sureBtnClicked {
//    dispatch_async(dispatch_get_main_queue(), ^{
        [self hiddenAllBtns];
        [self removeObserver];
        [self stopTimer];
        [self stopHiddenTimer];
        [self stopDanMuTimer];
// 销毁文档和视频，清除视频和文档的时候需要调用,推出播放页面的时候也需要调用
        [_requestData requestCancel];
        _requestData = nil;
        [_modelView removeFromSuperview];
        _modelView = nil;
        [_voteViewResult removeFromSuperview];
        _voteViewResult = nil;
        [_voteView removeFromSuperview];
        _voteView = nil;
        [_lotteryView removeFromSuperview];
        _lotteryView = nil;
        [_questionnaireSurvey removeFromSuperview];
        _questionnaireSurvey = nil;
    [_questionnaireSurveyPopUp removeFromSuperview];
    _questionnaireSurveyPopUp = nil;
        [_rollcallView removeFromSuperview];
        _rollcallView = nil;
        [self dismissViewControllerAnimated:YES completion:^ {
        }];
//    });
}

-(void) stopTimer {
    if([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)startTimer {
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerfunc) userInfo:nil repeats:YES];
}

-(void)cancelBtnClicked {
    [_modelView removeFromSuperview];
    _modelView = nil;
}

- (void)timerfunc {
// (已废弃)获取在线房间人数，当登录成功后即可调用此接口，登录不成功或者退出登录后就不可以调用了，如果要求实时性比较强的话，可以写一个定时器，不断调用此接口，几秒钟发一次就可以，然后在代理回调函数中，处理返回的数据
    //最新注释:该接口默认最短响应时间为15秒,获取在线房间人数，当登录成功后即可调用此接口，登录不成功或者退出登录后就不可以调用了，如果要求实时性比较强的话，可以写一个定时器，不断调用此接口，然后在代理回调函数中，处理返回的数据
    [_requestData roomUserCount];
}

-(UILabel *)modeoCenterLabel {
    if(!_modeoCenterLabel) {
        _modeoCenterLabel = [UILabel new];
        _modeoCenterLabel.font = [UIFont systemFontOfSize:FontSize_30];
        _modeoCenterLabel.textAlignment = NSTextAlignmentCenter;
        _modeoCenterLabel.textColor = CCRGBColor(51,51,51);
        _modeoCenterLabel.text = @"您确认结束观看直播吗？";
    }
    return _modeoCenterLabel;
}

-(NSDictionary *)dataPrivateDic {
    if(!_dataPrivateDic) {
        _dataPrivateDic = [[NSMutableDictionary alloc] init];
    }
    return _dataPrivateDic;
}

-(CGSize)getTitleSizeByFont:(NSString *)str font:(UIFont *)font {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(20000.0f, 20000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return size;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    _currentRoadNum = 0;
    _currentSecRoadNum = 0;
    _isKeyBoardShow = NO;
    _isAllow = NO;
    _autoRotate = NO;   
    _roomUserCount = @"1";
    //页面
    [self initUI];
    //通知
    [self addObserver];
    //开启弹幕
    [self startDanMuTimer];
    //清屏
    [self startHiddenTimer];
    
    _secondToEnd = 8.0f;
    
    if(!self.isScreenLandScape) {
        _lineLimit = (CCGetRealFromPt(462) - 64) / (IMGWIDTH * 1.5);
    }

    PlayParameter *parameter = [[PlayParameter alloc] init];
    parameter.userId = GetFromUserDefaults(WATCH_USERID);
    parameter.roomId = GetFromUserDefaults(WATCH_ROOMID);
    parameter.viewerName = GetFromUserDefaults(WATCH_USERNAME);
    parameter.token = GetFromUserDefaults(WATCH_PASSWORD);
    parameter.docParent = self.pptView;
    parameter.docFrame = self.pptView.frame;
    parameter.playerParent = self.videoView;
    parameter.playerFrame = _videoRect;
    parameter.security = NO;
    parameter.PPTScalingMode = 4;
    parameter.defaultColor = [UIColor whiteColor];
    parameter.scalingMode = 1;
    parameter.pauseInBackGround = NO;
    parameter.viewerCustomua = @"viewercustomua";
    _requestData = [[RequestData alloc] initWithParameter:parameter];
    _requestData.delegate = self;
    
    _loadingView = [[LoadingView alloc] initWithLabel:@"视频加载中" centerY:YES];
    [self.videoView addSubview:_loadingView];

    UITapGestureRecognizer *hideTextBoardTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleInformationTap)];
    [_loadingView addGestureRecognizer:hideTextBoardTap];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(50, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
    
//    UIButton * surebtn = [[UIButton alloc] init];
//    [surebtn setBackgroundColor:[UIColor redColor]];
//    surebtn.frame = CGRectMake(50, 30, 50, 50);
//    [surebtn addTarget:self action:@selector(banroom:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:surebtn];
//
//    UIButton * canclebtn = [[UIButton alloc] init];
//    [canclebtn setBackgroundColor:[UIColor greenColor]];
//    canclebtn.frame = CGRectMake(100, 30, 50, 50);
//    [canclebtn addTarget:self action:@selector(unbanroom:) forControlEvents:UIControlEventTouchUpInside];
//
//    [self.view addSubview:canclebtn];
}


//直播间被封
- (void)theRoomWasBanned {
    [self loadInformationView:@"该直播间已封禁"];

}
//直播间解禁
- (void)theRoomWasCleared {
    
}
//翻页数据
- (void)onPageChange:(NSDictionary *) dictionary {
    
//    NSLog(@"翻页数据%@",dictionary);
}
//最后一条广播
- (void)broadcastLast_msg:(NSArray *)array {
//    NSLog(@"最后一条广播%@",array);
    
}
//获取开播时间
- (void)startTimeAndDurationLiveBroadcast:(NSDictionary *)dataDic{
    //    NSLog(@"开播时间%@",dataDic);
}
//点击公告
- (void)dealSingleTap:(UITapGestureRecognizer *)tap {
    [self.view endEditing:YES];
    CGPoint point = [tap locationInView:self.view];
    if(!_isScreenLandScape) {
//        if(_daohangView.hidden == NO && CGRectContainsPoint(_daohangView.frame, point)) {
//            return;
//        } else
            if (_barImageView.hidden == NO && CGRectContainsPoint(_barImageView.frame, point)) {
            return;
        } else if (_lianMaiView && _lianMaiView.hidden == NO && CGRectContainsPoint(_lianMaiView.frame, point)) {
            return;
        } else if(_gongGaoView) {
            return;
        } else if([self hasViewOnTheScreen:YES]) {
            return;
        }
        
        if(self.daohangView.hidden == YES) {
            self.hiddenTime = 5.0f;
            [self showAll];
        } else {
            self.hiddenTime = 0.0f;
            [self hiddenAllBtns];
        }
    } else {
//        if(_daohangView.hidden == NO && CGRectContainsPoint(_daohangView.frame, point)) {
//            return;
//        } else
            if (_lianMaiView && _lianMaiView.hidden == NO && CGRectContainsPoint(_lianMaiView.frame, point)) {
            return;
        } else if(_gongGaoView) {
            return;
        } else if([self hasViewOnTheScreen:YES]) {
            return;
        }
        
        if([_chatTextField isFirstResponder] || self.daohangView.hidden) {
            [_chatTextField resignFirstResponder];
            
            self.hiddenTime = 5.0f;
            [self showAll];
        } else {
            self.hiddenTime = 0.0f;
            [self hiddenAllBtns];
        }
    }
}

-(UIImageView *)soundBg {
    if(!_soundBg) {
        _soundBg = [[UIImageView alloc] init];
        _soundBg.image = [UIImage imageNamed:@"video_img_sound"];
        _soundBg.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _soundBg;
}

-(UIImageView *)daohangView {
    if(!_daohangView) {
        _daohangView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"daohang"]];
        _daohangView.userInteractionEnabled = YES;
        _daohangView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _daohangView;
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
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_back_nor"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_leftButton setImage:image forState:UIControlStateNormal];
        _leftButton.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _leftButton;
}

-(CGSize)getTitleSizeByFont:(NSString *)str width:(CGFloat)width font:(UIFont *)font {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, 20000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return size;
}

- (UIImage*)createImageWithColor: (UIColor*) color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(UIImageView *)userCountLogo {
    if(!_userCountLogo) {
        _userCountLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_dis_people"]];
        _userCountLogo.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _userCountLogo;
}

-(UIButton *)gongGaoBtn {
    if(!_gongGaoBtn) {
        _gongGaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if(self.isScreenLandScape) {
            _gongGaoBtn.layer.backgroundColor = [CCRGBAColor(0, 0, 0, 0.3) CGColor];
        } else {
            [_gongGaoBtn setTitle:@"公告" forState:UIControlStateNormal];
            [_gongGaoBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_28]];
            [_gongGaoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_gongGaoBtn setBackgroundColor:CCClearColor];
        }
        [_gongGaoBtn addTarget:self action:@selector(gongGaoAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _gongGaoBtn;
}

-(UIImageView *)gongGaoDot {
    if(!_gongGaoDot) {
        _gongGaoDot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_btn_msg"]];
        _gongGaoDot.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _gongGaoDot;
}

-(UILabel *)soundLabel {
    if(!_soundLabel) {
        _soundLabel = [UILabel new];
        _soundLabel.backgroundColor = CCClearColor;
        _soundLabel.textColor = CCRGBAColor(255,255,255,0.5);
        _soundLabel.textAlignment = NSTextAlignmentCenter;
        _soundLabel.font = [UIFont systemFontOfSize:FontSize_32];
        _soundLabel.text = @"音频模式";
    }
    return _soundLabel;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                  selector:@selector(movieLoadStateDidChange:)
                                                      name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                    object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieNaturalSizeAvailableNotification:) name:IJKMPMovieNaturalSizeAvailableNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeLotteryView:)
                                                 name:@"remove_lotteryView"
                                               object:nil];
}

- (void)removeLotteryView:(NSNotification*) notification
{
    NSDictionary *dic = [notification object];
    NSInteger tag = [dic[@"tag"] integerValue];
    LotteryView *lotteryView = [APPDelegate.window viewWithTag:tag];
    [lotteryView removeFromSuperview];
    lotteryView = nil;
}

-(void)movieNaturalSizeAvailableNotification:(NSNotification *)notification {
//    NSLog(@"player.naturalSize = %@",NSStringFromCGSize(_requestData.ijkPlayer.naturalSize));
}

-(void)play_loadVideoFail {
    [self loadInformationView:@"视频加载失败"];
}

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
            [_informationView removeFromSuperview];
            _informationView = nil;
            
            [[SaveLogUtil sharedInstance] saveLog:@"" action:@"视频加载成功或开始播放，多次调用，不必关心"];
            
            break;
        }
        case IJKMPMoviePlaybackStatePaused:{
//            [_loadingView removeFromSuperview];
//            _loadingView = nil;
//            [_informationView removeFromSuperview];
//            _informationView = nil;
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

- (void)appWillEnterBackgroundNotification {
    _needReloadLianMainView = NO;
    self.lianMaiHidden = NO;
    if(_lianMaiView) {
        _needReloadLianMainView = YES;
        self.lianMaiHidden = _lianMaiView.hidden;
        [_lianMaiView removeFromSuperview];
        _lianMaiView = nil;
    }
}

- (void)appWillEnterForegroundNotification {
    if(_needReloadLianMainView == YES) {
        
        if(_lianMaiView) {
            self.lianMaiHidden = _lianMaiView.hidden;
            [_lianMaiView removeFromSuperview];
            _lianMaiView = nil;
        }
        [self showAll];
        [self.videoView addSubview:self.lianMaiView];
        _lianMaiView.hidden = self.lianMaiHidden;
        
        AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        
        [self judgeLianMaiLocationWithVideoPermission:statusVideo AudioPermission:statusAudio];
        
        [_lianMaiView initUIWithVideoPermission:statusVideo AudioPermission:statusAudio];
    }
}

#pragma mark keyboard notification
- (void)keyboardWillShow:(NSNotification *)notif {
    if(![self.chatTextField isFirstResponder]) {
        return;
    }
    self.hideTextBoardTap1.enabled = YES;
    NSDictionary *userInfo = [notif userInfo];
    _isKeyBoardShow = YES;
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardRect = [aValue CGRectValue];
    CGFloat y = _keyboardRect.size.height;
//    CGFloat x = _keyboardRect.size.width;
//    NSLog(@"键盘高度是  %d",(int)y);
//    NSLog(@"键盘宽度是  %d",(int)x);

    if ([self.chatTextField isFirstResponder]) {
        WS(ws)
        [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.bottom.mas_equalTo(ws.view).offset(-y);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];
        
        [UIView animateWithDuration:0.25f animations:^{
            [ws.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    WS(ws)
    self.hideTextBoardTap1.enabled = NO;
    _isKeyBoardShow = NO;
    [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(110));
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        [ws.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IJKMPMovieNaturalSizeAvailableNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"remove_lotteryView"
                                                  object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self chatSendMessage];
    return YES;
}

-(void)chatSendMessage {
    NSString *str = _chatTextField.text;
    if(str == nil || str.length == 0 || !_isScreenLandScape) {
        return;
    }
// 发送公聊信息
    [_requestData chatMessage:str];
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
}

-(UIView *)contentView {
    if(!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = CCRGBAColor(171,179,189,0.30);
    }
    return _contentView;
}

-(CustomTextField *)chatTextField {
    if(!_chatTextField) {
        _chatTextField = [CustomTextField new];
        _chatTextField.delegate = self;
        [_chatTextField addTarget:self action:@selector(chatTextFieldChange) forControlEvents:UIControlEventEditingChanged];
        _chatTextField.rightView = self.rightView;
    }
    return _chatTextField;
}

-(void)chatTextFieldChange {
    if(_chatTextField.text.length > 300) {
//        [self.view endEditing:YES];
        _chatTextField.text = [_chatTextField.text substringToIndex:300];
        [_informationViewPop removeFromSuperview];
        _informationViewPop = [[InformationShowView alloc] initWithLabel:@"输入限制在300个字符以内"];
        [APPDelegate.window addSubview:_informationViewPop];
        [_informationViewPop mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationViewPop) userInfo:nil repeats:NO];
    }
}

-(UIButton *)rightView {
    if(!_rightView) {
        _rightView = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightView.frame = CGRectMake(0, 0, CCGetRealFromPt(48), CCGetRealFromPt(48));
        _rightView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightView.backgroundColor = CCClearColor;
        [_rightView setImage:[UIImage imageNamed:@"chat_ic_face_nor"] forState:UIControlStateNormal];
        [_rightView setImage:[UIImage imageNamed:@"chat_ic_face_hov"] forState:UIControlStateSelected];
        [_rightView addTarget:self action:@selector(faceBoardClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightView;
}

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

-(UIButton *)sendButton {
    if(!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.backgroundColor = CCRGBColor(255,102,51);
        _sendButton.layer.cornerRadius = CCGetRealFromPt(4);
        _sendButton.layer.masksToBounds = YES;
        _sendButton.layer.borderColor = [CCRGBColor(255,71,0) CGColor];
        _sendButton.layer.borderWidth = 1;
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:CCRGBColor(255,255,255) forState:UIControlStateNormal];
        [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
        [_sendButton addTarget:self action:@selector(sendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

-(void)sendBtnClicked {
    if(!StrNotEmpty([_chatTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]])) {
        [_informationViewPop removeFromSuperview];
        _informationViewPop = [[InformationShowView alloc] initWithLabel:@"发送内容为空"];
        [APPDelegate.window addSubview:_informationViewPop];
        [_informationViewPop mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationViewPop) userInfo:nil repeats:NO];
        return;
    }
    [self chatSendMessage];
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
}

-(UIButton *)soundVideoBtn {
    if(!_soundVideoBtn) {
        _soundVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_soundVideoBtn setBackgroundImage:[UIImage imageNamed:@"video_ic_live_nor"] forState:UIControlStateNormal];
        [_soundVideoBtn setBackgroundImage:[UIImage imageNamed:@"video_ic_live_hov"] forState:UIControlStateSelected];
        [_soundVideoBtn addTarget:self action:@selector(soundVideoBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _soundVideoBtn;
}

-(UIButton *)selectRoadBtn {
    if(!_selectRoadBtn) {
        _selectRoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectRoadBtn setBackgroundImage:[UIImage imageNamed:@"video_ic_line"] forState:UIControlStateNormal];
        [_selectRoadBtn addTarget:self action:@selector(selectRoadBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectRoadBtn;
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

/**
 *	@brief	收到在线人数
 */
- (void)onUserCount:(NSString *)count {
    WS(ws)
    _roomUserCount = count;
    dispatch_async(dispatch_get_main_queue(), ^{
        ws.userCountLabel.text = [NSString stringWithFormat:@"%@",count];
    });
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
//    NSLog(@"请求成功！");
    [self startTimer];
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
//    [_loadingView removeFromSuperview];
//    _loadingView = nil;
    [_informationViewPop removeFromSuperview];
    
    _informationViewPop = [[InformationShowView alloc] initWithLabel:message];
    [self.view addSubview:_informationViewPop];
    [_informationViewPop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationViewPop) userInfo:nil repeats:NO];
}

-(UIButton *)mainRoad {
    if(!_mainRoad) {
        _mainRoad = [UIButton new];
        _mainRoad.backgroundColor = CCRGBAColor(0, 0, 0, 0.6);
        _mainRoad.layer.shadowOffset = CGSizeMake(0, 2);
        _mainRoad.layer.shadowColor = [CCRGBAColor(0,0,0,0.5) CGColor];
        
        [_mainRoad setTitleEdgeInsets:UIEdgeInsetsMake(CCGetPxFromPt(10),CCGetPxFromPt(19),0,0)];
        [_mainRoad setTitle:@"主线路" forState:UIControlStateNormal];
        [_mainRoad.titleLabel setFont:[UIFont systemFontOfSize:FontSize_26]];
        [_mainRoad setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _mainRoad.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_mainRoad addTarget:self action:@selector(mainRoadBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mainRoad;
}

-(UIButton *)secondRoad {
    if(!_secondRoad) {
        _secondRoad = [UIButton new];
        _secondRoad.backgroundColor = CCRGBAColor(0, 0, 0, 0.6);
        _secondRoad.layer.shadowOffset = CGSizeMake(0, 2);
        _secondRoad.layer.shadowColor = [CCRGBAColor(0,0,0,0.5) CGColor];
        [_secondRoad setTitleEdgeInsets:UIEdgeInsetsMake(0,CCGetPxFromPt(19),CCGetPxFromPt(10),0)];
        [_secondRoad setTitle:@"备用线路1" forState:UIControlStateNormal];
        [_secondRoad.titleLabel setFont:[UIFont systemFontOfSize:FontSize_26]];
        [_secondRoad setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _secondRoad.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_secondRoad addTarget:self action:@selector(secondRoadBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _secondRoad;
}


-(void)roadHide{
    _mainRoad.hidden = YES;
    _secondRoad.hidden = YES;
//    _thirdRoad.hidden = YES;
}

-(void)mainRoadBtnClicked {
    self.hiddenTime = 5;
    [NSTimer scheduledTimerWithTimeInterval:0.25f target:self selector:@selector(roadHide) userInfo:nil repeats:NO];

    if(_currentRoadNum == 0) {
        return;
    }
    _currentRoadNum = 0;
    
    UIImageView *imageView1 = [(UIImageView *)self.mainRoad viewWithTag:1];
    UIImageView *imageView2 = [(UIImageView *)self.secondRoad viewWithTag:1];
//    UIImageView *imageView3 = [(UIImageView *)self.thirdRoad viewWithTag:1];
    imageView1.hidden = NO;
    imageView2.hidden = YES;
//    imageView3.hidden = YES;
// 切换线路
    if(self.soundVideoBtn.selected) {
        [_requestData switchToPlayUrlWithFirIndex:_currentRoadNum key:@""];
    } else {
        [_requestData switchToPlayUrlWithFirIndex:_currentRoadNum key:[_secRoadKeyArray objectAtIndex:_currentSecRoadNum]];
    }
    
    [_informationView removeFromSuperview];
    _informationView = nil;
    _loadingView = [[LoadingView alloc] initWithLabel:@"视频加载中" centerY:YES];
    [self.videoView addSubview:_loadingView];
    UITapGestureRecognizer *hideTextBoardTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleInformationTap)];
    [_loadingView addGestureRecognizer:hideTextBoardTap];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(50, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
}

-(void)secondRoadBtnClicked {
    self.hiddenTime = 5;
    [NSTimer scheduledTimerWithTimeInterval:0.25f target:self selector:@selector(roadHide) userInfo:nil repeats:NO];
    if(_currentRoadNum == 1) {
        return;
    }
    _currentRoadNum = 1;
    
    UIImageView *imageView1 = [(UIImageView *)self.mainRoad viewWithTag:1];
    UIImageView *imageView2 = [(UIImageView *)self.secondRoad viewWithTag:1];
//    UIImageView *imageView3 = [(UIImageView *)self.thirdRoad viewWithTag:1];
    imageView1.hidden = YES;
    imageView2.hidden = NO;
//    imageView3.hidden = YES;
    if(self.soundVideoBtn.selected) {
        [_requestData switchToPlayUrlWithFirIndex:_currentRoadNum key:@""];
    } else {
        [_requestData switchToPlayUrlWithFirIndex:_currentRoadNum key:[_secRoadKeyArray objectAtIndex:_currentSecRoadNum]];
    }
    
    [_informationView removeFromSuperview];
    _informationView = nil;
    _loadingView = [[LoadingView alloc] initWithLabel:@"视频加载中" centerY:YES];
    [self.videoView addSubview:_loadingView];
    UITapGestureRecognizer *hideTextBoardTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleInformationTap)];
    [_loadingView addGestureRecognizer:hideTextBoardTap];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(50, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
}

-(void)thirdRoadBtnClicked {
    self.hiddenTime = 5;
    [NSTimer scheduledTimerWithTimeInterval:0.25f target:self selector:@selector(roadHide) userInfo:nil repeats:NO];
    if(_currentRoadNum == 2) {
        return;
    }
    _currentRoadNum = 2;
    
    UIImageView *imageView1 = [(UIImageView *)self.mainRoad viewWithTag:1];
    UIImageView *imageView2 = [(UIImageView *)self.secondRoad viewWithTag:1];
//    UIImageView *imageView3 = [(UIImageView *)self.thirdRoad viewWithTag:1];
    imageView1.hidden = YES;
    imageView2.hidden = YES;
//    imageView3.hidden = NO;
    if(self.soundVideoBtn.selected) {
        [_requestData switchToPlayUrlWithFirIndex:_currentRoadNum key:@""];
    } else {
        [_requestData switchToPlayUrlWithFirIndex:_currentRoadNum key:[_secRoadKeyArray objectAtIndex:_currentSecRoadNum]];
    }
    
    [_informationView removeFromSuperview];
    _informationView = nil;
    _loadingView = [[LoadingView alloc] initWithLabel:@"视频加载中" centerY:YES];
    [self.videoView addSubview:_loadingView];
    UITapGestureRecognizer *hideTextBoardTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleInformationTap)];
    [_loadingView addGestureRecognizer:hideTextBoardTap];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(50, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
}

-(void)gongGaoAction {
    
    self.hiddenTime = 5;
    
    if([self hasViewOnTheScreen:NO] || _loadingView) return;
    
    self.newGongGao = NO;
    [self hiddenAllBtns];
    WS(ws)
    [self.videoView addSubview:self.gongGaoView];
    if(self.isScreenLandScape) {
        [_gongGaoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.videoView);
        }];
    } else {
        [_gongGaoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.videoView);
        }];
    }
}

-(UIView *)gongGaoView {
    if(!_gongGaoView) {
        WS(ws)
        _gongGaoView = [[GongGaoView alloc] initWithLeftLabelText:_gongGaoStr isScreenLandScape:self.isScreenLandScape forPC:YES block:^{
            [ws.gongGaoView removeFromSuperview];
            ws.gongGaoView = nil;
            [ws showAll];
        }];
        _gongGaoView.userInteractionEnabled = YES;
    }
    return _gongGaoView;
}

-(void)selectRoadBtnClicked {
    self.hiddenTime = 5;
    
    if([self hasViewOnTheScreen:NO]) return;
    
    if(self.mainRoad.hidden) {
        _mainRoad.hidden = NO;
        _secondRoad.hidden = NO;
//        _thirdRoad.hidden = NO;
    } else {
        _mainRoad.hidden = YES;
        _secondRoad.hidden = YES;
//        _thirdRoad.hidden = YES;
    }
}

-(void)soundVideoBtnClicked {
    self.hiddenTime = 5;
    
    if([self hasViewOnTheScreen:NO]) return;
    
    BOOL selected = self.soundVideoBtn.selected;
    self.soundVideoBtn.selected = !selected;
//切换音视频
    if(self.soundVideoBtn.selected) {
        [_requestData switchToPlayUrlWithFirIndex:_currentRoadNum key:@""];
        self.soundBg.hidden = NO;
        self.soundLabel.hidden = NO;
    } else {
        self.soundBg.hidden = YES;
        self.soundLabel.hidden = YES;
        [_requestData switchToPlayUrlWithFirIndex:_currentRoadNum key:[_secRoadKeyArray objectAtIndex:_currentSecRoadNum]];
    }
}

-(void)onSelectVC {
//    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.isScreenLandScape) {
            [self quanPingBtnClicked];
        } else {
            [self closeBtnClicked];
        }
//    });
}

/*
 *  @brief 切换源，firRoadNum表示一共有几个源，secRoadKeyArray表示每
 *  个源的描述数组，具体参见demo，firRoadNum是下拉列表有面的tableviewcell
 *  的行数，secRoadKeyArray是左面的tableviewcell的描述信息数组
 */
- (void)firRoad:(NSInteger)firRoadNum secRoadKeyArray:(NSArray *)secRoadKeyArray {
    _secRoadKeyArray = [secRoadKeyArray mutableCopy];
//    NSLog(@"firRoadNum = %d,secRoadKeyArray = %@",(int)firRoadNum,secRoadKeyArray);
}

- (void)OnPrivateChat:(NSDictionary *)dic {
//    NSLog(@"OnPrivateChat = %@",dic);
//    if(self.isScreenLandScape) return;
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
    
//    NSLog(@"------anteid = %@,anteName = %@",anteid,anteName);
    
    [self.chatView reloadPrivateChatDict:self.dataPrivateDic anteName:anteName anteid:anteid];
}

/**
 *	@brief	服务器端给自己设置的UserId
 */
-(void)setMyViewerId:(NSString *)viewerId {
//    NSLog(@"---viewerId = %@",viewerId);
    _viewerId = viewerId;
}

- (void)startDanMuTimer {
    [self stopDanMuTimer];
    _danMuTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(makeTheRightAction) userInfo:nil repeats:YES];
}

- (void)stopDanMuTimer {
    if ([_danMuTimer isValid]){
        [_danMuTimer invalidate];
        _danMuTimer=nil;
        [self.array removeAllObjects];
    }
}

- (void)makeTheRightAction {
    if([_requestData isPlaying] && _loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
    
    for(int i = 0;i < _lineLimit;i++){
        if ([self.array count] >= 1) {
            [self makeLabel:[_array objectAtIndex:0] currentLine:i];
            [_array removeObjectAtIndex:0];
        } else {
            break;
        }
    }
}

-(NSMutableArray *)array {
    if(!_array) {
        _array = [NSMutableArray new];
    }
    return _array;
}

- (void)insertStr:(NSString *)str{
    if ([_danMuTimer isValid]) {
        [self.array addObject:str];
    }
}

- (void)makeLabel:(NSString *)str currentLine:(int)currentLine{
    NSMutableAttributedString *attrStr = [Utility emotionStrWithString:str y:-8];
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:20.0f]
                    range:NSMakeRange(0, attrStr.length)];
    CGSize textSize = [attrStr boundingRectWithSize:CGSizeMake(100000, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil].size;
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 64 + IMGWIDTH * 0.5 * (currentLine + 1) + IMGWIDTH * currentLine, textSize.width, textSize.height + 2)];
    contentLabel.font = [UIFont systemFontOfSize:20.0f];
    contentLabel.numberOfLines = 1;
    contentLabel.attributedText = attrStr;
    contentLabel.shadowOffset = CGSizeMake(0, 1);
    contentLabel.shadowColor = CCRGBAColor(0, 0, 0, 0.5);
    contentLabel.backgroundColor = [UIColor clearColor];
    //设置字体颜色为green
    contentLabel.textColor = [UIColor whiteColor];
    //文字居中显示
    contentLabel.textAlignment = NSTextAlignmentCenter;
    //自动折行设置
    contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.videoView insertSubview:contentLabel belowSubview:self.zhibozhongImage];
    
    [self moveAction:contentLabel size:textSize];
}

- (void)moveAction:(UIView *)view size:(CGSize) size {
    [UIView animateWithDuration:_secondToEnd delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        view.frame = CGRectMake(-size.width,view.frame.origin.y,size.width,size.height);
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

-(void)announcement:(NSString *)str {
//    NSLog(@"公告str = %@",str);
    if(StrNotEmpty(str)) {
        _gongGaoStr = str;
        self.newGongGao = YES;
        self.gongGaoDot.hidden = !self.newGongGao;
    } else {
        _gongGaoStr = @"";
        self.newGongGao = NO;
        self.gongGaoDot.hidden = !self.newGongGao;
    }
}

- (void)on_announcement:(NSDictionary *)dict {
    if([dict[@"action"] isEqualToString:@"release"]) {
        if(!_gongGaoView) {
            self.newGongGao = YES;
            self.gongGaoDot.hidden = !self.newGongGao;
        }
        _gongGaoStr = dict[@"announcement"];
    } else if([dict[@"action"] isEqualToString:@"remove"]) {
        self.newGongGao = NO;
        self.gongGaoDot.hidden = !self.newGongGao;
        _gongGaoStr = @"";
    }
    if(_gongGaoView) {
        [_gongGaoView updateViews:self.gongGaoStr];
    }
}

- (void)onQuestionDic:(NSDictionary *)questionDic
{
//    NSLog(@"收到提问: questionDic = %@",questionDic);
    
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
 *	@brief  收到回答
 */
- (void)onAnswerDic:(NSDictionary *)answerDic
{
//    NSLog(@"收到回答: answerDic = %@",answerDic);
    
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
 *	@brief  收到提问&回答
 */
- (void)onQuestionArr:(NSArray *)questionArr onAnswerArr:(NSArray *)answerArr
{
//    NSLog(@"questionArr = %@,answerArr = %@",questionArr,answerArr);
    
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

/**
 *    @brief  历史聊天数据
 */
- (void)onChatLog:(NSArray *)chatLogArr {
//    NSLog(@"onChatLog = %@",chatLogArr);
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
- (void)onChangeNickname:(NSString *)nickNime {
//    NSLog(@"修改后的昵称%@",nickNime);
}

- (void)onPublicChatMessage:(NSDictionary *)dic {
    NSLog(@"onPublicChatMessage = %@",dic);
    if(!_hideDanMuBtn.selected) {
        [self insertStr:dic[@"msg"]];
    }
    
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

/*
 *  @brief  收到自己的禁言消息，如果你被禁言了，你发出的消息只有你自己能看到，其他人看不到
 */
- (void)onSilenceUserChatMessage:(NSDictionary *)message {
//    NSLog(@"message = %@",message);
    [self onPublicChatMessage:message];
}

/**
 *	@brief	当主讲全体禁言时，你再发消息，会出发此代理方法，information是禁言提示信息
 */
- (void)information:(NSString *)information {
    NSString *str = @"讲师暂停了问答，请专心看直播吧";
    if(_segment.selectedSegmentIndex == 1) {
        str = @"讲师暂停了文字聊天，请专心看直播吧";
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:str preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [_voteViewResult removeFromSuperview];
    _voteViewResult = nil;
    [_voteView removeFromSuperview];
    _voteView = nil;
    [_lotteryView removeFromSuperview];
    _lotteryView = nil;
    [_questionnaireSurvey removeFromSuperview];
    _questionnaireSurvey = nil;
    [_questionnaireSurveyPopUp removeFromSuperview];
    _questionnaireSurveyPopUp = nil;
    [_rollcallView removeFromSuperview];
    _rollcallView = nil;
    
    [self hiddenAllBtns];
    [self removeObserver];
    [self stopTimer];
    [self stopHiddenTimer];
    [self stopDanMuTimer];
// 销毁文档和视频，清除视频和文档的时候需要调用,推出播放页面的时候也需要调用
    [_requestData requestCancel];
    _requestData = nil;
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    [self dismissViewControllerAnimated:YES completion:^ {
    }];
}

/**
 *	@brief  收到踢出消息，停止推流并退出播放（被主播踢出）
 */
- (void)onKickOut {
// 播放器停止
    [_requestData stopPlayer];
    [self.view endEditing:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您已被管理员踢出！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(UIView *)emojiView {
    if(!_emojiView) {
        if(_keyboardRect.size.width == 0 || _keyboardRect.size.height ==0) {
            _keyboardRect = CGRectMake(0, 0, 736, 194);
        }
//        NSLog(@"_keyboardRect = %@",NSStringFromCGRect(_keyboardRect));
        
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

- (void)faceButtonClicked:(id)sender {
    NSInteger i = ((UIButton*)sender).tag;
    
    NSMutableString *faceString = [[NSMutableString alloc]initWithString:_chatTextField.text];
    [faceString appendString:[NSString stringWithFormat:@"[em2_%02d]",(int)i]];
    _chatTextField.text = faceString;
}

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

- (CGSize)heightOfCellWithMessage:(NSString *)message withFont:(UIFont *)font textMaxWidth:(CGFloat)textMaxWidth lineHeight:(CGFloat)LineHeight
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:message];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.minimumLineHeight = LineHeight;
    paragraphStyle.maximumLineHeight = LineHeight;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *dict = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle};
    
    [attrStr addAttributes:dict range:NSMakeRange(0, attrStr.length)];
    CGSize textSize = [attrStr boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil].size;
    return textSize;
}

/*
 *  自定义消息
 */
- (void)customMessage:(NSString *)message {
    
}
/**
 *	@brief	提问
 *	@param 	message 提问内容
 */
- (void)question:(NSString *)message {
//提问
    [_requestData question:message];
}

/**
 *	@brief  获取房间信息，主要是要获取直播间模版来类型，根据直播间模版类型来确定界面布局
 */
-(void)roomInfo:(NSDictionary *)dic {
    _roomDesc = dic[@"desc"];
    if(!StrNotEmpty(_roomDesc)) {
        _roomDesc = @"暂无简介";
    }
    _roomName = dic[@"name"];
    self.leftLabel.text = _roomName;
    
    NSArray *array = [_introductionView subviews];
    for(UIView *view in array) {
        [view removeFromSuperview];
    }
    
    float textMaxWidth = CCGetRealFromPt(690);
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:_roomName];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.minimumLineHeight = CCGetRealFromPt(48);
    paragraphStyle.maximumLineHeight = CCGetRealFromPt(48);
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_32],NSParagraphStyleAttributeName:paragraphStyle};
    
    [attrStr addAttributes:dict range:NSMakeRange(0, attrStr.length)];
    CGSize textSize = [attrStr boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil].size;
    
    UIView *titleLabelView = [UIView new];
    titleLabelView.backgroundColor = [UIColor whiteColor];
    titleLabelView.frame = CGRectMake(0, 0, self.introductionView.frame.size.width, textSize.height + CCGetRealFromPt(30) + CCGetRealFromPt(30));
    [self.introductionView addSubview:titleLabelView];

    UILabel *titleLabel = [UILabel new];
    titleLabel.numberOfLines = 0;
    titleLabel.backgroundColor = CCClearColor;
    titleLabel.textColor = CCRGBColor(255,102,51);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.attributedText = attrStr;
    titleLabel.frame = CGRectMake(CCGetRealFromPt(30), CCGetRealFromPt(30), textSize.width, textSize.height);
    [titleLabelView addSubview:titleLabel];
    self.roomDesc = [self filterHTML:self.roomDesc];

    NSMutableAttributedString *attrStrDesc = [[NSMutableAttributedString alloc] initWithString:self.roomDesc];
    NSMutableParagraphStyle *paragraphStyleDesc = [[NSMutableParagraphStyle alloc]init];
    paragraphStyleDesc.minimumLineHeight = CCGetRealFromPt(42);
    paragraphStyleDesc.maximumLineHeight = CCGetRealFromPt(42);
    paragraphStyleDesc.alignment = NSTextAlignmentLeft;
    paragraphStyleDesc.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *dictDesc = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_28],NSParagraphStyleAttributeName:paragraphStyleDesc};
    
    [attrStrDesc addAttributes:dictDesc range:NSMakeRange(0, attrStrDesc.length)];
    CGSize textSizeDesc = [attrStrDesc boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                    context:nil].size;
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = CCRGBColor(232,232,232);
    lineView.frame = CGRectMake(0, titleLabelView.frame.size.height + titleLabelView.frame.origin.y, titleLabelView.frame.size.width, 1);
    [self.introductionView addSubview:lineView];

    UIView *titleLabelViewDesc = [UIView new];
    titleLabelViewDesc.backgroundColor = [UIColor whiteColor];
    CGFloat titleLabelViewDescHeight = 0;
    CGFloat height = lineView.frame.size.height + lineView.frame.origin.y + textSizeDesc.height + CCGetRealFromPt(30) + CCGetRealFromPt(30);
    if(height > self.introductionView.frame.size.height) {
        titleLabelViewDescHeight = self.introductionView.frame.size.height - (lineView.frame.size.height + lineView.frame.origin.y);
    } else {
        titleLabelViewDescHeight = textSizeDesc.height + CCGetRealFromPt(30) + CCGetRealFromPt(30);
    }
    titleLabelViewDesc.frame = CGRectMake(0, lineView.frame.size.height + lineView.frame.origin.y, lineView.frame.size.width, titleLabelViewDescHeight);
    [self.introductionView addSubview:titleLabelViewDesc];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(CCGetRealFromPt(30), CCGetRealFromPt(30),lineView.frame.size.width - CCGetRealFromPt(30) - CCGetRealFromPt(30), titleLabelViewDescHeight - CCGetRealFromPt(30) - CCGetRealFromPt(30))];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.bounces = NO;
    scrollView.delegate = self;
    scrollView.contentSize = textSizeDesc;
    scrollView.showsHorizontalScrollIndicator = NO;
    [titleLabelViewDesc addSubview:scrollView];
    
    UILabel *titleLabelDesc = [UILabel new];
    titleLabelDesc.numberOfLines = 0;
    titleLabelDesc.backgroundColor = CCClearColor;
    titleLabelDesc.textColor = CCRGBColor(51,51,51);
    titleLabelDesc.textAlignment = NSTextAlignmentLeft;
    titleLabelDesc.attributedText = attrStrDesc;
    titleLabelDesc.frame = CGRectMake(0, 0, textSizeDesc.width, textSizeDesc.height);
    [scrollView addSubview:titleLabelDesc];

    CGFloat shadowViewY = self.segment.frame.origin.y+self.segment.frame.size.height-4;
    _templateType = [dic[@"templateType"] integerValue];
//    @"文档",@"聊天",@"问答",@"简介"
    if (_templateType == 1) {
        //聊天互动： 无 直播文档： 无 直播问答： 无
        [_segment setWidth:0.0f forSegmentAtIndex:0];
        [_segment setWidth:0.0f forSegmentAtIndex:1];
        [_segment setWidth:0.0f forSegmentAtIndex:2];
        [_segment setWidth:self.segment.frame.size.width forSegmentAtIndex:3];
        _segment.selectedSegmentIndex = 3;
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0] + [self.segment widthForSegmentAtIndex:1] + [self.segment widthForSegmentAtIndex:2], shadowViewY, [self.segment widthForSegmentAtIndex:3], 4);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(self.view.frame.size.width * 3, py)];
    } else if (_templateType == 2) {
        //聊天互动： 有 直播文档： 无 直播问答： 有
        [_segment setWidth:0.0f forSegmentAtIndex:0];
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:2];
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:3];
        _segment.selectedSegmentIndex = 1;
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0], shadowViewY, [self.segment widthForSegmentAtIndex:1], 4);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(self.view.frame.size.width, py)];
    } else if (_templateType == 3) {
        //聊天互动： 有 直播文档： 无 直播问答： 无
        [_segment setWidth:0.0f forSegmentAtIndex:0];
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:1];
        [_segment setWidth:0.0f forSegmentAtIndex:2];
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:3];
        _segment.selectedSegmentIndex = 1;
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0], shadowViewY, [self.segment widthForSegmentAtIndex:1], 4);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(self.view.frame.size.width, py)];
    } else if (_templateType == 4) {
        //聊天互动： 有 直播文档： 有 直播问答： 无
        _segment.selectedSegmentIndex = 0;
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:0];
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:1];
        [_segment setWidth:0.0f forSegmentAtIndex:2];
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:3];
        _shadowView.frame = CGRectMake(0, shadowViewY, [self.segment widthForSegmentAtIndex:0], 4);
    } else if (_templateType == 5) {
        [_segment setWidth:self.segment.frame.size.width/4 forSegmentAtIndex:0];
        [_segment setWidth:self.segment.frame.size.width/4 forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/4 forSegmentAtIndex:2];
        [_segment setWidth:self.segment.frame.size.width/4 forSegmentAtIndex:3];
        _segment.selectedSegmentIndex = 0;
        _shadowView.frame = CGRectMake(0, shadowViewY, [self.segment widthForSegmentAtIndex:0], 4);
        //聊天互动： 有 直播文档： 有 直播问答： 有
    }else if(_templateType == 6) {
        //聊天互动： 无 直播文档： 无 直播问答： 有
        _segment.selectedSegmentIndex = 2;
        [_segment setWidth:0.0f forSegmentAtIndex:0];
        [_segment setWidth:0.0f forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:2];
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:3];
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0] + [self.segment widthForSegmentAtIndex:1], shadowViewY, [self.segment widthForSegmentAtIndex:2], 4);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(self.view.frame.size.width * 2, py)];
    }
}

-(NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return html;
}

- (BOOL)shouldAutorotate{
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

- (void)broadcast_msg:(NSDictionary *)dic {
//    NSLog(@"broadcast_msg dic:%@",dic);
    Dialogue *dialogue = [[Dialogue alloc] init];
    dialogue.msg = [NSString stringWithFormat:@"系统消息：%@",dic[@"value"][@"content"]];
    
    [self.publicChatArray addObject:dialogue];
    
    [self.chatView reloadPublicChatArray:self.publicChatArray];
}


@end

