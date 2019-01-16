//
//  CCPlayerView.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/31.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"
#import "InformationShowView.h"//提示框
#import "LianmaiView.h"//a连麦
#import "CCSDK/RequestData.h"//SDK
#import "SelectMenuView.h"//更多菜单
#import "LoadingView.h"//加载
NS_ASSUME_NONNULL_BEGIN

@protocol CCPlayerViewDelegate <NSObject>

/**
 点击全屏按钮
 */
- (void)quanpingButtonClick;

/**
 //结束直播和退出全屏
 
 @param sender 点击按钮
 */
- (void)backButtonClick:(UIButton *)sender;

@end

@interface CCPlayerView : UIView

@property (nonatomic, weak)id<CCPlayerViewDelegate>       delegate;
@property (nonatomic, strong)UIView                     * topShadowView;//上面的阴影
@property (nonatomic, strong)UIView                     * bottomShadowView;//下面的阴影
@property (nonatomic, strong)UIView                     * selectedIndexView;//选择线路背景视图
@property (nonatomic, strong)UIView                     * contentView;//横屏聊天视图
@property (nonatomic, strong)UILabel                    * titleLabel;//房间标题
@property (nonatomic, strong)UILabel                    * unStart;//直播未开始
@property (nonatomic, strong)UILabel                    * userCountLabel;//在线人数
@property (nonatomic, strong)UIButton                   * backButton;//返回按钮
@property (nonatomic, strong)UIButton                   * changeButton;//切换视频文档按钮
@property (nonatomic, strong)UIButton                   * quanpingButton;//全屏按钮
@property (nonatomic, strong)UIImageView                * liveUnStart;//直播未开始视图
@property (nonatomic, strong)CustomTextField            * chatTextField;//横屏聊天

@property (nonatomic,copy) void(^selectedRod)(NSInteger);//切换线路
@property (nonatomic,copy) void(^sendChatMessage)(NSString *);//发送聊天
@property (nonatomic,copy) void(^selectedIndex)(NSInteger,NSInteger);//切换清晰度

//----------------------------新加属性------------------------------------------
@property (nonatomic,strong)RequestData              * requestData;//sdk
@property(nonatomic,strong)SelectMenuView               *menuView;//选择菜单视图

@property (nonatomic,strong)UIView                   * smallVideoView;//文档或者小图

@property (nonatomic,strong)LoadingView              * loadingView;//加载视图
@property (nonatomic,assign)BOOL                     endNormal;//是否直播结束
@property (nonatomic,assign)NSInteger                  templateType;//房间类型
//#ifdef LIANMAI_WEBRTC
@property(nonatomic,strong)LianmaiView              *lianMaiView;//连麦
@property(assign,nonatomic)BOOL                     isAllow;
@property(assign,nonatomic)BOOL                     needReloadLianMainView;
@property(nonatomic,assign)BOOL                     lianMaiHidden;
@property(nonatomic,strong)InformationShowView      *informationViewPop;
@property(nonatomic, assign)NSInteger               videoType;
@property(nonatomic,assign)NSInteger                audoType;
@property(copy,nonatomic)  NSString                 *videosizeStr;
@property(nonatomic,assign)BOOL                     isAudioVideo;//YES表示音视频连麦，NO表示音频连麦
@property(strong,nonatomic)UIView                   *remoteView;//远程连麦视图
@property(nonatomic,strong)UIImageView              *connectingImage;//连麦中提示信息
//#endif

//meauView点击方法
-(void)menuViewSelected:(BOOL)selected;
//连麦点击
-(void)lianmaiBtnClicked;
/*
 *  @brief WebRTC连接成功，在此代理方法中主要做一些界面的更改
 */
- (void)connectWebRTCSuccess;
/*
 *  @brief 当前是否可以连麦
 */
- (void)whetherOrNotConnectWebRTCNow:(BOOL)connect;

- (void)acceptSpeak:(NSDictionary *)dict;
/*
 *  @brief 主播端发送断开连麦的消息，收到此消息后做断开连麦操作
 */
-(void)speak_disconnect:(BOOL)isAllow;
/*
 *  @brief 本房间为允许连麦的房间，会回调此方法，在此方法中主要设置UI的逻辑，
 *  在断开推流,登录进入直播间和改变房间是否允许连麦状态的时候，都会回调此方法
 */
- (void)allowSpeakInteraction:(BOOL)isAllow;
#pragma mark - 直播状态相关代理
/**
 *    @brief  收到播放直播状态 0直播 1未直播
 */
- (void)getPlayStatue:(NSInteger)status;
/**
 *    @brief  主讲开始推流
 */
- (void)onLiveStatusChangeStart;
/**
 *    @brief  停止直播，endNormal表示是否停止推流
 */
- (void)onLiveStatusChangeEnd:(BOOL)endNormal;
/**
 *  @brief  加载视频失败
 */
- (void)play_loadVideoFail;
#pragma mark- 视频或者文档大窗
/**
 *  @brief  视频或者文档大窗(The new method)
 *  isMain 1为视频为主,0为文档为主"
 */
- (void)onSwitchVideoDoc:(BOOL)isMain;



//-(void)changeBtnClick:(UIButton *)sender;
///**
// *  @brief  切换横竖屏
// *  @param  screenLandScape yes:横屏 no:竖屏
// */
//- (void)layouUI:(BOOL)screenLandScape;


/**
 *  @brief  切换线路
 *  @param  firRoadNum 线路
 *  @param  secRoadKeyArray 清晰度
 */
- (void)SelectLinesWithFirRoad:(NSInteger)firRoadNum secRoadKeyArray:(NSArray *)secRoadKeyArray;
/**
 *  @brief  插入弹幕内容
 *  @param  str 弹幕内容
 */
- (void)insertDanmuString:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
