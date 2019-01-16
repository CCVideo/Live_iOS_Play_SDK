//
//  PhotoNotPermissionVC.m
//  NewCCDemo
//
//  Created by cc on 2016/12/5.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "PhotoNotPermissionVC.h"

@interface PhotoNotPermissionVC ()

@property(nonatomic,strong)UIBarButtonItem              *rightBarCancelBtn;
@property(nonatomic,strong)UILabel                      *inforLabel;
@property(nonatomic,strong)UIBarButtonItem              *leftBarBtn;    

@end

@implementation PhotoNotPermissionVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem=self.leftBarBtn;
    self.navigationItem.rightBarButtonItem=self.rightBarCancelBtn;
    [self.navigationController.navigationBar setBackgroundImage:
     [self createImageWithColor:CCRGBColor(255,102,51)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.title = @"";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.inforLabel];
    WS(ws)
    [_inforLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(112));
        make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(112));
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(100));
        make.height.mas_equalTo(CCGetRealFromPt(312));
    }];
    self.navigationItem.rightBarButtonItem=self.rightBarCancelBtn;
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

-(UIBarButtonItem *)rightBarCancelBtn {
    if(_rightBarCancelBtn == nil) {
        _rightBarCancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelBtn)];
        [_rightBarCancelBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:FontSize_32],NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    }
    return _rightBarCancelBtn;
}

-(void)onCancelBtn {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UILabel *)inforLabel {
    if(!_inforLabel) {
        _inforLabel = [UILabel new];
        _inforLabel.textAlignment = NSTextAlignmentCenter;
        _inforLabel.numberOfLines = 0;
        _inforLabel.textColor = CCRGBColor(51,51,51);
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"请在iPhone的“设置-隐私-照片”选项中，\n允许CC云直播访问你的手机相册。"];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:CCGetRealFromPt(18)];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_28],NSParagraphStyleAttributeName:paragraphStyle};
        
        [attrStr addAttributes:dict range:NSMakeRange(0, attrStr.length)];
        _inforLabel.attributedText = attrStr;
    }
    return _inforLabel;
}

-(UIBarButtonItem *)leftBarBtn {
    if(_leftBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_back_nor"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _leftBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSelectVC)];
    }
    return _leftBarBtn;
}

-(void)onSelectVC {
    [self.navigationController popViewControllerAnimated:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
