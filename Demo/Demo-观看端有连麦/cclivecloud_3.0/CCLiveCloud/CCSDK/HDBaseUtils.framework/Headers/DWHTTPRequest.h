#import <Foundation/Foundation.h>

typedef void (^DWHTTPRequestDrmProgressBlock)(NSData *data, NSInteger totalBytesReceived, NSInteger totalBytesExpectedToReceive);
typedef void (^DWErrorBlock)(NSError *error);
typedef void (^DWHTTPRequestReceiveResponseBlock)(NSHTTPURLResponse *response);
typedef void (^DWHTTPRequestDownloadProgressBlock)(NSInteger bytesWritten, NSInteger totalBytesReceived, NSInteger totalBytesExpectedToReceive);
typedef void (^DWHTTPRequestUploadProgressBlock)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);
typedef void (^DWHTTPRequestFinishLoadingBlock)(NSHTTPURLResponse *response, NSData *responseBody);
typedef void (^DWHTTPRequestFinishLoadingStringBlock)(NSHTTPURLResponse *response, NSString *responseBodyString);

@interface DWHTTPRequest : NSObject <NSURLConnectionDataDelegate,NSURLSessionTaskDelegate,NSURLSessionDelegate>{
    NSURLSession *inProcessSession;
}

# pragma mark - http request
/**
 *  @brief url
 */
@property(strong, nonatomic)NSURL *url;

/**
 *  @brief 请求方式
 */
@property(copy, nonatomic)NSString *HTTPMethod;

/**
 *  @brief 请求头
 */
@property(strong, nonatomic, readonly)NSDictionary *requestHeaders;

/**
 *  @brief 请求body
 */
@property(strong, nonatomic)NSData *requestBody;

/**
 *  @brief 请求超时时间，默认10秒
 */
@property(assign, nonatomic)NSTimeInterval timeoutSeconds;

# pragma mark - http response
/**
 *  @brief 响应头
 */
@property(strong, nonatomic, readonly)NSHTTPURLResponse *response;

/**
 *  @brief 响应头字符串
 */
@property(assign, nonatomic)NSStringEncoding forcedResponseEncoding;

/**
 *  @brief 响应体body
 */
@property(strong, nonatomic, readonly)NSData *responseBody;

/**
 *  @brief 响应体body字符串
 */
@property(copy, nonatomic, readonly)NSString *responseBodyString;


/**
 *  若设置为YES，则在 -connection:didReceiveData: 中不会copy接受的数据。
 *  默认为NO，若使用 -startAsynchronousWithDestinationFilePath:，则接收到的数据会被写入文件，否则追加到buffer。
 */
@property(assign, nonatomic)BOOL unCopyResponseBody;
@property(copy)DWHTTPRequestDrmProgressBlock drmProgressBlock;
@property(copy)DWHTTPRequestReceiveResponseBlock receiveReponseBlock;
@property(copy)DWHTTPRequestDownloadProgressBlock downoadProgressBlock;
@property(copy)DWHTTPRequestUploadProgressBlock uploadProgressBlock;

/**
 非点播产品线，只需关心这3个回调即可！！！
 */
/**
 *  @brief 网络请求完成回调
 */
@property(copy)DWHTTPRequestFinishLoadingBlock finishLoadingBlock;

/**
 *  @brief 网络请求完成回调
 */
@property(copy)DWHTTPRequestFinishLoadingStringBlock finishLoadingStringBlock;

/**
 *  @brief 网络请求失败回调
 */
@property(copy)DWErrorBlock errorBlock;

/*!
 * @method
 * @abstract 通过NSURL初始化
 * @discussion 设置默认请求超时时间：10秒
 * @param url 网络请求URL
 * @result DWHTTPRequest对象
 */
+(DWHTTPRequest *)requestWithURL:(NSURL *)url;

/*!
 * @method
 * @abstract 通过字符串url初始化
 * @discussion 设置默认请求超时时间：10秒
 * @param urlString 字符串url
 * @result DWHTTPRequest对象
 */
+(DWHTTPRequest *)requestWithURLString:(NSString *)urlString;

/*!
 * @method
 * @abstract 发起同步HTTP请求
 * @discussion 发起同步HTTP请求
 * @param error 错误信息
 * @result HTTP响应体
 */
-(NSData *)startSynchronousWithError:(NSError **)error;

/*!
 * @method
 * @abstract 发起异步HTTP请求
 * @discussion 发起异步HTTP请求
 */
-(void)startAsynchronous;

/*!
* @method
* @abstract 结束本次HTTP请求
* @discussion 结束本次HTTP请求
*/
-(void)finish;

/*!
 * @method
 * @abstract 设置HTTPHeaderField
 * @discussion 设置HTTPHeaderField
 * @param value 值
 * @param name key
 */
-(void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)name;


@end
