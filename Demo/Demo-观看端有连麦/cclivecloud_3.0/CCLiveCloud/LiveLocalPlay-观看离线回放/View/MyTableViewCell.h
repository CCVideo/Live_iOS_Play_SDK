//
//  MyTableViewCell.h
//  DownloadDemo
//
//  Created by 王建 on 16/4/5.
//  Copyright © 2016年 王建.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel           *fileNameLabel;
@property (nonatomic, strong) UILabel           *progressLabel;
@property (nonatomic, strong) UIView            *backView;
@property (nonatomic, strong) UIView            *progressView;
@property (nonatomic, strong) UIImageView       *downloadImageView;
@property (nonatomic, strong) UILabel           *informationLabel;
//@property (nonatomic, assign) NSInteger         rowIndex;

//+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

-(void)updateUIWithAlreadyDownLoadSize:(long long)alreadyDownLoadSize totalSize:(long long)totalSize;

-(void)updateUIToFull;

- (instancetype)init;

@end
