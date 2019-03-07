//
//  RequestData.h
//  CCavPlayDemo
//
//  Created by ma yige on 15/6/29.
//  Copyright (c) 2015年 ma yige. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PlayParameter.h"
#import "IJKMediaFramework/IJKMediaPlayback.h"
#import "IJKMediaFramework/IJKFFMoviePlayerController.h"
#define SDKVersion @"3.2.1"


@protocol RequestDataDelegate <NSObject>
@optional
//@optional
/**
 *	@brief	请求播放地址成功
 */
-(void)requestSucceed;
/**
 *	@brief	请求播放地址失败
 */
-(void)requestFailed:(NSError *)error reason:(NSString *)reason;
/**
 *	@brief  收到提问，用户观看时和主讲的互动问答信息
 */
- (void)onQuestionDic:(NSDictionary *)questionDic;
/**
 *	@brief  收到回答，用户观看时和主讲的互动问答信息
 */
- (void)onAnswerDic:(NSDictionary *)answerDic;
/**
 *	@brief  收到提问&回答，在用户登录之前，主讲和其他用户的历史互动问答信息
 */
- (void)onQuestionArr:(NSArray *)questionArr onAnswerArr:(NSArray *)answerArr;
/**
 *    @brief  历史聊天数据
 */
- (void)onChatLog:(NSArray *)chatLogArr;
/**
 *	@brief  主讲开始推流
 */
- (void)onLiveStatusChangeStart;
/**
 *	@brief  停止直播，endNormal表示是否异常停止推流，这个参数对观看端影响不大
 */
- (void)onLiveStatusChangeEnd:(BOOL)endNormal;
/**
 *	@brief  收到公聊消息
 */
- (void)onPublicChatMessage:(NSDictionary *)message;
/**
 *	@brief	收到私聊信息
 */
- (void)OnPrivateChat:(NSDictionary *)dic;
/**
 *    @brief    修改昵称
 */
- (void)onChangeNickname:(NSString *)nickNime;
/*
 *  @brief  收到自己的禁言消息，如果你被禁言了，你发出的消息只有你自己能看到，其他人看不到
 */
- (void)onSilenceUserChatMessage:(NSDictionary *)message;
/**
 *	@brief	收到在线人数
 */
- (void)onUserCount:(NSString *)count;
/**
 *	@brief	当主讲全体禁言时，你再发消息，会出发此代理方法，information是禁言提示信息
 */
- (void)information:(NSString *)information;
/**
 *	@brief	服务器端给自己设置的UserId
 */
-(void)setMyViewerId:(NSString *)viewerId;
/**
 *	@brief  收到踢出消息，停止推流并退出播放（被主播踢出）(change)
 kick_out_type
 10 在允许重复登录前提下，后进入者会登录会踢出先前登录者
 20 讲师、助教、主持人通过页面踢出按钮踢出用户
 */
- (void)onKickOut:(NSDictionary *)dictionary;
/**
 *	@brief  获取房间信息，主要是要获取直播间模版来类型，根据直播间模版类型来确定界面布局
 *	房间简介：dic[@"desc"];
 *	房间名称：dic[@"name"];
 *	房间模版类型：[dic[@"templateType"] integerValue];
 *	模版类型为1: 聊天互动： 无 直播文档： 无 直播问答： 无
 *	模版类型为2: 聊天互动： 有 直播文档： 无 直播问答： 有
 *	模版类型为3: 聊天互动： 有 直播文档： 无 直播问答： 无
 *	模版类型为4: 聊天互动： 有 直播文档： 有 直播问答： 无
 *	模版类型为5: 聊天互动： 有 直播文档： 有 直播问答： 有
 *	模版类型为6: 聊天互动： 无 直播文档： 无 直播问答： 有
 */
-(void)roomInfo:(NSDictionary *)dic;
/**
 *	@brief  收到播放直播状态 0直播 1未直播
 */
- (void)getPlayStatue:(NSInteger)status;
/**
 *	@brief  获取文档内白板或者文档本身的宽高，来进行屏幕适配用的
 */
- (void)getDocAspectRatioOfWidth:(CGFloat)width height:(CGFloat)height;
/**
 *  @brief  获取ppt当前页数和总页数
 *
 *  回调当前翻页的页数信息 <br/>
 *  白板docTotalPage一直为0, pageNum从1开始<br/>
 *  其他文档docTotalPage为正常页数,pageNum从0开始<br/>
 *  @param dictionary 翻页信息
 */
- (void)onPageChange:(NSDictionary *) dictionary;
/**
 *	@brief  登录成功
 */
- (void)loginSucceedPlay;
/**
 *	@brief  登录失败
 */
-(void)loginFailed:(NSError *)error reason:(NSString *)reason;

/**
 *  @brief 切换源，firRoadNum表示一共有几个源，secRoadKeyArray表示每
 *  个源的描述数组，具体参见demo，firRoadNum是下拉列表有面的tableviewcell
 *  的行数，secRoadKeyArray是左面的tableviewcell的描述信息数组
 */
- (void)firRoad:(NSInteger)firRoadNum secRoadKeyArray:(NSArray *)secRoadKeyArray;
/**
 *  @brief  自定义消息
 */
- (void)customMessage:(NSString *)message;
/**
 *  @brief  公告
 */
- (void)announcement:(NSString *)str;
/**
 *  @brief  监听到有公告消息
 */
- (void)on_announcement:(NSDictionary *)dict;
/**
 *  @brief  开始抽奖
 */
- (void)start_lottery;
/**
 *  @brief  抽奖结果
 *  remainNum   剩余奖品数
 */
- (void)lottery_resultWithCode:(NSString *)code myself:(BOOL)myself winnerName:(NSString *)winnerName remainNum:(NSInteger)remainNum;
/**
 *  @brief  退出抽奖
 */
- (void)stop_lottery;
/**
 *  @brief  开始签到
 */
- (void)start_rollcall:(NSInteger)duration;
/**
 *  @brief  开始答题
 */
- (void)start_vote:(NSInteger)count singleSelection:(BOOL)single;
/**
 *  @brief  结束答题
 */
- (void)stop_vote;
/**
 *  @brief  答题结果
 */
- (void)vote_result:(NSDictionary *)resultDic;
/**
 *  @brief  加载视频失败
 */
- (void)play_loadVideoFail;
/**
 *  @brief  接收到发送的广播
 */
- (void)broadcast_msg:(NSDictionary *)dic;
/**
 *  @brief  接收到最后一条广播(直播中途进入,会返回最后一条广播)
 */
- (void)broadcastLast_msg:(NSArray *)array;
/**
 *  @brief  发布问题的ID
 */
- (void)publish_question:(NSString *)publishId;
/**
 *  @brief  发布问卷
 */
- (void)questionnaire_publish;
/**
 *  @brief  结束发布问卷
 */
- (void)questionnaire_publish_stop;
/**
 *  @brief  获取问卷详细内容
 *  forcibly 为1就是强制答卷，0为非强制答卷
 */
- (void)questionnaireDetailInformation:(NSDictionary *)detailDic;
/**
 *  @brief  获取问卷统计
 */
- (void)questionnaireStaticsInformation:(NSDictionary *)staticsDic;
/**
 *  @brief  提交问卷结果（成功，失败）
 */
- (void)commitQuestionnaireResult:(BOOL)success;
/**
 *  @brief  问卷功能
 */
- (void)questionnaireWithTitle:(NSString *)title url:(NSString *)url;
/**
 *  @brief  收到最后一条广播
 *  content 广播内容
 *  time 发布时间(单位:秒)
 */
- (void)broadcastHistory_msg:(NSArray *)History_msg;

/**
 *    @brief     双击ppt
 */
- (void)doubleCllickPPTView;

/**
 *  @brief  获取直播开始时间和直播时长
 *  liveDuration 直播持续时间，单位（s），直播未开始返回-1"
 *  liveStartTime 新增开始直播时间（格式：yyyy-MM-dd HH:mm:ss），如果直播未开始，则返回空字符串
 */
- (void)startTimeAndDurationLiveBroadcast:(NSDictionary *)dataDic;

/**
 *    @brief     直播间被禁
 */
- (void)theRoomWasBanned;

/**
 *    @brief     直播间解禁
 */
- (void)theRoomWasCleared;

/**
 *    @brief     获取所有文档列表
 */
- (void)receivedDocsList:(NSDictionary *)listDic;
/**
 *    @brief     客户端关闭摄像头
 数据源类型    数据源值    数据源类型描述       数据源类型描述值
 source_type    0     source_type_desc    数据源类型：默认值，
 source_type    10    source_type_desc    数据源类型：摄像头打开
 source_type    11    source_type_desc    数据源类型：摄像头关闭
 source_type    20    source_type_desc    数据源类型：图片
 source_type    30    source_type_desc    数据源类型：插播视频
 source_type    40    source_type_desc    数据源类型：区域捕获
 source_type    50    source_type_desc    数据源类型：桌面共享
 source_type    60    source_type_desc    数据源类型：自定义场景
 
 ps:
 source_type 参数 0 值 应用场景：
 1. 文档模式下 0 默认值
 2. 非文档模式下 0 无意义
 3. 低版本客户端 0 无意义
 source_type 参数 60 值 应用场景：
 当以上场景无法满足要求时，主播可自定义场景，用户不需要关心自定义场景细节内容
 */
- (void)receivedSwitchSource:(NSDictionary *)dic;
/**
 *  @brief  视频或者文档大窗
 *  isMain 1为视频为主,0为文档为主"
 */
- (void)onSwitchVideoDoc:(BOOL)isMain;
/**
 *    @brief    服务器端给自己设置的信息(The new method)
 *    viewerId 服务器端给自己设置的UserId
 *    groupId 分组id
 *    name 用户名
 */
-(void)setMyViewerInfo:(NSDictionary *) infoDic;
/**
 *    @brief    收到聊天禁言(The new method)
 *    mode 禁言类型 1：个人禁言  2：全员禁言
 */
-(void)onBanChat:(NSDictionary *) modeDic;
/**
 *    @brief    收到解除禁言事件(The new method)
 *    mode 禁言类型 1：个人禁言  2：全员禁言
 */
-(void)onUnBanChat:(NSDictionary *) modeDic;
/**
 *    @brief    聊天管理(The new method)
 *    status    聊天消息的状态 0 显示 1 不显示
 *    chatIds   聊天消息的id列列表
 */
-(void)chatLogManage:(NSDictionary *) manageDic;

/**
 *    @brief    文档加载状态(The new method)
 *    index
 *      0 文档组件初始化完成
 *      1 动画文档加载完成
 *      2 非动画文档加载完成
 */
- (void)docLoadCompleteWithIndex:(NSInteger)index;

/**
 *    @brief    接收到随堂测(The new method)
 *    rseultDic    随堂测内容
 */
-(void)receivePracticeWithDic:(NSDictionary *) resultDic;
/**
 *    @brief    随堂测提交结果(The new method)
 *    rseultDic    提交结果,调用commitPracticeWithPracticeId:(NSString *)practiceId options:(NSArray *)options后执行
 */
-(void)practiceSubmitResultsWithDic:(NSDictionary *) resultDic;
/**
 *    @brief    随堂测统计结果(The new method)
 *    rseultDic    统计结果,调用getPracticeStatisWithPracticeId:(NSString *)practiceId后执行
 */
-(void)practiceStatisResultsWithDic:(NSDictionary *) resultDic;
/**
 *    @brief    随堂测排名结果(The new method)
 *    rseultDic    排名结果,调用getPracticeRankWithPracticeId:(NSString *)practiceId后执行
 */
-(void)practiceRankResultsWithDic:(NSDictionary *) resultDic;
/**
 *    @brief    停止随堂测(The new method)
 *    rseultDic    结果
 */
-(void)practiceStopWithDic:(NSDictionary *) resultDic;
/**
 *    @brief    关闭随堂测(The new method)
 *    rseultDic    结果
 */
-(void)practiceCloseWithDic:(NSDictionary *) resultDic;
/**
 *    @brief    视频状态(The new method)
 *    rseult    playing/paused
 */
-(void)videoStateChangeWithString:(NSString *) result;



//#ifdef LIANMAI_WEBRTC
/**
 *  @brief WebRTC连接成功，在此代理方法中主要做一些界面的更改
 */
- (void)connectWebRTCSuccess;
/**
 *  @brief 当前是否可以连麦
 */
- (void)whetherOrNotConnectWebRTCNow:(BOOL)connect;
/**
 *  @brief 主播端接受连麦请求，在此代理方法中，要调用DequestData对象的
 *  - (void)saveUserInfo:(NSDictionary *)dict remoteView:(UIView *)remoteView;方法
 *  把收到的字典参数和远程连麦页面的view传进来，这个view需要自己设置并发给SDK，SDK将要在这个view上进行渲染
 */
- (void)acceptSpeak:(NSDictionary *)dict;
/**
 *  @brief 主播端发送断开连麦的消息，收到此消息后做断开连麦操作
 */
-(void)speak_disconnect:(BOOL)isAllow;
/**
 *  @brief 本房间为允许连麦的房间，会回调此方法，在此方法中主要设置UI的逻辑，
 *  在断开推流,登录进入直播间和改变房间是否允许连麦状态的时候，都会回调此方法
 */
- (void)allowSpeakInteraction:(BOOL)isAllow;
//#endif

@end

@interface RequestData : NSObject

@property (weak,nonatomic) id<RequestDataDelegate>      delegate;
@property (retain,    atomic) IJKFFMoviePlayerController      *ijkPlayer;

/**
 *	@brief	登录房间
 *	@param 	parameter   配置参数信息
 *  必填参数 userId;
 *  必填参数 roomId;
 *  必填参数 viewerName;
 *  必填参数 token;
 *  必填参数 security;
 *  （选填参数） viewercustomua;
 */
- (id)initLoginWithParameter:(PlayParameter *)parameter;
/**
 *	@brief	进入房间，并请求画图聊天数据并播放视频（可以不登陆，直接从此接口进入直播间）
 *	@param 	parameter   配置参数信息
 *  必填参数 userId;
 *  必填参数 roomId;
 *  必填参数 viewerName;
 *  必填参数 token;
 *  必填参数 docParent;
 *  必填参数 docFrame;
 *  必填参数 playerParent;
 *  必填参数 playerFrame;
 *  必填参数 scalingMode;
 *  必填参数 security;
 *  必填参数 defaultColor;
 *  必填参数 scalingMode;
 *  必填参数 PPTScalingMode;
 *  必填参数 pauseInBackGround;
 *  （选填参数） viewercustomua;
 */
- (id)initWithParameter:(PlayParameter *)parameter;
/**
 *	@brief	提问
 *	@param 	message 提问内容
 */
- (void)question:(NSString *)message;
/**
 *	@brief	发送公聊信息
 *	@param 	message  发送的消息内容
 */
- (void)chatMessage:(NSString *)message;
/**
 *	@brief  发送私聊信息
 */
- (void)privateChatWithTouserid:(NSString *)touserid msg:(NSString *)msg;
/**
 *	@brief	销毁文档和视频，清除视频和文档的时候需要调用,推出播放页面的时候也需要调用
 */
- (void)requestCancel;
/**
 *	@brief  获取在线房间人数，当登录成功后即可调用此接口，登录不成功或者退出登录后就不可以调用了，如果要求实时性比较强的话，可以写一个定时器，不断调用此接口，几秒钟发一次就可以，然后在代理回调函数中，处理返回的数据
 */
- (void)roomUserCount;
/**
 *	@brief  获取文档区域内白板或者文档本身的宽高比，返回值即为宽高比，做屏幕适配用
 */
- (CGFloat)getDocAspectRatio;
/**
 *	@brief  改变文档区域大小,主要用在文档生成后改变文档窗口的frame
 */
- (void)changeDocFrame:(CGRect) docFrame;
/**
 *	@brief  改变播放器frame
 */
- (void)changePlayerFrame:(CGRect) playerFrame;
/**
 *    @brief  改变播放器父窗口
 */
- (void)changePlayerParent:(UIView *) playerParent;
/**
 *    @brief  改变文档父窗口
 */
- (void)changeDocParent:(UIView *) docParent;
/**
 *	@brief  播放器暂停
 */
- (void)pausePlayer;
/**
 *	@brief  播放器播放
 */
- (void)startPlayer;
/**
 *	@brief  播放器关闭并移除
 */
- (void)shutdownPlayer;
/**
 *	@brief  播放器停止
 */
- (void)stopPlayer;
/**
 *	@brief   切换播放线路
 *  firIndex表示第几个源
 *  key表示该源对应的描述信息
 */
- (void)switchToPlayUrlWithFirIndex:(NSInteger)firIndex key:(NSString *)key;
/**
 *  @brief 重新加载视频,参数force表示是否强制重新加载视频，
 * 一般重新加载视频的时间间隔应该超过3秒，如果强制重新加载视频，时间间隔可以在3S之内
 */
-(void)reloadVideo:(BOOL)force;
/**
 *  @brief 签到
 */
-(void)answer_rollcall;
/**
 *  @brief 答单选题
 */
-(void)reply_vote_single:(NSInteger)index;
/**
 *  @brief 答多选题
 */
-(void)reply_vote_multiple:(NSMutableArray *)indexArray;
/**
 *	@brief  播放器是否播放
 */
- (BOOL)isPlaying;
/**
 *	@brief  设置后台是否可播放
 */
- (void)setpauseInBackGround:(BOOL)pauseInBackGround;
/**
 *  @brief 提交问卷结果
 */
-(void)commitQuestionnaire:(NSDictionary *)dic;
/**
 *  @brief 主动请求问卷
 */
-(void)getPublishingQuestionnaire;
/**
 *    @brief     修改昵称
 *    @param     nickName  修改后的昵称
 */
- (void)changeNickName:(NSString *)nickName;

/**
 *    @brief     切换当前的文档模式
 *      1.切换至跟随模式（默认值）值为0，
 *      2.切换至自由模式；值为1，
 */
- (void)changeDocMode:(NSInteger)mode;
/**
 *    @brief     查找并获取当前文档的信息
 *      @param     docId  文档的docId
 *      @param     pageIndex  跳转的页数
 */
- (void)changePageToNumWithDocId:(NSString *)docId pageIndex:(NSInteger)pageIndex;

/**
 *    @brief     提交随堂测(The new method)
 *      @param     practiceId  随堂测ID
 *      @param     options   选项ID
 */
- (void)commitPracticeWithPracticeId:(NSString *)practiceId options:(NSArray *)options;
/**
 *    @brief     获取随堂测统计信息(可多次调用)(The new method)
 *      @param     practiceId  随堂测ID
 */
-(void)getPracticeStatisWithPracticeId:(NSString *)practiceId;
/**
 *    @brief     获取随堂测排名(可多次调用)(The new method)
 *      @param     practiceId  随堂测ID
 */
-(void)getPracticeRankWithPracticeId:(NSString *)practiceId;
/**
 *    @brief     获取随堂测(The new method)
 *      @param     practiceId  随堂测ID(没有传@"")
 */
-(void)getPracticeInfo:(NSString *)practiceId;



//#ifdef LIANMAI_WEBRTC
/**
 *  @brief 当收到- (void)acceptSpeak:(NSDictionary *)dict;回调方法后，调用此方法
 * dict 正是- (void)acceptSpeak:(NSDictionary *)dict;接收到的的参数
 * remoteView 是远程连麦页面的view，需要自己设置并发给SDK，SDK将要在这个view上进行远程画面渲染
 */
- (void)saveUserInfo:(NSDictionary *)dict remoteView:(UIView *)remoteView;
/**
 *  @brief 观看端主动断开连麦时候需要调用的接口
 */
- (void)disConnectSpeak;
/**
 *  @brief 当观看端主动申请连麦时，需要调用这个接口，并把本地连麦预览窗口传给SDK，SDK会在这个view上
 * 进行远程画面渲染
 * param localView:本地预览窗口，传入本地view，连麦准备时间将会自动绘制预览画面在此view上
 * param isAudioVideo:是否是音视频连麦，不是音视频即是纯音频连麦(YES表示音视频连麦，NO表示音频连麦)
 */
-(void)requestAVMessageWithLocalView:(UIView *)localView isAudioVideo:(BOOL)isAudioVideo;
/**
 *  @brief 设置本地预览窗口的大小，连麦成功后调用才生效，连麦不成功调用不生效
 */
-(void)setLocalVideoFrameA:(CGRect)localVideoFrame;
/**
 *  @brief 设置远程连麦窗口的大小，连麦成功后调用才生效，连麦不成功调用不生效
 */
-(void)setRemoteVideoFrameA:(CGRect)remoteVideoFrame;
/**
 *  @brief 将要连接WebRTC
 */
-(void)gotoConnectWebRTC;

//#endif

@end
