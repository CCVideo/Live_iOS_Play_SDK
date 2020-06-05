//
//  CCChatBaseRadioCell.m
//  CCLiveCloud
//
//  Created by Apple on 2020/6/4.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "CCChatBaseRadioCell.h"
#import "Utility.h"
#import "CCChatViewDataSourceManager.h"

#define BGColor [UIColor colorWithHexString:@"#f5f5f5" alpha:1.0f]


@interface CCChatBaseRadioCell ()

#pragma mark - 广播
@property (nonatomic, strong) UIButton    *radioBgButton;//广播背景视图
@property (nonatomic, strong) UILabel     *radioLabel;//广播label

@end

@implementation CCChatBaseRadioCell

//初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.backgroundColor = CCClearColor;
        self.backgroundColor = BGColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        for (id subView in self.contentView.subviews) {
            [subView removeFromSuperview];
        }
        [self setUpUI];
    }
    return self;
}

#pragma mark - 设置UI布局
-(void)setUpUI{
        
    //设置广播消息
    _radioBgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBgButton.enabled = NO;
    _radioBgButton.layer.cornerRadius = CCGetRealFromPt(4);
    _radioBgButton.layer.masksToBounds = YES;
    [_radioBgButton setBackgroundColor:CCRGBColor(237,237,237)];
    [self addSubview:_radioBgButton];
    //设置广播文本
    _radioLabel = [[UILabel alloc] init];
    _radioLabel.numberOfLines = 0;
//    _radioLabel.backgroundColor = CCClearColor;
    _radioLabel.backgroundColor = CCRGBColor(237,237,237);
    _radioLabel.textColor = CCRGBColor(248,129,25);
    _radioLabel.textAlignment = NSTextAlignmentLeft;
    _radioLabel.userInteractionEnabled = NO;
    [_radioBgButton addSubview:_radioLabel];
    _radioLabel.font = [UIFont systemFontOfSize:FontSize_24];
}
#pragma mark - 加载广播消息

/**
 加载广播消息

 @param model 公聊数据模型
 */
-(void)setRadioModel:(CCPublicChatModel *)model{
    //设置广播消息的背景btn
    [_radioBgButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(CCGetRealFromPt(25) * 2 + model.textSize.width);
        make.top.mas_equalTo(self).offset(CCGetRealFromPt(15));
        make.bottom.mas_equalTo(self).offset(CCGetRealFromPt(-15));
    }];
    //设置广播的消息内容
    _radioLabel.text = model.msg;
    [_radioLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_radioBgButton.mas_centerX);
        make.centerY.mas_equalTo(_radioBgButton.mas_centerY).offset(-1);
        make.size.mas_equalTo(CGSizeMake(model.textSize.width + 1, model.textSize.height + 1));
    }];
}

@end
