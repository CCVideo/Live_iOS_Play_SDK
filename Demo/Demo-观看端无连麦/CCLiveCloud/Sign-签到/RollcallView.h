//
//  RollcallView.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/22.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

//签到回调
typedef void(^LotteryBtnClicked)(void);

@interface RollcallView : UIView

    
/**
 初始化签到

 @param duration 签到时长
 @param lotteryblock 签到回调
 @param isScreenLandScape 是否全屏
 @return self
 */
-(instancetype) initWithDuration:(NSInteger)duration
                    lotteryblock:(LotteryBtnClicked)lotteryblock
               isScreenLandScape:(BOOL)isScreenLandScape;

@end
