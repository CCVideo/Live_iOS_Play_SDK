//
//  CCBarrage.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/5/5.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCPublicChatModel.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, BarrageStyle) {//弹幕样式
    NomalBarrageStyle,//正常显示模式
    FixedSpeedAnimationCellBarrageStyle,//彩色背景模式
};
typedef NS_ENUM(NSUInteger, RenderViewStyle){//弹幕视图显示位置
    RenderViewFullScreen = 0,//全屏
    RenderViewCenter,//中
    RenderViewBottom,//下
    RenderViewTop//上
};
@interface CCBarrage : NSObject
/**
 初始化方法

 @param videoView 视频视图
 */
//-(instancetype)initWithVideoView:(UIView *)videoView barrageStyle:(BarrageStyle)barrageStyle;
-(instancetype)initWithVideoView:(UIView *)videoView barrageStyle:(BarrageStyle)barrageStyle ReferenceView:(UIView *)referenceView;


/**
 添加一条弹幕信息

 @param model 弹幕数据
 */
-(void)insertBarrageMessage:(CCPublicChatModel *)model;


/**
 停止弹幕
 */
-(void)barrageClose;

/**
 开启弹幕
 */
-(void)barrageOpen;

/**
 暂停弹幕
 */
- (void)barragePause;

/**
 继续弹幕
 */
- (void)barrageResume;


/**
 更改弹幕渲染层样式

 @param renderViewStyle 弹幕样式
 */
-(void)changeRenderViewStyle:(RenderViewStyle)renderViewStyle;


/**
 更改弹幕消息样式

 @param barrageStyle 弹幕消息样式
 */
-(void)changeBarrageStyle:(BarrageStyle)barrageStyle;
@end

NS_ASSUME_NONNULL_END
