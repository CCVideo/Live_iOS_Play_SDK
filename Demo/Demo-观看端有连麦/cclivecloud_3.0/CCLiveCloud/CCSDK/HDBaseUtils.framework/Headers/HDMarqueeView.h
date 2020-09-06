//
//  HDMarqueeView.h
//  HDMarqueeTool
//
//  Created by zwl on 2020/3/9.
//  Copyright © 2020 zwl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@class HDMarqueeAction;

typedef NS_ENUM(NSUInteger, HDMarqueeViewStyle) {
    HDMarqueeViewStyleTitle,//文字样式
    HDMarqueeViewStyleImage //图片样式
};

///跑马灯控件
@interface HDMarqueeView : UIView

/**
 *  @brief 父视图，必填
 */
@property(nonatomic,assign)UIView * fatherView;

/**
 *  @brief 跑马灯样式，默认文字样式
 */
@property(nonatomic,assign)HDMarqueeViewStyle style;

/**
 *  @brief 跑马灯文字内容
 */
@property(nonatomic,copy)NSString * text;

/**
 *  @brief 跑马灯文字格式
 */
@property(nonatomic,copy)NSDictionary * textAttributed;

/**
 *  @brief 跑马灯文字对齐方式，默认kCAAlignmentNatural
 */
@property(nonatomic,copy)NSString * textAlignmentMode;

/**
 *  @brief 跑马灯文字显示不全时，裁剪方式，默认kCATruncationNone
 */
@property(nonatomic,copy)NSString * textTruncationMode;

/**
 *  @brief 跑马灯文字是否自动换行，默认NO
 */
@property(nonatomic,assign)BOOL wrapped;

/**
 *  @brief 跑马灯图片
 */
@property(nonatomic,strong)NSURL * imageURL;

/**
 *  @brief 跑马灯效果，必填
 */
@property(nonatomic,strong)NSArray <HDMarqueeAction *> * actions;

/**
 *  @brief 循环次数，默认1，0表示无限循环
 */
@property(nonatomic,assign)NSInteger repeatCount;

/*!
 * @method
 * @abstract 开始跑马灯
 * @discussion 开始跑马灯
 */
-(void)startMarquee;

/*!
 * @method
 * @abstract 结束跑马灯
 * @discussion 结束跑马灯
 */
-(void)stopMarquee;

@end

