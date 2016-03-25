//
//  ZAFNetWorkService.h
//  RequestNetWork
//
//  Created by Bourne on 14/11/21.
//  Copyright (c) 2014年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef NS_ENUM (NSUInteger, HttpMethod) {
	HttpMethod_GET,
	HttpMethod_POST
};

//用于回调请求成功或者失败的信息
typedef void (^ SuccessHandle)(id _Nullable responseObject);
typedef void (^ FailureHandle)(NSError *_Nonnull error);

///// 所有简单指针对象都被假定为nonnull，因此我们只需要去指定那些nullable的指针即可。
NS_ASSUME_NONNULL_BEGIN
@interface ZDAFNetWorkHelper : NSObject

@property (nonatomic, copy, nullable) NSString *baseURLString;      ///< baseURL

/**
 *  单例
 *
 *  @return 实例化后的selfClass
 */
+ (nonnull instancetype)shareInstance;

/**
 *  @abstract GET && POST请求
 *
 *  @param urlString : 请求地址
 *  @param params : 请求参数
 *  @param httpMethod : GET/POST 请求
 *  @param successBlock/failureBlock : 回调block
 *
 *  @discussion
 */
- (nullable NSURLSessionDataTask *)requestWithURL:(nonnull NSString *)URLString
                                           params:(nullable id)params
                                       httpMethod:(HttpMethod)httpMethod
                                          success:(nullable SuccessHandle)successBlock
                                          failure:(nullable FailureHandle)failureBlock;

- (void)cancelAllOperations;

@end
NS_ASSUME_NONNULL_END
