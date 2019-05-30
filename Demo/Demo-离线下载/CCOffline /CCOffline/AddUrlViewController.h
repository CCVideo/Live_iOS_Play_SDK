//
//  AddUrlViewController.h
//  Test
//
//  Created by cc on 2017/2/10.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AddUrlBlock)(NSString *url);

@interface AddUrlViewController : UIViewController

-(instancetype)initWithAddUrlBlock:(AddUrlBlock)addUrlBlock;

@end
