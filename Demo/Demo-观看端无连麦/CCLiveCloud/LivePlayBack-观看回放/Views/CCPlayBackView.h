//
//  CCPlayBackView.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/20.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySlider.h"
#import "LoadingView.h"//加载
#import "CCDocView.h"//文档视图
NS_ASSUME_NONNULL_BEGIN

@protocol CCPlayBackViewDelegate <NSObject>

/**
 全屏按钮点击代理

 @param tag 1视频为主，2文档为主
 */
-(void)quanpingBtnClicked:(NSInteger)tag;

/**
 返回按钮点击代理

 @param tag 1.视频为主，2.文档为主
 */
-(void)backBtnClicked:(NSInteger)tag;

/**
 切换视频/文档按钮点击回调

 @param tag changeBtn的tag值
 */
-(void)changeBtnClicked:(NSInteger)tag;

/**
 开始播放时调用此方法
 */
-(void)timerfunc;

@end

@interface CCPlayBackView : UIView
@property (nonatomic,assign)BOOL                          isScreenLandScape;//是否横屏
@property (nonatomic,assign)float                         playBackRate;//播放速率
@property (nonatomic,strong)NSTimer                     * timer;//计时器
@property (nonatomic,strong)CCDocView                   * smallVideoView;//文档或者小图
@property (nonatomic, strong)UIButton                   * smallCloseBtn;//小窗关闭按钮
@property (nonatomic,strong)LoadingView                 * loadingView;//加载视图
@property (nonatomic, weak)id<CCPlayBackViewDelegate>   delegate;//代理

@property (nonatomic, strong)UILabel                    * titleLabel;//房间标题
@property (nonatomic, strong)UILabel                    * leftTimeLabel;//当前播放时长
@property (nonatomic, strong)UILabel                    * rightTimeLabel;//总时长
@property (nonatomic, strong)MySlider                   * slider;//滑动条
@property (nonatomic, strong)UIButton                   * backButton;//返回按钮
@property (nonatomic, strong)UIButton                   * changeButton;//切换视频文档按钮
@property (nonatomic, strong)UIButton                   * quanpingButton;//全屏按钮
@property (nonatomic, strong)UIButton                   * pauseButton;//暂停按钮
@property (nonatomic, strong)UIButton                   * speedButton;//倍速按钮
@property (nonatomic, assign)NSInteger                  sliderValue;//滑动值
@property (nonatomic, strong)UIView                     * topShadowView;//上面的阴影
@property (nonatomic, strong)UIView                     * bottomShadowView;//下面的阴影

@property (nonatomic, strong)UIImageView                * liveEnd;//播放结束视图

@property (nonatomic,copy) void(^exitCallBack)(void);//退出直播间回调
@property (nonatomic,copy) void(^sliderCallBack)(int);//滑块回调
@property (nonatomic,copy) void(^sliderMoving)(void);//滑块移动回调
@property (nonatomic,copy) void(^changeRate)(float rate);//改变播放器速率回调
@property (nonatomic,copy) void(^pausePlayer)(BOOL pause);//暂停播放器回调




/**
 初始化方法

 @param frame frame
 @param isSmallDocView 是否是文档小窗
 @return self;
 */
- (instancetype)initWithFrame:(CGRect)frame docViewType:(BOOL)isSmallDocView;
/**
 开始播放
 */
-(void)startTimer;

/**
 停止播放
 */
-(void)stopTimer;

/**
 显示加载中视图
 */
-(void)showLoadingView;

/**
 移除加载中视图
 */
-(void)removeLoadingView;
#pragma mark - 屏幕旋转
//转为横屏
-(void)turnRight;
//转为竖屏
-(void)turnPortrait;
//添加小窗
- (void)addSmallView;
@end

NS_ASSUME_NONNULL_END
