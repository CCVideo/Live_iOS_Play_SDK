//
//  QuestionnaireSurveyPopUp.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/12/20.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//
//

#import <UIKit/UIKit.h>

//确认回调
typedef void(^SureBtnBlock)(void);

@interface QuestionnaireSurveyPopUp : UIView

/**
 初始化方法

 @param isScreenLandScape 是否是全屏
 @param sureBtnBlock 点击确定回调
 @return self
 */
-(instancetype)initIsScreenLandScape:(BOOL)isScreenLandScape
                        SureBtnBlock:(SureBtnBlock)sureBtnBlock;

@end
