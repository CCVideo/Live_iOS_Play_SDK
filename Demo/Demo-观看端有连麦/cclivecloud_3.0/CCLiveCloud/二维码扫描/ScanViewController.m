//
//  ScanViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/12/4.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "ScanOverViewController.h"
#import "PhotoNotPermissionVC.h"

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(nonatomic,strong)UIBarButtonItem              *leftBarBtn;//左侧导航按钮
@property(nonatomic,strong)UIBarButtonItem              *rightBarPicBtn;//右侧相册选择按钮
@property(strong,nonatomic)AVCaptureDevice              *device;//设备信息
@property(strong,nonatomic)AVCaptureDeviceInput         *input;//输入
@property(strong,nonatomic)AVCaptureMetadataOutput      *output;//输出
@property(strong,nonatomic)AVCaptureSession             *session;
@property(strong,nonatomic)AVCaptureVideoPreviewLayer   *preview;//预览视图
@property(strong,nonatomic)NSTimer                      *timer;//扫描超时的timer
@property(strong,nonatomic)NSTimer                      *scanTimer;//扫描分界线的timer

@property(strong,nonatomic)UIView                       *overView;
@property(strong,nonatomic)UIImageView                  *centerView;//中间的视图
@property(strong,nonatomic)UIImageView                  *scanLine;//扫描分界线
@property(strong,nonatomic)UILabel                      *bottomLabel;//底部label

@property(strong,nonatomic)UILabel                      *overCenterViewTopLabel;//扫描结束上侧提示文字
@property(strong,nonatomic)UILabel                      *overCenterViewBottomLabel;//扫描结束下册提示文字

@property(strong,nonatomic)UIView                       *topView;//顶部视图
@property(strong,nonatomic)UIView                       *bottomView;//底部视图
@property(strong,nonatomic)UIView                       *leftView;//左侧视图
@property(strong,nonatomic)UIView                       *rightView;//右侧视图

@property(strong,nonatomic)UITapGestureRecognizer       *singleRecognizer;//单击手势
@property(strong,nonatomic)ScanOverViewController       *scanOverViewController;//扫描结束控制器
@property(strong,nonatomic)PhotoNotPermissionVC         *photoNotPermissionVC;//没有相册权限控制器
@property(strong,nonatomic)UIImagePickerController      *picker;//图片选择控制器
@property(assign,nonatomic)NSInteger                    index;//需要解析的二维码类型

@end

#define TITLE @"扫描观看地址二维码"
#define BOTTOM_TEXT @"将二维码置于框中，即可自动扫描"
#define CENTER_TOP_TEXT @"未发现二维码"
#define CENTER_BOTTOM_TEXT @"轻触屏幕继续扫描"
@implementation ScanViewController
/*
 扫描类型：（1）我要直播，（2）观看直播，（3）观看回放
 */
-(instancetype)initWithType:(NSInteger)index {
    self = [super init];
    if(self) {
        self.index = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置导航栏
    self.navigationItem.leftBarButtonItem=self.leftBarBtn;
    self.navigationItem.rightBarButtonItem=self.rightBarPicBtn;
    self.title = TITLE;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:FontSize_32],NSFontAttributeName,nil]];
    [self.navigationController.navigationBar setBackgroundImage:
     [self createImageWithColor:CCRGBColor(255,255,255)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    //判断相机状态
    [self judgeCameraStatus];
}
#pragma mark - 判断相机状态
-(void)judgeCameraStatus {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusAuthorized:{//已经开启授权
            [self didAuthorized];
        }
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {//限制访问
            //添加未识别视图
            [self addCannotScanViews];
            //添加提示信息
            _scanOverViewController = [[ScanOverViewController alloc] initWithBlock:^{
                [_scanOverViewController removeFromParentViewController];
                [self.navigationController popViewControllerAnimated:NO];
            }];
            [self.navigationController addChildViewController:_scanOverViewController];
        }
            break;
        default:
            break;
    }
}
//已经开启权限
-(void)didAuthorized{
    // 已经开启授权，可继续
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_session canAddInput:self.input]){
        [_session addInput:self.input];
    }
    if ([_session canAddOutput:self.output]){
        [_session addOutput:self.output];
    }
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
    _preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    //开始扫描
    [_session startRunning];
    //添加扫描视图
    [self addScanViews];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self startTimer];
    });
}
#pragma mark - 设置扫描视图
//添加未识别扫描视图
-(void)addCannotScanViews {
    //添加背景视图
    [self.view addSubview:self.overView];
    [_overView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    //添加中间视图
    [_overView addSubview:self.centerView];
    [_centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(CCGetRealFromPt(175));
        make.top.mas_equalTo(self.view).offset(CCGetRealFromPt(398));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(400), CCGetRealFromPt(400)));
    }];
    //添加底部提示信息
    [_overView addSubview:self.bottomLabel];
    [_bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.centerView.mas_bottom);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(CCGetRealFromPt(108));
    }];
}
//添加扫描视图
-(void)addScanViews {
    //添加背景视图
    [self.view addSubview:self.overView];
    [_overView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    //添加中间视图
    [_overView addSubview:self.centerView];
    [_centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(CCGetRealFromPt(175));
        make.top.mas_equalTo(self.view).offset(CCGetRealFromPt(398));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(400), CCGetRealFromPt(400)));
    }];
    //添加扫描分界线
    [_centerView addSubview:self.scanLine];
    [_scanLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(self.centerView);
        make.height.mas_equalTo(CCGetRealFromPt(4));
    }];
    //添加顶部视图
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = CCRGBAColor(0, 0, 0, 0.8);
    [_overView addSubview:_topView];
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(self.overView);
        make.bottom.mas_equalTo(self.centerView.mas_top);
    }];
    //添加底部视图
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = CCRGBAColor(0, 0, 0, 0.8);
    [_overView addSubview:_bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(self.overView);
        make.top.mas_equalTo(self.centerView.mas_bottom);
    }];
    //左侧视图
    _leftView = [[UIView alloc] init];
    _leftView.backgroundColor = CCRGBAColor(0, 0, 0, 0.8);
    [_overView addSubview:_leftView];
    [_leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.mas_equalTo(self.centerView);
        make.left.mas_equalTo(self.overView);
        make.right.mas_equalTo(self.centerView.mas_left);
    }];
    //右侧视图
    _rightView = [[UIView alloc] init];
    _rightView.backgroundColor = CCRGBAColor(0, 0, 0, 0.8);
    [_overView addSubview:_rightView];
    [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.mas_equalTo(self.centerView);
        make.right.mas_equalTo(self.overView);
        make.left.mas_equalTo(self.centerView.mas_right);
    }];
    //添加底部提示文字
    [self.overView addSubview:self.bottomLabel];
    [_bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.centerView.mas_bottom);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(CCGetRealFromPt(108));
    }];
}
#pragma mark - 定时器相关
//开启定时器
-(void)startTimer {
    [self stopTimer];
    WS(ws)
    if(!_scanLine) {
        [_centerView addSubview:self.scanLine];
        [_scanLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.top.mas_equalTo(ws.centerView);
            make.height.mas_equalTo(CCGetRealFromPt(4));
        }];
    }
    [self startScaneLine];
    
    //开启长时间未响应的timer
    _timer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(stopScaneCode) userInfo:nil repeats:NO];
    //开启扫描分界线的timer
    _scanTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(startScaneLine) userInfo:nil repeats:YES];
}
//扫描分界线
-(void)startScaneLine {
    WS(ws)
    [_scanLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.centerView);
        make.top.mas_equalTo(ws.centerView).offset(ws.centerView.frame.size.height);
        make.height.mas_equalTo(CCGetRealFromPt(4));
    }];
    //添加分界线扫描动画
    [UIView animateWithDuration:1.9f animations:^{
        [self.centerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [_scanLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.top.mas_equalTo(ws.centerView);
            make.height.mas_equalTo(CCGetRealFromPt(4));
        }];
    }];
}
//停止扫描提示
-(void)stopScaneCode {
    //关闭定时器
    [self stopTimer];
    [_session stopRunning];
    [_scanLine removeFromSuperview];
    _scanLine = nil;
    //更新centerView
    [self.centerView setImage:[UIImage imageNamed:@"scan_black"]];
    self.centerView.userInteractionEnabled = YES;
    [self.centerView addSubview:self.overCenterViewTopLabel];
    [self.centerView addSubview:self.overCenterViewBottomLabel];
    
    //设置为扫描二维码提示信息
    [_overCenterViewTopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self.centerView);
        make.top.mas_equalTo(self.centerView).offset(CCGetRealFromPt(150));
        make.height.mas_equalTo(CCGetRealFromPt(50));
    }];
    
    [_overCenterViewBottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self.centerView);
        make.bottom.mas_equalTo(self.centerView).offset(-CCGetRealFromPt(150));
        make.height.mas_equalTo(CCGetRealFromPt(46));
    }];
    //添加单击手势
    [self.centerView addGestureRecognizer:self.singleRecognizer];
}
#pragma mark - 懒加载
//单击手势
-(UITapGestureRecognizer *)singleRecognizer {
    if(!_singleRecognizer) {
        _singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        _singleRecognizer.numberOfTapsRequired = 1; // 单击
    }
    return _singleRecognizer;
}
//单击手势点击事件
-(void)singleTap {
    [self.centerView setImage:[UIImage imageNamed:@"scan_white"]];
    [_overCenterViewTopLabel removeFromSuperview];
    [_overCenterViewBottomLabel removeFromSuperview];
    self.centerView.userInteractionEnabled = NO;
    [self.centerView removeGestureRecognizer:self.singleRecognizer];
    [_session startRunning];
    
    [self startTimer];
}
#pragma mark - 扫描结果解析
//获取扫描到的信息
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self stopTimer];
    NSString *result = nil;
    if ([metadataObjects count] >0){
        //停止扫描
        [_session stopRunning];
        [_scanLine removeFromSuperview];
        _scanLine = nil;
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        result = metadataObject.stringValue;
    }
    //解析数据
    [self parseCodeStr:result];
}
//解析扫描后的数据
-(void)parseCodeStr:(NSString *)result {
    NSRange rangeRoomId = [result rangeOfString:@"roomid="];
    NSRange rangeUserId = [result rangeOfString:@"userid="];
    NSRange rangeLiveId = [result rangeOfString:@"liveid="];
//    NSRange rangeRecordId = [result rangeOfString:@"recordid="];
    WS(ws);
    if (self.index == 4) { //离线回放
        SaveToUserDefaults(@"SCAN_RESULT",result);
    }else {
        if (!StrNotEmpty(result) || rangeRoomId.location == NSNotFound || rangeUserId.location == NSNotFound || (self.index == 3 && rangeLiveId.location == NSNotFound)) {
            //扫描失败
            [self scanFailed];
        } else {
            NSString *roomId = [result substringWithRange:NSMakeRange(rangeRoomId.location + rangeRoomId.length, rangeUserId.location - 1 - (rangeRoomId.location + rangeRoomId.length))];
            if(self.index == 1) {//我要直播
                NSString *userId = [result substringFromIndex:rangeUserId.location + rangeUserId.length];
        //            NSLog(@"roomId = %@,userId = %@",roomId,userId);
                SaveToUserDefaults(LIVE_USERID,userId);
                SaveToUserDefaults(LIVE_ROOMID,roomId);
            } else if(self.index == 2) {//观看直播
                NSString *userId = [result substringFromIndex:rangeUserId.location + rangeUserId.length];
        //            NSLog(@"roomId = %@,userId = %@",roomId,userId);
                SaveToUserDefaults(WATCH_USERID,userId);
                SaveToUserDefaults(WATCH_ROOMID,roomId);
            } else if(self.index == 3) {//观看回放
                [self parseCodeWithPlayBackStr:result roomId:roomId];
            } else if(self.index == 4) { //观看离线回放
        //            NSString *userId = [result substringWithRange:NSMakeRange(rangeUserId.location + rangeUserId.length, rangeLiveId.location - 1 - (rangeUserId.location + rangeUserId.length))];
        //            NSString *liveId = [result substringFromIndex:rangeLiveId.location + rangeLiveId.length];
        //            SaveToUserDefaults(PLAYBACK_USERID,userId);
        //            SaveToUserDefaults(PLAYBACK_ROOMID,roomId);
        //            SaveToUserDefaults(PLAYBACK_LIVEID,liveId);
                SaveToUserDefaults(@"SCAN_RESULT",result);
            }
        }
    }
    [ws.navigationController popViewControllerAnimated:NO];
}
//扫描失败
-(void)scanFailed{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:SCAN_FAILED message:SCAN_FAILED_MESSAGE preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self singleTap];
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
//解析回放数据
-(void)parseCodeWithPlayBackStr:(NSString *)result roomId:(NSString *)roomId{
    NSRange rangeUserId = [result rangeOfString:@"userid="];
    NSRange rangeLiveId = [result rangeOfString:@"liveid="];
    NSRange rangeRecordId = [result rangeOfString:@"recordid="];
    
    if(rangeRecordId.location == NSNotFound) {//如果找不到回放id的字段,返回空
        NSString *userId = [result substringWithRange:NSMakeRange(rangeUserId.location + rangeUserId.length, rangeLiveId.location - 1 - (rangeUserId.location + rangeUserId.length))];
        NSString *liveId = [result substringFromIndex:rangeLiveId.location + rangeLiveId.length];
        //                NSLog(@"roomId = %@,userId = %@,liveId = %@",roomId,userId,liveId);
        SaveToUserDefaults(PLAYBACK_USERID,userId);
        SaveToUserDefaults(PLAYBACK_ROOMID,roomId);
        SaveToUserDefaults(PLAYBACK_LIVEID,liveId);
        SaveToUserDefaults(PLAYBACK_RECORDID,@"");
    } else {//解析回放相关信息
        NSRange ra = [result rangeOfString:@"?"];
        NSString *newUrl = [result substringFromIndex:(ra.location + 1)];
        NSArray *array = [newUrl componentsSeparatedByString:@"&"];
        
        for (NSInteger i = 0;i < array.count; i++ ) {
            NSString *s = array[i];
            NSString *keyName ;
            if ([s containsString:@"roomid"]) {
                keyName = PLAYBACK_ROOMID;
            } else if ([s containsString:@"userid"]) {
                keyName = PLAYBACK_USERID;
            } else if ([s containsString:@"liveid"]) {
                keyName = PLAYBACK_LIVEID;
            } else if ([s containsString:@"recordid"]) {
                keyName = PLAYBACK_RECORDID;
            } else {
                keyName = @"UNKNOW";
            }
            s = [s substringFromIndex:([s rangeOfString:@"="].location + 1)];
            SaveToUserDefaults(keyName,s);
        }
    }
}

//关闭计时器
-(void)stopTimer {
    if([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    
    if([_scanTimer isValid]) {
        [_scanTimer invalidate];
    }
    _scanTimer = nil;
}
//视图销毁
-(void)dealloc {
    [_session stopRunning];
    [_scanLine removeFromSuperview];
    _scanLine = nil;
    [self stopTimer];
}
#pragma mark - 懒加载
//左侧返回按钮
-(UIBarButtonItem *)leftBarBtn {
    if(_leftBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_back_nor"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _leftBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSelectVC)];
    }
    return _leftBarBtn;
}
//右侧图片选择按钮
-(UIBarButtonItem *)rightBarPicBtn {
    if(_rightBarPicBtn == nil) {
        _rightBarPicBtn = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(onSelectPic)];
        [_rightBarPicBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:FontSize_30],NSFontAttributeName,[UIColor blackColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    }
    return _rightBarPicBtn;
}
//点击返回按钮
-(void)onSelectVC {
    [self.navigationController popViewControllerAnimated:NO];
}
//点击相册按钮
-(void)onSelectPic {
    [self stopTimer];
    [_session stopRunning];
    [_scanLine removeFromSuperview];
    _scanLine = nil;
    
    WS(ws)
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch(status) {
        case PHAuthorizationStatusNotDetermined: {//未确定相册权限时，发起相册权限
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(status == PHAuthorizationStatusAuthorized) {
                        [ws pickImage];
                    } else if(status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {//如果没有相册权限，进入PhotoNotPermissionVC
                        _photoNotPermissionVC = [[PhotoNotPermissionVC alloc] init];
                        [self.navigationController pushViewController:_photoNotPermissionVC animated:NO];
                    }
                });
            }];
        }
            break;
        case PHAuthorizationStatusAuthorized: {
            [ws pickImage];//选择图片
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied: {//权限被拒绝时
            _photoNotPermissionVC = [[PhotoNotPermissionVC alloc] init];
            [self.navigationController pushViewController:_photoNotPermissionVC animated:NO];
        }
            break;
        default:
            break;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(_photoNotPermissionVC) {
        _photoNotPermissionVC = nil;
        [self singleTap];
    }
}
//背景视图
-(UIView *)overView {
    if(!_overView) {
        _overView = [[UIView alloc] init];
        _overView.backgroundColor = CCClearColor;
    }
    return _overView;
}
//中间视图
-(UIImageView *)centerView {
    if(!_centerView) {
        _centerView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scan_white"]];
        _centerView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _centerView;
}
//分界线视图
-(UIImageView *)scanLine {
    if(!_scanLine) {
        _scanLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"QRCodeLine"]];
        _centerView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _scanLine;
}
//底部提示文字
-(UILabel *)bottomLabel {
    if(!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.text = BOTTOM_TEXT;
        _bottomLabel.font = [UIFont systemFontOfSize:FontSize_28];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        _bottomLabel.numberOfLines = 1;
        _bottomLabel.textColor = CCRGBAColor(255,255,255,0.4);
    }
    return _bottomLabel;
}
//未发现二维码提示文字
-(UILabel *)overCenterViewTopLabel {
    if(!_overCenterViewTopLabel) {
        _overCenterViewTopLabel = [[UILabel alloc] init];
        _overCenterViewTopLabel.text = CENTER_TOP_TEXT;
        _overCenterViewTopLabel.font = [UIFont systemFontOfSize:FontSize_30];
        _overCenterViewTopLabel.textAlignment = NSTextAlignmentCenter;
        _overCenterViewTopLabel.numberOfLines = 1;
        _overCenterViewTopLabel.textColor = [UIColor whiteColor];
    }
    return _overCenterViewTopLabel;
}
//单击扫描提示
-(UILabel *)overCenterViewBottomLabel {
    if(!_overCenterViewBottomLabel) {
        _overCenterViewBottomLabel = [[UILabel alloc] init];
        _overCenterViewBottomLabel.text = CENTER_BOTTOM_TEXT;
        _overCenterViewBottomLabel.font = [UIFont systemFontOfSize:FontSize_26];
        _overCenterViewBottomLabel.textAlignment = NSTextAlignmentCenter;
        _overCenterViewBottomLabel.numberOfLines = 1;
        _overCenterViewBottomLabel.textColor = CCRGBAColor(255, 255, 255, 0.69);
    }
    return _overCenterViewBottomLabel;
}
//解析图片二维码的信息
-(void)readQRCodeFromImage:(UIImage *)image {
    NSData *data = UIImagePNGRepresentation(image);
    CIImage *ciimage = [CIImage imageWithData:data];
    NSString *result = nil;
    if (ciimage) {
        CIDetector *qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:[CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}] options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
        NSArray *resultArr = [qrDetector featuresInImage:ciimage];
        if (resultArr.count >0) {
            CIFeature *feature = resultArr[0];
            CIQRCodeFeature *qrFeature = (CIQRCodeFeature *)feature;
            result = qrFeature.messageString;
        }
    }
    [self parseCodeStr:result];
}
//选择图片
-(void)pickImage {
    if([self isPhotoLibraryAvailable]) {
        _picker = [[UIImagePickerController alloc]init];
        _picker.view.backgroundColor = [UIColor clearColor];
        UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        _picker.sourceType = sourcheType;
        _picker.delegate = self;
        [self presentViewController:_picker animated:YES completion:nil];
    }
}

//支持相片库
- (BOOL)isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary];
}
#pragma mark - UIImagePickerControllerDelegate
//已经完成选择图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image= [info objectForKey:UIImagePickerControllerOriginalImage];
    WS(ws)
    [_picker dismissViewControllerAnimated:YES completion:^{
        [ws readQRCodeFromImage:image];
    }];
}
//取消选择
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    WS(ws)
    [_picker dismissViewControllerAnimated:YES completion:^{
        [ws singleTap];
    }];
}
#pragma mark - color转image
//用color返回一个image
- (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
#pragma mark - 屏幕旋转
- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
