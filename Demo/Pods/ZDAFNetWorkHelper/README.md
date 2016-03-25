[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/faimin/ZDAFNetWorkHelper/blob/master/LICENSE)&nbsp;
[![Language](http://img.shields.io/badge/language-objc-brightgreen.svg?style=flat
)](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html)&nbsp;

## ZDAFNetWork

>  利用[AFNetworking](https://github.com/AFNetworking/AFNetworking)把`GET`和`POST`请求封装到了一个方法中 
> 
-------

```objc
- (nullable NSURLSessionDataTask *)requestWithURL:(nonnull NSString *)URLString
                                           params:(nullable id)params
                                       httpMethod:(HttpMethod)httpMethod
                                          success:(nullable SuccessHandle)successBlock
                                          failure:(nullable FailureHandle)failureBlock;                                          
```
