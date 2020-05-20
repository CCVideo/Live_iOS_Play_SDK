//
//  OfflinePlayBackViewController.h
//  CCOffline
//
//  Created by 何龙 on 2019/5/14.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OfflinePlayBackViewController : UIViewController


-(instancetype)initWithDestination:(NSString *)destination;
/*
 修改备注:1.聊天数据没有myViewerId这个字段
 2.图标元素缺失
 */
@end

NS_ASSUME_NONNULL_END
