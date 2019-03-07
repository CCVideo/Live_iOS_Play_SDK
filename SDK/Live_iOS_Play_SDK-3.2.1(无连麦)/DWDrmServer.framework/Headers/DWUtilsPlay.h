#import <Foundation/Foundation.h>

@interface DWUtilsPlay : NSObject

/**
 *  生成HTTP请求头"User-Agent"
 *
 *  @return 类似于：appName appVersion (deviceName; systemName systemVersion; locale)”
 */
+ (NSString *)generateUserAgent;

+ (NSString *)urlEncode:(NSString *)urlString;

+(NSString*)UUID;

+ (NSString *)MD5File:(NSString *)path andUpper:(BOOL)uppercase;
+ (NSString *)MD5String:(NSString *)str andUpper:(BOOL)uppercase;
+ (NSString *)thqsWith:(NSDictionary *)dict andLocaltime:(NSString *)localtime key:(NSString *)key;

+ (BOOL)createDirectoryWithFilePath:(NSString *)filePath error:(NSError **)error;
+ (BOOL)createDirectoryWithDirectoryPath:(NSString *)directoryPath error:(NSError **)error;

+ (NSInteger)getFileSizeWithPath:(NSString *)filePath Error:(NSError **)error;

+ (NSString *)stringUrlEncode:(NSString *)string;
+ (NSString *)stringUrlDecode:(NSString *)string;
+ (NSString *)CC_getUUID;

// 获取设备型号然后手动转化为对应名称
+ (NSString *)getDeviceName;

# pragma mark - NSURL
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
+ (NSDictionary *)urlQueryDictionaryWithURLString:(NSString *)urlString;
+ (NSDictionary *)urlQueryDictionaryWithUrl:(NSURL *)url;

+ (UInt64)htonll:(UInt64)n;
+ (UInt64)ntohll:(UInt64)n;

+ (NSData *)encrypt:(NSData *)data key:(NSString *)key;
+ (NSData *)decrypt:(NSData *)data key:(NSString *)key;

+ (u_char *)memcpyFrom:(const u_char *)src to:(u_char *)dst length:(size_t)len;

//DWPlayInfo的返回信息解析
+ (NSDictionary *)parsePlayInfoResponse:(NSDictionary *)response;


@end
