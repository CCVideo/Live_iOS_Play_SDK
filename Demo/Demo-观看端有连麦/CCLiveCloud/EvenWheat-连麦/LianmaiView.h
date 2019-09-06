//
//  LianmaiView.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/12/26.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol LianMaiDelegate <NSObject>
@optional


/**
 请求连麦

 @param isVideo 是否是视频
 */
-(void)requestLianmaiBtnClicked:(BOOL)isVideo;

//取消连麦
-(void)cancelLianmainBtnClicked;

//挂断连麦
-(void)hungupLianmainiBtnClicked;

@end;

typedef void(^IsVideoBlock)(BOOL isVideo);//是否是视频回调

@interface LianmaiView : UIView

//@property(nonatomic,strong)UIButton                 *requestLianmaiBtn;
@property (nonatomic, strong) UIButton              *audioBtn;//音频按钮
@property (nonatomic, strong) UIButton              *videoBtn;//视频按钮
@property(nonatomic,strong)UIButton                 *cancelLianmainBtn;//取消连麦按钮
@property(nonatomic,strong)UIButton                 *hungupLianmainBtn;//挂断连麦按钮
@property(weak,nonatomic)  id<LianMaiDelegate>      delegate;//连麦代理
@property(nonatomic,assign)BOOL                     needToRemoveLianMaiView;//是否需要移除连麦视图
@property(nonatomic,copy)IsVideoBlock               isVideoBlock;//是否是视频回调


/**
 初始化方法

 @param videoPermission 视频权限
 @param audioPermission 音频权限
 */
-(void) initUIWithVideoPermission:(AVAuthorizationStatus)videoPermission AudioPermission:(AVAuthorizationStatus)audioPermission;
/**
 成功连接
 */
-(void) connectWebRTCSuccess;

/**
 没有网络
 */
-(void) hasNoNetWork;

/**
 正在连接
 */
-(void) connectingToRTC;


/**
 是否正在连接

 @return 是否连接中
 */
-(BOOL)isConnecting;


/**
 初始化连麦申请状态
 */
-(void)initialState;

//-(instancetype)initWithVideo:(BOOL)isVideo;

@end
