//
//  CCBarrage.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/5/5.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCBarrage.h"
#import "OCBarrage.h"
#import "OCBarrageGradientBackgroundColorCell.h"
#import "OCBarrageWalkBannerCell.h"
#import "OCBarrageBecomeNobleCell.h"
#import "OCBarrageVerticalAnimationCell.h"
#import "Utility.h"
#define kRandomColor [UIColor colorWithRed:arc4random_uniform(256.0)/255.0 green:arc4random_uniform(256.0)/255.0 blue:arc4random_uniform(256.0)/255.0 alpha:1.0]

@interface CCBarrage ()
@property (nonatomic, strong) CATextLayer *textlayer;
@property (nonatomic, strong) OCBarrageManager *barrageManager;
@property (nonatomic, assign) int times;
@property (nonatomic, assign) int stopY;
@property (nonatomic, assign) BarrageStyle barrageStyle;
@property(nonatomic,assign)UIView * referenceView;

@end

@implementation CCBarrage

-(instancetype)initWithVideoView:(UIView *)videoView barrageStyle:(BarrageStyle)barrageStyle ReferenceView:(UIView *)referenceView
{
    self = [super init];
    if (self) {
        self.barrageManager = [[OCBarrageManager alloc] init];
        [videoView addSubview:self.barrageManager.renderView];
        
        /* 默认弹幕是全屏状态   */
        self.barrageManager.renderView.frame = CGRectMake(0.0, 0.0, videoView.frame.size.width, videoView.frame.size.height);
        self.barrageManager.renderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.barrageStyle = barrageStyle;
    }
    return self;
}

-(void)insertBarrageMessage:(CCPublicChatModel *)model{
    
    UIView *superView = [self.barrageManager.renderView superview];
    if (self.referenceView) {
        [superView insertSubview:self.barrageManager.renderView belowSubview:self.referenceView];
    }else{
        [superView bringSubviewToFront:self.barrageManager.renderView];
    }

    [superView bringSubviewToFront:self.barrageManager.renderView];
    
    /*  这里是有两个模版，模版一样式为:1.其他学生发送没有背景.
                                  2.自己发送彩色背景
                                   3.主持人，助教，讲师发送会有彩色背景色和身份标识。
     模版二样式根据初始化的BarrageStyle来实现弹幕效果:1.彩色背景样式
                                               2.正常显示模式
                                               3.带头部和尾部飘带样式
                                               4.中间停留模式
                                               5.从上到下模式
    */
    
    /*     模版一     */
    /* 判断消息身份 */
    //判断消息方是否是自己
    BOOL fromSelf = [model.fromuserid isEqualToString:model.myViwerId];
    if (!fromSelf && [model.userrole isEqualToString:@"student"]) {
        //其他学生发送的消息
        [self addNormalBarrageWithStr:model];
    }else{
        [self addFixedSpeedAnimationCellWithStr:model];
    }
    
    
    
    /*  模版二    */
//    switch (self.barrageStyle) {
//        case FixedSpeedAnimationCellBarrageStyle:
//            /* 彩色背景样式 (背景彩色字体白色)*/
//            [self addFixedSpeedAnimationCellWithStr:model];
//            break;
//        case NomalBarrageStyle:
//            /* 正常显示模式 */
//            [self addNormalBarrageWithStr:model];
//            break;
//        case WalkBannerBarrageStyle:
//            /* 带头部样式(头部样式，加背景图，字体彩色) */
//            [self addWalkBannerBarrageWithStr:model];
//            break;
//        case StopoverBarrageStyle:
//            /* 中间停留模式 */
//            [self addStopoverBarrage];
//            break;
//        case VerticalAnimationCellBarrageStyle:
//            /* 从上到下模式 */
//            [self addVerticalAnimationCellWithStr:model];
//            break;
//
//        default:
//            break;
//    }
}
#pragma mark - 弹幕显示样式

/**
 正常弹幕显示样式

 @param model 显示消息
 */
- (void)addNormalBarrageWithStr:(CCPublicChatModel *)model {
    
    /*
     正常速度建议设fixedSpeed为38;
     慢速建议设fixedSpeend为20;
     快速建议设fixedSpeed为58.
     */
    OCBarrageTextDescriptor *textDescriptor = [[OCBarrageTextDescriptor alloc] init];
    textDescriptor.attributedText = [self getAttributedText:model];
    textDescriptor.positionPriority = OCBarragePositionLow;
    textDescriptor.fixedSpeed = 38;
    textDescriptor.barrageCellClass = [OCBarrageTextCell class];
    
    [self.barrageManager renderBarrageDescriptor:textDescriptor];
}
/**
 彩色背景样式

 @param model 消息
 */
- (void)addFixedSpeedAnimationCellWithStr:(CCPublicChatModel *)model {
    OCBarrageGradientBackgroundColorDescriptor *gradientBackgroundDescriptor = [[OCBarrageGradientBackgroundColorDescriptor alloc] init];
    gradientBackgroundDescriptor.attributedText = [self getAttributedText:model];
    gradientBackgroundDescriptor.positionPriority = OCBarragePositionLow;
    gradientBackgroundDescriptor.fixedSpeed = 38.0;//用fixedSpeed属性设定速度
    gradientBackgroundDescriptor.barrageCellClass = [OCBarrageGradientBackgroundColorCell class];
    gradientBackgroundDescriptor.userrole = model.userrole;
    
    [self.barrageManager renderBarrageDescriptor:gradientBackgroundDescriptor];
}

/**
 带头部样式

 @param model 消息
 */
- (void)addWalkBannerBarrageWithStr:(CCPublicChatModel *)model {
    OCBarrageWalkBannerDescriptor *bannerDescriptor = [[OCBarrageWalkBannerDescriptor alloc] init];
    bannerDescriptor.attributedText = [self getAttributedText:model];
    bannerDescriptor.positionPriority = OCBarragePositionLow;
    bannerDescriptor.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    bannerDescriptor.strokeWidth = -1;
    bannerDescriptor.animationDuration = arc4random()%5 + 5;
    bannerDescriptor.barrageCellClass = [OCBarrageWalkBannerCell class];
    [self.barrageManager renderBarrageDescriptor:bannerDescriptor];
}

/**
 中间暂停样式
 */
- (void)addStopoverBarrage {
    OCBarrageBecomeNobleDescriptor *becomeNobleDescriptor = [[OCBarrageBecomeNobleDescriptor alloc] init];
    becomeNobleDescriptor.cellTouchedAction = ^(OCBarrageDescriptor *__weak descriptor, OCBarrageCell *__weak cell) {
        OCBarrageBecomeNobleCell *becomeCell = (OCBarrageBecomeNobleCell *)cell;
        [becomeCell removeFromSuperview];
    };
    NSMutableAttributedString *mAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"~获得场景视频~视频直播~荣誉出品~"]];
    [mAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, mAttributedString.length)];
    [mAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(1, 6)];
    [mAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor cyanColor] range:NSMakeRange(7, 6)];
    [mAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(13, 4)];
    [mAttributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17.0] range:NSMakeRange(0, mAttributedString.length)];
    becomeNobleDescriptor.attributedText = mAttributedString;
    CGFloat bannerHeight = 185.0/2.0;
    UIView *superView = [self.barrageManager.renderView superview];
    CGFloat minOriginY = CGRectGetMidY(superView.frame) - bannerHeight;
    CGFloat maxOriginY = CGRectGetMidY(superView.frame) + bannerHeight;
    becomeNobleDescriptor.renderRange = NSMakeRange(minOriginY, maxOriginY);
    becomeNobleDescriptor.positionPriority = OCBarragePositionVeryHigh;
    becomeNobleDescriptor.animationDuration = 4.0;
    becomeNobleDescriptor.barrageCellClass = [OCBarrageBecomeNobleCell class];
    becomeNobleDescriptor.backgroundImage = [UIImage imageNamed:@"noble_background_image@2x"];
    [self.barrageManager renderBarrageDescriptor:becomeNobleDescriptor];
    
    if (self.stopY == 0) {
        self.stopY = bannerHeight;
    } else {
        self.stopY = 0;
    }
}

/**
 垂直显示模式
 */
- (void)addVerticalAnimationCellWithStr:(CCPublicChatModel *)model {
    OCBarrageVerticalTextDescriptor *verticalTextDescriptor = [[OCBarrageVerticalTextDescriptor alloc] init];
    verticalTextDescriptor.attributedText = [self getAttributedText:model];
    verticalTextDescriptor.positionPriority = OCBarragePositionLow;
    verticalTextDescriptor.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    verticalTextDescriptor.strokeWidth = -1;
    verticalTextDescriptor.animationDuration = 5;
    verticalTextDescriptor.barrageCellClass = [OCBarrageVerticalAnimationCell class];
    
    [self.barrageManager renderBarrageDescriptor:verticalTextDescriptor];
}

/**
 得到处理过的文字样式

 @param model 需要处理的消息
 @return 处理过的消息
 */
-(NSMutableAttributedString *)getAttributedText:(CCPublicChatModel *)model{
    NSMutableAttributedString *attrStr = [Utility emotionStrWithString:model.msg y:-8];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attrStr.length)];
    if (IOS_SYSTEMVERSION >9) {
        [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:15] range:NSMakeRange(0, attrStr.length)];
    }
    [attrStr addAttribute:NSStrokeWidthAttributeName value:@-5 range:NSMakeRange(0, attrStr.length)];
    [attrStr addAttribute:NSStrokeColorAttributeName value:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3] range:NSMakeRange(0, attrStr.length)];
    return attrStr;
}
#pragma mark - 弹幕显示控制

/**
 关闭弹幕
 */
-(void)barrageClose{
    [self.barrageManager stop];
}

/**
 开启弹幕
 */
-(void)barrageOpen{
    [self.barrageManager start];
}

/**
 暂停弹幕
 */
-(void)barragePause{
    [self.barrageManager pause];
}

/**
 继续弹幕
 */
-(void)barrageResume{
    [self.barrageManager resume];
}
#pragma mark - 修改弹幕样式

/**
 修改弹幕显示位置

 @param renderViewStyle 弹幕样式
 */
-(void)changeRenderViewStyle:(RenderViewStyle)renderViewStyle{
    CGRect superFrame = [self.barrageManager.renderView superview].frame;
    switch (renderViewStyle) {
        case RenderViewTop://上
            self.barrageManager.renderView.frame = CGRectMake(0, 0, superFrame.size.width, superFrame.size.height /3);
            break;
        case RenderViewBottom://下
            self.barrageManager.renderView.frame = CGRectMake(0, superFrame.size.height / 3 * 2, superFrame.size.width, superFrame.size.height / 3);
            break;
        case RenderViewCenter://中
            self.barrageManager.renderView.frame = CGRectMake(0, 0, superFrame.size.width, superFrame.size.height / 2);
            break;
        case RenderViewFullScreen://全屏弹幕层
            self.barrageManager.renderView.frame = CGRectMake(0, 0, superFrame.size.width, superFrame.size.height);
            break;
            
        default:
            break;
    }
}


/**
 修改弹幕显示样式

 @param barrageStyle 弹幕显示样式
 */
-(void)changeBarrageStyle:(BarrageStyle)barrageStyle{
    if (barrageStyle) {
        self.barrageStyle = barrageStyle;
    }
}
@end
