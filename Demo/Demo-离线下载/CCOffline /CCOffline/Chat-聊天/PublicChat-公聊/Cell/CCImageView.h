//
//  CCImageView.h
//  CCLiveCloud
//
//  Created by 何龙 on 2018/12/12.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCImageView : UIImageView
//传入图片,返回一个处理过的CGSize
-(CGSize)getCGSizeWithImage:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
