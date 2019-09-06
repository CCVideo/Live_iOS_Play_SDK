//
//  LotteryView.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/22.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LotteryView : UIView

/**
 初始化方法

 @param isScreenLandScape 是否是全屏
 @param clearColor clearColor
 @return self
 */
-(instancetype)initIsScreenLandScape:(BOOL)isScreenLandScape clearColor:(BOOL)clearColor;

/**
 *  @brief  抽奖结果
 *  remainNum   剩余奖品数
 */
- (void)lottery_resultWithCode:(NSString *)code myself:(BOOL)myself winnerName:(NSString *)winnerName remainNum:(NSInteger)remainNum IsScreenLandScape:(BOOL)isScreenLandScape;

//移除视图
-(void)remove;
/**
 自己获奖

 @param code 中奖码
 */
-(void)myselfWin:(NSString *)code;

/**
 其他人中奖

 @param winnerName 中奖者名称
 */
-(void)otherWin:(NSString *)winnerName;

@property(nonatomic,assign)NSInteger                   type;

@end
