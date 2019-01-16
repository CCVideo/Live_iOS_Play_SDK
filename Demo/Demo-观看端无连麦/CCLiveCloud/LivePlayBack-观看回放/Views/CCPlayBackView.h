//
//  CCPlayBackView.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/20.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySlider.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCPlayBackView : UIView

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

@property (nonatomic,copy) void(^sliderCallBack)(int);
@property (nonatomic,copy) void(^sliderMoving)(void);

/**
 改变横竖屏

 @param screenLandScape 横竖屏
 */
- (void)layouUI:(BOOL)screenLandScape;

@end

NS_ASSUME_NONNULL_END
