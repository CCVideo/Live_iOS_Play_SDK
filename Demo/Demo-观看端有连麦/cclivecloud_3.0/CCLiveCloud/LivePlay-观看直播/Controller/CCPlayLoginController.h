//
//  CCPlayLoginController.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/29.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCPlayLoginController : UIViewController


/**
 从网页端调起，如果是直播自动登录，调用此方法;
 */
-(void)loginAction;
@end

NS_ASSUME_NONNULL_END
