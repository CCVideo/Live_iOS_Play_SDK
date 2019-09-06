//
//  CCImageView.m
//  CCLiveCloud
//
//  Created by 何龙 on 2018/12/12.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCImageView.h"
#import "CCPhotoBrowser.h"
#import "UIView+GetVC.h"

@interface CCImageView ()
@property (nonatomic, strong) CCPhotoBrowser *photoView;
@end

@implementation CCImageView


-(instancetype)init{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToPhotoView)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
#pragma mark - 查看大图
-(void)pushToPhotoView
{
    NSDictionary *hiddenDic = [NSDictionary dictionaryWithObject:@"1" forKey:@"keyBorad_hidden"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"keyBorad_hidden" object:nil userInfo:hiddenDic];
    self.userInteractionEnabled = NO;
    //传入image即可实现浏览大图的功能
    _photoView = [CCPhotoBrowser sharedBrowser];
    WS(weakSelf)
    _photoView.block = ^(BOOL flag) {
        weakSelf.userInteractionEnabled = YES;
        
        NSDictionary *showDic = [NSDictionary dictionaryWithObject:@"0" forKey:@"keyBorad_hidden"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"keyBorad_hidden" object:nil userInfo:showDic];
    };
    [self.photoView createWithImage:self.image];
    [APPDelegate.window addSubview:self.photoView];
    [[self getViewController].view endEditing:YES];
}
//返回一个处理过的图片大小
-(CGSize)getCGSizeWithImage:(UIImage *)image{
    self.image = image;
    CGSize imageSize = image.size;
    if (imageSize.width > CCGetRealFromPt(438)) {
        imageSize.height = CCGetRealFromPt(438) / imageSize.width * imageSize.height;
        imageSize.width = CCGetRealFromPt(438);
    }
    return imageSize;
}
@end
