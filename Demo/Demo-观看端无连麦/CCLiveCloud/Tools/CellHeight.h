//
//  CellHeight.h
//  CCLiveCloud
//
//  Created by 何龙 on 2018/12/29.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CellHeight : NSObject

/**
 返回唯一一个计算高度的类

 @return self
 */
+(CellHeight *)sharedHeight;

/**
 存入图片的高度

 @param height 图片高度
 @param url 图片的地址
 */
-(void)setHeight:(CGFloat)height ForKey:(NSString *)url;

/**
 得到图片的高度

 @param url 图片的url
 @return self
 */
-(CGFloat)getHeightForKey:(NSString *)url;

/**
 去除所有存入的url
 */
-(void)removeAllKeys;
@end

NS_ASSUME_NONNULL_END
