//
//  GongGaoView.h
//  NewCCDemo
//
//  Created by cc on 2016/12/17.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CloseBlock)();

@interface GongGaoView : UIView

-(instancetype)initWithLeftLabelText:(NSString *)leftLabelText isScreenLandScape:(BOOL)isScreenLandScape forPC:(BOOL)forPC block:(CloseBlock)block ;

-(void)updateViews:(NSString *)str;

@end

