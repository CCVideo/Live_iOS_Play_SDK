

#pragma mark- 集成须知

/**
 
 1:本产品作为一个demo供参考
 2:功能模块划分很详细了,每个模块的功能和UI都已经单独封装!
 3:项目入口为CCEntranceViewController 分为观看直播入口和观看回放入口,入口文件见左侧文件夹已经为您分别使用中/英文两种语言命名
 4:当您只需要使用某一个功能的时候只需要拷贝走对应的文件夹以及直播或者回放控制器的代码就好,对应的代码我们已经在selection中使用mark进行了标注(selection在当前路径的正上方, .m文件的旁边)
 5:如果遇到问题请先测试demo,如果demo也有问题请联系技术支持人员(请带上系统版本号,手机型号,SDK版本号,问题描述,有日志带上日志)
 6:如果遇到问题也可以直接百度"集成CC视频sdk+您的问题"自行解决
 
 [[SaveLogUtil sharedInstance]isNeedToSaveLog:YES];这个需要在AppDelegate.m中设置一下,如果遇见问题可以查看一下手机日志确定稳定的位置!如果不会查看手机日志的话可以参考:https://www.jianshu.com/p/d5e3a6109036
 
 祝您使用愉快!!!
 
 */

#import "AppDelegate.h"
#import "CCEntranceViewController.h"
#import "CCSDK/SaveLogUtil.h"
#import "CCNAVController.h"
#import <Bugly/Bugly.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [Bugly startWithAppId:@"144af8c8e4"];
    _window = [[UIWindow alloc] init];
    _window.backgroundColor = [UIColor whiteColor];
    _window.frame = [UIScreen mainScreen].bounds;
    CCEntranceViewController *vc = [[CCEntranceViewController alloc] init];
    CCNAVController *navigationController = [[CCNAVController alloc] initWithRootViewController:vc];
    self.window.rootViewController = navigationController;
    [_window makeKeyAndVisible];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
/**
 *  @brief  是否存储日志
 */
    [[SaveLogUtil sharedInstance]isNeedToSaveLog:YES];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
