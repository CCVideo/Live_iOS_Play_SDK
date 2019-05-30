//
//  MyTableViewCell.m
//  DownloadDemo
//
//  Created by 王建 on 16/4/5.
//  Copyright © 2016年 王建.com. All rights reserved.
//

#import "MyTableViewCell.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>
#define UISCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define UISCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@implementation MyTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
     // NSLog(@"cellForRowAtIndexPath");
     static NSString *identifier = @"CellDownLoad";
     // 1.缓存中取
     MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
     // 2.创建
     if (cell == nil) {
         cell = [[MyTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
     return cell;
}

/**
 *  构造方法(在初始化对象的时候会调用)
 *  一般在这个方法中添加需要显示的子控件
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
        [self layoutIfNeeded];
    }
    return self;
}

-(void)updateUIWithAlreadyDownLoadSize:(long long)alreadyDownLoadSize totalSize:(long long)totalSize {
    if(alreadyDownLoadSize <= 0) alreadyDownLoadSize = 0;
    if(totalSize <= 0) totalSize = 1000000000;
//    NSLog(@"self.progressView.frame %@,self.backView.frame = %@",NSStringFromCGRect(self.progressView.frame),NSStringFromCGRect(self.backView.frame));
    self.progressView.frame = CGRectMake(self.backView.frame.origin.x, self.backView.frame.origin.y, self.backView.frame.size.width * ((float)alreadyDownLoadSize/(float)totalSize), self.backView.frame.size.height);
}

-(void)updateUIToFull {
    self.progressView.frame = self.backView.frame;
//    NSLog(@"self.progressView.frame %@,self.backView.frame = %@",NSStringFromCGRect(self.progressView.frame),NSStringFromCGRect(self.backView.frame));
}

/**
*  构造方法(在初始化对象的时候会调用)
*  一般在这个方法中添加需要显示的子控件
*/
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
 self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
 if (self) {
     [self initUI];
     [self layoutIfNeeded];
 }
 return self;
}

-(void)initUI {
    WS(ws)
    [self addSubview:self.fileNameLabel];
    [_fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws).offset(CCGetRealFromPt(30));
        make.right.mas_equalTo(ws).offset(-CCGetRealFromPt(30));
        make.top.mas_equalTo(ws).offset(CCGetRealFromPt(30));
        make.height.mas_equalTo(CCGetRealFromPt(28));
    }];
    
    [self addSubview:self.progressLabel];
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.fileNameLabel);
        make.right.mas_equalTo(ws.fileNameLabel);
        make.top.mas_equalTo(ws.fileNameLabel.mas_bottom).offset(CCGetRealFromPt(10));
        make.height.mas_equalTo(CCGetRealFromPt(20));
    }];
    [self addSubview:self.backView];
    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.progressLabel);
        make.top.mas_equalTo(ws.progressLabel.mas_bottom).offset(CCGetRealFromPt(10));
        make.size.mas_equalTo(CGSizeMake(UISCREENWIDTH - CCGetRealFromPt(30) - CCGetRealFromPt(80), CCGetRealFromPt(40)));
    }];
    
    [self addSubview:self.progressView];
    
    [self addSubview:self.downloadImageView];
    [_downloadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.backView.mas_right).offset(CCGetRealFromPt(20));
        make.centerY.mas_equalTo(ws.backView);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(44), CCGetRealFromPt(44)));
    }];
    
    [self addSubview:self.informationLabel];
    [_informationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.fileNameLabel);
        make.right.mas_equalTo(ws.fileNameLabel);
        make.top.mas_equalTo(ws.backView.mas_bottom).offset(CCGetRealFromPt(10));
        make.height.mas_equalTo(CCGetRealFromPt(20));
    }];
}

-(UILabel *)fileNameLabel {
    if(!_fileNameLabel) {
        _fileNameLabel = [UILabel new];
        _fileNameLabel.backgroundColor = CCClearColor;
        _fileNameLabel.font = [UIFont systemFontOfSize:FontSize_28];
        _fileNameLabel.textColor = CCRGBColor(51,51,51);
    }
    return _fileNameLabel;
}

-(UILabel *)progressLabel {
    if(!_progressLabel) {
        _progressLabel = [UILabel new];
        _progressLabel.backgroundColor = CCClearColor;
        _progressLabel.font = [UIFont systemFontOfSize:FontSize_20];
        _progressLabel.textColor = CCRGBColor(51,51,51);
    }
    return _progressLabel;
}

-(UIView *)backView {
    if(!_backView) {
        _backView = [UIView new];
        _backView.backgroundColor = CCRGBColor(204,204,204);
    }
    return _backView;
}

-(UIView *)progressView {
    if(!_progressView) {
        _progressView = [UIView new];
        _progressView.backgroundColor = CCRGBColor(0,203,64);
    }
    return _progressView;
}

-(UIImageView *)downloadImageView {
    if(!_downloadImageView) {
        _downloadImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"downloading"]];
        _downloadImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _downloadImageView;
}

-(UILabel *)informationLabel {
    if(!_informationLabel) {
        _informationLabel = [UILabel new];
        _informationLabel.backgroundColor = CCClearColor;
        _informationLabel.font = [UIFont systemFontOfSize:FontSize_20];
        _informationLabel.textColor = CCRGBColor(51,51,51);
    }
    return _informationLabel;
}

@end
