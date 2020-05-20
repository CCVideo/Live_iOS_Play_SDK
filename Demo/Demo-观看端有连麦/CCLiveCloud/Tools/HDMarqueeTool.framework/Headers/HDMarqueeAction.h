//
//  HDMarqueeAction.h
//  HDMarqueeTool
//
//  Created by zwl on 2020/3/10.
//  Copyright © 2020 zwl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class HDMarqueeActionPosition;

///跑马灯动作
@interface HDMarqueeAction : NSObject

//持续时间
@property(nonatomic,assign)CGFloat duration;

//动作开始时坐标位置
@property(nonatomic,strong,readonly)HDMarqueeActionPosition * startPostion;

//动作结束时坐标位置
@property(nonatomic,strong,readonly)HDMarqueeActionPosition * endPostion;

@end

///用于记录每次的位置
@interface HDMarqueeActionPosition : NSObject

///坐标位置，取值范围0 - 1，例如(0.5,0.5)
@property(nonatomic,assign)CGPoint pos;

///透明度，取值范围 0 - 1
@property(nonatomic,assign)CGFloat alpha;

@end
