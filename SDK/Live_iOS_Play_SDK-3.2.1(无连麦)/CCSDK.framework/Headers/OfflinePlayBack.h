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

@protocol OfflinePlayBackDelegate <NSObject>
@optional
/**
 *	@brief  获取文档内白板或者文档本身的宽高，来进行屏幕适配用的
 */
- (void)offline_getDocAspectRatioOfWidth:(CGFloat)width height:(CGFloat)height;
/**
 *	@brief	收到本房间的历史提问&回答
 */
- (void)offline_onParserQuestionArr:(NSArray *)questionArr onParserAnswerArr:(NSArray *)answerArr;
/**
 *	@brief	解析本房间的历史聊天数据
 */
-(void)offline_onParserChat:(NSArray *)arr;
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
-(void)offline_roomInfo:(NSDictionary *)dic;
/**
 *    @brief   加载视频失败
 */
- (void)offline_loadVideoFail;
/**
 *    @brief   回放翻页数据列表
 */
- (void)pageChangeList:(NSMutableArray *)array;
/**
 *  @brief  收到本房间历史广播(The new method)
 *  content 广播内容
 *  time 发布时间(单位:秒)
 */
- (void)broadcastHistory_msg:(NSArray *)array;
/**
 *  @brief 回放的开始时间和结束时间(The new method)
 */
-(void)liveInfo:(NSDictionary *)dic;

/**
 *    @brief    文档加载状态(The new method)
 *    index
 *      2 非动画文档加载完成
 */
- (void)docLoadCompleteWithIndex:(NSInteger)index;



@end

@interface OfflinePlayBack : NSObject

@property (weak,nonatomic) id<OfflinePlayBackDelegate>  delegate;//代理
@property (retain,    atomic) id<IJKMediaPlayback>      ijkPlayer;//播放器
/**
 *	@brief	初始化
 *	@param 	parameter   配置参数信息
 *  必填参数 docFrame;
 *  必填参数 docParent;
 *  必填参数 playerParent;
 *  必填参数 playerFrame;
 *  必填参数 scalingMode;
 *  必填参数 destination;
 *  必填参数 defaultColor;
 *  必填参数 PPTScalingMode;
 *  必填参数 pauseInBackGround;
 */
- (id)initWithParameter:(PlayParameter *)parameter;

/**
 *  @brief	开始解析数据并播放视频
 */
-(void)startPlayAndDecompress;

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
 *	@brief  播放器关闭并移除
 */
- (void)shutdownPlayer;
/**
 *	@brief  播放器停止
 */
- (void)stopPlayer;
/**
 *	@brief  从头播放
 */
- (void)replayPlayer;
/**
 *	@brief  播放器是否播放
 */
- (BOOL)isPlaying;
/**
 *  @brief  播放器当前播放时间
 */
- (NSTimeInterval)currentPlaybackTime;
/**
 *  @brief  设置播放器当前播放时间（用于拖拽进度条时掉用的）
 */
- (void)setCurrentPlaybackTime:(NSTimeInterval)time;
/**
 *  @brief 回放视频总时长
 */
- (NSTimeInterval)playerDuration;
/**
 *	@brief  设置后台是否可播放
 */
- (void)setpauseInBackGround:(BOOL)pauseInBackGround;
/**
 * @brief 解压并解密(加密和非加密均能解压)
 * @param dst 需要进行解压解密的文件.
 * @param dir 解压后输出目录, =NULL则解压到当前目录.
 * @return 0-成功
 * errcode:
 -1 -打开输入文件(dst)失败；
 -2 -本地生成(dst)内部目录或文件失败,fopen或mkdir失败，检测是否有权限或者目录名是否正确;
 -3 -获取压缩文件中具体文件信息(dst->file)失败;
 -4 -获取全局信息(dst)失败;
 -5 -打开或读取压缩文件的内部文件失败;
 -6 -dst存在但并不是加密文件格式;
 */
- (int)DecompressZipWithDec:(NSString *)dst dir:(NSString *)dir;


@end
