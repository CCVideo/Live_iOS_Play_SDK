//
//  CCLockView.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/3/12.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


/**
 暂停回调

 @param pause 是否暂停
 */
typedef void(^PauseCallBack)(BOOL pause);

/**
 改变播放进度回调

 @param time 改变后的进度时间
 */
typedef void(^ChangeProgress)(int time);
@interface CCLockView : UIView

@property (nonatomic, copy) PauseCallBack pauseCallBack;
@property (nonatomic, copy) ChangeProgress progressBlock;

/**
 初始化方法

 @param roomName 房间名称
 @param duration 视频时长
 @return self
 */
-(instancetype)initWithRoomName:(NSString *)roomName duration:(int)duration;

/**
 更新锁屏信息
 */
-(void)updateLockView;

/**
 更新当前的时间

 @param currentDurtion 当前的时间
 */
-(void)updateCurrentDurtion:(int)currentDurtion;

/**
 更新播放速率

 @param rate 播放速率
 */
-(void)updatePlayBackRate:(float)rate;

/**
 更新聊天信息

 @param str 聊天信息
 */
-(void)updateCurrentChat:(NSString *)str;
@end

NS_ASSUME_NONNULL_END
