//
//  AppDelegate.m
//  Test
//
//  Created by cc on 2017/1/23.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "AppDelegate.h"
#import "DownLoadViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

/*
 Demo 离线下载主要类说明：
 FileManager 文件处理类，负责文件内容读入和读取
 Download 下载类，下载文件在此类中，用NSURLSession来下载，具体用法网上可以查，断点续传后台下载都支持
 AddUrlViewController 扫码或者手动添加URL的controller类
 PlayBackVC 播放类，展示画面及聊天，文档，问答
 DownLoadViewController 下载列表类，注意UITableViewCell复用问题，我没有复用，我复用的时候出现了一些UI错乱的问题，因为一些被复用的Cell所关联的下载数据一直在下载并尝试更新UI，当Cell超出屏幕时会出现下载进度前后摆动的异常现象，现在的解决办法是不复用，没有出现问题，如果您有更好的办法，请告知😄
 MyTableViewCell 自定义UITableViewCell
 */

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    CCLog(@"SCREEN_SCALE = %f,NativeScale = %f",SCREEN_SCALE,NativeScale);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    DownLoadViewController *downLoadViewController = [[DownLoadViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:downLoadViewController];
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [application beginBackgroundTaskWithExpirationHandler:^{
        
    }];
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
