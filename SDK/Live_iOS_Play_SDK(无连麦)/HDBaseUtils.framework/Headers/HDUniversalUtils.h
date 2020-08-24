//
//  HDUniversalUtils.h
//  HDBaseUtils
//
//  Created by zwl on 2020/3/24.
//  Copyright © 2020 zwl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HDUniversalUtils : NSObject

#pragma mark - Public Func
/*!
 * @method
 * @abstract 获取系统版本
 * @discussion 获取系统版本
 * @result 系统版本
 */
+(NSString *)HD_GetSystemVersion;

/*!
 * @method
 * @abstract 获取设备型号
 * @discussion 获取设备型号
 * @result 设备型号
 */
+(NSString *)HD_GetDeviceName;

#pragma mark - NSURL

/*!
 * @method
 * @abstract 字符串加密
 * @discussion 字符串加密
 * @param string 加密前字符串
 * @result 加密后字符串
 */
+(NSString *)HD_stringUrlEncode:(NSString *)string;

/*!
 * @method
 * @abstract 字符串解密
 * @discussion 字符串解密
 * @param string 解密前字符串
 * @result 解密后字符串
 */
+(NSString *)HD_stringUrlDecode:(NSString *)string;

/**
 *  从 urlString 解析url参数到 NSDictionary
 *  如 http://123.com/a/b/c.txt?v1=k1&v2=k3&v3=k3 解析的结果为：
 *   {
 *       "v1":"k1，
 *       "v2":"k3",
 *       "v3":"k3"，
 *    }
 *
 *  注意：该函数对字典里的value做了url解码。
 *
 *  @param urlString 字符串 url
 *
 *  @return url参数 字典
 */
+(NSDictionary *)HD_urlQueryDictionaryWithURLString:(NSString *)urlString;
+(NSDictionary *)HD_urlQueryDictionaryWithUrl:(NSURL *)url;

/*!
 * @method
 * @abstract 数据加密
 * @discussion 数据加密
 * @param data 待加密数据
 * @param key 秘钥
 * @result 加密后数据
 */
+(NSData *)HD_encrypt:(NSData *)data key:(NSString *)key;

/*!
 * @method
 * @abstract 数据解密
 * @discussion 数据解密
 * @param data 待解密数据
 * @param key 秘钥
 * @result 解密后数据
*/
+(NSData *)HD_decrypt:(NSData *)data key:(NSString *)key;

/*!
 * @method
 * @abstract 主机字节顺序转换成网络字节顺序
 * @discussion 从主机字节顺序转换成网络字节顺序
 * @param n 主机字节顺序
 * @result 网络字节顺序
 */
+(UInt64)HD_htonll:(UInt64)n;

/*!
 * @method
 * @abstract 网络字节顺序转换为主机字节顺序
 * @discussion 网络字节顺序转换为主机字节顺序
 * @param n 网络字节顺序
 * @result 主机字节顺序
 */
+(UInt64)HD_ntohll:(UInt64)n;

/*!
 * @method
 * @abstract 复制字符
 * @discussion 复制字符
 * @param src 源字符
 * @param dst 目标字符
 * @param len 长度
 * @result 复制后字符
 */
+(u_char *)HD_memcpyFrom:(const u_char *)src to:(u_char *)dst length:(size_t)len;

/*!
 * @method
 * @abstract 字节数换算
 * @discussion 字节数换算
 * @param bytes 字节数
 * @result 换算后大小
 */
+(float)HD_calculateSizeWithBytes:(long long)bytes;

/*!
 * @method
 * @abstract 返回换算单位
 * @discussion 返回换算单位
 * @param bytes 字节数
 * @result 换算后单位
 */
+(NSString *)HD_calculateBytes:(long long)bytes;

/*!
 * @method
 * @abstract 创建设备唯一标识
 * @discussion 创建设备唯一标识
 * @result 唯一标识
 */
+(NSString *)uniqueMark;

/*!
 * @method
 * @abstract 删除创建的设备唯一标识
 * @discussion 删除创建的设备唯一标识
 */
+(void)deleteUniqueMark;

/*!
 * @method
 * @abstract 域名解析ip地址
 * @discussion 域名解析ip地址
 * @param hostName 待解析域名
 * @result ip地址
 */
+(NSString *)HD_getIPWithHostName:(const NSString*)hostName;

@end

