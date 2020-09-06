//
//  CCAnimationView.h
//  CCLiveCloud
//
//  Created by Clark on 2019/11/1.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCAnimationView : UIView
@property (nonatomic, strong, readonly) UIColor *tintColor;

@property (nonatomic, assign, readonly) NSTimeInterval timeInterval;

@property (nonatomic, assign, readonly) NSTimeInterval duration;

@property (nonatomic, assign, readonly) NSInteger waveCount;

@property (nonatomic, assign, readonly) CGFloat minRadius;

@property (nonatomic, assign, readonly) BOOL animating;

- (instancetype)initWithTintColor:(UIColor *)tintColor minRadius:(CGFloat)minRadius waveCount:(NSInteger)waveCount timeInterval:(NSTimeInterval)timeInterval duration:(NSTimeInterval)duration;

- (void)startAnimating;
- (void)stopAnimating;

@end

NS_ASSUME_NONNULL_END
