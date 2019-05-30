//
//  AnnouncementView.h
//  CCLiveCloud
//
//  Created by 何龙 on 2018/12/25.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnnouncementView : UIView

/**
 初始化方法

 @param str 公告内容
 @return self
 */
-(instancetype)initWithAnnouncementStr:(NSString *)str;
/**
 更新公告内容

 @param str 公告内容
 */
-(void)updateViews:(NSString *)str;
@end

NS_ASSUME_NONNULL_END
