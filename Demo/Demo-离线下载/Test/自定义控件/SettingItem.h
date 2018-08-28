//
//  SettingItem.h
//  NewCCDemo
//
//  Created by cc on 2016/11/28.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ActionBlock)();
typedef void(^SwitchBtnClickedBlock)();

@interface SettingItem : UIView

@property(nonatomic,strong)UILabel              *rightLabel;

-(void)setSwitchBtnClickedBlock:(SwitchBtnClickedBlock)switchBtnClickedBlock;

- (void)settingWithLineLong:(BOOL)lineLong leftText:(NSString *)leftText rightText:(NSString *)rightText rightArrow:(BOOL)rightArrow screenDirection:(BOOL)screenDirection beautiful:(BOOL)beautiful block:(ActionBlock)block ;

-(void)setSwitchOn:(BOOL)on;

-(BOOL)isSwitchOn;

@end
