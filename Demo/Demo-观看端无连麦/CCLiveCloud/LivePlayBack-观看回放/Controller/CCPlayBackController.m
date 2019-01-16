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
#import "LoadingView.h"//加载
#import "InformationShowView.h"//提示
#import "CCSDK/SaveLogUtil.h"//日志
#import "CCIntroductionView.h"//简介
#import "CCQuestionView.h"//问答
#import "Dialogue.h"//模型
#import "ChatView.h"//聊天


@interface CCPlayBackController ()<RequestDataPlayBackDelegate,UIScrollViewDelegate>

@property (nonatomic,strong)UIView                      * smallVideoView;//文档或者小图
@property (nonatomic,strong)CCPlayBackView              * playerView;//视频视图
@property (nonatomic,strong)RequestDataPlayBack         * requestDataPlayBack;//sdk

@property (nonatomic,assign)BOOL                          isScreenLandScape;//是否横屏
@property (nonatomic,assign)float                         playBackRate;//播放速率
@property (nonatomic,strong)UIView                      * shadowView;//滚动条
@property (nonatomic,strong)UIView                      * lineView;
@property (nonatomic,strong)UIView                      * line;
@property (nonatomic,strong)NSTimer                     * timer;//计时器
@property (nonatomic,copy)  NSString                    * roomName;
@property (nonatomic,strong)UIButton                    * changeButton;//切换窗口
@property (nonatomic,assign)NSInteger                     sliderValue;//滑动值
@property (nonatomic,assign)NSInteger                     templateType;
@property (nonatomic,strong)LoadingView                 * loadingView;//加载视图
@property (nonatomic,strong)UIScrollView                * scrollView;
@property (nonatomic,strong)UISegmentedControl          * segment;//功能切换,文档,聊天等

@property (nonatomic,strong)CCIntroductionView          * introductionView;//简介视图

@property (nonatomic,strong)CCQuestionView              * questionChatView;//问答视图
@property (nonatomic,strong)NSMutableDictionary         * QADic;//问答z字典
@property (nonatomic,strong)NSMutableArray              * keysArrAll;//所有数据

@property (nonatomic,strong)ChatView                    * chatView;//聊天
@property (nonatomic,strong)NSMutableArray              * publicChatArray;//公聊
@property (nonatomic,assign)int                           currentChatTime;//当前聊天时间
@property (nonatomic,assign)int                           currentChatIndex;//当前索引
@property (nonatomic,copy)  NSString                    * groupId;//聊天分组
@property (nonatomic, strong)UIButton                   * smallCloseBtn;//小窗关闭按钮

@end

@implementation CCPlayBackController

- (void)viewDidLoad {
    [super viewDidLoad];
    _sliderValue = 0;
    _playBackRate = 1.0;
    _currentChatTime = 0;
    _currentChatIndex = -1;
    //初始化背景颜色，设置状态栏样式
    self.view.backgroundColor = [UIColor blackColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [self setupUI];
    [self addObserver];
    [self integrationSDK];//集成SDK
}

//集成SDK
- (void)integrationSDK {
    PlayParameter *parameter = [[PlayParameter alloc] init];
    parameter.userId = GetFromUserDefaults(PLAYBACK_USERID);
    parameter.roomId = GetFromUserDefaults(PLAYBACK_ROOMID);
    parameter.liveId = GetFromUserDefaults(PLAYBACK_LIVEID);
    parameter.recordId = GetFromUserDefaults(PLAYBACK_RECORDID);
    parameter.viewerName = GetFromUserDefaults(PLAYBACK_USERNAME);
    parameter.token = GetFromUserDefaults(PLAYBACK_PASSWORD);
    parameter.docParent = self.smallVideoView;
    parameter.docFrame = CGRectMake(0, 0, self.smallVideoView.frame.size.width, self.smallVideoView.frame.size.height);
    parameter.playerParent = self.playerView;
    parameter.playerFrame = CGRectMake(0, 0,self.playerView.frame.size.width, self.playerView.frame.size.height);
    parameter.security = YES;
    parameter.PPTScalingMode = 4;
    parameter.pauseInBackGround = YES;
    parameter.defaultColor = [UIColor whiteColor];
    parameter.scalingMode = 1;
    parameter.pptInteractionEnabled = NO;
//        parameter.groupid = self.groupId;//用户的groupId
    _requestDataPlayBack = [[RequestDataPlayBack alloc] initWithParameter:parameter];
    _requestDataPlayBack.delegate = self;
    
    _loadingView = [[LoadingView alloc] initWithLabel:@"视频加载中" centerY:YES];
    [self.playerView addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(50, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
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
}
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
    }
}
#pragma mark- 回放的开始时间和结束时间
/**
 *  @brief 回放的开始时间和结束时间
 */
-(void)liveInfo:(NSDictionary *)dic {
    NSLog(@"%@",dic);
     SaveToUserDefaults(LIVE_STARTTIME, dic[@"startTime"]);
}
#pragma mark- 聊天
/**
 *    @brief    解析本房间的历史聊天数据
 */
-(void)onParserChat:(NSArray *)chatArr {

    if ([chatArr count] == 0) {
        return;
    }
    for (NSDictionary *dic in chatArr) {
        Dialogue *dialogue = [[Dialogue alloc] init];
        //通过groupId过滤数据------start
        NSString *msgGroupId = dic[@"groupId"];
        //判断是否自己or消息的groupId为空or是否是本组聊天信息or是否是讲师
        if ([_groupId isEqualToString:@""] || [msgGroupId isEqualToString:@""] || [self.groupId isEqualToString:msgGroupId] || !msgGroupId) {
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
            dialogue.chatId = dic[@"chatId"];
            dialogue.status = dic[@"status"];
            //将过滤过的消息添加至数组
            [self.publicChatArray addObject:dialogue];
        }
    }

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
#pragma mark- 问答
/**
 *    @brief  收到提问&回答
 */
- (void)onParserQuestionArr:(NSArray *)questionArr onParserAnswerArr:(NSArray *)answerArr
{
    //    NSLog(@"questionArr = %@,answerArr = %@",questionArr,answerArr);
    
    if ([questionArr count] == 0 && [answerArr count] == 0) {
        return;
    }
    [self.QADic removeAllObjects];
    for (NSDictionary *dic in questionArr) {
        Dialogue *dialog = [[Dialogue alloc] init];
        //通过groupId过滤数据------
        NSString *msgGroupId = dic[@"groupId"];
        //判断是否自己or消息的groupId为空or是否是本组聊天信息
        if ([_groupId isEqualToString:@""] || [msgGroupId isEqualToString:@""] || [self.groupId isEqualToString:msgGroupId] || !msgGroupId) {
            dialog.msg = dic[@"content"];
            dialog.username = dic[@"questionUserName"];
            dialog.fromuserid = dic[@"questionUserId"];
            dialog.time = dic[@"time"];
            dialog.encryptId = dic[@"encryptId"];
            dialog.useravatar = dic[@"useravatar"];
            dialog.dataType = NS_CONTENT_TYPE_QA_QUESTION;
            dialog.isPublish = [dic[@"isPublish"] boolValue];
            
            //将过滤后的问答添加到问答数组
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
    }
    
    for (NSDictionary *dic in answerArr) {
        Dialogue *dialog = [[Dialogue alloc] init];
        dialog.msg = dic[@"content"];
        dialog.username = dic[@"answerUserName"];
        dialog.fromuserid = dic[@"answerUserId"];
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

//切换底部功能 如聊天,问答,简介等
- (void)segmentAction:(UISegmentedControl *)segment
{
    //    WS(ws)
    NSInteger index = segment.selectedSegmentIndex;
    int py = _scrollView.contentOffset.y;
    [self.view endEditing:YES];
    CGFloat width0 = [segment widthForSegmentAtIndex:0];
    CGFloat width1 = [segment widthForSegmentAtIndex:1];
    CGFloat width2 = [segment widthForSegmentAtIndex:2];
    //    CGFloat width3 = [segment widthForSegmentAtIndex:3];
    CGFloat shadowViewY = segment.frame.origin.y + segment.frame.size.height - 2;
    switch(index){
        case 0: {
            [UIView animateWithDuration:0.25 animations:^{
                self.shadowView.frame = CGRectMake(width0/4, shadowViewY, width0/2, 2);
            }];
        }
            [self.scrollView setContentOffset:CGPointMake(0, py)];
            break;
        case 1: {
            [UIView animateWithDuration:0.25 animations:^{
                self.shadowView.frame = CGRectMake(width0+width1/4, shadowViewY, width1/2, 2);
            }];
        }
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, py)];
            break;
        case 2: {
            [UIView animateWithDuration:0.25 animations:^{
                self.shadowView.frame = CGRectMake(width0 + width1+width2/4, shadowViewY, width2/2, 2);
            }];
        }
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 2, py)];
            break;
        case 3: {
        }
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 3, py)];
            break;
        default:
            break;
    }
    
}
//倍速
-(void)playbackRateBtnClicked {
    NSString *title = self.playerView.speedButton.titleLabel.text;
    if([title isEqualToString:@"1.0x"]) {
        [self.playerView.speedButton setTitle:@"1.5x" forState:UIControlStateNormal];
        _playBackRate = 1.5;
        _requestDataPlayBack.ijkPlayer.playbackRate = 1.5;
    } else if([title isEqualToString:@"1.5x"]) {
        [self.playerView.speedButton setTitle:@"0.5x" forState:UIControlStateNormal];
        _playBackRate = 0.5;
        _requestDataPlayBack.ijkPlayer.playbackRate = 0.5;
    } else if([title isEqualToString:@"0.5x"]) {
        [self.playerView.speedButton setTitle:@"1.0x" forState:UIControlStateNormal];
        _playBackRate = 1.0;
        _requestDataPlayBack.ijkPlayer.playbackRate = 1.0;
    }
    
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / _playBackRate) target:self selector:@selector(timerfunc) userInfo:nil repeats:YES];
}
//暂停和继续
- (void)pauseButtonClick {
    if (self.playerView.pauseButton.selected == NO) {
        self.playerView.pauseButton.selected = YES;
        [_requestDataPlayBack pausePlayer];
    } else if (self.playerView.pauseButton.selected == YES){
        self.playerView.pauseButton.selected = NO;
        [_requestDataPlayBack startPlayer];
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
//点击全屏按钮
- (void)quanpingButtonClick:(UIButton *)sender {
    
    if (!sender.selected) {
        sender.selected = YES;
        sender.tag = 2;
        self.isScreenLandScape = YES;
        self.playerView.backButton.tag = 2;
        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        self.isScreenLandScape = NO;
        [UIApplication sharedApplication].statusBarHidden = YES;
        if (_changeButton.tag == 1) {
            
            [_requestDataPlayBack changePlayerFrame:self.view.frame];
        } else {
            [_requestDataPlayBack changeDocFrame:self.view.frame];
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
    } else {
        sender.selected = NO;
        [self backButtonClick:sender];
        sender.tag = 1;
    }
}
//切换视频和文档
- (void)changeButtonClick:(UIButton *)sender {
    if (_smallVideoView.hidden) {
        NSString *title = _changeButton.tag == 1 ? @"切换文档" : @"切换视频";
        [_changeButton setTitle:title forState:UIControlStateNormal];
        _smallVideoView.hidden = NO;
        return;
    }
    if (sender.tag == 1) {//切换文档大屏
        sender.tag = 2;
        [sender setTitle:@"切换视频" forState:UIControlStateNormal];
        [_requestDataPlayBack changeDocParent:self.playerView];
        [_requestDataPlayBack changePlayerParent:self.smallVideoView];
        [_requestDataPlayBack changeDocFrame:CGRectMake(0, 0,self.playerView.frame.size.width, self.playerView.frame.size.height)];
        [_requestDataPlayBack changePlayerFrame:CGRectMake(0, 0, self.smallVideoView.frame.size.width, self.smallVideoView.frame.size.height)];
    } else {//切换文档小屏
        sender.tag = 1;
        [sender setTitle:@"切换文档" forState:UIControlStateNormal];
        [_requestDataPlayBack changeDocParent:self.smallVideoView];
        [_requestDataPlayBack changePlayerParent:self.playerView];
        [_requestDataPlayBack changePlayerFrame:CGRectMake(0, 0,self.playerView.frame.size.width, self.playerView.frame.size.height)];
        [_requestDataPlayBack changeDocFrame:CGRectMake(0, 0, self.smallVideoView.frame.size.width, self.smallVideoView.frame.size.height)];
    }
    [self.playerView bringSubviewToFront:self.playerView.topShadowView];
    [self.playerView bringSubviewToFront:self.playerView.bottomShadowView];
}
//结束直播和退出全屏
- (void)backButtonClick:(UIButton *)sender {
    if (sender.tag == 2) {//横屏返回竖屏
        self.isScreenLandScape = YES;
        sender.tag = 1;
        [self.playerView endEditing:NO];
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
        [UIApplication sharedApplication].statusBarHidden = NO;
        self.isScreenLandScape = NO;
        if (_changeButton.tag == 1) {
            
            [_requestDataPlayBack changePlayerFrame:CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462))];
        } else {
            [_requestDataPlayBack changeDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(462))];
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT_EXITPLAYBACK message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.requestDataPlayBack requestCancel];
        self.requestDataPlayBack = nil;
        [self.smallVideoView removeFromSuperview];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        NSLog(@"点击了取消");
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
//播放和根据时间添加数据
- (void)timerfunc
{
    if([_requestDataPlayBack isPlaying]) {
        if(_loadingView) {
            [_loadingView removeFromSuperview];
            _loadingView = nil;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval position = (int)round(self.requestDataPlayBack.currentPlaybackTime);
        NSTimeInterval duration = (int)round(self.requestDataPlayBack.playerDuration);
        //存在播放器最后一点不播放的情况，所以把进度条的数据对到和最后一秒想同就可以了
        if(duration - position == 1 && (self.sliderValue == position || self.sliderValue == duration)) {
            position = duration;
        }
        //            NSLog(@"---%f",_requestDataPlayBack.currentPlaybackTime);
        
        self.playerView.slider.maximumValue = (int)duration;
        self.playerView.rightTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(duration / 60), (int)(duration) % 60];
        
        if(position == 0 && self.sliderValue != 0) {
            self.requestDataPlayBack.currentPlaybackTime = self.sliderValue;
            position = self.sliderValue;
            self.playerView.slider.value = self.sliderValue;
        } else if(fabs(position - self.playerView.slider.value) > 10) {
            self.requestDataPlayBack.currentPlaybackTime = self.playerView.slider.value;
            position = self.playerView.slider.value;
            self.sliderValue = self.playerView.slider.value;
        } else {
            self.playerView.slider.value = position;
            self.sliderValue = self.playerView.slider.value;
        }
        
        if(self.requestDataPlayBack.ijkPlayer.playbackRate != self.playBackRate) {
            self.requestDataPlayBack.ijkPlayer.playbackRate = self.playBackRate;
            [self startTimer];
        }
        if(self.playerView.pauseButton.selected == NO && self.requestDataPlayBack.ijkPlayer.playbackState == IJKMPMoviePlaybackStatePaused) {
            [self.requestDataPlayBack startPlayer];
        }
        [self.requestDataPlayBack continueFromTheTime:self.sliderValue];
        [self parseChatOnTime:(int)self.sliderValue];
        self.playerView.leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(self.sliderValue / 60), (int)(self.sliderValue) % 60];
    });
}
//开始播放
-(void)startTimer {
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / _playBackRate) target:self selector:@selector(timerfunc) userInfo:nil repeats:YES];
}
//停止播放
-(void) stopTimer {
    if([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}
//监听播放状态
-(void)movieLoadStateDidChange:(NSNotification*)notification
{
    switch (_requestDataPlayBack.ijkPlayer.loadState)
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

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    switch (_requestDataPlayBack.ijkPlayer.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            break;
        }
        case IJKMPMoviePlaybackStatePlaying:
        case IJKMPMoviePlaybackStatePaused: {
            if(self.playerView.pauseButton.selected == YES && [_requestDataPlayBack isPlaying]) {
                [_requestDataPlayBack pausePlayer];
            }
            if(_loadingView && ![_timer isValid]) {
                [self startTimer];
                [_loadingView removeFromSuperview];
                _loadingView = nil;
                [[SaveLogUtil sharedInstance] saveLog:@"" action:SAVELOG_ALERT];
                [_requestDataPlayBack continueFromTheTime:0];
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
    [self removeObserver];
}
//创建UI
- (void)setupUI {
    //大窗
    self.playerView = [[CCPlayBackView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(CCGetRealFromPt(462));
        make.top.equalTo(self.view).offset(SCREEN_STATUS);
    }];
    [self.playerView layoutIfNeeded];
    [self.playerView.backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.playerView.changeButton addTarget:self action:@selector(changeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _changeButton = self.playerView.changeButton;
    [self.playerView.quanpingButton addTarget:self action:@selector(quanpingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.playerView.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.playerView.speedButton addTarget:self action:@selector(playbackRateBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    WS(weakSelf)
    self.playerView.sliderCallBack = ^(int duration) {
            weakSelf.requestDataPlayBack.currentPlaybackTime = duration;
            if (weakSelf.requestDataPlayBack.ijkPlayer.playbackState != IJKMPMoviePlaybackStatePlaying) {
                [weakSelf.requestDataPlayBack startPlayer];
            }
    };
    self.playerView.sliderMoving = ^{
            if (weakSelf.requestDataPlayBack.ijkPlayer.playbackState != IJKMPMoviePlaybackStatePaused) {
                [weakSelf.requestDataPlayBack pausePlayer];
            }
    };
    
    //小窗
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
    
    //为小窗视图添加关闭按钮
    [self.smallVideoView addSubview:self.smallCloseBtn];
    
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
        make.height.mas_equalTo(1);
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
    //聊天
    [_scrollView addSubview:self.chatView];
    self.chatView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    //问答
    [_scrollView addSubview:self.questionChatView];
    self.questionChatView.frame = CGRectMake(_scrollView.frame.size.width * 1, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    //简介
    [_scrollView addSubview:self.introductionView];
    self.introductionView.frame = CGRectMake(_scrollView.frame.size.width * 2, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    
}
//创建聊天视图
-(ChatView *)chatView {
    if(!_chatView) {
        _chatView = [[ChatView alloc] initWithPublicChatBlock:^(NSString *msg) {
        } PrivateChatBlock:^(NSString *anteid, NSString *msg) {
        } input:NO];
        _chatView.backgroundColor = CCRGBColor(250,250,250);
    }
    return _chatView;
}
-(NSMutableArray *)publicChatArray {
    if(!_publicChatArray) {
        _publicChatArray = [[NSMutableArray alloc] init];
    }
    return _publicChatArray;
}

//创建问答视图
-(CCQuestionView *)questionChatView {
    if(!_questionChatView) {
        _questionChatView = [[CCQuestionView alloc] initWithQuestionBlock:^(NSString *message) {

        } input:NO];
        _questionChatView.backgroundColor =[UIColor grayColor];
    }
    return _questionChatView;
}
-(NSMutableDictionary *)QADic {
    if(!_QADic) {
        _QADic = [[NSMutableDictionary alloc] init];
    }
    return _QADic;
}
-(NSMutableArray *)keysArrAll {
    if(!_keysArrAll) {
        _keysArrAll = [[NSMutableArray alloc] init];
    }
    return _keysArrAll;
}
//创建简介视图
-(CCIntroductionView *)introductionView {
    if(!_introductionView) {
        _introductionView = [[CCIntroductionView alloc] init];
        _introductionView.backgroundColor = CCRGBColor(250,250,250);
    }
    return _introductionView;
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
-(UIView *)shadowView {
    if(!_shadowView) {
        _shadowView = [UIView new];
        _shadowView.backgroundColor = CCRGBColor(255,102,51);
    }
    return _shadowView;
}
//为小窗添加关闭按钮
-(UIButton *)smallCloseBtn{
    if (!_smallCloseBtn) {
        _smallCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _smallCloseBtn.frame = CGRectMake(CCGetRealFromPt(10), CCGetRealFromPt(10), CCGetRealFromPt(50), CCGetRealFromPt(50));
        _smallCloseBtn.hidden = YES;
        [_smallCloseBtn setBackgroundImage:[UIImage imageNamed:@"fenestrule_delete"] forState:UIControlStateNormal];
        _smallCloseBtn.backgroundColor = [UIColor clearColor];
        _smallCloseBtn.layer.cornerRadius = CCGetRealFromPt(25);
        _smallCloseBtn.layer.masksToBounds = YES;
        [_smallCloseBtn addTarget:self action:@selector(hiddenSmallVideoview) forControlEvents:UIControlEventTouchUpInside];
    }
    return _smallCloseBtn;
}
//隐藏小窗视图
-(void)hiddenSmallVideoview{
    _smallVideoView.hidden = YES;
    NSString *title = _changeButton.tag == 1 ? @"显示文档" : @"显示视频";
    [_changeButton setTitle:title forState:UIControlStateNormal];
}
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
}


-(void) removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:nil];
}
//APP进入前后台
- (void)appWillEnterForegroundNotification {
    [self startTimer];
}

- (void)appWillEnterBackgroundNotification {
    UIApplication *app = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier taskID = 0;
    taskID = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:taskID];
    }];
    if (taskID == UIBackgroundTaskInvalid) {
        return;
    }
    [self stopTimer];
}


//拖拽小屏
- (void) handlePan:(UIPanGestureRecognizer*) recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self.smallVideoView bringSubviewToFront:self.smallCloseBtn];
            _smallCloseBtn.hidden = NO;
            break;
        case UIGestureRecognizerStateChanged:
        {
            _smallCloseBtn.hidden = NO;
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _smallCloseBtn.hidden = YES;
            });
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

//旋转方向
- (BOOL)shouldAutorotate{
    if (self.isScreenLandScape == YES) {
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
