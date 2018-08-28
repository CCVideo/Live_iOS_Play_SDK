//
//  QuestionnaireSurvey.h
//  NewCCDemo
//
//  Created by cc on 2017/8/9.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CloseBlock)();
typedef void(^CommitBlock)(NSDictionary *dic);

@interface QuestionnaireSurvey : UIView


-(instancetype)initWithCloseBlock:(CloseBlock)closeblock CommitBlock:(CommitBlock)commitblock questionnaireDic:(NSDictionary *)questionnaireDic isScreenLandScape:(BOOL)isScreenLandScape isStastic:(BOOL)isStastic;

-(void)commitSuccess:(BOOL)success;

@end
