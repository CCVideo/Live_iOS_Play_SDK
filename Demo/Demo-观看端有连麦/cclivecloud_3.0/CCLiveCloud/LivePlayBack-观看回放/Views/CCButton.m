//
//  CCButton.m
//  CCLiveCloud
//
//  Created by Apple on 2020/6/29.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "CCButton.h"

@implementation CCButton

/** 重写结束点击事件 */
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.endTouchBlock) {
            self.endTouchBlock(@"");
        }
    });
}

@end
