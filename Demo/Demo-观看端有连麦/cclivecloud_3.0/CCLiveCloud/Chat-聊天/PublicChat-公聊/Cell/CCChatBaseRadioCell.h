//
//  CCChatBaseRadioCell.h
//  CCLiveCloud
//
//  Created by Apple on 2020/6/4.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCPublicChatModel.h"//公聊数据模型
NS_ASSUME_NONNULL_BEGIN

@interface CCChatBaseRadioCell : UITableViewCell
/**
 加载广播cell

 @param model 公聊数据模型
 */
-(void)setRadioModel:(CCPublicChatModel *)model;

@end

NS_ASSUME_NONNULL_END
