//
//  VoteViewResult.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/12/25.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteViewResult : UIView

/**
 初始化方法

 @param resultDic 答题结果字典
 @param mySelectIndex 我选择的答案
 @param mySelectIndexArray 我选择的答案数组
 @param isScreenLandScape 是否全屏
 @return self
 */
-(instancetype) initWithResultDic:(NSDictionary *)resultDic
                    mySelectIndex:(NSInteger)mySelectIndex
               mySelectIndexArray:(NSMutableArray *)mySelectIndexArray
                isScreenLandScape:(BOOL)isScreenLandScape;

@end
