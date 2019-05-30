//
//  UIButton+UserInfo.m
//  demo
//
//  Created by cc on 16/10/11.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "UIButton+UserInfo.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

static char key;

@implementation UIButton (UserInfo)

- (NSObject *)userid {
    return objc_getAssociatedObject(self, &key);
}

- (void)setUserid:(NSObject *)value {
    objc_setAssociatedObject(self, &key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
