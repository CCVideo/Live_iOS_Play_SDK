//
//  CCInteractionView.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/1/7.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCInteractionView.h"
#import "CCIntroductionView.h"//简介
#import "CCQuestionView.h"//问答
#import "Dialogue.h"//模型
#import "CCChatViewDataSourceManager.h"//数据处理
#import "CCProxy.h"

#define livePlayQuestionDataCount 20 //默认单次处理20条

//收到历史聊天数据 广播标识
#define CCChatLast_msg @"CCChatHistoryData"

static int flagCount = 0; //计数器

@interface CCInteractionView ()<UIScrollViewDelegate, CCChatViewDataSourceManagerDelegate,CCQuestionViewDelegate>

@property (nonatomic, strong)CCChatViewDataSourceManager *manager;//聊天数据源
@property (nonatomic,strong)CCIntroductionView       * introductionView;//简介视图
@property (nonatomic,strong)CCQuestionView           * questionChatView;//问答视图
@property (strong, nonatomic) NSMutableArray         * keysArrAll;//问答数组
@property (nonatomic,strong)NSMutableDictionary      * QADic;//问答字典
@property (nonatomic,strong)UIScrollView             * scrollView;//文档聊天等视图
@property (nonatomic,strong)NSMutableDictionary      * userDic;//聊天字典
@property (nonatomic,strong)NSMutableDictionary      * dataPrivateDic;//私聊
@property (nonatomic,strong)UIView                   * lineView;//分割线
@property (nonatomic,strong)UIView                   * line;//分割线
@property (nonatomic,strong)UIView                   * shadowView;//滚动条
@property (nonatomic,assign)NSInteger                  templateType;//房间类型
@property (nonatomic,copy)  NSString                 * viewerId;
@property (nonatomic,strong)NSMutableArray           * chatArr;//聊天数组
@property (nonatomic,assign)NSInteger                  lastTime;//最后一条消息
@property (nonatomic,strong)NSTimer                  * updateTimer;//更新计时器
@property (nonatomic, assign)BOOL                       isSmallDocView;//是否是文档小窗模式

@property (nonatomic,copy) HiddenMenuViewBlock       hiddenMenuViewBlock;//隐藏菜单按钮
@property (nonatomic,copy) ChatMessageBlock          chatMessageBlock;//公聊回调
@property (nonatomic,copy) PrivateChatBlock          privateChatBlock;//私聊回调
@property (nonatomic,copy) QuestionBlock             questionBlock;//问答回调


/** 历史问答数组, 用于下滑查看历史数据用 */
@property (nonatomic,strong) NSMutableArray          *historyQuestionArray;
/** 历史答案数组, 用于下滑查看历史数据用 */
@property (nonatomic,strong) NSMutableArray          *historyAnswerArray;
/** 直播问答当前页面 */
@property (nonatomic,assign) int                     livePlayQuestionCurrentPage;
/** 首次进入直播间 */
@property (nonatomic,assign) BOOL                    isFirstJoinLiveRoom;
/** 是否有历史数据 */
@property (nonatomic,assign) BOOL                    isDoneAllData;
/** 计时器 记录问答数据 */
@property (nonatomic,strong) NSTimer                 *timer;
/** 查看历史问答翻页标记已添加回复 */
@property (nonatomic,strong) NSMutableDictionary      *QADicFlag;
/** 历史聊天数据处理完成 */
@property (nonatomic, assign) BOOL                   isDoneChatHistoryData;
/** 历史聊天数据处理完成 */
@property (nonatomic, assign) BOOL                   isDoneRadioHistoryData;
/** 进出直播间提示数组 */
@property (nonatomic, strong) NSMutableArray         *remindDataArray;
/** 是否正在显示提示view */
@property (nonatomic, assign) BOOL                   isShowRemindView;

@end
#define IMGURL @"[img_"
@implementation CCInteractionView
- (void)dealloc
{
    [_updateTimer invalidate];
    // 注销定时器
    [self stopTimer];
    
    [[NSNotificationCenter defaultCenter]removeObserver:CCChatLast_msg];
}

-(instancetype)initWithFrame:(CGRect)frame
              hiddenMenuView:(nonnull HiddenMenuViewBlock)block
                   chatBlock:(nonnull ChatMessageBlock)chatBlock
            privateChatBlock:(nonnull PrivateChatBlock)privateChatBlock
               questionBlock:(nonnull QuestionBlock)questionBlock
                 docViewType:(BOOL)isSmallDocView{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _hiddenMenuViewBlock = block;
        _chatMessageBlock = chatBlock;
        _privateChatBlock = privateChatBlock;
        _questionBlock = questionBlock;
        _isSmallDocView = isSmallDocView;
        [self.remindDataArray removeAllObjects];
        [self addObserver];
        [self setUpUI];
        // 开启定时器
        [self startTimer];
        self.isShowRemindView = NO;
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dataFormatter = [[NSDateFormatter alloc]init];
        [dataFormatter setDateFormat:@"HH:mm:ss"];
        NSString *dateString = [dataFormatter stringFromDate:currentDate];
        _lastTime = [NSString timeSwitchTimestamp:dateString andFormatter:@"HH:mm:ss"];
    }
    return self;
}

/**
 *    @brief    添加通知
 */
- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatLast_data) name:CCChatLast_msg object:nil];
}

/**
 *    @brief    开启Timer
 */
- (void)startTimer
{
    CCProxy *weakObject = [CCProxy proxyWithWeakObject:self];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:weakObject selector:@selector(timerfunc) userInfo:nil repeats:YES];
}
/**
 *    @brief    关闭Timer
 */
-(void)stopTimer {
    if([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
}

/**
 *    @brief    timer 回调
 */
- (void)timerfunc
{
    if (flagCount > 10) { // 同一时段返回多条问答 按每秒刷新
        [self updata]; // 刷新
        flagCount = 0;
    }else {
        return;
    }
}

//初始化布局
-(void)setUpUI{
    //设置功能切换
    //UISegmentedControl,功能控制,聊天文档等
    self.livePlayQuestionCurrentPage = 0; // 历史数据页码
    self.isFirstJoinLiveRoom = YES; // 首次进入直播间标记
    
    [self addSubview:self.segment];
    self.segment.frame = CGRectMake(0, 0, SCREEN_WIDTH, CCGetRealFromPt(82));
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = CCRGBColor(232,232,232);
    [self addSubview:_lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.segment);
        make.height.mas_equalTo(1);
    }];
    
    [self addSubview:self.shadowView];
    self.line = [[UIView alloc] init];
    self.line.backgroundColor = [UIColor colorWithHexString:@"#dddddd" alpha:1.0f];
    [self addSubview:_line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.segment);
        make.height.mas_equalTo(0.5f);
        make.bottom.equalTo(self.shadowView);
    }];
    //UIScrollView分块,聊天,问答,简介均添加在这里
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CCGetRealFromPt(82), self.frame.size.width , SCREENH_HEIGHT - (CCGetRealFromPt(462) + CCGetRealFromPt(80))-SCREEN_STATUS)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollEnabled = NO;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 3, _scrollView.frame.size.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    //添加更多菜单
//    [APPDelegate.window addSubview:self.menuView];
    
    //添加聊天
    [_scrollView addSubview:self.chatView];
    self.chatView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    
    //添加问答
    [_scrollView addSubview:self.questionChatView];
    self.questionChatView.frame = CGRectMake(_scrollView.frame.size.width * 1, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    
    //添加简介
    [_scrollView addSubview:self.introductionView];
    self.introductionView.frame = CGRectMake(_scrollView.frame.size.width * 2, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    
    //添加文档
    if (!_isSmallDocView) {
        [_scrollView addSubview:self.docView];
        self.docView.frame = CGRectMake(_scrollView.frame.size.width * 3, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    }
}

#pragma mark - 响应事件
#pragma mark - 切换底部功能
//切换底部功能 如聊天,问答,简介等
- (void)segmentAction:(UISegmentedControl *)segment
{
    NSInteger index = segment.selectedSegmentIndex;
    int py = _scrollView.contentOffset.y;
    [self endEditing:YES];
    CGFloat width0 = [segment widthForSegmentAtIndex:0];
    CGFloat width1 = [segment widthForSegmentAtIndex:1];
    CGFloat width2 = [segment widthForSegmentAtIndex:2];
    CGFloat width3 = 0;//[segment widthForSegmentAtIndex:3];
    CGFloat shadowViewY = segment.frame.origin.y + segment.frame.size.height - 2;
    switch(index){
        case 0: {
            [UIView animateWithDuration:0.25 animations:^{
                self.shadowView.frame = CGRectMake(width0/4, shadowViewY, width0/2, 2);
            }];
            //收回菜单视图
            if (_hiddenMenuViewBlock) {
                _hiddenMenuViewBlock();
            }
        }
            [self.scrollView setContentOffset:CGPointMake(0, py)];
            break;
        case 1: {
            [UIView animateWithDuration:0.25 animations:^{
                self.shadowView.frame = CGRectMake(width0+width1/4, shadowViewY, width1/2, 2);
            }];
            //收回菜单视图
            if (_hiddenMenuViewBlock) {
                _hiddenMenuViewBlock();
            }
        }
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, py)];
            [self.questionChatView becomeFirstResponder];
            break;
        case 2: {
            [UIView animateWithDuration:0.25 animations:^{
                self.shadowView.frame = CGRectMake(width0 + width1+width2/4, shadowViewY, width2/2, 2);
            }];
            //收回菜单视图
            if (_hiddenMenuViewBlock) {
                _hiddenMenuViewBlock();
            }
        }
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 2, py)];
            break;
        case 3: {
            [UIView animateWithDuration:0.25 animations:^{
                self.shadowView.frame = CGRectMake(width0 + width1 + width2 + width3 / 4, shadowViewY, width3 / 2, 2);
            }];
            //收回菜单视图
            if (_hiddenMenuViewBlock) {
                _hiddenMenuViewBlock();
            }
        }
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 3, py)];
            break;
        default:
            break;
    }
    
}
#pragma mark - 私有方法-----

/**
 移除文档视图(接收到房间信息，不支持房间类型时移除文档视图

 @param docView docView
 */
-(void)removeDocView:(UIView *)docView{
    if (!_isSmallDocView) {
        [_docView removeFromSuperview];
        _docView = nil;
    }else{
        [docView removeFromSuperview];
    }
}
#pragma mark - SDK代理方法----------------------------
#pragma mark- 房间信息
//房间信息
-(void)roomInfo:(NSDictionary *)dic withPlayView:(CCPlayerView *)playerView smallView:(UIView *)smallView{
    
    NSArray *array = [_introductionView subviews];
    for(UIView *view in array) {
        [view removeFromSuperview];
    }
    self.introductionView.roomDesc = dic[@"desc"];
    if(!StrNotEmpty(dic[@"desc"])) {
        self.introductionView.roomDesc = EMPTYINTRO;
    }
    self.introductionView.roomName = dic[@"name"];
    
    CGFloat shadowViewY = self.segment.frame.origin.y + self.segment.frame.size.height-2;
    _templateType = [dic[@"templateType"] integerValue];
    //    @"文档",@"聊天",@"问答",@"简介"
    if (_templateType == 1) {
        //聊天互动： 无 直播文档： 无 直播问答： 无
        [_segment setWidth:0.0f forSegmentAtIndex:0];
        [_segment setTitle:@"" forSegmentAtIndex:0];
        [_segment setWidth:0.0f forSegmentAtIndex:1];
        [_segment setTitle:@"" forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width forSegmentAtIndex:2];
//        [_segment setWidth:0.0f forSegmentAtIndex:3];
        _segment.selectedSegmentIndex = 2;
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0] + [self.segment widthForSegmentAtIndex:1]+[self.segment widthForSegmentAtIndex:2]/4, shadowViewY, [self.segment widthForSegmentAtIndex:2]/2, 2);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 2, py)];
        
        /*    移除文档视图,隐藏切换按钮,移除视频聊天功能   */
        [self removeDocView:smallView];
        playerView.changeButton.hidden = YES;
        [playerView.contentView removeFromSuperview];
    } else if (_templateType == 2) {
        //聊天互动： 有 直播文档： 无 直播问答： 有
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:0];
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:2];
//        [_segment setWidth:0.0f forSegmentAtIndex:3];
        _segment.selectedSegmentIndex = 0;
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0]/4, shadowViewY, [self.segment widthForSegmentAtIndex:1]/2, 2);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(0, py)];
        
        /*    移除文档视图,隐藏切换按钮   */
        [self removeDocView:smallView];
        playerView.changeButton.hidden = YES;
    } else if (_templateType == 3) {
        //聊天互动： 有 直播文档： 无 直播问答： 无
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:0];
        [_segment setWidth:0.0f forSegmentAtIndex:1];
        [_segment setTitle:@"" forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:2];
//        [_segment setWidth:0.0f forSegmentAtIndex:3];
        _segment.selectedSegmentIndex = 0;
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0]/4, shadowViewY, [self.segment widthForSegmentAtIndex:1]/2, 2);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(0, py)];
        
        /*    移除文档视图,隐藏切换按钮   */
        [self removeDocView:smallView];
        playerView.changeButton.hidden = YES;
    } else if (_templateType == 4) {
        //聊天互动： 有 直播文档： 有 直播问答： 无
        _segment.selectedSegmentIndex = 0;
        CGFloat count = _isSmallDocView ? 2 : 3;
//        CGFloat docWidth = _isSmallDocView ? 0 : self.segment.frame.size.width / count;
        [_segment setWidth:self.segment.frame.size.width/count forSegmentAtIndex:0];
        [_segment setWidth:0.0f forSegmentAtIndex:1];
        [_segment setTitle:@"" forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/count forSegmentAtIndex:2];
//        [_segment setWidth:docWidth forSegmentAtIndex:3];
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0]/4, shadowViewY, [self.segment widthForSegmentAtIndex:0]/2, 2);
        
        /*  如果文档在下，隐藏切换按钮   */
        if (!_isSmallDocView) {
            _playerView.changeButton.hidden = YES;
            _playerView.changeButton.tag = 1;
        }
    } else if (_templateType == 5) {
        //聊天互动： 有 直播文档： 有 直播问答： 有
        CGFloat count = _isSmallDocView ? 3 : 4;
//        CGFloat docWidth = _isSmallDocView ? 0 : self.segment.frame.size.width / count;
        [_segment setWidth:self.segment.frame.size.width/count forSegmentAtIndex:0];
        [_segment setWidth:self.segment.frame.size.width/count forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/count forSegmentAtIndex:2];
//        [_segment setWidth:docWidth forSegmentAtIndex:3];
        _segment.selectedSegmentIndex = 0;
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0]/4, shadowViewY, [self.segment widthForSegmentAtIndex:0]/2, 2);
        
        /*  如果文档在下,隐藏切换按钮   */
        if (!_isSmallDocView) {
            _playerView.changeButton.hidden = YES;
            _playerView.changeButton.tag = 1;
        }
    }else if(_templateType == 6) {
        //聊天互动： 无 直播文档： 无 直播问答： 有
        _segment.selectedSegmentIndex = 1;
        [_segment setWidth:0.0f forSegmentAtIndex:0];
        [_segment setTitle:@"" forSegmentAtIndex:0];
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:2];
//        [_segment setWidth:0.0f forSegmentAtIndex:3];
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0]+[self.segment widthForSegmentAtIndex:1]/4, shadowViewY, [self.segment widthForSegmentAtIndex:1]/2, 2);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, py)];
        
        /*    移除文档视图,隐藏切换按钮   */
        [self removeDocView:smallView];
        playerView.changeButton.hidden = YES;
        [playerView.contentView removeFromSuperview];
    }
}
#pragma mark - 服务器端给自己设置的groupId
/**
 *    @brief    服务器端给自己设置的信息(The new method)
 *    viewerId 服务器端给自己设置的UserId
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
    _viewerId = infoDic[@"viewerId"];
}
#pragma mark - 进出直播间题型
- (void)HDUserRemindWithModel:(RemindModel *)model
{
    dispatch_queue_t queue = dispatch_queue_create(0, 0);
    dispatch_async(queue, ^{
        // 1.数组中最多保留10条数据
        if (self.remindDataArray.count >= 10) {
            // 2.大于10条后移除最早之前的一条
            [self.remindDataArray removeObjectAtIndex:0];
            // 3.添加最新的一条数据
            [self.remindDataArray addObject:model];
        }else {
            [self.remindDataArray addObject:model];
        }
        // 4.空数组return
        if (self.remindDataArray.count == 0) {
           return;
        }
        if (self.isShowRemindView == NO) {
            self.isShowRemindView = YES;
            // 5.添加第一个数据
            [self.chatView addRemindModel:[self.remindDataArray firstObject]];
            // 6.移除第一个数据
            [self.remindDataArray removeObjectAtIndex:0];
        }
        WS(weakSelf)
        self.chatView.ShowOrHiddenRemindBlock = ^(BOOL result) {
            if (result == YES) {
                // 4.空数组return
                if (weakSelf.remindDataArray.count == 0) {
                    weakSelf.isShowRemindView = NO;
                    return;
                }
                // 5.添加第一个数据
                [weakSelf.chatView addRemindModel:[weakSelf.remindDataArray firstObject]];
                // 6.移除第一个数据
                [weakSelf.remindDataArray removeObjectAtIndex:0];
                NSLog(@"---remind0-%@%@%@---%zd",model.prefixContent,model.userName,model.suffixContent,weakSelf.remindDataArray.count);
            }else {
                weakSelf.isShowRemindView = NO;
                return;
            }
        };
    });
    NSLog(@"---remind1-%@%@%@---%zd",model.prefixContent,model.userName,model.suffixContent,self.remindDataArray.count);
}

#pragma mark - 聊天管理
/**
 *    @brief    聊天管理(The new method)
 *    status    聊天消息的状态 0 显示 1 不显示
 *    chatIds   聊天消息的id列列表
 */
-(void)chatLogManage:(NSDictionary *) manageDic{
    //遍历数组,取出每一条聊天信息
    NSMutableArray *reloadArr = [NSMutableArray array];
    NSMutableArray *newPublicChatArr = [self.manager.publicChatArray mutableCopy];
    for (Dialogue *model in self.manager.publicChatArray) {
        //找到需要更改状态的那条信息
        if ([manageDic[@"chatIds"] containsObject:model.chatId]) {
            BOOL fromSelf = [model.fromuserid isEqualToString:model.myViwerId];
            BOOL haveImg = [model.msg containsString:@"http://"];
            if ([manageDic[@"status"] isEqualToString:@"0"] && !fromSelf && !haveImg) {
                [self.playerView insertDanmuModel:(CCPublicChatModel *)model];
            }
            //找到消息的位置
            NSUInteger index = [self.manager.publicChatArray indexOfObject:model];
            //更改消息的状态码
            model.status = manageDic[@"status"];
            //更新公聊数组状态
            [newPublicChatArr replaceObjectAtIndex:index withObject:model];
            //记录更改状态的模型下标
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [reloadArr addObject:indexPath];
        }
    }
    if (!reloadArr.count) {
        //NSLog(@"找不到聊天审核的信息");
        return;
    }
    //调用chatView的方法,更新聊天状态,并且刷新某一行
    [self.chatView reloadStatusWithIndexPaths:reloadArr publicArr:newPublicChatArr];
    [self.manager.publicChatArray removeAllObjects];
    self.manager.publicChatArray = [newPublicChatArr mutableCopy];
}
#pragma mark- 聊天
/**
 *    @brief    收到私聊信息
 *    @param    dic {fromuserid         //发送者用户ID
 *                   fromusername       //发送者用户名
 *                   fromuserrole       //发送者角色
 *                   msg                //消息内容
 *                   time               //发送时间
 *                   touserid           //接受者用户ID
 *                   tousername         //接受者用户名}
 */
- (void)OnPrivateChat:(NSDictionary *)dic withMsgBlock:(NewMessageBlock)block {
    //判断消息方是否是自己
    BOOL fromSelf = [dic[@"fromuserid"] isEqualToString:_viewerId];
    if ((!fromSelf && _chatView.ccPrivateChatView.frame.origin.y == SCREENH_HEIGHT) || _chatView.ccPrivateChatView.hidden) {
        //提示新私聊消息
        block();
    }
    
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
    dialogue.useravatar = dic[@"useravatar"];
    dialogue.touserid = dic[@"touserid"];
    dialogue.msg = dic[@"msg"];
    dialogue.time = dic[@"time"];
    dialogue.tousername = self.userDic[dialogue.touserid];
    dialogue.myViwerId = _viewerId;
    //判断是否有fromuserrole这个字段，如果没有，给他赋值
    if (![[dic allKeys] containsObject:@"fromuserrole"]) {
//        NSLog(@"没有身份标识");
        dialogue.fromuserrole = @"host";
    }else{
        dialogue.fromuserrole = dic[@"fromuserrole"];
    }
    
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
 *    @param  chatLogArr [{ chatId          //聊天ID
                            content         //聊天内容
                            groupId         //聊天组ID
                            time            //时间
                            userAvatar      //用户头像
                            userId          //用户ID
                            userName        //用户名称
                            userRole        //用户角色}]
 */
- (void)onChatLog:(NSArray *)chatLogArr {
    /*  防止网络不好或者断开连麦时重新刷新此接口，导致重复显示历史聊天数据 */
    if (self.manager.publicChatArray.count > 0) {
        return;
    }
    /* 没有历史聊天不需要进行数据处理 */
    if (chatLogArr.count == 0) {
        //发送通知 历史聊天数据已处理完成
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CCChatHistoryData" object:nil];
        return;
    }
    //解析历史聊天数据
    [self.manager initWithPublicArray:chatLogArr userDic:self.userDic viewerId:self.viewerId groupId:self.groupId];
}
/**
 *    @brief  禁言删除聊天记录
 */
- (void)onBanDeleteChatMessage:(NSDictionary *)dic {
    NSString * viewerId = dic[@"viewerId"];
    BOOL fromSelf = [viewerId isEqualToString:_viewerId];//判断是否是自己发的
    if (fromSelf) {
        return;
    } else {
        for (NSInteger i = 0; i <self.manager.publicChatArray.count;i++ ) {
            if ([self.manager.publicChatArray[i].fromuserid isEqualToString:viewerId]) {
                [self.manager.publicChatArray removeObjectAtIndex:i];
                i--;
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.chatView reloadPublicChatArray:self.manager.publicChatArray];
        });
    }
}
/**
 *  @brief  收到公聊消息
    @param  dic {  groupId         //聊天组ID
                       msg             //消息内容
                       time            //发布时间
                       useravatar      //用户头像
                       userid          //用户ID
                       username        //用户名称
                       userrole        //用户角色}
 */
- (void)onPublicChatMessage:(NSDictionary *)dic{
    //解析公聊消息
    WS(weakSelf)
    [self.manager addPublicChat:dic userDic:self.userDic viewerId:self.viewerId groupId:self.groupId danMuBlock:^(CCPublicChatModel * _Nonnull model) {
        //弹幕
        [weakSelf.playerView insertDanmuModel:model];
    }];
    //判断时间
    NSString *publistTime = dic[@"time"];
    NSInteger publish = [NSString timeSwitchTimestamp:publistTime andFormatter:@"HH:mm:ss"];
    if (_lastTime == publish) {
        //添加数组
        [self.chatArr addObject:[self.manager.publicChatArray lastObject]];
//        NSLog(@"同一秒，添加至数组");
        [_updateTimer invalidate];
        if (@available(iOS 10.0, *)) {
            _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
                if (weakSelf.chatArr.count != 0) {
                    [weakSelf.chatView addPublicChatArray:weakSelf.chatArr];
                    [weakSelf.chatArr removeAllObjects];
                    //                NSLog(@"延迟数据校对");
                }
            }];
        } else {
         _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addPublicChatArray) userInfo:nil repeats:YES];
        }

    }else{
        if (self.chatArr.count != 0) {
            [self.chatView addPublicChatArray:self.chatArr];
            [self.chatArr removeAllObjects];
//            NSLog(@"将数组中的元素添加至消息中");
        }
        [self.chatView addPublicChat:[self.manager.publicChatArray lastObject]];
        _lastTime = publish;
    }
    
//    [self.chatView reloadPublicChatArray:self.manager.publicChatArray];
}
- (void)addPublicChatArray {
    if (self.chatArr.count != 0) {
        [self.chatView addPublicChatArray:self.chatArr];
        [self.chatArr removeAllObjects];
        //                NSLog(@"延迟数据校对");
    }
}

/*
 *  @brief  收到自己的禁言消息，如果你被禁言了，你发出的消息只有你自己能看到，其他人看不到
    @param  message {   groupId         //聊天组ID
                        msg             //消息内容
                        time            //发布时间
                        useravatar      //用户头像
                        userid          //用户ID
                        username        //用户名称
                        userrole        //用户角色}
 */
- (void)onSilenceUserChatMessage:(NSDictionary *)message {
    
    [self onPublicChatMessage:message];
}
/**
 *    @brief    当主讲全体禁言时，你再发消息，会出发此代理方法，information是禁言提示信息
 */
- (void)information:(NSString *)information {
    
}

/**
 *    @brief    历史聊天数据 广播回调
 */
- (void)chatLast_data
{
    _isDoneChatHistoryData = YES;
    [self chatAndRadioDataSorting];
}

#pragma mark - 广播
/**
 *  @brief  接收到发送的广播
 *  @param  dic {
                content         //广播内容
                userid          //发布者ID
                username        //发布者名字
                userrole        //发布者角色
                createTime      //绝对时间
                time            //相对时间(相对直播)
                id              //广播ID }
 */
- (void)broadcast_msg:(NSDictionary *)dic {
    //解析广播消息
    [self.manager addRadioMessage:dic];
    [self.chatView addPublicChat:[self.manager.publicChatArray lastObject]];
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
- (void)broadcastLast_msg:(NSArray *)array {
    if (array.count == 0) {
        _isDoneRadioHistoryData = YES;
        [self chatAndRadioDataSorting];
        return;
    }
    //处理历史广播数据 返回self.manager.historyRadioArray
    for (int i = 0; i < array.count; i++) {
        [self.manager receiveRadioHistoryMessage:array[i]];
    }
    //历史广播数据处理完成
    _isDoneRadioHistoryData = YES;
    [self chatAndRadioDataSorting];
}

/**
 *    @brief    删除广播
 *    @param    dic   广播信息
 *              dic {action             //操作 1.删除
                     id                 //广播ID }
 */
- (void)broadcast_delete:(NSDictionary *)dic {
    /**
     1.遍历公聊数组找到对应的广播
     2.将对应模型的action置为1 放到数组对应的位置
     3.刷新列表
     */
    /// 广播ID
    NSString *boardcastId = dic[@"id"];
    NSInteger action = [dic[@"action"] integerValue];
    if (action == 0) {
        return;
    }
    for (int i = 0; i < self.manager.publicChatArray.count; i++) {
        CCPublicChatModel *model = self.manager.publicChatArray[i];
        /// 找到对应的广播
        if (model.typeState == RadioState && model.boardcastId.length > 0 && [model.boardcastId isEqualToString:boardcastId]) {
            model.action = [dic[@"action"] integerValue];
            model.cellHeight = 0;
            [self.manager.publicChatArray replaceObjectAtIndex:i withObject:model];
            break;
        }
    }
    [self.chatView reloadPublicChatArray:self.manager.publicChatArray];
}

/**
 *    @brief    历史聊天广播数据排序
 */
- (void)chatAndRadioDataSorting
{
    if (_isDoneChatHistoryData == YES && _isDoneRadioHistoryData == YES) {
        
        NSMutableArray *publicChatArrCopy = [NSMutableArray array];
        [publicChatArrCopy addObjectsFromArray:self.manager.publicChatArray];
        NSMutableArray *radioArray = [NSMutableArray array];
        [radioArray addObjectsFromArray:self.manager.historyRadioArray];
        
        /**
         * 获取历史广播接口会被重复调用
         * 需要遍历一下当前广播是否被添加
         */
        ///取出最后一条历史广播数据
        CCPublicChatModel *radioModel = [radioArray lastObject];
        for (CCPublicChatModel *model in self.manager.publicChatArray) {
            if ([radioModel.boardcastId isEqualToString:model.boardcastId]) {
                [self.chatView reloadPublicChatArray:self.manager.publicChatArray];
                return;
            }
        }
        
        NSMutableArray *res = [NSMutableArray arrayWithCapacity:[publicChatArrCopy count] + [radioArray count]];
        int i = 0, j = 0; //i 表示历史聊天数据的下标  j表示历史广播数据的下标
        while (i < [publicChatArrCopy count]  &&  j < [radioArray count]) {
            CCPublicChatModel *chatModel = publicChatArrCopy[i];
            CCPublicChatModel *radioModel = radioArray[j];
            if ([chatModel.time integerValue] <= [radioModel.time integerValue]) {
                [res addObject:publicChatArrCopy[i++]];
            }else {
                [res addObject:radioArray[j++]];
            }
        }
        
        while (i < [publicChatArrCopy count]) {
            [res addObject:publicChatArrCopy[i++]];
        }
        
        while (j < [radioArray count]) {
            [res addObject:radioArray[j++]];
        }
        [self.manager.publicChatArray removeAllObjects];
        [self.manager.publicChatArray addObjectsFromArray:res];
        //数据组合完成刷新
        [self.chatView reloadPublicChatArray:self.manager.publicChatArray];
    }
}
#pragma mark- 问答
/**
 *  @brief  统一更新数据 （短时间 数据量大 按秒刷新，数据量少 按条刷新）
 */
- (void)updata
{
    [self.questionChatView reloadQADic:self.QADic keysArrAll:self.keysArrAll questionSourceType:QuestionSourceTypeFromLive currentPage:0 isDoneAllData:YES];
}
/**
 *  @brief  发布问题的id
 */
-(void)publish_question:(NSString *)publishId {
    for(NSString *encryptId in self.keysArrAll) {
        NSMutableArray *arr = [self.QADic objectForKey:encryptId];
        Dialogue *dialogue = [arr objectAtIndex:0];
        if(dialogue.dataType == NS_CONTENT_TYPE_QA_QUESTION && [dialogue.encryptId isEqualToString:publishId]) {
            dialogue.isPublish = YES;
        }
    }
//    [self.questionChatView reloadQADic:self.QADic keysArrAll:self.keysArrAll questionSourceType:QuestionSourceTypeFromLive currentPage:0 isDoneAllData:YES];
    flagCount++; // 计数器 小于10条按条刷新
    if (flagCount < 10) {
        [self updata];
    }
}
/**
 *    @brief  收到提问，用户观看时和主讲的互动问答信息
 */
- (void)onQuestionDic:(NSDictionary *)questionDic
{
    
    if ([questionDic count] == 0) return ;
    if (questionDic) {
        Dialogue *dialog = [[Dialogue alloc] init];
        //通过groupId过滤数据------
        NSString *msgGroupId = questionDic[@"value"][@"groupId"];
        //判断是否自己or消息的groupId为空or是否是本组聊天信息
        if ([_groupId isEqualToString:@""] || [msgGroupId isEqualToString:@""] || [self.groupId isEqualToString:msgGroupId] || !msgGroupId) {
            
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
            
            
            //将过滤过的数据添加至问答字典
            NSMutableArray *arr = [self.QADic objectForKey:dialog.encryptId];
            if (arr == nil) {
                arr = [[NSMutableArray alloc] init];
                [self.QADic setObject:arr forKey:dialog.encryptId];
            }
            if(![self.keysArrAll containsObject:dialog.encryptId]) {
                [self.keysArrAll addObject:dialog.encryptId];
            }
            [arr addObject:dialog];
//            [self.questionChatView reloadQADic:self.QADic keysArrAll:self.keysArrAll questionSourceType:QuestionSourceTypeFromLive currentPage:0 isDoneAllData:YES];
            flagCount++; // 计数器 小于10条按条刷新
            if (flagCount < 10) {
               [self updata];
            }
        }
    }
}
/**
 *    @brief  收到回答
 */
- (void)onAnswerDic:(NSDictionary *)answerDic
{
    
    if ([answerDic count] == 0) return;
    
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
//        [self.questionChatView reloadQADic:self.QADic keysArrAll:self.keysArrAll questionSourceType:QuestionSourceTypeFromLive currentPage:0 isDoneAllData:YES];
        flagCount++; // 计数器 小于10条按条刷新
        if (flagCount < 10) {
           [self updata];
        }
    }
}

/**
 *    @brief  收到提问&回答(历史)
 */
- (void)onQuestionArr:(NSArray *)questionArr onAnswerArr:(NSArray *)answerArr
{
    if ([questionArr count] == 0 && [answerArr count] == 0) {
        return;
    }
    [self.QADic removeAllObjects];
    // 第一次进入直播间 包含有历史问答 记录
    if (self.isFirstJoinLiveRoom == YES && questionArr.count > 0) {
        [self.historyAnswerArray removeAllObjects];
        [self.historyQuestionArray removeAllObjects];
        // 首次进入直播间加载历史数据
        [self.historyQuestionArray addObjectsFromArray:questionArr];
        [self.historyAnswerArray addObjectsFromArray:answerArr];
        
        [self.QADicFlag removeAllObjects];
        for (int i = 0; i < answerArr.count; i++) {
            NSString *flagKey = [NSString stringWithFormat:@"%@%d",@"answer",i];
            [self.QADicFlag setObject:@(0) forKey:flagKey];
        }
        
    }
    // 问答总条数
    int questionArrCount = (int)[questionArr count];
    NSArray *tempArr = [NSArray array];
    if (questionArrCount > livePlayQuestionDataCount) { // 历史问答数 > 20 条，先加载最后20条 开启分页
        NSRange range = NSMakeRange(questionArrCount - livePlayQuestionDataCount, livePlayQuestionDataCount);
        tempArr = [questionArr subarrayWithRange:range];
        [self livePlayWithQuestionArr:tempArr answerArr:answerArr qustionSouceType:QuestionSourceTypeFromLive];
    }else {
        [self livePlayWithQuestionArr:questionArr answerArr:answerArr qustionSouceType:QuestionSourceTypeFromLive];
    }
    self.isFirstJoinLiveRoom = NO; //非首次进入直播间
}

/**
 *    @brief  直播查看历史数据 （QuestionView 代理方法）
 */
- (void)livePlayLoadHistoryDataWithPage:(int)currentPage
{
    // 是否包含历史数据
    if (self.historyQuestionArray.count == 0) return;
    // 剩余数据count
    int resuideKeysCount = (int)_historyQuestionArray.count - currentPage *livePlayQuestionDataCount;
    // 最后一页数据 不够一整页数据时 计算剩余数据count
    if (resuideKeysCount < livePlayQuestionDataCount) {
       // 无更多数据
       _isDoneAllData = YES;
    }
    if (resuideKeysCount <= 0) { // 剩余条数不足
        NSMutableArray *tempQuestionArr = [NSMutableArray array];
        NSMutableArray *tempAnswerArr = [NSMutableArray array];
        [self livePlayWithQuestionArr:tempQuestionArr answerArr:tempAnswerArr qustionSouceType:QuestionSourceTypeFromLiveHistory];
    }else {
        // 当前分页范围
        int location = resuideKeysCount < livePlayQuestionDataCount ? 0 : resuideKeysCount - livePlayQuestionDataCount;
        NSRange range = NSMakeRange(location, livePlayQuestionDataCount < resuideKeysCount ? livePlayQuestionDataCount : resuideKeysCount);
        NSMutableArray *tempQuestionArr = [NSMutableArray array];
        // 取出分页范围的数据
        [tempQuestionArr addObjectsFromArray:[_historyQuestionArray subarrayWithRange:range]];
        // 记录当前分页
        _livePlayQuestionCurrentPage = currentPage;
        
        [self livePlayWithQuestionArr:tempQuestionArr answerArr:self.historyAnswerArray qustionSouceType:QuestionSourceTypeFromLiveHistory];
    }
}

/**
 * @brief 历史问答 数据统一处理
 *
 * @param questionArr 提问数组
 * @param answerArr 回复数组
 * @param questionSourceType 问答来源类型
*/
- (void)livePlayWithQuestionArr:(NSArray *)questionArr answerArr:(NSArray *)answerArr qustionSouceType:(QuestionSourceType)questionSourceType
{
    dispatch_queue_t queue = dispatch_queue_create("LiveQuestion", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        // 临时数组用于存储历史数据按顺序展示
        NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *dic in questionArr) {
            Dialogue *dialog = [[Dialogue alloc] init];
            //通过groupId过滤数据------start
            NSString *msgGroupId = dic[@"groupId"];
            //判断是否自己 or消息的groupId为空 or是否是本组聊天信息
            if ([_groupId isEqualToString:@""] ||
                [msgGroupId isEqualToString:@""] ||
                [self.groupId isEqualToString:msgGroupId] ||
                !msgGroupId) {
                
                dialog.msg = dic[@"content"];
                dialog.username = dic[@"questionUserName"];
                dialog.fromuserid = dic[@"questionUserId"];
                dialog.myViwerId = _viewerId;
                dialog.time = dic[@"time"];
                dialog.encryptId = dic[@"encryptId"];
                dialog.useravatar = dic[@"useravatar"];
                dialog.dataType = NS_CONTENT_TYPE_QA_QUESTION;
                dialog.isPublish = [dic[@"isPublish"] boolValue];
                
                //将过滤过的数据添加至问答字典
                NSMutableArray *arr = [self.QADic objectForKey:dialog.encryptId];
                if (arr == nil) {
                    arr = [[NSMutableArray alloc] init];
                    [self.QADic setObject:arr forKey:dialog.encryptId];
                }
                if(![self.keysArrAll containsObject:dialog.encryptId]) {
                    if (questionSourceType == QuestionSourceTypeFromLiveHistory) {
                        [temp addObject:dialog.encryptId];
                    }else {
                        [self.keysArrAll addObject:dialog.encryptId];
                    }
                }

                [arr addObject:dialog];
            }
        }
        if (questionSourceType == QuestionSourceTypeFromLiveHistory) { // 直播查看历史问答
            // 将新数据插入到 keysArrAll 数组最前面
            NSMutableIndexSet  *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, temp.count)];
            [self.keysArrAll insertObjects:temp atIndexes:indexes];
        }
        
        for (int i = 0; i < answerArr.count; i++) {
            NSDictionary *dic = answerArr[i];
            Dialogue *dialog = [[Dialogue alloc] init];
            dialog.msg = dic[@"content"];
            dialog.username = dic[@"answerUserName"];
            dialog.fromuserid = dic[@"answerUserId"];
            dialog.encryptId = dic[@"encryptId"];
            dialog.useravatar = dic[@"useravatar"];
            dialog.dataType = NS_CONTENT_TYPE_QA_ANSWER;
            dialog.isPrivate = [dic[@"isPrivate"] boolValue];
            dialog.time = dic[@"time"];
            NSMutableArray *arr = [self.QADic objectForKey:dialog.encryptId];
            NSString *flagKey = [NSString stringWithFormat:@"%@%d",@"answer",i];
            NSInteger answerFlag = [[self.QADicFlag objectForKey:flagKey] integerValue];
            if (arr != nil) {
                if (answerFlag == 0) {
                    [arr addObject:dialog];
                    [self.QADicFlag setObject:@(1) forKey:flagKey];
                }
            }
        }
        
        [self.questionChatView reloadQADic:self.QADic keysArrAll:self.keysArrAll questionSourceType:questionSourceType currentPage:_livePlayQuestionCurrentPage isDoneAllData:_isDoneAllData];
    });
}

/**
 *    @brief    提问
 *    @param     message 提问内容
 */
- (void)question:(NSString *)message {
    //提问
    if (_questionBlock) {
        _questionBlock(message);
    }
}
#pragma mark - 懒加载
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
        
//        _segment.tintColor = [UIColor whiteColor];
        [_segment setBackgroundImage:[self imageWithColor:UIColor.whiteColor] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [_segment setBackgroundImage:[self imageWithColor:UIColor.whiteColor] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        [_segment setDividerImage:[self imageWithColor:UIColor.whiteColor] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        _segment.momentary = NO;
        [_segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        
    }
    return _segment;
}
- (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}
-(CCDocView *)docView{
    if (!_docView) {
        _docView = [[CCDocView alloc] initWithType:_isSmallDocView];
    }
    return _docView;
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
        WS(weakSelf)
        _questionChatView = [[CCQuestionView alloc] initWithQuestionBlock:^(NSString *message) {
            [weakSelf question:message];
        } input:YES];
        _questionChatView.delegate = self;
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
//存储已发布的 问答 和 回复
-(NSMutableDictionary *)QADic {
    if(!_QADic) {
        _QADic = [[NSMutableDictionary alloc] init];
    }
    return _QADic;
}
//存储已发布问答的回复关联标记
-(NSMutableDictionary *)QADicFlag {

    if(!_QADicFlag) {
        _QADicFlag = [[NSMutableDictionary alloc] init];
    }
    return _QADicFlag;
}

//创建聊天视图
-(CCChatBaseView *)chatView {
    if(!_chatView) {
        WS(weakSelf)
        //公聊发消息回调
        _chatView = [[CCChatBaseView alloc] initWithPublicChatBlock:^(NSString * _Nonnull msg) {
            // 发送公聊信息
            if (weakSelf.chatMessageBlock) {
                weakSelf.chatMessageBlock(msg);
            }
        } isInput:YES];
        //私聊发消息回调
        _chatView.privateChatBlock = ^(NSString * _Nonnull anteid, NSString * _Nonnull msg) {
            // 发送私聊信息
            if (weakSelf.privateChatBlock) {
                weakSelf.privateChatBlock(anteid, msg);
            }
        };
        _chatView.backgroundColor = CCRGBColor(250,250,250);
    }
    return _chatView;
}
//初始化数据管理
-(CCChatViewDataSourceManager *)manager{
    if (!_manager) {
        _manager = [CCChatViewDataSourceManager sharedManager];
        _manager.delegate = self;
//        [_manager removeData];
    }
    return _manager;
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
//滚动条
-(UIView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[UIView alloc] init];
        _shadowView.backgroundColor = CCRGBColor(255,102,51);
    }
    return _shadowView;
}
//聊天数组
-(NSMutableArray *)chatArr{
    if (!_chatArr) {
        _chatArr = [NSMutableArray array];
    }
    return _chatArr;
}
//历史问答数据
- (NSMutableArray *)historyQuestionArray
{
    if (!_historyQuestionArray) {
        _historyQuestionArray = [NSMutableArray array];
    }
    return _historyQuestionArray;
}
//历史回复数据
- (NSMutableArray *)historyAnswerArray
{
    if (!_historyAnswerArray) {
        _historyAnswerArray = [NSMutableArray array];
    }
    return _historyAnswerArray;
}

- (NSMutableArray *)remindDataArray
{
    if (!_remindDataArray) {
        _remindDataArray = [NSMutableArray array];
    }
    return _remindDataArray;
}
#pragma mark - CCChatViewDataSourceDelegate
- (void)updateIndexPath:(nonnull NSIndexPath *)indexPath chatArr:(nonnull NSMutableArray *)chatArr {
    id object = [chatArr objectAtIndex:indexPath.row];
    [self.chatView.publicChatArray replaceObjectAtIndex:indexPath.row withObject:object];
    [self.chatView reloadStatusWithIndexPath:indexPath publicArr:self.chatView.publicChatArray];
}

#pragma mark - 移除聊天
-(void)removeChatView{
    [[CCChatViewDataSourceManager sharedManager] removeData];
    [self.chatView.ccPrivateChatView removeFromSuperview];
}



@end
