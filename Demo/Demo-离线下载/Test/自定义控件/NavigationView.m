//
//  NavigationView.m
//  NewCCDemo
//
//  Created by cc on 2016/11/25.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "NavigationView.h"
#import "SelectMenuView.h"
#import "UITouchView.h"

@interface NavigationView()

@property(nonatomic,strong)UIImageView          *iconImage;
@property(nonatomic,strong)UILabel              *label;
@property(nonatomic,copy)  NSString             *title;
@property(nonatomic,strong)SelectMenuView       *selectMenuView;
@property(nonatomic,strong)UITouchView          *view;
@property(nonatomic,copy)  PushToIndex          pushBlock;

@end

@implementation NavigationView

-(void)handleSingleTap
{
    _view.hidden = !_view.hidden;
    if(_view.hidden == YES) {
        [_iconImage setImage:[UIImage imageNamed:@"nav_ic_cbb-nor"]];
    } else if(_view.hidden == NO) {
        [_iconImage setImage:[UIImage imageNamed:@"nav_ic_cbb-hov"]];
        NSInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:CONTROLLER_INDEX] integerValue];
        [_selectMenuView showMenuWithIndex:index];
    }
}

-(UIView *)view {
    if(_view == nil) {
        WS(ws)
        _view = [[UITouchView alloc] initWithBlock:^{
            BOOL hidden = ws.view.hidden;
            ws.view.hidden = !hidden;
            if(ws.view.hidden == YES) {
                [ws.iconImage setImage:[UIImage imageNamed:@"nav_ic_cbb-nor"]];
            } else if(ws.view.hidden == NO) {
                [ws.iconImage setImage:[UIImage imageNamed:@"nav_ic_cbb-hov"]];
                NSInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:CONTROLLER_INDEX] integerValue];
                [ws.selectMenuView showMenuWithIndex:index];
            }
        } passToNext:NO];
        [_view setBackgroundColor:CCClearColor];
    }
    return _view;
}

-(void)hideNavigationView {
    _view.hidden = YES;
    [_iconImage setImage:[UIImage imageNamed:@"nav_ic_cbb-nor"]];
}

-(instancetype)initWithTitle:(NSString *)title pushBlock:(PushToIndex)pushBlock {
    self = [super init];
    if (self){
        self.title = title;
        self.pushBlock = pushBlock;
        [self loadImageAndIcon];
        [self loadView];
        [self loadSelectMenu];
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
        [self addGestureRecognizer:singleTap];
    }
    return self;
}

-(void)loadView {
    [APPDelegate.window addSubview:self.view];
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(APPDelegate.window);
        make.top.mas_equalTo(APPDelegate.window).offset(64 - 14);
        make.size.mas_equalTo(APPDelegate.window);
    }];
}

-(void)loadSelectMenu {
    [self.view addSubview:self.selectMenuView];
    [_view setHidden:YES];
    WS(ws)
    [_selectMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.view);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(250),CCGetRealFromPt(230)));
    }];
}

-(SelectMenuView *)selectMenuView {
    if(_selectMenuView == nil) {
        WS(ws)
        _selectMenuView = [[SelectMenuView alloc] initWithBlock:^{
            [ws handleSingleTap];
        } pushBlock:^(NSInteger index) {
            if(ws.pushBlock) {
                ws.pushBlock(index);
            }
        }];
    }
    return _selectMenuView;
}

-(void)loadImageAndIcon {
    [self addSubview:self.iconImage];
    [self addSubview:self.label];
    WS(ws)
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ws);
        make.centerY.mas_equalTo(ws.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(155),CCGetRealFromPt(34)));
    }];
    
    [self.iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(ws);
        make.centerY.mas_equalTo(ws.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(28),CCGetRealFromPt(16)));
    }];
}

-(UIView *)iconImage {
    if(_iconImage == nil) {
        _iconImage = [UIImageView new];
        [_iconImage setImage:[UIImage imageNamed:@"nav_ic_cbb-nor"]];
    }
    return _iconImage;
}

-(UIView *)label {
    if(_label == nil) {
        _label = [UILabel new];
        [_label setTextColor:[UIColor whiteColor]];
        _label.font = [UIFont systemFontOfSize:FontSize_32];
        _label.text = self.title;
    }
    return _label;
}

@end
