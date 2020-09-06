//
//  HDHttpRequestManager.h
//  HDBaseUtils
//
//  Created by zwl on 2020/5/6.
//  Copyright © 2020 zwl. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DWHTTPRequest;

typedef void(^HDSSuccessBlock)(id responseObject,NSData *responseBody);
typedef void(^HDSFailureBlock)(id responseObject,NSError *error);

@interface HDHttpRequestManager : NSObject

/**
 eg:
 DWHTTPRequest * r = [HDHttpRequestManager GET:@"" Headers:@{} Success:^(id responseObject,                         NSData *responseBody) {
     
                     } Failure:^(id responseObject, NSError *error) {
     
                     }];
 [r startAsynchronous];
 
 */

/*!
 * @method
 * @abstract GET请求
 * @discussion get请求
 * @param URLString url
 * @param headers 请求头headers
 * @param success 请求成功回调
 * @param failure 请求失败回调
 * @result DWHTTPRequest对象
 */
+(DWHTTPRequest *)GET:(NSString *)URLString
              Headers:(NSDictionary <NSString *, NSString *> *)headers
              Success:(HDSSuccessBlock)success
              Failure:(HDSFailureBlock)failure;

/*!
 * @method
 * @abstract POST请求
 * @discussion POST请求
 * @param headers 请求头headers
 * @param success 请求成功回调
 * @param failure 请求失败回调
 * @result DWHTTPRequest对象
 */
+(DWHTTPRequest *)POST:(NSString *)URLString
               Headers:(NSDictionary <NSString *, NSString *> *)headers
               Success:(HDSSuccessBlock)success
               Failure:(HDSFailureBlock)failure;

@end
