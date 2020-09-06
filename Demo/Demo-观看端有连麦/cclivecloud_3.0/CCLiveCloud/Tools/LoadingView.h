//
//  LoadingView.h
//  NewCCDemo
//
//  Created by cc on 2016/11/27.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

@property(nonatomic,strong)UILabel                  *label;

-(instancetype)initWithLabel:(NSString *)str centerY:(BOOL)centerY ;

@end
