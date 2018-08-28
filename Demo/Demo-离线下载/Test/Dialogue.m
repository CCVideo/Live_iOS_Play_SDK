//
//  Dialogue.m
//  demo
//
//  Created by cc on 16/7/18.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "Dialogue.h"

@implementation Dialogue

- (NSString *)description {
    return [NSString stringWithFormat:@"userid=%@,username=%@,userrole=%@,fromuserid=%@,fromusername=%@,fromuserrole=%@,touserid=%@,tousername=%@,msg=%@,time=%@,head=%@,myViwerId=%@", _userid,_username,_userrole,_fromuserid,_fromusername,_fromuserrole,_touserid,_tousername,_msg,_time,_head,_myViwerId];
}

@end
