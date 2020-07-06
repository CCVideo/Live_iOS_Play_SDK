//
//  RequestDataPlayBack.h
//  CCLivePlayDemo
//
//  Created by cc-mac on 15/11/10.
//  Copyright © 2015年 ma yige. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PlayParameter.h"
#import "IJKMediaFramework/IJKMediaPlayback.h"
#import "IJKMediaFramework/IJKFFMoviePlayerController.h"
#import <WebKit/WebKit.h>

#define SDKVersion @"3.9.0"
@protocol RequestDataPlayBackDelegate <NSObject>
@optional
/**
 *	@brief  获取文档内白板或者文档本身的宽高，来进行屏幕适配用的
 */
- (void)getDocAspectRatioOfWidth:(CGFloat)width height:(CGFloat)height;
/**
 *  @brief  获取ppt当前页数和总页数(The new method)
 *
 *  回调当前翻页的页数信息 <br/>
 *  白板docTotalPage一直为0, pageNum从1开始<br/>
 *  其他文档docTotalPage为正常页数,pageNum从0开始<br/>
 *  @param dictionary 翻页信息
 */
- (void)onPageChange:(NSDictionary *) dictionary;
/**
 *	@brief	收到本房间的历史提问&回答
 */
- (void)onParserQuestionArr:(NSArray *)questionArr onParserAnswerArr:(NSArray *)answerArr;
/**
 *	@brief	解析本房间的历史聊天数据
 */
-(void)onParserChat:(NSArray *)arr;
/**
 *  @brief  收到本房间历史广播(The new method)
 *  content 广播内容
 *  time 发布时间(单位:秒)
 */
- (void)broadcastHistory_msg:(NSArray *)array;
/**
 *	@brief	请求回放地址成功
 */
-(void)requestSucceed;
/**
 *	@brief	请求回放地址失败
 */
-(void)requestFailed:(NSError *)error reason:(NSString *)reason;
/**
 *	@brief  登录成功
 */
- (void)loginSucceedPlayBack;
/**
 *	@brief  登录失败
 */
-(void)loginFailed:(NSError *)error reason:(NSString *)reason;
/**
 *	@brief  获取房间信息，主要是要获取直播间模版来类型，根据直播间模版类型来确定界面布局
 *	房间信息
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
 *  @brief 回放的开始时间和结束时间(The new method)
 */
-(void)liveInfo:(NSDictionary *)dic;
/**
 *  @brief  加载视频失败
 */
- (void)playback_loadVideoFail;
/**
 *  @brief  回放翻页数据列表
 */
- (void)pageChangeList:(NSMutableArray *)array;
/**
 *    @brief     双击ppt
 */
- (void)doubleCllickPPTView;
/**
 *    @brief    服务器端给自己设置的信息(The new method)
 *    viewerId 服务器端给自己设置的UserId
 *    groupId 分组id
 *    name 用户名
 */
-(void)setMyViewerInfo:(NSDictionary *) infoDic;
/**
 *    @brief    文档加载状态(The new method)
 *    index
 *      0 文档组件初始化完成
 *      1 动画文档加载完成
 *      2 非动画文档加载完成
 */
- (void)docLoadCompleteWithIndex:(NSInteger)index;
/**
 *    @brief    接收到随堂测
 *    rseultDic    随堂测内容
 */
-(void)receivePracticeWithDic:(NSDictionary *) resultDic;
/**
 *    @brief    视频状态
 *    rseult    playing/paused/loading
 */
-(void)videoStateChangeWithString:(NSString *) result;
/**
 *    @brief    跑马灯信息,需要开启跑马灯功能且iOS 9.0以上
*/
-(void)receivedMarqueeInfo:(NSDictionary *)dic;
/**
 *接收到播放线路   例:int值 2 代表两条 changeLineWithNum传0或1 (已废弃)
 */
-(void)numberOfReceivedLines:(NSInteger)linesCount;

/**
 *接收到播放线路   例:videoArray元素个数 2 代表2条线路 changeLineWithPlayParameter传0或1
 */
-(void)numberOfReceivedLinesWithVideo:(NSArray *)videoArray audio:(NSArray *)audioArray;

@end

@interface RequestDataPlayBack : NSObject

@property (weak,nonatomic) id<RequestDataPlayBackDelegate>  delegate;
/**
 *  @brief  播放器
 */
@property (retain,    atomic) IJKFFMoviePlayerController      *ijkPlayer;

/**
 *	@brief	登录房间
 *	@param 	parameter   配置参数信息
 *  必填参数 userId
 *  必填参数 roomId
 *  必填参数 liveid
 *  必填参数 viewerName
 *  必填参数 token
 *  必填参数 security
 */
- (id)initLoginWithParameter:(PlayParameter *)parameter;
/**
 *	@brief	进入房间，并请求画图聊天数据并播放视频（可以不登陆，直接从此接口进入直播间）
 *	@param 	parameter   配置参数信息
 *  必填参数 userId;
 *  必填参数 roomId;
 *  必填参数 liveid;
 *  必填参数 viewerName;
 *  必填参数 token;
 *  必填参数 docParent;
 *  必填参数 docFrame;
 *  必填参数 playerParent;
 *  必填参数 playerFrame;
 *  必填参数 security;
 *  必填参数 pauseInBackGround;
 *  必填参数 defaultColor;
 *  必填参数 PPTScalingMode;
 *  必填参数 scalingMode;
 */
- (id)initWithParameter:(PlayParameter *)parameter;

/**
 *	@brief	销毁文档和视频，清除视频和文档的时候需要调用,推出播放页面的时候也需要调用
 */
- (void)requestCancel;
/**
 *	@brief	time：从直播开始到现在的秒数，SDK会在画板上绘画出来相应的图形
 */
- (void)continueFromTheTime:(NSInteger)time;

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
 *	@brief  播放器关闭
 */
- (void)shutdownPlayer;
/**
 *	@brief  播放器停止
 */
- (void)stopPlayer;
/**
 *	@brief  从头重新播放
 */
- (void)replayPlayer;
/**
 *	@brief  播放器是否播放
 */
- (BOOL)isPlaying;
/**
 *    @brief   播放器当前播放时间
 */
- (NSTimeInterval)currentPlaybackTime;
/**
 *    @brief   设置播放器当前播放时间（用于拖拽进度条时掉用的）
 */
- (void)setCurrentPlaybackTime:(NSTimeInterval)time;
/**
 *    @brief  回放视频总时长
 */
- (NSTimeInterval)playerDuration;
/**
 *	@brief  设置后台是否可播放
 */
- (void)setpauseInBackGround:(BOOL)pauseInBackGround;

/**
 *  @brief  改变文档背景颜色
 
 @param hexColor 字符串,传颜色的HEXColor 如:#000000
 */
- (void)changeDocWebColor:(NSString *)hexColor;
/**
 *  @brief 获取随堂测信息
 */
-(void)getPracticeInformation;
/**
 *  @brief 切换线路 (已废弃)
 * index 传入numberOfReceivedLines的返回值 如:返回2 则传0或1
 * results:
    success 0 切换成功 -1切换失败 -2 切换频繁
    currentIndex 当前播放线路
 */
- (void)changeLineWithNum:(NSInteger)index completion:(void (^)(NSDictionary * results))completion;

/**
 *  @brief 切换线路
 * param
 *       disableVideo  视频传no,音频传yes(账号开启音频模式下才可以传yes)
 *       lineNum 线路 例:-(void)numberOfReceivedLinesWithVideo:(NSArray *)videoArray audio:(NSArray *)audioArray;中videoArray元素个数为2 则传0或1
 * results:
    success 0 切换成功 -1切换失败 -2 切换频繁
    currentIndex 当前播放线路
 */
- (void)changeLineWithPlayParameter:(PlayParameter *)param completion:(void (^)(NSDictionary * results))completion;
/**
 *    @brief    主动调用方法      用于调整PPT缩放模式
 *    @param    docFrame        文档的frame
 *    @param    PPTScalingMode  PPT缩放模式
 *                               1.一种是全部填充屏幕，可拉伸变形，
 *                               2.第二种是等比缩放，横向或竖向贴住边缘，另一方向可以留黑边，
 *                               3.第三种是等比缩放，横向或竖向贴住边缘，另一方向出边界，裁剪PPT，不可以留黑边，
 *                               4.根据直播间文档显示模式的返回值进行设置(推荐)(The New Method)
 *
 *    需要调整docFrame 请直接调用 - (void)changeDocFrame:(CGRect)docFrame;方法
 */
- (void)changeDocFrame:(CGRect)docFrame withPPTScalingMode:(NSInteger)PPTScalingMode;

@end
