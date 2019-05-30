//
//  OCBarrageBackgroundColorTextCell.m
//  OCBarrage
//
//  Created by QMTV on 2017/8/25.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageGradientBackgroundColorCell.h"

#define ImageWidth 30.0
#define ImageHeight 18.0
@implementation OCBarrageGradientBackgroundColorCell

- (void)updateSubviewsData {
    [super updateSubviewsData];
    
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    [self.textLabel setAttributedText:nil];
    [self addSubview:self.textLabel];
}

- (void)layoutContentSubviews {
    [super layoutContentSubviews];
    [self addGradientLayer];
}

- (void)convertContentToImage {
    UIImage *contentImage = [self.layer convertContentToImageWithSize:_gradientLayer.frame.size];
    [self.layer setContents:(__bridge id)contentImage.CGImage];
}

- (void)removeSubViewsAndSublayers {
    [super removeSubViewsAndSublayers];
    
    _gradientLayer = nil;
}

- (void)addGradientLayer {
    BOOL haveIdor = NO;
    NSString *userRole = self.gradientDescriptor.userrole;
    NSString *idorImageName;
    CGFloat imageWidth = ImageWidth;
    if ([userRole isEqualToString:@"publisher"]) {//主讲
        haveIdor = YES;
        idorImageName = @"barrage_publisher";
        self.gradientDescriptor.gradientColor = CCRGBColor(255, 72, 0);
    } else if ([userRole isEqualToString:@"student"]) {//学生或观众
        imageWidth = 0;
        self.gradientDescriptor.gradientColor = CCRGBColor(255, 72, 0);
    } else if ([userRole isEqualToString:@"host"]) {//主持人
        haveIdor = YES;
        idorImageName = @"barrage_host";
        imageWidth = 40;
        self.gradientDescriptor.gradientColor = CCRGBColor(0, 242, 254);
    } else if ([userRole isEqualToString:@"unknow"]) {//其他没有角色
        imageWidth = 0;
    } else if ([userRole isEqualToString:@"teacher"]) {//助教
        haveIdor = YES;
        idorImageName = @"barrage_teacher";
        self.gradientDescriptor.gradientColor = CCRGBColor(41, 208, 147);
    } else{
        imageWidth = 0;
    }

    if (!self.gradientDescriptor.gradientColor) {
        return;
    }
    CALayer *layer = [CALayer layer];
    if (haveIdor) {
        /* 当是主持人，助教，讲师时，添加前缀标识  */
        CGFloat leftImageViewX = (self.textLabel.frame.size.height + 6 - ImageHeight) / 2;
        CGFloat leftImageViewY = leftImageViewX;
        layer.frame = CGRectMake(leftImageViewX, leftImageViewY, imageWidth, ImageHeight);;
        layer.backgroundColor = [UIColor clearColor].CGColor;
        layer.contents = (__bridge id _Nullable)([UIImage imageNamed:idorImageName].CGImage);
        [self.layer insertSublayer:layer atIndex:0];
        
        self.textLabel.frame = CGRectMake(leftImageViewX * 2 + imageWidth, 0, self.textLabel.frame.size.width, self.textLabel.frame.size.height + 6);
    }else{
        self.textLabel.frame = CGRectMake(10, 0, self.textLabel.frame.size.width, self.textLabel.frame.size.height + 6);
    }
    
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[self.gradientDescriptor.gradientColor colorWithAlphaComponent:1.0f].CGColor, (__bridge id)[self.gradientDescriptor.gradientColor colorWithAlphaComponent:0.0].CGColor];
    gradientLayer.locations = @[@0.2, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1.0, 0);
    gradientLayer.frame = CGRectMake(0.0, 0.0, self.textLabel.frame.size.width + 25.0 + imageWidth, self.textLabel.frame.size.height);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:gradientLayer.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:gradientLayer.bounds.size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = gradientLayer.bounds;
    maskLayer.path = maskPath.CGPath;
    gradientLayer.mask = maskLayer;
    _gradientLayer = gradientLayer;
    if (haveIdor) {
        [self.layer insertSublayer:gradientLayer below:layer];
    }else{
        [self.layer insertSublayer:gradientLayer atIndex:0];
    }
}

- (void)setBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor {
    [super setBarrageDescriptor:barrageDescriptor];
    self.gradientDescriptor = (OCBarrageGradientBackgroundColorDescriptor *)barrageDescriptor;
}

@end
