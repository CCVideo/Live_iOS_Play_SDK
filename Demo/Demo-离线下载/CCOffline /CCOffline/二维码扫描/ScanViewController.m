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
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>
@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(nonatomic,strong)UIBarButtonItem              *leftBarBtn;
@property(nonatomic,strong)UIBarButtonItem              *rightBarPicBtn;
@property(strong,nonatomic)AVCaptureDevice              *device;
@property(strong,nonatomic)AVCaptureDeviceInput         *input;
@property(strong,nonatomic)AVCaptureMetadataOutput      *output;
@property(strong,nonatomic)AVCaptureSession             *session;
@property(strong,nonatomic)AVCaptureVideoPreviewLayer   *preview;
@property(strong,nonatomic)NSTimer                      *timer;
@property(strong,nonatomic)NSTimer                      *scanTimer;

@property(strong,nonatomic)UIView                       *overView;
@property(strong,nonatomic)UIImageView                  *centerView;
@property(strong,nonatomic)UIImageView                  *scanLine;
@property(strong,nonatomic)UILabel                      *bottomLabel;

@property(strong,nonatomic)UILabel                      *overCenterViewTopLabel;
@property(strong,nonatomic)UILabel                      *overCenterViewBottomLabel;

@property(strong,nonatomic)UIView                       *topView;
@property(strong,nonatomic)UIView                       *bottomView;
@property(strong,nonatomic)UIView                       *leftView;
@property(strong,nonatomic)UIView                       *rightView;

@property(strong,nonatomic)UITapGestureRecognizer       *singleRecognizer;
@property(strong,nonatomic)ScanOverViewController       *scanOverViewController;
@property(strong,nonatomic)PhotoNotPermissionVC         *photoNotPermissionVC;
@property(strong,nonatomic)UIImagePickerController      *picker;
@property(assign,nonatomic)NSInteger                    index;

@end

@implementation ScanViewController

-(instancetype)initWithType:(NSInteger)index {
    self = [super init];
    if(self) {
        self.index = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self addObserver];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem=self.leftBarBtn;
    self.navigationItem.rightBarButtonItem=self.rightBarPicBtn;
    self.title = @"扫描观看地址二维码";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:FontSize_34],NSFontAttributeName,nil]];
    [self.navigationController.navigationBar setBackgroundImage:
     [self createImageWithColor:CCRGBColor(255,102,51)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [self judgeCameraStatus];
}

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
    _timer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(stopScaneCode) userInfo:nil repeats:NO];
    _scanTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(startScaneLine) userInfo:nil repeats:YES];
}

-(void)startScaneLine {
    WS(ws)
    [_scanLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.centerView);
        make.top.mas_equalTo(ws.centerView).offset(ws.centerView.frame.size.height);
        make.height.mas_equalTo(CCGetRealFromPt(4));
    }];
    
    [UIView animateWithDuration:1.9f animations:^{
        [self.centerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [_scanLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.top.mas_equalTo(ws.centerView);
            make.height.mas_equalTo(CCGetRealFromPt(4));
        }];
    }];
}

-(void)stopScaneCode {
    [self stopTimer];
    [_session stopRunning];
    [_scanLine removeFromSuperview];
    _scanLine = nil;
    
    [self.centerView setImage:[UIImage imageNamed:@"scan_black"]];
    self.centerView.userInteractionEnabled = YES;
    [self.centerView addSubview:self.overCenterViewTopLabel];
    [self.centerView addSubview:self.overCenterViewBottomLabel];
    WS(ws)
    [_overCenterViewTopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.centerView);
        make.top.mas_equalTo(ws.centerView).offset(CCGetRealFromPt(150));
        make.height.mas_equalTo(CCGetRealFromPt(50));
    }];
    
    [_overCenterViewBottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.centerView);
        make.bottom.mas_equalTo(ws.centerView).offset(-CCGetRealFromPt(150));
        make.height.mas_equalTo(CCGetRealFromPt(46));
    }];
    
    [self.centerView addGestureRecognizer:self.singleRecognizer];
}

-(UITapGestureRecognizer *)singleRecognizer {
    if(!_singleRecognizer) {
        _singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        _singleRecognizer.numberOfTapsRequired = 1; // 单击
    }
    return _singleRecognizer;
}

-(void)singleTap {
    [self.centerView setImage:[UIImage imageNamed:@"scan_white"]];
    [_overCenterViewTopLabel removeFromSuperview];
    [_overCenterViewBottomLabel removeFromSuperview];
    self.centerView.userInteractionEnabled = NO;
    [self.centerView removeGestureRecognizer:self.singleRecognizer];
    [_session startRunning];
    
    [self startTimer];
}

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
    NSLog(@"---result = %@",result);
    SaveToUserDefaults(@"SCAN_RESULT",result);
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)parseCodeStr:(NSString *)result {
    NSLog(@"result = %@",result);
    
    NSRange rangeRoomId = [result rangeOfString:@"roomid="];
    NSRange rangeUserId = [result rangeOfString:@"userid="];
    NSRange rangeLiveId = [result rangeOfString:@"liveid="];
    WS(ws)
    if (!StrNotEmpty(result) || rangeRoomId.location == NSNotFound || rangeUserId.location == NSNotFound || (self.index == 3 && rangeLiveId.location == NSNotFound)) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"扫描错误" message:@"没有识别到有效的二维码信息" preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ws singleTap];
        }];
        [alertController addAction:okAction];
        
        [ws presentViewController:alertController animated:YES completion:nil];
    } else {
        NSString *roomId = [result substringWithRange:NSMakeRange(rangeRoomId.location + rangeRoomId.length, rangeUserId.location - 1 - (rangeRoomId.location + rangeRoomId.length))];
        if(self.index == 1) {
            NSString *userId = [result substringFromIndex:rangeUserId.location + rangeUserId.length];
            NSLog(@"roomId = %@,userId = %@",roomId,userId);
            SaveToUserDefaults(LIVE_USERID,userId);
            SaveToUserDefaults(LIVE_ROOMID,roomId);
        } else if(self.index == 2) {
            NSString *userId = [result substringFromIndex:rangeUserId.location + rangeUserId.length];
            NSLog(@"roomId = %@,userId = %@",roomId,userId);
            SaveToUserDefaults(WATCH_USERID,userId);
            SaveToUserDefaults(WATCH_ROOMID,roomId);
        } else if(self.index == 3) {
            NSString *userId = [result substringWithRange:NSMakeRange(rangeUserId.location + rangeUserId.length, rangeLiveId.location - 1 - (rangeUserId.location + rangeUserId.length))];
            NSString *liveId = [result substringFromIndex:rangeLiveId.location + rangeLiveId.length];
            NSLog(@"roomId = %@,userId = %@,liveId = %@",roomId,userId,liveId);
            SaveToUserDefaults(PLAYBACK_USERID,userId);
            SaveToUserDefaults(PLAYBACK_ROOMID,roomId);
            SaveToUserDefaults(PLAYBACK_LIVEID,liveId);
        }
        [ws.navigationController popViewControllerAnimated:NO];
    }
}

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

-(void)dealloc {
    [_session stopRunning];
    [_scanLine removeFromSuperview];
    _scanLine = nil;
    [self stopTimer];
}

-(void)judgeCameraStatus {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusAuthorized:{
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
            
            if ([_session canAddInput:self.input])
            {
                [_session addInput:self.input];
            }
            
            if ([_session canAddOutput:self.output])
            {
                [_session addOutput:self.output];
            }
            _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
            _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
            _preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
            _preview.frame =self.view.layer.bounds;
            [self.view.layer insertSublayer:_preview atIndex:0];
            [_session startRunning];
            
            [self addScanViews];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self startTimer];
            });
        }
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            [self addCannotScanViews];
            
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

-(UIBarButtonItem *)leftBarBtn {
    if(_leftBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_back_nor"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _leftBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSelectVC)];
    }
    return _leftBarBtn;
}

-(UIBarButtonItem *)rightBarPicBtn {
    if(_rightBarPicBtn == nil) {
        _rightBarPicBtn = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(onSelectPic)];
        [_rightBarPicBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:FontSize_32],NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    }
    return _rightBarPicBtn;
}

-(void)onSelectVC {
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)onSelectPic {
    [self stopTimer];
    [_session stopRunning];
    [_scanLine removeFromSuperview];
    _scanLine = nil;
    
    WS(ws)
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    dispatch_async(dispatch_get_main_queue(), ^{
        switch(status) {
            case PHAuthorizationStatusNotDetermined: {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if(status == PHAuthorizationStatusAuthorized) {
                        [ws pickImage];
                    } else if(status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
                        _photoNotPermissionVC = [PhotoNotPermissionVC new];
                        [self.navigationController pushViewController:_photoNotPermissionVC animated:NO];
                    }
                }];
            }
                break;
            case PHAuthorizationStatusAuthorized: {
                [ws pickImage];
            }
                break;
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied: {
                NSLog(@"4");
                _photoNotPermissionVC = [PhotoNotPermissionVC new];
                [self.navigationController pushViewController:_photoNotPermissionVC animated:NO];
            }
                break;
            default:
                break;
        }
    });
}

-(void)addCannotScanViews {
    WS(ws)
    [self.view addSubview:self.overView];
    [_overView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    
    [_overView addSubview:self.centerView];
    [_centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(175));
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(398));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(400), CCGetRealFromPt(400)));
    }];
    
    [_overView addSubview:self.bottomLabel];
    [_bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.centerView.mas_bottom);
        make.left.mas_equalTo(ws.view);
        make.right.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(108));
    }];
}

-(void)addScanViews {
    WS(ws)
    [self.view addSubview:self.overView];
    [_overView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    
    [_overView addSubview:self.centerView];
    [_centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(175));
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(398));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(400), CCGetRealFromPt(400)));
    }];
    
    [_centerView addSubview:self.scanLine];
    [_scanLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(ws.centerView);
        make.height.mas_equalTo(CCGetRealFromPt(4));
    }];
    
    _topView = [UIView new];
    _topView.backgroundColor = CCRGBAColor(0, 0, 0, 0.8);
    [_overView addSubview:_topView];

    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(ws.overView);
        make.bottom.mas_equalTo(ws.centerView.mas_top);
    }];
    
    _bottomView = [UIView new];
    _bottomView.backgroundColor = CCRGBAColor(0, 0, 0, 0.8);
    [_overView addSubview:_bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(ws.overView);
        make.top.mas_equalTo(ws.centerView.mas_bottom);
    }];
    
    _leftView = [UIView new];
    _leftView.backgroundColor = CCRGBAColor(0, 0, 0, 0.8);
    [_overView addSubview:_leftView];
    [_leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.mas_equalTo(ws.centerView);
        make.left.mas_equalTo(ws.overView);
        make.right.mas_equalTo(ws.centerView.mas_left);
    }];
    
    _rightView = [UIView new];
    _rightView.backgroundColor = CCRGBAColor(0, 0, 0, 0.8);
    [_overView addSubview:_rightView];
    [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.mas_equalTo(ws.centerView);
        make.right.mas_equalTo(ws.overView);
        make.left.mas_equalTo(ws.centerView.mas_right);
    }];
    
    [self.overView addSubview:self.bottomLabel];
    [_bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.centerView.mas_bottom);
        make.left.mas_equalTo(ws.view);
        make.right.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(108));
    }];
}

-(UIView *)overView {
    if(!_overView) {
        _overView = [UIView new];
        _overView.backgroundColor = CCClearColor;
    }
    return _overView;
}

-(UIImageView *)centerView {
    if(!_centerView) {
        _centerView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scan_white"]];
        _centerView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _centerView;
}

-(UIImageView *)scanLine {
    if(!_scanLine) {
        _scanLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"QRCodeLine"]];
        _centerView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _scanLine;
}

-(UILabel *)bottomLabel {
    if(!_bottomLabel) {
        _bottomLabel = [UILabel new];
        _bottomLabel.text = @"将二维码置于框中，即可自动扫描";
        _bottomLabel.font = [UIFont systemFontOfSize:FontSize_28];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        _bottomLabel.numberOfLines = 1;
        _bottomLabel.textColor = CCRGBAColor(255,255,255,0.4);
    }
    return _bottomLabel;
}

-(UILabel *)overCenterViewTopLabel {
    if(!_overCenterViewTopLabel) {
        _overCenterViewTopLabel = [UILabel new];
        _overCenterViewTopLabel.text = @"未发现二维码";
        _overCenterViewTopLabel.font = [UIFont systemFontOfSize:FontSize_30];
        _overCenterViewTopLabel.textAlignment = NSTextAlignmentCenter;
        _overCenterViewTopLabel.numberOfLines = 1;
        _overCenterViewTopLabel.textColor = [UIColor whiteColor];
    }
    return _overCenterViewTopLabel;
}

-(UILabel *)overCenterViewBottomLabel {
    if(!_overCenterViewBottomLabel) {
        _overCenterViewBottomLabel = [UILabel new];
        _overCenterViewBottomLabel.text = @"轻触屏幕继续扫描";
        _overCenterViewBottomLabel.font = [UIFont systemFontOfSize:FontSize_26];
        _overCenterViewBottomLabel.textAlignment = NSTextAlignmentCenter;
        _overCenterViewBottomLabel.numberOfLines = 1;
        _overCenterViewBottomLabel.textColor = CCRGBAColor(255, 255, 255, 0.69);
    }
    return _overCenterViewBottomLabel;
}

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
    WS(ws)
    [ws parseCodeStr:result];
}

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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image= [info objectForKey:UIImagePickerControllerOriginalImage];
    WS(ws)
    [_picker dismissViewControllerAnimated:YES completion:^{
        [ws readQRCodeFromImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    WS(ws)
    [_picker dismissViewControllerAnimated:YES completion:^{
        [ws singleTap];
    }];
}

@end
