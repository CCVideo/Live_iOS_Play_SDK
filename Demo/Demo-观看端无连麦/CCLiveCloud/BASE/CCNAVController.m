//
//  CCNAVController.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/28.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCNAVController.h"

@interface CCNAVController ()

@end

@implementation CCNAVController

- (void)viewDidLoad {
    [super viewDidLoad];
}
/**
 *  @brief  跟控制器设置旋转屏
 *  ps:跟控制器为UINavigationController
 */
-(BOOL)shouldAutorotate {
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations {
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

/**
 *  @brief  跟控制器设置旋转屏
 *  ps: 跟控制器是tabBar控制器，那么在这个tabBar控制器中实现下面三个方法
 */
//-(BOOL)shouldAutorotate {
//    return [self.selectedViewController shouldAutorotate];
//}
//
//-(NSUInteger)supportedInterfaceOrientations {
//    return [self.selectedViewController supportedInterfaceOrientations];
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
//}


@end
