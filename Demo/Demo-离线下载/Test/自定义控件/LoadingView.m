//
//  LoadingView.m
//  NewCCDemo
//
//  Created by cc on 2016/11/27.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "LoadingView.h"
#import "UIImage+GIF.h"
#import "UITouchView.h"

@interface LoadingView()

@property(nonatomic,strong)UILabel                  *label;
//@property(nonatomic,strong)UIView                   *view;
@property(nonatomic,strong)UIView                   *centerView;

@end

@implementation LoadingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithLabel:(NSString *)str centerY:(BOOL)centerY{
    self = [super init];
    if(self) {
        WS(ws)
//        [self addSubview:self.view];
//        [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(ws);
//        }];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleTap:)];
        [self addGestureRecognizer:singleTap];
        
        self.userInteractionEnabled = YES;
        CGSize size = [self getTitleSizeByFont:str font:[UIFont systemFontOfSize:FontSize_28]];
        size.width = ceilf(size.width);
        size.height = ceilf(size.height);
        [self addSubview:self.centerView];
        [self.centerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ws);
            if(centerY) {
                make.centerY.mas_equalTo(ws);
            } else {
                make.centerY.mas_equalTo(ws.mas_bottom).offset(CCGetRealFromPt(-646));
            }
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(150) + CCGetRealFromPt(70) + size.width,CCGetRealFromPt(120)));
        }];
        
        [self.centerView addSubview:self.label];
        [self.label setText:str];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.and.height.mas_equalTo(ws.centerView);
            make.left.mas_equalTo(ws.centerView).offset(CCGetRealFromPt(150));
            make.right.mas_equalTo(ws.centerView).offset(CCGetRealFromPt(-70));
        }];
        
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage sd_animatedGIFNamed:@"loading"]];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"loading@3x" ofType:@"gif"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        UIImage *image = [UIImage sd_animatedGIFWithData:data];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self.centerView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.centerView).offset(CCGetRealFromPt(70));
            make.centerY.mas_equalTo(ws.centerView);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(52), CCGetRealFromPt(52)));
        }];
    }
    return self;
}

-(void)runAnimate {
    WS(ws)
    [UIView animateWithDuration:0.5 animations:^{
        ws.centerView.alpha = 0.0f;
    }];
}

- (void)dealSingleTap:(UITapGestureRecognizer *)tap {
}

-(CGSize)getTitleSizeByFont:(NSString *)str font:(UIFont *)font {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(20000.0f, 20000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return size;
}

-(UIView *)centerView {
    if(_centerView == nil) {
        _centerView = [UIView new];
        _centerView.layer.cornerRadius = CCGetRealFromPt(10);
        _centerView.layer.masksToBounds = YES;
        [_centerView.layer setShadowOffset:CGSizeMake(CCGetRealFromPt(5), CCGetRealFromPt(15))];
        [_centerView.layer setShadowColor:[CCRGBAColor(102, 102, 102,0.5) CGColor]];
        [_centerView.layer setBackgroundColor:[CCRGBAColor(20, 20, 20, 0.89) CGColor]];
    }
    return _centerView;
}

//-(UIView *)view {
//    if(_view == nil) {
//        _view = [[UIView alloc] init];
//        _view.userInteractionEnabled = YES;
////        [[UITouchView alloc] initWithBlock:^{
////        } passToNext:YES];
//        [_view setBackgroundColor:CCClearColor];
//        _view.backgroundColor = CCRGBAColor(255, 0, 0, 0.2);
//    }
//    return _view;
//}

-(UILabel *)label {
    if(_label == nil) {
        _label = [UILabel new];
        [_label setBackgroundColor:CCClearColor];
        [_label setFont:[UIFont systemFontOfSize:FontSize_28]];
        [_label setTextColor:CCRGBAColor(255, 255, 255, 0.69)];
        [_label setTextAlignment:NSTextAlignmentCenter];
    }
    return _label;
}

//-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    UIView *hitView = [super hitTest:point withEvent:event];
//    if (hitView == self)
//    {
//        return nil;
//    }
//    else
//    {
//        return hitView;
//    }
//}

@end

