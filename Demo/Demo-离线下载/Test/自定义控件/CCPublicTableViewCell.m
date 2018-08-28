//
//  CCTableViewCell.m
//  NewCCDemo
//
//  Created by cc on 2016/12/5.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "CCPublicTableViewCell.h"
#import "UIButton+UserInfo.h"

@interface CCPublicTableViewCell()

@property(nonatomic,strong)UIButton                 *button;
@property(nonatomic,assign)BOOL                     *isPublisher;
@property(nonatomic,copy)AnteSomeone                atsoBlock;
@property(nonatomic,strong)UILabel                  *label;
@property(nonatomic,copy) NSString                  *antename;
@property(nonatomic,copy) NSString                  *anteid;
@property(nonatomic,strong)UIView                   *centerView;

@end

@implementation CCPublicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)reloadWithDialogue:(Dialogue *)dialogue antesomeone:(AnteSomeone)atsoBlock {
    self.atsoBlock = atsoBlock;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:dialogue.msg];
    if([dialogue.fromuserid isEqualToString:dialogue.myViwerId]) {
        [text addAttribute:NSForegroundColorAttributeName value:CCRGBColor(255,102,51) range:NSMakeRange(0, text.length)];
    } else {
        [text addAttribute:NSForegroundColorAttributeName value:CCRGBColor(247,247,247) range:NSMakeRange(0, text.length)];
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.firstLineHeadIndent = dialogue.userNameSize.width;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    
    [self.button setTitle:dialogue.username forState:UIControlStateNormal];
    [self.button setUserid:dialogue.userid];
    self.label.attributedText = text;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier dialogue:(Dialogue *)dialogue antesomeone:(AnteSomeone)atsoBlock {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.atsoBlock = atsoBlock;
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:self.centerView];
        WS(ws)
        [_centerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws);
            make.top.mas_equalTo(ws).offset(5);
            make.bottom.mas_equalTo(ws).offset(-5);
        }];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:dialogue.msg];
        
        if([dialogue.fromuserid isEqualToString:dialogue.myViwerId]) {
            [text addAttribute:NSForegroundColorAttributeName value:CCRGBColor(255,102,51) range:NSMakeRange(0, text.length)];
        } else {
            [text addAttribute:NSForegroundColorAttributeName value:CCRGBColor(247,247,247) range:NSMakeRange(0, text.length)];
        }
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.firstLineHeadIndent = dialogue.userNameSize.width;
        style.lineBreakMode = NSLineBreakByCharWrapping;
        [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
        
        [_centerView addSubview:self.button];
        [_centerView addSubview:self.label];
        
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.mas_equalTo(ws.centerView);
            make.size.mas_equalTo(CGSizeMake(dialogue.userNameSize.width, dialogue.userNameSize.height));
        }];
        
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.mas_equalTo(ws.centerView);
            make.size.mas_equalTo(ws.centerView);
        }];
        
        [_button setTitle:dialogue.username forState:UIControlStateNormal];
        [_button setUserid:dialogue.userid];
        _label.attributedText = text;
    }
    return self;
}

-(UIButton *)button {
    if(!_button) {
        _button = [UIButton new];
        _button.backgroundColor = CCClearColor;
        [_button setTitleColor:CCRGBColor(245,177,8) forState:UIControlStateNormal];
        [_button.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
        _button.layer.shadowColor = [CCRGBAColor(0,0,0,0.50) CGColor];
        _button.layer.shadowOffset = CGSizeMake(0, 1);
        [_button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

-(void)btnClicked:(UIButton *)sender {
    NSString *str = [sender titleForState:UIControlStateNormal];
    
    NSRange range = [str rangeOfString:@": "];
    if(range.location == NSNotFound) {
        _antename = str;
    } else {
        _antename = [str substringToIndex:range.location];
    }
//    CCLog(@"str = %@,range = %@,_antename = %@",str,NSStringFromRange(range),_antename);
    _anteid = sender.userid;
    
    if(self.atsoBlock) {
        self.atsoBlock(_antename,_anteid);
    }
}

-(UILabel *)label {
    if(!_label) {
        _label = [UILabel new];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont systemFontOfSize:FontSize_32];
        _label.numberOfLines = 0;
        _label.textColor = CCRGBColor(247,247,247);
        _label.textAlignment = NSTextAlignmentLeft;
        _label.shadowOffset = CGSizeMake(0, 1);
        _label.shadowColor = CCRGBAColor(0, 0, 0, 0.5);
    }
    return _label;
}

-(UIView *)centerView {
    if(!_centerView) {
        _centerView = [UIView new];
        _centerView.backgroundColor = CCClearColor;
    }
    return _centerView;
}

@end

