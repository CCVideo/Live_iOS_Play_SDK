//
//  MySlider.m
//  NewCCDemo
//
//  Created by cc on 2016/12/15.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "MySlider.h"
#define thumbBound_x 10
#define thumbBound_y 20

@interface MySlider()

@property(nonatomic,assign)CGRect       lastBounds;

@end

@implementation MySlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    rect.origin.y= rect.origin.y-10;
    rect.origin.x= rect.origin.x-16;
    rect.size.height= rect.size.height+20;
    rect.size.width= rect.size.width+32;//35

    CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
    _lastBounds = result;
    return result;
}

- (CGRect)trackRectForBounds:(CGRect)bounds {
    
    return CGRectMake(0, 0, bounds.size.width, 3);
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    
//    UIView *result = [super hitTest:point withEvent:event];
//    if ((point.y >= -thumbBound_y) && (point.y < _lastBounds.size.height + thumbBound_y)) {
//        float value = 0.0;
//        value = point.x - self.bounds.origin.x;
//        value = value/self.bounds.size.width;
//        
//        value = value < 0? 0 : value;
//        value = value > 1? 1: value;
//        
//        value = value * (self.maximumValue - self.minimumValue) + self.minimumValue;
//        [self setValue:value animated:YES];
//    }
//    return result;
//    
//}
//
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
//    BOOL result = [super pointInside:point withEvent:event];
//    if (!result && point.y > -10) {
//        if ((point.x >= _lastBounds.origin.x - thumbBound_x) && (point.x <= (_lastBounds.origin.x + _lastBounds.size.width + thumbBound_x)) && (point.y < (_lastBounds.size.height + thumbBound_y))) {
//            result = YES;
//        }
//    }
//    return result;
//}

@end

