//
//  HDPlayerView.h
//  HDBaseUtils
//
//  Created by zwl on 2020/5/12.
//  Copyright © 2020 zwl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class HDPlayerView;

@protocol HDPlayerViewDelegate <NSObject>

@optional
//可播放
- (void)videoPlayerIsReadyToPlayVideo:(HDPlayerView *)playerView;

//播放完毕
- (void)videoPlayerDidReachEnd:(HDPlayerView *)playerView;

//播放中  time:当前播放时间
- (void)videoPlayer:(HDPlayerView *)playerView timeDidChange:(float)time;

//duration 当前缓冲的长度
- (void)videoPlayer:(HDPlayerView *)playerView loadedTimeRangeDidChange:(float)duration;

//没数据 即播放卡顿
- (void)videoPlayerPlaybackBufferEmpty:(HDPlayerView *)playerView;

//有数据 能够继续播放
- (void)videoPlayerPlaybackLikelyToKeepUp:(HDPlayerView *)playerView;

//加载超时/scrub超时
//- (void)videoPlayer:(HDPlayerView *)playerView receivedTimeOut:(DWPlayerViewTimeOut )timeOut;

//加载失败
- (void)videoPlayer:(HDPlayerView *)playerView didFailWithError:(NSError *)error;

//AVPlayerLayer对象发生改变时回调
//- (void)videoPlayer:(DWPlayerView *)playerView ChangePlayerLayer:(AVPlayerLayer *)playerLayer;

@end

@interface HDPlayerView : UIView

/**
 播放属性
 */
@property(nonatomic,strong,readonly)AVPlayer *player;

/**
 播放图层
 */
@property(nonatomic,strong,readonly)AVPlayerLayer *playerLayer;

/**
 代理
 */
@property(nonatomic,weak) id<HDPlayerViewDelegate> delegate;

/**
 AVPlayerLayer的videoGravity属性设置
 AVLayerVideoGravityResize,       // 非均匀模式。两个维度完全填充至整个视图区域
 AVLayerVideoGravityResizeAspect,  // 等比例填充，直到一个维度到达区域边界
 AVLayerVideoGravityResizeAspectFill, // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
 */
@property(nonatomic,copy)NSString *videoGravity;

/**
 //是否正在播放
 */
@property(nonatomic,assign,readonly)BOOL playing;

/**
 初始化播放对象

 @return DWPlayerView
 */
-(instancetype)init;

/**
 初始化播放对象

 @param frame
 @return DWPlayerView
 */
-(instancetype)initWithFrame:(CGRect)frame;

/// 设置播放链接
/// @param URL 播放地址
- (void)setURL:(NSURL *)URL;

/**
 切换倍速
 
 @param rate 速率
 */
- (void)setPlayerRate:(float)rate;

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 拖到XX秒播放视频，在AVPlayerItemStatusReadyToPlay即状态处于可播放后 才会有效果

 @param time 跳转时间
 */
- (void)scrub:(float)time;

/**
 精确拖拽到XX秒播放视频，在AVPlayerItemStatusReadyToPlay即状态处于可播放后 才会有效果

 @param time 跳转时间
 @param completion 跳转完成回调
 */
-(void)scrubPrecise:(float)time CompletionHandler:(void(^)(BOOL finished))completion;

/**
 关闭|释放播放资源
 */
- (void)resetPlayer;

/**
 停止视频播放统计 播放页面关闭时务必调用removeTimer方法
 注意：播放页面关闭时 如需释放资源 调用方式如下{
                                          [playerView removeTimer];
                                          [playerView resetPlayer];
 
                                        }
 
                 如无需释放播放资源 调用方式如下{
                                            [playerView removeTimer];
                                            [playerView pause];
 }
 */
- (void)removeTimer;

@end

