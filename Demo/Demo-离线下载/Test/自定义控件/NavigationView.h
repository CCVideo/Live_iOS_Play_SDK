//
//  NavigationView.h
//  NewCCDemo
//
//  Created by cc on 2016/11/25.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PushToIndex)(NSInteger);

@interface NavigationView : UIView

-(void)hideNavigationView ;

-(instancetype)initWithTitle:(NSString *)title pushBlock:(PushToIndex)pushBlock;

@end
