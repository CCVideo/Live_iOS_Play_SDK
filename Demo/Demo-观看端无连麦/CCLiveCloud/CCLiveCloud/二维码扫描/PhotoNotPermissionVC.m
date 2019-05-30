//
//  PhotoNotPermissionVC.m
//  NewCCDemo
//
//  Created by cc on 2016/12/5.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "PhotoNotPermissionVC.h"

@interface PhotoNotPermissionVC ()

@property(nonatomic,strong)UIBarButtonItem              *rightBarCancelBtn;//右侧取消按钮
@property(nonatomic,strong)UILabel                      *inforLabel;//提示信息
@property(nonatomic,strong)UIBarButtonItem              *leftBarBtn;//左侧返回按钮

@end

@implementation PhotoNotPermissionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置导航栏
    self.navigationItem.leftBarButtonItem=self.leftBarBtn;
    self.navigationItem.rightBarButtonItem=self.rightBarCancelBtn;
    [self.navigationController.navigationBar setBackgroundImage:
     [self createImageWithColor:CCRGBColor(255,102,51)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.title = SCAN_NOPERMISSION;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //添加提示信息
    [self.view addSubview:self.inforLabel];
    [_inforLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(CCGetRealFromPt(112));
        make.right.mas_equalTo(self.view).offset(-CCGetRealFromPt(112));
        make.top.mas_equalTo(self.view).offset(CCGetRealFromPt(100));
        make.height.mas_equalTo(CCGetRealFromPt(312));
    }];
    self.navigationItem.rightBarButtonItem=self.rightBarCancelBtn;
}
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
//右侧取消按钮
-(UIBarButtonItem *)rightBarCancelBtn {
    if(_rightBarCancelBtn == nil) {
        _rightBarCancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelBtn)];
        [_rightBarCancelBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:FontSize_32],NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    }
    return _rightBarCancelBtn;
}
//点击取消按钮
-(void)onCancelBtn {
    [self.navigationController popViewControllerAnimated:YES];
}
//提示信息
-(UILabel *)inforLabel {
    if(!_inforLabel) {
        _inforLabel = [[UILabel alloc] init];
        _inforLabel.textAlignment = NSTextAlignmentCenter;
        _inforLabel.numberOfLines = 0;
        _inforLabel.textColor = CCRGBColor(51,51,51);
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:SCAN_PHOTONOTPERMISSION];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:CCGetRealFromPt(18)];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_28],NSParagraphStyleAttributeName:paragraphStyle};
        
        [attrStr addAttributes:dict range:NSMakeRange(0, attrStr.length)];
        _inforLabel.attributedText = attrStr;
    }
    return _inforLabel;
}
//左侧leftLabel
-(UIBarButtonItem *)leftBarBtn {
    if(!_leftBarBtn) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_back_nor"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _leftBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSelectVC)];
    }
    return _leftBarBtn;
}
//返回扫描视图
-(void)onSelectVC {
    [self.navigationController popViewControllerAnimated:NO];
}

@end
