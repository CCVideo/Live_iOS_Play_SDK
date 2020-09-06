//
//  CCClassTestProgressView.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/27.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCClassTestProgressView : UIView

/**
 *    @brief    初始化方法
 *    @param    frame frame
 *    @param    dic 统计字典
 *    @param    isScreen 是否是全屏
 *    @return   self
 */
-(instancetype)initWithFrame:(CGRect)frame ResultDic:(NSDictionary *)dic isScreen:(BOOL)isScreen;

/**
 *    @brief    更新方法
 *    @param    dic 随堂测统计字典
 *    @param    isScreen 是否是全屏
 */
-(void)updateWithResultDic:(NSDictionary *)dic isScreen:(BOOL)isScreen;

@end

NS_ASSUME_NONNULL_END
