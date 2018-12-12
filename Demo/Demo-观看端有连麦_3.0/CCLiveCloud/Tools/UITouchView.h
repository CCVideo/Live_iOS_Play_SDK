//
//  UITouchView.h
//  NewCCDemo
//
//  Created by cc on 2016/11/26.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ViewBeTouched)();

@interface UITouchView : UIView

-(instancetype)initWithBlock:(ViewBeTouched)block passToNext:(BOOL)passToNext ;

@end
