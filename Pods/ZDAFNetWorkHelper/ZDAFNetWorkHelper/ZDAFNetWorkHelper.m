//
// ZSNetWorkService.m
// RequestNetWork
//
// Created by Bourne on 14/11/21.
// Copyright (c) 2014年 Zero.D.Saber. All rights reserved.
//

#import "ZDAFNetWorkHelper.h"
#import "AFNetworkActivityIndicatorManager.h"

@interface ZDAFNetWorkHelper ()
@property (nonatomic, strong) AFHTTPSessionManager *httpSessionManager;
@property (nonatomic, assign) BOOL hasCertificate;  ///< 有无证书，default is NO
@end

@implementation ZDAFNetWorkHelper

#pragma mark - Singleton

static ZDAFNetWorkHelper *zdAFHelper = nil;
+ (instancetype)shareInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		zdAFHelper = [[ZDAFNetWorkHelper alloc] init];
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
	});
    
	return zdAFHelper;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        zdAFHelper = [super allocWithZone:zone];
    });
    
    return zdAFHelper;
}

- (id)copyWithZone:(NSZone *)zone
{
    return zdAFHelper;
}

#pragma mark - GET && POST请求
// 返回值:NSURLSessionTask *
- (NSURLSessionDataTask *)requestWithURL:(NSString *)URLString
                                  params:(id)params
                              httpMethod:(HttpMethod)httpMethod
                                 success:(SuccessHandle)successBlock
                                 failure:(FailureHandle)failureBlock
{
	// 1.处理URL
    NSString *URL = [[NSString stringWithFormat:@"%@%@", (self.baseURLString ? : @""), URLString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0) {
        URL = [URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];// controlCharacterSet
    }
    else {
        URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
	// 2.初始化请求管理对象，设置规则
	
	// 3.发送请求
	NSURLSessionDataTask *sessionTask = nil;
	__weak __typeof(&*self) ws = self;
    switch (httpMethod) {
        case HttpMethod_GET: {
            sessionTask = [self.httpSessionManager GET:URL parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
                //TODO:下载进度
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (successBlock) {
                    successBlock([ws decodeData:responseObject]);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
            
            break;
        }
            
        case HttpMethod_POST: {
            BOOL isFile = NO;
            for (id value in [params allValues]) {
                if ([value isKindOfClass:[NSData class]]) {
                    isFile = YES;
                    break;
                }
                else if ([value isKindOfClass:[NSURL class]]) {
                    isFile = NO;
                    break;
                }
            }
            
            if (!isFile) {
                // 参数中不包含NSData类型
                sessionTask = [self.httpSessionManager POST:URL parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                    //TODO:上传进度
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    if (successBlock) {
                        successBlock([ws decodeData:responseObject]);
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    if (failureBlock) {
                        failureBlock(error);
                    }
                }];
            }
            else {
                // 参数中包含NSData或者fileURL类型
                sessionTask = [self.httpSessionManager POST:URL parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    for (NSString *key in [params allKeys]) {
                        id value = params[key];
                        // 判断参数是否是文件数据
                        if ([value isKindOfClass:[NSData class]]) {
                            // 将文件数据添加到formData中
                            // image/jpeg、text/plain、text/html、application/octet-stream , fileName后面一定要加后缀,否则上传文件会出错
                            [formData appendPartWithFileData:value
                                                        name:key
                                                    fileName:[NSString stringWithFormat:@"%@.jpg", key]
                                                    mimeType:@"image/jpg"];
                        }
                        else if ([value isKindOfClass:[NSURL class]]) {
                            NSError *error;
                            NSURL *localFileURL = value;
                            [formData appendPartWithFileURL:localFileURL
                                                       name:localFileURL.absoluteString
                                                   fileName:localFileURL.absoluteString
                                                   mimeType:@"image/jpg"
                                                      error:&error];
                        }
                    }
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    //TODO:上传进度
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    if (successBlock) {
                        successBlock([ws decodeData:responseObject]);
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    if (failureBlock) {
                        failureBlock(error);
                    }
                }];
            }

            break;
        }
            
        default: {
            break;
        }
    }

    return sessionTask;
}

///解析数据
- (id)decodeData:(id)data
{
    if (!data) {
        return nil;
    }
	NSError *__autoreleasing error;
	return [data isKindOfClass:[NSData class]] ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error] : data;
}

#pragma mark - Operations

- (void)cancelAllOperations
{
    [[ZDAFNetWorkHelper shareInstance].httpSessionManager.operationQueue cancelAllOperations];
}

#pragma mark - Property

- (AFHTTPSessionManager *)httpSessionManager
{
    if (!_httpSessionManager) {
        _httpSessionManager = [AFHTTPSessionManager manager];
        _httpSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", @"application/rss+xml", @"application/soap+xml", @"application/xml", nil];
        _httpSessionManager.requestSerializer.timeoutInterval = 10;
        self.hasCertificate = NO;
        
        if (self.hasCertificate) {
            ///有cer证书时AF会自动从bundle中寻找并加载cer格式的证书
            AFSecurityPolicy *securityPolicy = ({
                AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
                securityPolicy.allowInvalidCertificates = YES;
                securityPolicy;
            });
            _httpSessionManager.securityPolicy = securityPolicy;
        }
        else {
            ///无cer证书的情况,忽略证书,实现Https请求
            AFSecurityPolicy *securityPolicy = ({
                AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
                securityPolicy.allowInvalidCertificates = YES;
                securityPolicy.validatesDomainName = NO;
                securityPolicy;
            });
            _httpSessionManager.securityPolicy = securityPolicy;
        }
    }
    return _httpSessionManager;
}

@end


/**
 *  @discussion   下面如果写成 sessionManager.responseSerializer = [AFJSONResponseSerializer serializer]会出现1016的错误.这种方法只能解析返回的是Json类型的数据,其他类型无法解析。
 *
 *  @add
 *
 *  AFJSONResponseSerializer *jsonResponse = [AFJSONResponseSerializer serializer];
 *  jsonResponse.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain",@"text/html", nil];
 *  sessionManager.responseSerializer = jsonResponse;
 *
 *  这样就可以自动解析了
 *  此处我是手动解析的,因为有的数据还是无法自动解析
 */

// 4.返回数据的格式(默认是json格式)

/**
 *  当AF带的方法不能自动解析的时候再打开下面的
 *  此处我是让它返回的是NSData二进制数据类型,然后自己手动解析;
 *  默认情况下,提交的是二进制数据请求,返回Json格式的数据
 */
// sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];

