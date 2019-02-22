//
//  ScanOverViewController.h
//  NewCCDemo
//
//  Created by cc on 2016/12/5.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OkBtnClickBlock)();//确认点击回调

@interface ScanOverViewController : UIViewController

/**
 初始化方法

 @param block 确认回调
 @return self
 */
-(instancetype)initWithBlock:(OkBtnClickBlock)block;

@end
