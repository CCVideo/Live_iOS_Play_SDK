//
//  SelectMenuView.h
//  NewCCDemo
//
//  Created by cc on 2016/11/26.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ButtonClicked)();
typedef void (^PushToIndex)(NSInteger);

@interface SelectMenuView : UIView

-(instancetype)initWithBlock:(ButtonClicked)block pushBlock:(PushToIndex)pushBlock;

-(void)showMenuWithIndex:(NSInteger) index;

@end
