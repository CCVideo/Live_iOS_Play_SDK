//
//  CCTableViewCell.h
//  NewCCDemo
//
//  Created by cc on 2016/12/5.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dialogue.h"

typedef void(^AnteSomeone)(NSString *antename,NSString *anteid);

@interface CCPublicTableViewCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier dialogue:(Dialogue *)dialogue antesomeone:(AnteSomeone)atsoBlock ;

-(void)reloadWithDialogue:(Dialogue *)dialogue antesomeone:(AnteSomeone)atsoBlock;

@end

