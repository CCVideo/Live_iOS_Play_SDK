//
//  HLPhotoView.h
//  HL
//
//  Created by 何龙 on 2018/12/11.
//  Copyright © 2018 何龙. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PhotoBlock)(BOOL flag);

@interface CCPhotoBrowser : UIView

@property (nonatomic, copy) PhotoBlock block;

//返回一个唯一的照片查看器
+(CCPhotoBrowser *)sharedBrowser;

/**
 初始化方法

 @param image 需要传入的图片
 */
-(void)createWithImage:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
