//
//  QuestionView.h
//  NewCCDemo
//
//  Created by cc on 2016/12/30.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^QuestionBlock)(NSString *message);

@interface QuestionView : UIView

-(instancetype)initWithQuestionBlock:(QuestionBlock)questionBlock input:(BOOL)input;

-(void)reloadQADic:(NSMutableDictionary *)QADic keysArrAll:(NSMutableArray *)keysArrAll;

@end
