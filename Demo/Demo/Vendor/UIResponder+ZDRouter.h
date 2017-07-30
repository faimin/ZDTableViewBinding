//
//  UIResponder+ZDRouter.h
//  Demo
//
//  Created by Zero.D.Saber on 2017/7/27.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//
//  https://casatwy.com/responder_chain_communication.html

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (ZDRouter)

/// 把事件传递给下一个响应者
- (void)deliverEventWithName:(NSString *)eventName parameters:(NSDictionary * _Nullable)paramsDict;

@end

NS_ASSUME_NONNULL_END
