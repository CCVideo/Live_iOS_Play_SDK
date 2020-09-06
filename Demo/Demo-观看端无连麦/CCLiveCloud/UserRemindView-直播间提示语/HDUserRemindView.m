//
//  HDUserRemindView.m
//  CCLiveCloud
//
//  Created by Apple on 2020/8/29.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "HDUserRemindView.h"

#define BGColor [UIColor colorWithHexString:@"#f5f5f5" alpha:1.0f]

@interface HDUserRemindView ()
/** 提示图片 */
@property (nonatomic, strong)UIImageView        *tipImageView;
/** 当前显示Label */
@property (nonatomic, strong) UILabel           *currentScrollLabel;
/** 预显示Label */
@property (nonatomic, strong) UILabel           *standbyScrollLabel;
/** 序号 */
@property (nonatomic, assign) NSInteger         index;
/** 需要停止 */
@property (nonatomic, assign) NSInteger         needStop;
/** 开始滚动 */
@property (nonatomic, assign) NSInteger         isRunning;
/** 文本字体 */
@property (nonatomic, copy)   UIFont            *textFont;
/** 文本颜色 */
@property (nonatomic, copy)   UIColor           *textColor;
/** 文本显示位置 */
@property (nonatomic)         NSTextAlignment   textAlignment;
/** 历史数据 */
@property (nonatomic, copy)   NSString          *historyText;

@end

@implementation HDUserRemindView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        [self initConfiguration];
        [self setupUI];
    }
    return self;
}

/**
 *    @brief    初始化配置项
 */
- (void)initConfiguration
{
    self.clipsToBounds = YES;
    self.backgroundColor = BGColor;
    self.userInteractionEnabled = NO;
    
    _index         = 0;
    _needStop      = NO;
    _isRunning     = NO;
    _textDataArr   = @[];
    self.historyText   = @"";
    
    _textStayTime  = 0.25;
    _scrollAnimationTime = 0.2;
    
    _textFont      = [UIFont systemFontOfSize:12];
    _textColor     = [UIColor colorWithHexString:@"#FF6633" alpha:1];
    _textAlignment = NSTextAlignmentLeft;
    
    self.currentScrollLabel = nil;
    self.standbyScrollLabel = nil;
}

- (void)setupUI
{
    [self addSubview:self.tipImageView];
    [self createScrollLabelNeedStandbyLabel:YES];
}

- (UIImageView *)tipImageView
{
    if (!_tipImageView) {
        CGFloat imageX = 10;
        CGFloat imageY = 0;
        CGFloat imageW = 30;
        CGFloat imageH = 30;
        CGRect imageFrame = CGRectMake(imageX, imageY, imageW, imageH);
        _tipImageView = [[UIImageView alloc]initWithFrame:imageFrame];
        _tipImageView.image = [UIImage imageNamed:@"join_room_tip"];
        _tipImageView.contentMode = UIViewContentModeCenter;
    }
    return _tipImageView;
}

- (void)setTextDataArr:(NSArray *)textDataArr
{
    _textDataArr = textDataArr;
//    NSLog(@"---remind2--%@",[textDataArr firstObject]);
    [self start];
    self.hidden = NO;
}


#pragma mark - ActionMethod
/**
 *    @brief    开始
 */
- (void)start
{
    if (_isRunning) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(start) object:nil];
        [self performSelector:@selector(start) withObject:nil afterDelay:0.5f];
        return;
    }
    [self scrollWithNoSpaceByDirection:@(1)];
}

#pragma mark - Clear / Create
- (void)resetStateToEmpty
{
    if (self.currentScrollLabel) {
        [self.currentScrollLabel removeFromSuperview];
        self.currentScrollLabel = nil;
    }
    if (self.standbyScrollLabel) {
        [self.standbyScrollLabel removeFromSuperview];
        self.standbyScrollLabel = nil;
    }
    
    _index      = 0;
    _needStop   = NO;
}


- (void)createScrollLabelNeedStandbyLabel:(BOOL)isNeed
{
    self.currentScrollLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, -30, self.frame.size.width, self.frame.size.height)];
    self.currentScrollLabel.textAlignment = _textAlignment;
    self.currentScrollLabel.textColor     = _textColor;
    self.currentScrollLabel.font          = _textFont;
    [self addSubview:self.currentScrollLabel];
    
    if (isNeed) {
        self.standbyScrollLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, -60, self.frame.size.width, self.frame.size.height)];
        self.standbyScrollLabel.textAlignment = _textAlignment;
        self.standbyScrollLabel.textColor     = _textColor;
        self.standbyScrollLabel.font          = _textFont;
        [self addSubview:self.standbyScrollLabel];
    }
}


#pragma mark - Scroll Action
- (void)scrollWithNoSpaceByDirection:(NSNumber *)direction {
    // 取消上次隐藏事件
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenView) object:nil];
    
    if (_textDataArr.count == 0) {
        _isRunning = NO;
        return;
    }else{
        _isRunning = YES;
    }
    if (self.showOrHiddenRemindView) {
        self.showOrHiddenRemindView(YES);
    }
    @synchronized (self) {    
        self.currentScrollLabel.text  = self.historyText;
        self.historyText = _textDataArr[[self nextIndex:_index]];
        self.standbyScrollLabel.text  = _textDataArr[[self nextIndex:_index]];
    }
    
    self.standbyScrollLabel.frame = CGRectMake(40, self.height*direction.integerValue, self.frame.size.width - 40, self.frame.size.height);
    
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:_scrollAnimationTime delay:_textStayTime options:UIViewAnimationOptionLayoutSubviews animations:^{

        weakSelf.currentScrollLabel.frame = CGRectMake(40, -weakSelf.height*direction.integerValue, weakSelf.frame.size.width - 40, weakSelf.frame.size.height);
        weakSelf.standbyScrollLabel.frame = CGRectMake(40, 0, weakSelf.frame.size.width - 40, weakSelf.frame.size.height);

    } completion:^(BOOL finished) {

        weakSelf.index = [self nextIndex:weakSelf.index];

        UILabel * temp = weakSelf.currentScrollLabel;
        weakSelf.currentScrollLabel = weakSelf.standbyScrollLabel;
        weakSelf.standbyScrollLabel = temp;
        weakSelf.needStop = YES;
        if (weakSelf.needStop) {
            weakSelf.isRunning = NO;
        }else{
            [weakSelf performSelector:@selector(scrollWithNoSpaceByDirection:) withObject:direction];
        }
    }];

    // 没有数据隐藏
    [self performSelector:@selector(hiddenView) withObject:nil afterDelay:3.f];
}

- (void)hiddenView
{
    self.hidden = YES;
    self.historyText = @"";
    if (self.showOrHiddenRemindView) {
        self.showOrHiddenRemindView(NO);
    }
}

- (NSInteger)nextIndex:(NSInteger)index{
    NSInteger nextIndex = index + 1;
    if (nextIndex >= _textDataArr.count) {
        nextIndex = 0;
    }
    return nextIndex;
}

#pragma mark - State Check
-(BOOL)isCurrentViewControllerVisible:(UIViewController *)viewController{
    return (viewController.isViewLoaded && viewController.view.window && [UIApplication sharedApplication].applicationState == UIApplicationStateActive);
}

- (UIViewController *)viewController {
    for (UIView * next = [self superview]; next; next = next.superview) {
        UIResponder * nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (NSString *)getNowTimeTimestamp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970]*1000) ];
    return timeSp;
}

@end
