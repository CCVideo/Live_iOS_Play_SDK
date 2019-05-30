//
//  CCPrivateChatViewCell.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/22.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dialogue.h"//数据模型
NS_ASSUME_NONNULL_BEGIN

@interface CCPrivateChatViewCell : UITableViewCell
@property (nonatomic, copy) void(^reloadIndexPath)(NSIndexPath *indexPath);//刷新某一行
//设置cell样式
-(void)setModel:(Dialogue *)dialog WithIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
