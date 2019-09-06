//
//  CCcommonDefine.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/23.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#ifndef CCcommonDefine_h
#define CCcommonDefine_h
//[em2_01]
#define FACE_NAME_HEAD  @"[em2_"
// 表情转义字符的长度（ [em2_占5个长度，xx占2个长度，]占一个长度,共8个长度 ）
#define FACE_NAME_LEN   8
#define FACE_COUNT_ALL  20
#define FACE_COUNT_ROW  3
#define FACE_COUNT_CLU  7
#define IMGWIDTH        28.0f

#define CONTROLLER_INDEX @"index"

#define LIVE_USERID @"Live_UserId"
#define LIVE_ROOMID @"Live_RoomId"
#define LIVE_USERNAME @"Live_UserName"
#define LIVE_PASSWORD @"Live_Password"
#define LIVE_STARTTIME @"Live_StatTime"
#define AUTOLOGIN @"AutoLogin"

#define WATCH_USERID @"Watch_UserId"
#define WATCH_ROOMID @"Watch_RoomId"
#define WATCH_USERNAME @"Watch_UserName"
#define WATCH_PASSWORD @"Watch_Password"

#define PLAYBACK_USERID @"PlayBack_UserId"
#define PLAYBACK_ROOMID @"PlayBack_RoomId"
#define PLAYBACK_LIVEID @"PlayBack_LiveId"
#define PLAYBACK_RECORDID @"PlayBack_RecordId"
#define PLAYBACK_USERNAME @"PlayBack_UserName"
#define PLAYBACK_PASSWORD @"PlayBack_Password"

#define SET_SCREEN_LANDSCAPE @"SetScreenLandscape"
#define SET_BEAUTIFUL @"SetBeautiful"
#define SET_CAMERA_DIRECTION @"SetCameraDirection"
#define SET_SIZE @"SetSize"
#define SET_BITRATE @"SetBitRate"
#define SET_IFRAME @"SetIFrame"
#define SET_SERVER_INDEX @"SetServerIndex"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

//1.获取屏幕宽度与高度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_SIZE [UIScreen mainScreen].bounds.size
#define SCREEN_STATUS [[UIApplication sharedApplication] statusBarFrame].size.height
#define NativeScale [UIScreen mainScreen].nativeScale
#define NativeBounds [UIScreen mainScreen].nativeBounds

#define SCREEN_SCALE NativeBounds.size.width / 750.0

#define CCGetRealFromPt(x) (x / NativeScale) * SCREEN_SCALE

#define CCGetPxFromPt(x) (x / NativeScale)

//2.获取通知中心
#define CCNotificationCenter [NSNotificationCenter defaultCenter]

//3.设置随机颜色
#define CCRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]

//4.设置RGB颜色/设置RGBA颜色
#define CCRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define CCRGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
// clear背景颜色
#define CCClearColor [UIColor clearColor]

//5.自定义高效率的 NSLog
#ifdef DEBUG
#define CCLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define CCLog(...)

#endif

//7.设置 view 圆角和边框
#define CCViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

//8.由角度转换弧度 由弧度转换角度
#define CCDegreesToRadian(x) (M_PI * (x) / 180.0)
#define CCRadianToDegrees(radian) (radian*180.0)/(M_PI)

//9.设置加载提示框（第三方框架：Toast）
#define CCToast(str)              CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle]; \
[kWindow  makeToast:str duration:0.6 position:CSToastPositionCenter style:style];\
kWindow.userInteractionEnabled = NO; \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{\
kWindow.userInteractionEnabled = YES;\
});\

//10.设置加载提示框（第三方框架：MBProgressHUD）
// 加载
#define kShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
// 收起加载
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
// 设置加载
#define NetworkActivityIndicatorVisible(x)  [UIApplication sharedApplication].networkActivityIndicatorVisible = x

#define kWindow [UIApplication sharedApplication].keyWindow

#define kBackView         for (UIView *item in kWindow.subviews) { \
if(item.tag == 10000) \
{ \
[item removeFromSuperview]; \
UIView * aView = [[UIView alloc] init]; \
aView.frame = [UIScreen mainScreen].bounds; \
aView.tag = 10000; \
aView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3]; \
[kWindow addSubview:aView]; \
} \
} \

#define kShowHUDAndActivity kBackView;[MBProgressHUD showHUDAddedTo:kWindow animated:YES];kShowNetworkActivityIndicator()


#define kHiddenHUD [MBProgressHUD hideAllHUDsForView:kWindow animated:YES]

#define kRemoveBackView         for (UIView *item in kWindow.subviews) { \
if(item.tag == 10000) \
{ \
[UIView animateWithDuration:0.4 animations:^{ \
item.alpha = 0.0; \
} completion:^(BOOL finished) { \
[item removeFromSuperview]; \
}]; \
} \
} \

#define kHiddenHUDAndAvtivity kRemoveBackView;kHiddenHUD;HideNetworkActivityIndicator()


//11.获取view的frame/图片资源
//获取view的frame（不建议使用）
//#define kGetViewWidth(view)  view.frame.size.width
//#define kGetViewHeight(view) view.frame.size.height
//#define kGetViewX(view)      view.frame.origin.x
//#define kGetViewY(view)      view.frame.origin.y

//获取图片资源
#define kGetImage(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]]


//12.获取当前语言
#define CCCurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

//13.使用 ARC 和 MRC
#if __has_feature(objc_arc)
// ARC
#else
// MRC
#endif

//14.判断当前的iPhone设备/系统版本
//判断是否为iPhone
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

// 判断是否为 iPhone 4/4s
#define iPhone4_4s NativeBounds.size.width == 640.0f && NativeBounds.size.height == 960.0f

// 判断是否为 iPhone 5/5s/5c/5SE
#define iPhone5_5s_5c_5SE NativeBounds.size.width == 640.0f && NativeBounds.size.height == 1136.0f

// 判断是否为iPhone 6/6s/7
#define iPhone6_6s_7 NativeBounds.size.width == 750.0f && NativeBounds.size.height == 1334.0f

// 判断是否为iPhone 6Plus/6sPlus/7Plus
#define iPhone6Plus_6sPlus_7Plus NativeBounds.size.width == 1242.0f && NativeBounds.size.height == 2208.0f
#define IOS_SYSTEMVERSION     ([[[UIDevice currentDevice] systemVersion] floatValue])
#define MinSize (iPhone4_4s || iPhone5_5s_5c_5SE || iPhone6_6s_7)
#define MaxSize iPhone6Plus_6sPlus_7Plus

#define FontSize_20 MinSize?10:12
#define FontSize_24 MinSize?12:13
#define FontSize_26 MinSize?13:14
#define FontSize_28 MinSize?14:15
#define FontSize_30 MinSize?15:16
#define FontSize_32 MinSize?16:17
#define FontSize_34 MinSize?17:18
#define FontSize_36 MinSize?18:19
#define FontSize_40 MinSize?20:21
#define FontSize_42 MinSize?21:23
#define FontSize_72 MinSize?36:40

#define kScreen_Max_Length        (MAX(SCREEN_WIDTH, SCREENH_HEIGHT))
#define kScreen_Min_Length        (MIN(SCREEN_WIDTH, SCREENH_HEIGHT))
/** 机型 */
#define IS_IPHONE_4              (kScreen_Max_Length == 480.0)
#define IS_IPHONE_5_OR_LESS      (kScreen_Max_Length <= 568.0)
#define IS_IPHONE_6_OR_MORE      (kScreen_Max_Length >= 667.0)
#define IS_IPHONE_5              (kScreen_Max_Length == 568.0)
#define IS_IPHONE_6_OR_7         (kScreen_Max_Length == 667.0)
#define IS_IPHONE_6P_OR_7R       (kScreen_Max_Length == 736.0)
#define IS_IPHONE_X              (kScreen_Max_Length > 736.0)
//安全区域高度
#define TabbarSafeBottomMargin     (IS_IPHONE_X ? 34.f : 0.f)
/** 导航以及Tabbar高度 */
#define kNaviHeight              (IS_IPHONE_X?88:64)
#define kTabbarHeight            (IS_IPHONE_X?83:49)
#define kScreenBottom            (IS_IPHONE_X?34:0)
#define kWIDTH_RATIO              (CGRectGetWidth([[UIScreen mainScreen] bounds]) / 375.0)
#define kHEIGHT_RATIO             (CGRectGetHeight([[UIScreen mainScreen] bounds]) / 667.0)
#define kAutoWidth(width)         kWIDTH_RATIO*width
#define kAutoHeight(height)       kHEIGHT_RATIO*height
#define kAutoFont(font)           kWIDTH_RATIO*font


typedef NS_ENUM(NSInteger, NSContentType) {
    NS_CONTENT_TYPE_CHAT,//默认从0开始
    NS_CONTENT_TYPE_QA_QUESTION,
    NS_CONTENT_TYPE_QA_ANSWER,
};

//获取系统版本
#define IOS_SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//判断 iOS 8 或更高的系统版本
#define IOS_VERSION_8_OR_LATER (([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0)? (YES):(NO))

//15.判断是真机还是模拟器
#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif

//16.沙盒目录文件
//获取temp
#define kPathTemp NSTemporaryDirectory()

//获取沙盒 Document
#define kPathDocument [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

//获取沙盒 Cache
#define kPathCache [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

//17.GCD 的宏定义
//GCD - 一次性执行
#define kDISPATCH_ONCE_BLOCK(onceBlock) static dispatch_once_t onceToken; dispatch_once(&onceToken, onceBlock);

//GCD - 在Main线程上运行
#define kDISPATCH_MAIN_THREAD(mainQueueBlock) dispatch_async(dispatch_get_main_queue(), mainQueueBlock);

//GCD - 开启异步线程
#define kDISPATCH_GLOBAL_QUEUE_DEFAULT(globalQueueBlock) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), globalQueueBlocl);

#define NavigationBarHiddenYES [self.navigationController setNavigationBarHidden:YES animated:YES];

#define NavigationBarHiddenNO [self.navigationController setNavigationBarHidden:NO animated:YES];

#define APPDelegate [UIApplication sharedApplication].delegate

#define SaveToUserDefaults(key,value) [[NSUserDefaults standardUserDefaults] setObject:value forKey:key]

#define GetFromUserDefaults(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]

#define StrNotEmpty(str) (str != nil && ![str isEqualToString:@""] && [str length] != 0)

/** 提示相关文字信息 */
//日志
#define SAVELOG_ALERT @"视频加载成功或开始播放，多次调用，不必关心"
//统计相关
#define COMMITSUCCESS @"答卷提交成功!"
#define COMMITFAILURE @"网络异常，提交失败，请重试。"
#define QUESTION_ALERT @"问答回复最多支持300个字符！"
#define QUESTION_CHECK @"您尚有部分题目未回答，请检查。"
#define QUESTION_CLOSE @"问卷已停止回收，点击确定后关闭问卷"
//抽奖相关
#define LOTTERY_WINNER(myself) (myself ? @"恭喜您中奖啦!" : @"哎呀,就差一点!")
#define LOTTERY_RESULT @"抽奖结果"
#define LOTTERY_ALERT(str) (str ? @"请牢记您的中奖码" : @"中奖者")
//登录界面
#define USERNAME_CONFINE @"用户名限制在20个字符以内"
//观看回放相关
#define ALERT_EXITPLAYBACK @"您确认结束观看回放吗？"
#define LOGIN_PLAYBACK @"观看回放"
//观看直播相关
#define ALERT_EXITPLAY @"您确认结束观看直播吗？"
#define ALERT_CLOSEQUESTION @"讲师暂停了问答，请专心看直播吧"
#define ALERT_CLOSECHAT @"讲师暂停了文字聊天，请专心看直播吧"
#define ALERT_BANCHAT(status) (status ? @"个人禁言" : @"全体禁言")
#define ALERT_UNBANCHAT(status) (status ? @"解除个人禁言" : @"解除全体禁言")
#define SURE @"确定"
#define CANCEL @"取消"
#define LOGIN_PLAY @"观看直播"
#define LOGIN_LOADING @"正在登录"
#define ALERT_KICKOUT @"您已被踢出直播间"
//观看直播输入框text 和 placeHolder
#define LOGIN_TEXT_USERID @"HD账号ID"
#define LOGIN_TEXT_USERID_PLACEHOLDER @"16位账号ID"
#define LOGIN_TEXT_ROOMID @"直播间ID"
#define LOGIN_TEXT_ROOMID_PLACEHOLDER @"32位直播间ID"
#define LOGIN_TEXT_USERNAME @"昵称"
#define LOGIN_TEXT_USERNAME_PLACEHOLDER @"聊天中显示的名字"
#define LOGIN_TEXT_PASSWORD @"密码"
#define LOGIN_TEXT_PASSWORD_PLACEHOLDER @"观看密码"
#define LOGIN_TEXT_LIVEID @"直播ID"
#define LOGIN_TEXT_LIVEID_PLACEHOLDER @"16位直播ID"
#define LOGIN_TEXT_RECORDID @"回放ID"
#define LOGIN_TEXT_RECORDID_PLACEHOLDER @"16位回放ID"

#define LOGIN_TEXT_INFOR @"直播间信息"
//私聊
#define ALERT_NEWMESSAGE(message) (message ? @"你有新私聊" : @"你有新公告")
#define PRIVATE_LIST @"私聊列表"
#define PRIVATE_PLACEHOLDER @"请输入消息"
//答题卡
#define ALERT_VOTE @"题干部分请参考文档或直播视频"
#define VOTE_TOPSTR @"答题卡"
#define VOTE_TITLESTR @"请选择答案"
#define VOTERESULT_MYANSWER @"您的答案:"
#define VOTERESULT_CORRECTANSWER @"正确答案:"
#define VOTERESULT_VOTEOVER @"答题结束"
#define VOTERESULT @"答题统计"
//连麦
#define LIANMAI_PERMISSION @"连麦需要允许以下权限:"
#define LIANMAI_MSGLABEL(IsVideo) (IsVideo ? @"视频连麦中 00:00" : @"语音连麦中 00:00")
#define LIANMAI_APPLYFOR(IsVideo) (IsVideo ? @"视频连麦申请中..." : @"音频连麦申请中...")
#define LIANMAI_INTERACTION(IsVideo) (IsVideo ? @"与主播视频互动" : @"与主播语音互动")
#define LIANMAI_LOSENETWORK @"网络异常，连麦失败"
#define LIANMAI_GETVIDEOPERMISSION @"获取摄像头权限"
#define LIANMAI_GETVOICEPERMISSION @"获取麦克风权限"
#define LIANMAI_VIDEOCONNECTING @"视频连麦中"
#define LIANMAI_AUDIOCONNECTING @"音频连麦中"
#define LIANMAI_VIDEO @"视频连麦"
#define LIANMAI_AUDIO @"音频连麦"
#define LIANMAI_CANCEL @"取消申请"
//问答
#define ALERT_EMPTYMESSAGE @"发送消息为空"
#define ALERT_INPUTLIMITATION @"输入限制在300个字符以内"
#define ALERT_CHECKQUESTION(Selected) (Selected ? @"查看我的问答" : @"查看所有问答")
//二维码扫描
#define SCAN_PHOTONOTPERMISSION @"请在iPhone的“设置-隐私-照片”选项中，\n允许CC云直播访问你的手机相册。"
#define SCAN_ALERTSTRING @"请在iPhone的“设置-隐私-相机”选项中，允许CC云直播访问你的相机。"
#define SCAN_NOPERMISSION @"没有相册权限"
#define SCAN_FAILED @"扫描错误"
#define SCAN_FAILED_MESSAGE @"没有识别到有效的二维码信息"
//简介
#define EMPTYINTRO @"暂无简介"
//CCPlayerView相关
#define PLAY_CHANGEVIDEO @"切换视频"
#define PLAY_CHANGEDOC @"切换文档"
#define PLAY_LOADING @"视频加载中"
#define PLAY_SHOWVIDEO @"显示视频"
#define PLAY_SHOWDOC @"显示文档"
#define PLAY_SOUND @"音频模式"
#define PLAY_UNSTART @"直播未开始"
#define PLAY_ONLYSOUND @"仅听音频"
#define PLAY_OVER @"直播已结束"
#define ALERT_LIANMAIFAILED @"主播未开启连麦功能"
#define PLAY_END @"播放结束"

//签到
#define ROLLCALL_OVER @"签到结束"
#define ROLLCALL_TIMER @"签到倒计时："
#define ROLLCALL_SIGN @"我要签到"
#define ROLLCALL_SUCCESS @"签到成功"
#define ROLLCALL @"签到"
//统计
#define STATISTICAL_COMMIT_SUCCESS @"已提交"
#define STATISTICAL_COMMIT_FAILED @"您尚有部分题目未回答，请检查。"
#define STATISTICAL_TITLE(ISSTASTIC) (ISSTASTIC?@"问卷统计":@"问卷")
//第三方问卷
#define QUESTIONNAIRE_TITLE @"问卷调查"
#define QUESTIONNAIRE_OPEN @"打开问卷"

#endif /* CCcommonDefine_h */
