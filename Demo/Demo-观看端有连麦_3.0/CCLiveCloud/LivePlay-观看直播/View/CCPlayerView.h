//
//  CCPlayerView.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/31.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCPlayerView : UIView

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

/**
 *  @brief  切换横竖屏
 *  @param  screenLandScape yes:横屏 no:竖屏
 */
- (void)layouUI:(BOOL)screenLandScape;
/**
 *  @brief  切换横竖屏
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
