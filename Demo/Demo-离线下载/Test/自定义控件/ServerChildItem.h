//
//  ServerChildItem.h
//  NewCCDemo
//
//  Created by cc on 2016/11/28.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ButtonClicked)();

@interface ServerChildItem : UIView

@property(nonatomic,strong)UIButton             *leftBtn;
@property(nonatomic,strong)UILabel              *rightLabel;
@property(nonatomic,strong)UILabel              *leftLabel;

- (void)settingWithLineLong:(BOOL)lineLong leftText:(NSString *)leftText rightText:(NSString *)rightText selected:(BOOL)selected block:(ButtonClicked)block ;

@end
