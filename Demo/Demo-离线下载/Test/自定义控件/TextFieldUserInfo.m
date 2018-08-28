//
//  LabelUserInfo.m
//  NewCCDemo
//
//  Created by cc on 2016/11/23.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "TextFieldUserInfo.h"

@interface TextFieldUserInfo()

@property(nonatomic,strong)UIView               *upLine;
@property(nonatomic,strong)UILabel              *leftLabel;
@property(nonatomic,strong)UIView               *leftLabelView;

@end

@implementation TextFieldUserInfo

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//UILabel
////创建uilabel
//UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 280, 80)];
////设置背景色
//label1.backgroundColor = [UIColor grayColor];
////设置tag
//label1.tag = 91;
////设置标签文本
//label1.text = @CCBASE.NET!;
////设置标签文本字体和字体大小
//label1.font = [UIFont fontWithName:@Arial size:30];
////设置文本对齐方式
//label1.textAlignment = UITextAlignmentCenter;
////文本对齐方式有以下三种
////typedef enum {
//// UITextAlignmentLeft = 0,左对齐
//// UITextAlignmentCenter,居中对齐
//// UITextAlignmentRight, 右对齐
////} UITextAlignment;
////文本颜色
//label1.textColor = [UIColor blueColor];
////超出label边界文字的截取方式
//label1.lineBreakMode = UILineBreakModeTailTruncation;
////截取方式有以下6种
////ypedef enum {
//// UILineBreakModeWordWrap = 0, 以空格为边界，保留整个单词
//// UILineBreakModeCharacterWrap, 保留整个字符
//// UILineBreakModeClip, 到边界为止
//// UILineBreakModeHeadTruncation, 省略开始，以……代替
//// UILineBreakModeTailTruncation, 省略结尾，以……代替
//// UILineBreakModeMiddleTruncation,省略中间，以……代替，多行时作用于最后一行
////} UILineBreakMode;
////文本文字自适应大小
//label1.adjustsFontSizeToFitWidth = YES;
////当adjustsFontSizeToFitWidth=YES时候，如果文本font要缩小时
////baselineAdjustment这个值控制文本的基线位置，只有文本行数为1是有效
//label1.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
////有三种方式
////typedef enum {
//// UIBaselineAdjustmentAlignBaselines = 0, 默认值文本最上端于label中线对齐
//// UIBaselineAdjustmentAlignCenters,//文本中线于label中线对齐
//// UIBaselineAdjustmentNone,//文本最低端与label中线对齐
////} UIBaselineAdjustment;
////文本最多行数，为0时没有最大行数限制
//label1.numberOfLines = 2;
////最小字体，行数为1时有效，默认为0.0
//label1.minimumFontSize = 10.0;
////文本高亮
//label1.highlighted = YES;
////文本是否可变
//label1.enabled = YES;
////去掉label背景色
////label1.backgroundColor = [UIColor clearColor];
////文本阴影颜色www.2cto.com
//label1.shadowColor = [UIColor grayColor];
////阴影大小
//label1.shadowOffset = CGSizeMake(1.0, 1.0);
////是否能与用户交互
//label1.userInteractionEnabled = YES;
//[self.view addSubview:label1];


//UITextFeild
//最右侧加图片是以下代码　 左侧类似
//UIImageView *image=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right.png"]];
//text.rightView=image;
//text.rightViewMode = UITextFieldViewModeAlways;
//
//typedef enum {
//    UITextFieldViewModeNever,
//    UITextFieldViewModeWhileEditing,
//    UITextFieldViewModeUnlessEditing,
//    UITextFieldViewModeAlways
//} UITextFieldViewMode;


//按return键键盘往下收  becomeFirstResponder
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [text resignFirstResponder];    //主要是[receiver resignFirstResponder]在哪调用就能把receiver对应的键盘往下收
//    return YES;
//}


//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    //返回一个BOOL值，指定是否循序文本字段开始编辑,返回NO时不能唤起键盘进行编辑
//    return YES;
//}

//- (void)textFieldDidBeginEditing:(UITextField *)textField{
//    //开始编辑时触发，文本字段将成为first responder
//}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
//    //返回BOOL值，指定是否允许文本字段结束编辑，当编辑结束，文本字段会让出first responder
//    　 //要想在用户结束编辑时阻止文本字段消失，可以返回NO
//    　 //这对一些文本字段必须始终保持活跃状态的程序很有用，比如即时消息
//    　 
//    return NO;　//一直处于编辑状态
//}

//- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    //当用户使用自动更正功能，把输入的文字修改为推荐的文字时，就会调用这个方法。
//    //这对于想要加入撤销选项的应用程序特别有用
//    //可以跟踪字段内所做的最后一次修改，也可以对所有编辑做日志记录,用作审计用途。
//    //要防止文字被改变可以返回NO
//    //这个方法的参数中有一个NSRange对象，指明了被改变文字的位置，建议修改的文本也在其中
//    
//    　   return YES;
//}

//- (BOOL)textFieldShouldClear:(UITextField *)textField{
//    
//    //返回一个BOOL值指明是否允许根据用户请求清除内容
//    //可以设置在特定条件下才允许清除内容
//    
//    　   return YES;　//返回YES，输入内容后，点击右边的清除按钮可以清除，返回NO，点击清除不起作用
//}

//UIKeyboardWillShowNotification 　//键盘显示之前发送
//UIKeyboardDidShowNotification  　//键盘显示之后发送
//UIKeyboardWillHideNotification 　//键盘隐藏之前发送
//UIKeyboardDidHideNotification  　//键盘隐藏之后发送

//在storyboard中设置UITextField
//
//1、Text ：设置文本框的默认文本。
//2、Placeholder ： 可以在文本框中显示灰色的字，用于提示用户应该在这个文本框输入什么内容。当这个文本框中输入了数据时，用于提示的灰色的字将会自动消失。
//3、Background ：
//4、Disabled ： 若选中此项，用户将不能更改文本框内容。
//5、接下来是三个按钮，用来设置对齐方式。
//6、Border Style ： 选择边界风格。
//7、Clear Button ： 这是一个下拉菜单，你可以选择清除按钮什么时候出现，所谓清除按钮就是出一个现在文本框右边的小 X ，你可以有以下选择：
//7.1 Never appears ： 从不出现
//7.2 Appears while editing ： 编辑时出现
//7.3 Appears unless editing ：
//7.4 Is always visible ： 总是可见
//8、Clear when editing begins ： 若选中此项，则当开始编辑这个文本框时，文本框中之前的内容会被清除掉。比如，你现在这个文本框 A 中输入了 "What" ，之后去编辑文本框 B，若再回来编辑文本框 A ，则其中的 "What" 会被立即清除。
//9、Text Color ： 设置文本框中文本的颜色。
//10、Font ： 设置文本的字体与字号。
//11、Min Font Size ： 设置文本框可以显示的最小字体（不过我感觉没什么用）
//12、Adjust To Fit ： 指定当文本框尺寸减小时，文本框中的文本是否也要缩小。选择它，可以使得全部文本都可见，即使文本很长。但是这个选项要跟 Min Font Size 配合使用，文本再缩小，也不会小于设定的 Min Font Size 。
//接下来的部分用于设置键盘如何显示。
//13、Captitalization ： 设置大写。下拉菜单中有四个选项：
//13.1 None ： 不设置大写
//13.2 Words ： 每个单词首字母大写，这里的单词指的是以空格分开的字符串
//13.3 Sentances ： 每个句子的第一个字母大写，这里的句子是以句号加空格分开的字符串
//13.4 All Characters ： 所以字母大写
//14、Correction ： 检查拼写，默认是 YES 。
//15、Keyboard ： 选择键盘类型，比如全数字、字母和数字等。
//16、Appearance：
//17、Return Key ： 选择返回键，可以选择 Search 、 Return 、 Done 等。
//18、Auto-enable Return Key ： 如选择此项，则只有至少在文本框输入一个字符后键盘的返回键才有效。
//19、Secure ： 当你的文本框用作密码输入框时，可以选择这个选项，此时，字符显示为星号。
//
//
//1.Alignment Horizontal 水平对齐方式
//2.Alignment Vertical 垂直对齐方式
//3.用于返回一个BOOL值　输入框是否 Selected(选中) Enabled(可用) Highlighted(高亮)

- (void)textFieldWithLeftText:(NSString *)leftText placeholder:(NSString *)placeholder lineLong:(BOOL)lineLong text:(NSString *)text {
    WS(ws);
    
    self.borderStyle = UITextBorderStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    self.placeholder = placeholder;
    self.font = [UIFont systemFontOfSize:FontSize_28];
    self.placeholder = placeholder;
    self.text = text;
    self.textColor = CCRGBColor(51, 51, 51);
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.autocorrectionType = UITextAutocorrectionTypeDefault;
    self.clearsOnBeginEditing = NO;
    self.textAlignment = NSTextAlignmentLeft;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.keyboardType = UIKeyboardTypeDefault;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.returnKeyType =UIReturnKeyDone;
    self.keyboardAppearance=UIKeyboardAppearanceDefault;
    self.leftViewMode = UITextFieldViewModeAlways;

    [self addSubview:self.upLine];
    self.leftView = self.leftLabelView;
    [_leftLabelView addSubview:self.leftLabel];
    [self.leftLabel setText:leftText];
    
    if(lineLong) {
        [_upLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws);
            make.top.mas_equalTo(ws.mas_top);
            make.height.mas_equalTo(1);
        }];
    } else {
        [_upLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws).offset(CCGetRealFromPt(40));
            make.right.mas_equalTo(ws).offset(-CCGetRealFromPt(40));
            make.top.mas_equalTo(ws.mas_top);
            make.height.mas_equalTo(1);
        }];
    }
    
    [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.leftLabelView).with.offset(CCGetRealFromPt(40));
        make.right.and.top.mas_equalTo(ws.leftLabelView);
        make.bottom.mas_equalTo(ws.leftLabelView).offset(-1);
    }];
}

-(UIView *)upLine {
    if(_upLine == nil) {
        _upLine = [UIView new];
        [_upLine setBackgroundColor:CCRGBColor(238,238,238)];
    }
    return _upLine;
}

-(UIView *)leftLabelView {
    if(_leftLabelView == nil) {
        _leftLabelView = [UIView new];
        [_leftLabelView setBackgroundColor:[UIColor whiteColor]];
        [_leftLabelView setFrame:CGRectMake(0, 2, CCGetRealFromPt(190), CCGetRealFromPt(92) - 2)];
    }
    return _leftLabelView;
}

-(UILabel *)leftLabel {
    if(_leftLabel == nil) {
        _leftLabel = [UILabel new];
        [_leftLabel setBackgroundColor:[UIColor whiteColor]];
        [_leftLabel setTextColor:[UIColor blackColor]];
        [_leftLabel setFont:[UIFont systemFontOfSize:FontSize_28]];
        _leftLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _leftLabel;
}

@end
