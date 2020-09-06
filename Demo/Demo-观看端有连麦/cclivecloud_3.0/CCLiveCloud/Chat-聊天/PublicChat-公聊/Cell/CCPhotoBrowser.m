//
//  HLPhotoView.m
//  HL
//
//  Created by 何龙 on 2018/12/11.
//  Copyright © 2018 何龙. All rights reserved.
//

#import "CCPhotoBrowser.h"
#import "CCAlertView.h"
@interface CCPhotoBrowser ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;//图片视图
@property (nonatomic, strong) UIImage *image;//图片
@property (nonatomic, strong) UIScrollView *scrollView;


@end
#define SCREENWIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREENHEIGHT [[UIScreen mainScreen] bounds].size.height
#define SAVEPHOTO @"保存图片"
#define ALERT_SAVEPHOTO @"图片已保存"
#define ALERT_SURE @"好的"
@implementation CCPhotoBrowser
+(CCPhotoBrowser *)sharedBrowser{
    static CCPhotoBrowser *_phothBrowser;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_phothBrowser) {
            _phothBrowser = [[self alloc] init];
        }
    });
    return _phothBrowser;
}
-(void)createWithImage:(UIImage *)image
{
    if (self) {
        for (UIView *view in self.subviews) {
            [view removeFromSuperview];
        }
        self.image = image;
        self.frame = CGRectMake(SCREENWIDTH / 2, SCREENHEIGHT / 2, 0, 0);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.95];
        //设置布局
        [self setUI];
        //添加手势
        [self addGestureRecognizer];
    }
}
#pragma mark - 设置布局
-(void)setUI{
    //初始化scrollView
//    self.scale = 1;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.minimumZoomScale = 0.7;
    self.scrollView.maximumZoomScale = 10;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    //初始化imageView
    _imageView = [[UIImageView alloc] init];
    _imageView.image = _image;
    _imageView.userInteractionEnabled = YES;
    _imageView.frame = CGRectMake(0, 0, 0, 0);
    [self.scrollView addSubview:self.imageView];
    
    self.alpha = 0.1f;
    self.backgroundColor = [UIColor whiteColor];
    //为视图添加动画
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
        self.scrollView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
        self.imageView.frame = [self getSmallFrame];
        self.alpha = 1.f;
        self.backgroundColor = [UIColor blackColor];
    }];
}
#pragma mark - 添加手势
-(void)addGestureRecognizer{
    //添加单击手势，移除视图
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remove)];
    [self addGestureRecognizer:tap];
    
    //添加长按手势
    WS(ws);
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:ws action:@selector(longPressAction:)];
    longPress.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:longPress];
}
#pragma mark - 长按手势
-(void)longPressAction:(UILongPressGestureRecognizer *)ges{
    if (ges.state == UIGestureRecognizerStateBegan) {
        WS(ws)
        NSArray *titleArr = [NSArray arrayWithObject:SAVEPHOTO];
        //        NSArray *titleArr = [NSArray arrayWithObjects:@"编辑图片", @"分享", @"删除图片", @"保存图片", nil];
        CCAlertView *alertView = [[CCAlertView alloc] initWithTitle:@"" alertStyle:CCAlertStyleActionSheet actionArr:titleArr];
        alertView.actionBlock = ^(NSInteger index) {
            //保存图片
            UIImageWriteToSavedPhotosAlbum(ws.imageView.image, nil, nil, nil);
            [ws showSaveSuccess];
        };
        [APPDelegate.window addSubview:alertView];
    }
}
//单击移除手势
-(void)remove
{
//    __weak typeof (self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(SCREENWIDTH / 2, SCREENHEIGHT / 2, 0, 0);
        self.scrollView.frame = CGRectZero;
        self.imageView.frame = CGRectZero;
        self.alpha = 0.1f;
    } completion:^(BOOL finished) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
        [self.scrollView removeFromSuperview];
        self.scrollView = nil;
        [self removeFromSuperview];
    }];
    if (_block) {
        _block(YES);
    }
}
#pragma mark - 自定义方法
//得到处理过的imageSize
-(CGRect)getSmallFrame
{
    CGSize imgSize = _imageView.image.size;
    CGFloat width = self.frame.size.width / imgSize.width;
    CGFloat height = self.frame.size.height / imgSize.height;
    CGFloat x = 0;
    CGFloat y = 0;
    //按照宽度算
    if (width < height) {
        imgSize.height = self.frame.size.width / imgSize.width * imgSize.height;
        imgSize.width = self.frame.size.width;
        x = 0;
        y = (self.frame.size.height - imgSize.height) / 2;
    }else{
        imgSize.width = self.frame.size.height / imgSize.height * imgSize.width;
        imgSize.height = self.frame.size.height;
        x = (self.frame.size.width - imgSize.width) / 2;
        y = 0;
    }
    CGRect smallFrame = CGRectMake(x, y, imgSize.width, imgSize.height);
    return smallFrame;
}
//弹出保存成功的提示
-(void)showSaveSuccess{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //弹出提示框
        CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:ALERT_SAVEPHOTO sureAction:ALERT_SURE cancelAction:nil sureBlock:nil];
        [APPDelegate.window addSubview:alertView];
    });
}
#pragma mark - scrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGRect frame = self.imageView.frame;
    
    frame.origin.y = (self.scrollView.frame.size.height - self.imageView.frame.size.height) > 0 ? (self.scrollView.frame.size.height - self.imageView.frame.size.height) * 0.5 : 0;
    frame.origin.x = (self.scrollView.frame.size.width - self.imageView.frame.size.width) > 0 ? (self.scrollView.frame.size.width - self.imageView.frame.size.width) * 0.5 : 0;
    self.imageView.frame = frame;
    
    self.scrollView.contentSize = CGSizeMake(self.imageView.frame.size.width + 30, self.imageView.frame.size.height + 30);
}
-(void)dealloc
{
//    NSLog(@"视图已销毁");
}

@end
