

#pragma mark- 集成须知

/**
 
 1:本产品作为一个demo供参考
 2:功能模块划分很详细了,每个模块的功能和UI都已经单独封装!
 3:项目入口为CCEntranceViewController 分为观看直播入口和观看回放入口,入口文件见左侧文件夹已经为您分别使用中/英文两种语言命名
 4:当您只需要使用某一个功能的时候只需要拷贝走对应的文件夹以及直播或者回放控制器的代码就好,对应的代码我们已经在selection中使用mark进行了标注(selection在当前路径的正上方, .m文件的旁边)
 5:如果遇到问题请先测试demo,如果demo也有问题请联系技术支持人员(请带上系统版本号,手机型号,SDK版本号,问题描述,有日志带上日志)
 6:如果遇到问题也可以直接百度"集成CC视频sdk+您的问题"自行解决
 
 [[SaveLogUtil sharedInstance]isNeedToSaveLog:YES];这个需要在AppDelegate.m中设置一下,如果遇见问题可以查看一下手机日志确定稳定的位置!如果不会查看手机日志的话可以参考:https://www.jianshu.com/p/d5e3a6109036
 
 
 如果想在该产品基础上做修改的可按如下方法修改
 一:修改项目名称(显示在手机上的名称)
    1.点击左侧CCLiveCloud项目名(最上层那个,旁边有个蓝色图标)
    2.点击TARGETS
    3.点击上方的Gengral
    4.下方有一个identity,identity里面有一项叫Display name, 修改Display name右边的文字为您想要的APP名称即可
 二:修改项目图标
    1.点击左侧Assets.xcassets文件会看到AppIcon
    2.点击AppIcon可以看到所有的图标,替换掉即可
    3.图标尺寸为20 29 40 60 76 83.5 1024的2x和3x图
 三:修改启动页
    1.点击左侧Assets.xcassets文件会看到LaunchImage
    2.点击LaunchImage可以看到所有的启动图,替换掉即可
    3.图片尺寸
        iOS11+:
         iPhone Xs Max: 1242 × 2688 px
         iPhone Xʀ: 828 × 1792 px
         iPhone X / iPhone Xs: 1125 × 2436 px
        iOS 8+:
         1242 × 2208 px
         750 × 1334 px
        iOS7+:
         640 × 960px
         640 × 1136px
        iOS5,6:
         320 × 480 px
         640 × 960 px
         640 × 1136 px
 四:修改登录背景图片
    1.点击左侧Assets.xcassets
    2.在Assets.xcassets内的搜索框内输入launch_backgroundImage
    3.将这个图片删掉或者修改他的名字,将您想要的登录背景图片放入文件内并命名为launch_backgroundImage
    4.图片尺寸1125 × 2436px和1688 × 3654px
 
至此,该产品的名字,图标和启动图片以及登录背景图片都已经变成了您替换过后的!
 
 上线流程:
 1.登录https://developer.apple.com
 2.点击account并登录,ps:个人版本/公司版本 99$/年;
 3.配置相关证书,这个可以自行百度解决
 4.点击App Store Connect 创建APP, 填写相关信息
 5.点击上方Product->Scheme->Edit Scheme
 6.修改Run和Archive右面的Build configuration的模式为release
 7.将模拟器或者真机换成Generic iOS Device
 8.点击上方Product->archive->distribute APP->ios App Store->upload然后一直下一步即可
 9.上传完成之后回到App Store Connect中构建刚才上传的版本,提交审核即可!
 
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
    // Override point for customization after application launch.f5758fac61
    [Bugly startWithAppId:@"144af8c8e4"];

    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
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

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if(url) {
//        cclivevc://live?userid=3FC516A8884CA0B5&roomid=2A2503C4AE74155E9C33DC5901307461&autoLogin=true&viewername=xxx&viewertoken=xxx
        //解析地址
        
        NSString *openurl = url.absoluteString;
        NSString *urlHeadStr = @"cclivevc://";
        NSRange range = [openurl rangeOfString:urlHeadStr];
        if(range.location == NSNotFound) return YES;
        
        NSString *args = [openurl substringFromIndex:(range.location + range.length)];
        
        if ([args containsString:@"live?"]) {//解析直播观看地址
            NSRange typeRange = [args rangeOfString:@"live?"];
            NSString *result =  [args substringFromIndex:(typeRange.location + typeRange.length)];
            //解析直播地址
            [self parseWithStr:result];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSDictionary *dic = [NSDictionary dictionaryWithObject:@"live" forKey:@"roomType"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"openUrl" object:nil userInfo:dic];
            });
        } else if ([args containsString:@"record?"]){//解析回放观看地址
            NSRange typeRange = [args rangeOfString:@"record?"];
            NSString *result =  [args substringFromIndex:(typeRange.location + typeRange.length)];
            //解析回放地址
            [self parseWithPlayBackStr:result];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSDictionary *dic = [NSDictionary dictionaryWithObject:@"record" forKey:@"roomType"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"openUrl" object:nil userInfo:dic];
            });
        }
    }
    return YES;
}
#pragma mark - 解析直播地址
-(NSString *)dealWithStr:(NSString *)str rangeStr:(NSString *)rangStr{
    NSRange range = [str rangeOfString:rangStr];
    return [str substringFromIndex:(range.location + range.length)];
}
//解析观看回放地址
-(void)parseWithPlayBackStr:(NSString *)result{
    /*          移除自动登录保存的一些信息      */
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PLAYBACK_LIVEID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PLAYBACK_RECORDID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PLAYBACK_USERNAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PLAYBACK_PASSWORD];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:AUTOLOGIN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PLAYBACK_ROOMID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PLAYBACK_USERID];
    NSArray *arr = [result componentsSeparatedByString:@"&"];
    for (NSString *str in arr) {
        if ([str containsString:@"userid="]) {
            NSString *userId = [self dealWithStr:str rangeStr:@"userid="];
            SaveToUserDefaults(PLAYBACK_USERID,userId);
        } else if ([str containsString:@"roomid="]){
            NSString *roomId = [self dealWithStr:str rangeStr:@"roomid="];
            SaveToUserDefaults(PLAYBACK_ROOMID,roomId);
        } else if ([str containsString:@"autoLogin="]){
            NSString *autoLogin = [self dealWithStr:str rangeStr:@"autoLogin="];
            SaveToUserDefaults(AUTOLOGIN, autoLogin);
        } else if ([str containsString:@"viewername="]){
            NSString *viewername = [self dealWithStr:str rangeStr:@"viewername="];
            SaveToUserDefaults(PLAYBACK_USERNAME,viewername);
        } else if ([str containsString:@"viewertoken="]){
            NSString *viewertoken = [self dealWithStr:str rangeStr:@"viewertoken="];
            SaveToUserDefaults(PLAYBACK_PASSWORD,viewertoken);
        } else if ([str containsString:@"recordid="]){
            NSString *recordid = [self dealWithStr:str rangeStr:@"recordid="];
            SaveToUserDefaults(PLAYBACK_RECORDID,recordid);
        } else if ([str containsString:@"liveid="]){
            NSString *liveid = [self dealWithStr:str rangeStr:@"liveid="];
            SaveToUserDefaults(PLAYBACK_LIVEID,liveid);
        }
    }
}
//解析观看直播地址
-(void)parseWithStr:(NSString *)result{
    /*          移除自动登录保存的一些信息      */
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WATCH_USERID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WATCH_ROOMID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WATCH_PASSWORD];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WATCH_USERNAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:AUTOLOGIN];
    NSArray *arr = [result componentsSeparatedByString:@"&"];
    for (NSString *str in arr) {
        if ([str containsString:@"userid="]) {
            NSString *userId = [self dealWithStr:str rangeStr:@"userid="];
            SaveToUserDefaults(WATCH_USERID,userId);
        } else if ([str containsString:@"roomid="]){
            NSString *roomId = [self dealWithStr:str rangeStr:@"roomid="];
            SaveToUserDefaults(WATCH_ROOMID,roomId);
        } else if ([str containsString:@"autoLogin="]){
            NSString *autoLogin = [self dealWithStr:str rangeStr:@"autoLogin="];
            SaveToUserDefaults(AUTOLOGIN, autoLogin);
        } else if ([str containsString:@"viewername="]){
            NSString *viewername = [self dealWithStr:str rangeStr:@"viewername="];
            SaveToUserDefaults(WATCH_USERNAME,viewername);
        } else if ([str containsString:@"viewertoken="]){
            NSString *viewertoken = [self dealWithStr:str rangeStr:@"viewertoken="];
            SaveToUserDefaults(WATCH_PASSWORD,viewertoken);
        }
    }
}
@end
