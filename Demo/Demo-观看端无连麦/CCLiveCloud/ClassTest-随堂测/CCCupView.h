//
//  CCCupView.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/3/7.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCCupView : UIView


/**
 奖杯初始化

 @param winnerName 获胜的用户名称(为@""时默认自己胜利)
 @param isScreen 是否是全屏
 @return self
 */
-(instancetype)initWithWinnerName:(NSString *)winnerName isScreen:(BOOL)isScreen;

@end

NS_ASSUME_NONNULL_END
