//
//  UISetingChildItem.h
//  NewCCDemo
//
//  Created by cc on 2016/11/28.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ButtonClicked)();

@interface UISetingChildItem : UIView

@property(nonatomic,strong)UIButton          *rightBtn;

- (void)settingWithLineLong:(BOOL)lineLong leftText:(NSString *)leftText selected:(BOOL)selected block:(ButtonClicked)block ;

@end
