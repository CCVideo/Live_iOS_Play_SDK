//
//  PrivateChatViewForOne.h
//  NewCCDemo
//
//  Created by cc on 2016/12/7.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

typedef void(^CloseBtnClicked)();

typedef void(^ChatIcBtnClicked)();

typedef void(^IsResponseBlock)(CGFloat y);

typedef void(^IsNotResponseBlock)();

@interface PrivateChatViewForOne : UIView

-(instancetype)initWithCloseBlock:(CloseBtnClicked)closeBlock ChatClicked:(ChatIcBtnClicked)chatBlock isResponseBlock:(IsResponseBlock)isResponseBlock isNotResponseBlock:(IsNotResponseBlock)isNotResponseBlock dataArrayForOne:(NSMutableArray *)dataArrayForOne anteid:(NSString *)anteid anteName:(NSString *)anteName isScreenLandScape:(BOOL)isScreenLandScape;

-(void)updateDataArray:(NSMutableArray *)dataArray;

@property(nonatomic,strong)CustomTextField          *chatTextField;

@end
