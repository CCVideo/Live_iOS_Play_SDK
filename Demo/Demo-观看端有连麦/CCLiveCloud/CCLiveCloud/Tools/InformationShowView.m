//
//  InformationShowView.m
//  NewCCDemo
//
//  Created by cc on 2016/11/26.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "InformationShowView.h"
#import "UITouchView.h"

@interface InformationShowView()

@property(nonatomic,strong)UILabel                  *label;
//@property(nonatomic,strong)UIView                   *view;
@property(nonatomic,strong)UIView                   *centerView;

@end

@implementation InformationShowView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame WithLabel:(NSString *)str{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleTap:)];
        [self addGestureRecognizer:singleTap];
        
        self.userInteractionEnabled = YES;
        CGSize size = [self getTitleSizeByFont:str font:[UIFont systemFontOfSize:FontSize_28]];
        
        [self addSubview:self.centerView];
        [self.centerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(self.mas_top);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(130) + size.width,CCGetRealFromPt(82) + size.height));
        }];
        
        [self.centerView addSubview:self.label];
        [self.label setText:str];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.centerView);
        }];
        self.centerView.alpha=0.0;
        [self layoutIfNeeded];
        
        //动画--淡入
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveLinear  animations:^{
            self.centerView.alpha=1.0;
        } completion:^(BOOL finished) {
            [self hiddenAnimation];
        }];
    }
    return self;
}
-(instancetype)initWithLabel:(NSString *)str {
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
        
        [self addSubview:self.centerView];
        [self.centerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ws);
            make.top.mas_equalTo(ws.mas_bottom).offset(- 100 - 110);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(130) + size.width,CCGetRealFromPt(82) + size.height));
        }];
        
        [self.centerView addSubview:self.label];
        [self.label setText:str];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.centerView);
        }];
        ws.centerView.alpha=0.0;
        [self layoutIfNeeded];
        
        //动画--淡入
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveLinear  animations:^{
            ws.centerView.alpha=1.0;
        } completion:^(BOOL finished) {
            [ws hiddenAnimation];
        }];
    }
    return self;
}

//动画--淡出
-(void)hiddenAnimation
{
    WS(ws)
    [UIView animateWithDuration:1.0f delay:0.5f options:UIViewAnimationOptionCurveLinear  animations:^{
        ws.centerView.alpha=0.0;
    } completion:^(BOOL finished) {
        
    }];
}

-(CGSize)getTitleSizeByFont:(NSString *)str font:(UIFont *)font {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(20000.0f, 20000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return size;
}

//-(UIView *)view {
//    if(_view == nil) {
////        WS(ws)
////        _view = [[UITouchView alloc] initWithBlock:^{
////        } passToNext:YES];
////        [ws.view setBackgroundColor:CCClearColor];
//        _view = [[UIView alloc] init];
//        _view.userInteractionEnabled = YES;
//        [_view setBackgroundColor:CCClearColor];
//    }
//    return _view;
//}
- (void)dealSingleTap:(UITapGestureRecognizer *)tap {
}

-(UIView *)centerView {
    if(_centerView == nil) {
        _centerView = [[UIView alloc] init];
        _centerView.layer.cornerRadius = CCGetRealFromPt(10);
        _centerView.layer.masksToBounds = YES;
        [_centerView.layer setShadowOffset:CGSizeMake(CCGetRealFromPt(5), CCGetRealFromPt(15))];
        [_centerView.layer setShadowColor:[CCRGBAColor(102, 102, 102,0.5) CGColor]];
        [_centerView.layer setBackgroundColor:[CCRGBAColor(20, 20, 20, 0.89) CGColor]];
    }
    return _centerView;
}

-(UILabel *)label {
    if(_label == nil) {
        _label = [[UILabel alloc] init];
        [_label setBackgroundColor:CCClearColor];
        [_label setFont:[UIFont systemFontOfSize:FontSize_28]];
        [_label setTextColor:CCRGBAColor(255, 255, 255, 0.89)];
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
