//
//  CCChatBaseImageCell.h
//  CCLiveCloud
//
//  Created by Apple on 2020/6/4.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCImageView.h"
#import "CCPublicChatModel.h"//公聊数据模型
NS_ASSUME_NONNULL_BEGIN

typedef void(^HeadBtnClickBlock)(UIButton *btn);//头像点击回调

@interface CCChatBaseImageCell : UITableViewCell

@property (nonatomic, copy) HeadBtnClickBlock headBtnClick;
#pragma mark - 图片消息
@property (nonatomic, strong) CCImageView *smallImageView;//图片视图

/**
 加载图片cell

 @param model 公聊数据模型
 @param input 是否有输入框
 @param indexPath 位置下标
 */
-(void)setImageModel:(CCPublicChatModel *)model
             isInput:(BOOL)input
           indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
