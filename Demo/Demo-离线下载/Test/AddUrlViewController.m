//
//  AddUrlViewController.m
//  Test
//
//  Created by cc on 2017/2/10.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AddUrlViewController.h"
#import "ScanViewController.h"
#import "CCSDK/OfflinePlayBack.h"
#import "LoadingView.h"
#import "InformationShowView.h"
@interface AddUrlViewController ()<UITextViewDelegate>

@property(nonatomic,strong)UIBarButtonItem      *rightBarBtn;
@property(nonatomic,strong)UITextView           *textViewInputUrl;
@property(nonatomic,strong)UIButton             *addUrlBtn;
@property(nonatomic,strong)LoadingView          *loadingView;
@property(nonatomic,copy)AddUrlBlock            addUrlBlock;

@end

@implementation AddUrlViewController

-(instancetype)initWithAddUrlBlock:(AddUrlBlock)addUrlBlock {
    self = [super init];
    if(self) {
        self.addUrlBlock = addUrlBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *gotoFrontPageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(gotoFrontPageClicked)];
    UIBarButtonItem *scanCodeBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(scanCodeBtnClicked)];
    self.navigationItem.leftBarButtonItem = gotoFrontPageButton;
    self.navigationItem.rightBarButtonItem = scanCodeBtn;
    
    [self.navigationController.navigationBar setBackgroundImage:
     [self createImageWithColor:CCRGBColor(255,102,51)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.view.backgroundColor = CCRGBColor(250, 250, 250);

    WS(ws)
    [self.view addSubview:self.textViewInputUrl];
    [_textViewInputUrl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(30));
        make.right.mas_equalTo(ws.view).with.offset(-CCGetRealFromPt(30));
        make.top.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(70));
        make.height.mas_equalTo(CCGetRealFromPt(300));
    }];
    
    [self.view addSubview:self.addUrlBtn];
    [_addUrlBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(65));
        make.right.mas_equalTo(ws.view).with.offset(-CCGetRealFromPt(65));
        make.top.mas_equalTo(ws.textViewInputUrl.mas_bottom).with.offset(CCGetRealFromPt(70));
        make.height.mas_equalTo(CCGetRealFromPt(86));
    }];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CCGetRealFromPt(178), CCGetRealFromPt(34))];
    [label setTextColor:[UIColor whiteColor]];
    label.font = [UIFont systemFontOfSize:FontSize_34];
    label.text = @"新建下载任务";

    self.navigationItem.titleView = label;
}

-(void)gotoFrontPageClicked {
    [self.navigationController popViewControllerAnimated:YES];
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

-(UITextView *)textViewInputUrl {
    if(!_textViewInputUrl) {
        _textViewInputUrl = [UITextView new];
        _textViewInputUrl.editable = YES;
//        _textViewInputUrl.textColor = [UIColor blackColor];
//        _textViewInputUrl.font = [UIFont systemFontOfSize:30];
        _textViewInputUrl.scrollEnabled = YES;
        _textViewInputUrl.backgroundColor = [UIColor clearColor];
        _textViewInputUrl.layer.borderColor = [CCRGBAColor(0, 0, 0, 0.2) CGColor];
        _textViewInputUrl.layer.borderWidth = 1;
        _textViewInputUrl.delegate = self;
    }
    return _textViewInputUrl;
}

-(UIButton *)addUrlBtn {
    if(_addUrlBtn == nil) {
        _addUrlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addUrlBtn.backgroundColor = CCRGBColor(255,102,51);
        [_addUrlBtn setTitle:@"下载" forState:UIControlStateNormal];
        [_addUrlBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_36]];
        [_addUrlBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_addUrlBtn setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
        [_addUrlBtn.layer setMasksToBounds:YES];
        [_addUrlBtn.layer setCornerRadius:CCGetRealFromPt(40)];
        [_addUrlBtn addTarget:self action:@selector(downLoadAction) forControlEvents:UIControlEventTouchUpInside];

        [_addUrlBtn setBackgroundImage:[self createImageWithColor:CCRGBColor(255,102,51)] forState:UIControlStateNormal];
        [_addUrlBtn setBackgroundImage:[self createImageWithColor:CCRGBAColor(255,102,51,0.2)] forState:UIControlStateDisabled];
        [_addUrlBtn setBackgroundImage:[self createImageWithColor:CCRGBColor(248,92,40)] forState:UIControlStateHighlighted];
    }
    return _addUrlBtn;
}

//监听touch事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)downLoadAction {
    [self.view endEditing:YES];

    if(StrNotEmpty(_textViewInputUrl.text) && ([_textViewInputUrl.text hasPrefix:@"http"] || [_textViewInputUrl.text hasPrefix:@"https"]) && [_textViewInputUrl.text hasSuffix:@".ccr"]) {
        if(self.addUrlBlock) {
            self.addUrlBlock(_textViewInputUrl.text);
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        InformationShowView *informationView = [[InformationShowView alloc] initWithLabel:@"下载链接不正确"];
        [self.view addSubview:informationView];
        [informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f repeats:NO block:^(NSTimer * _Nonnull timer) {
            [informationView removeFromSuperview];
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//    srand((unsigned)time(0)); //不加这句每次产生的随机数不变
//    int i = arc4random() % [self.urlArray count];
//    NSLog(@"---i = %d",i);
//    self.textViewInputUrl.text = [self.urlArray objectAtIndex:i];
    
    self.textViewInputUrl.text = GetFromUserDefaults(@"SCAN_RESULT");
//    if(!StrNotEmpty(self.textViewInputUrl.text)) {
//        self.textViewInputUrl.text = @"http://192.168.4.242/我是中国人.ccr";
//    }
//    self.textViewInputUrl.text = @"http://192.168.4.242/我是中国人.ccr";
    if(StrNotEmpty(_textViewInputUrl.text)) {
        _addUrlBtn.enabled = YES;
        [_addUrlBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
    } else {
        _addUrlBtn.enabled = NO;
        [_addUrlBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
    }
}

#pragma mark UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidChange:(UITextField *) TextField {
    if(StrNotEmpty(_textViewInputUrl.text)) {
        _addUrlBtn.enabled = YES;
        [_addUrlBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
    } else {
        _addUrlBtn.enabled = NO;
        [_addUrlBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

//扫码
-(void)scanCodeBtnClicked {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            // 许可对话没有出现，发起授权许可

            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:3];;
                        [self.navigationController pushViewController:scanViewController animated:NO];
                    }else{
                        //用户拒绝
                        ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:3];
                        [self.navigationController pushViewController:scanViewController animated:NO];
                    }
                });
            }];
        }
            break;
        case AVAuthorizationStatusAuthorized:{
            // 已经开启授权，可继续
            ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:3];
            [self.navigationController pushViewController:scanViewController animated:NO];
        }
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            // 用户明确地拒绝授权，或者相机设备无法访问
            ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:3];
            [self.navigationController pushViewController:scanViewController animated:NO];
        }
            break;
        default:
            break;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(StrNotEmpty(_textViewInputUrl.text)) {
        _addUrlBtn.enabled = YES;
        [_addUrlBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
    } else {
        _addUrlBtn.enabled = NO;
        [_addUrlBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
    }
}

@end
