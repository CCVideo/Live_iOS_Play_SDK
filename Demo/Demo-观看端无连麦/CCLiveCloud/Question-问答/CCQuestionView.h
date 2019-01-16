//
//  CCQuestionView.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/6.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^QuestionBlock)(NSString *message);

@interface CCQuestionView : UIView

-(instancetype)initWithQuestionBlock:(QuestionBlock)questionBlock input:(BOOL)input;

-(void)reloadQADic:(NSMutableDictionary *)QADic keysArrAll:(NSMutableArray *)keysArrAll;

@end



NS_ASSUME_NONNULL_END
