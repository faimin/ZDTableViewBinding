//
//  UIResponder+ZDRouter.m
//  Demo
//
//  Created by Zero.D.Saber on 2017/7/27.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "UIResponder+ZDRouter.h"

@implementation UIResponder (ZDRouter)

- (void)deliverEventWithName:(NSString *)eventName parameters:(NSDictionary *)paramsDict {
    [[self nextResponder] deliverEventWithName:eventName parameters:paramsDict];
}

@end
