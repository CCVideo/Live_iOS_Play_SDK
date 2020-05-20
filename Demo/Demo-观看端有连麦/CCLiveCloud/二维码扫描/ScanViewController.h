//
//  ScanViewController.h
//  NewCCDemo
//
//  Created by cc on 2016/12/4.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanViewController : UIViewController
/*
 扫描类型：（1）我要直播，（2）观看直播，（3）观看回放 (4) 离线回放
 */
-(instancetype)initWithType:(NSInteger)index;

@end
