//
//  CCButton.h
//  CCLiveCloud
//
//  Created by Apple on 2020/6/29.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 *    @brief    结束点击的回调
 */
typedef void(^endTouchBlock)(NSString *sting);

@interface CCButton : UIButton

@property (nonatomic, copy) endTouchBlock endTouchBlock;

@end

NS_ASSUME_NONNULL_END
