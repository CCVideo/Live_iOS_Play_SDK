//
//  CCDocView.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/3/21.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCDocView : UIView

@property (nonatomic, copy)void(^hiddenSmallVideoBlock)(void);
@property (nonatomic, copy)void(^changeDocView)(BOOL isScreenLandscape);
/**
 初始化方法

 @param smallVideo 是否是文档小窗
 @return self
 */
-(instancetype)initWithType:(BOOL)smallVideo;

@end

NS_ASSUME_NONNULL_END
