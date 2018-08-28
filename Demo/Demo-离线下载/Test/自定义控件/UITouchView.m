//
//  UITouchView.m
//  NewCCDemo
//
//  Created by cc on 2016/11/26.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "UITouchView.h"

@interface UITouchView()

@property(nonatomic,copy)ViewBeTouched      block;
@property(nonatomic,assign)BOOL             passToNext ;

@end

@implementation UITouchView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithBlock:(ViewBeTouched)block passToNext:(BOOL)passToNext {
    self = [super init];
    if(self) {
        self.block = block;
        self.passToNext = passToNext;
    }
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(self.block) {
        self.block();
    }
    if(self.passToNext) {
        NSLog(@"sdfdsfsdfdsfdsfdsfds");
        [super touchesBegan:touches withEvent:event];
    }
}

@end
