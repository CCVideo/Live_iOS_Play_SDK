//
//  CCQuestionViewCell.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/14.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dialogue.h"//数据模型
NS_ASSUME_NONNULL_BEGIN

@interface CCQuestionViewCell : UITableViewCell

/**
 为cell赋值

 @param dialogue 数据模型
 @param indexPath cell下标
 @param arr arr
 @param input 是否输入
 */
-(void)setQuestionModel:(Dialogue *)dialogue
              indexPath:(NSIndexPath *)indexPath
                    arr:(NSMutableArray *)arr
                isInput:(BOOL)input;

@end

NS_ASSUME_NONNULL_END
