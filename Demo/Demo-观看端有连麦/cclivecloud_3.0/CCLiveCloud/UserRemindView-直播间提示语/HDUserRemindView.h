//
//  HDUserRemindView.h
//  CCLiveCloud
//
//  Created by Apple on 2020/8/29.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^showOrHiddenRemindView)(BOOL result);//显示或隐藏题型view

@interface HDUserRemindView : UIView

/** 数据源 */
@property (nonatomic,copy)   NSArray        *textDataArr;
/** 文字停留时间 */
@property (nonatomic,assign) CGFloat        textStayTime;
/** 文字滚动动画时间 */
@property (nonatomic,assign) CGFloat        scrollAnimationTime;

@property (nonatomic,copy) showOrHiddenRemindView showOrHiddenRemindView;

@end

NS_ASSUME_NONNULL_END
