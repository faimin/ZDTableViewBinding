//
//  ZD.m
//  Demo
//
//  Created by 符现超 on 16/3/9.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZD.h"

@implementation ZD

@end
@implementation Status

@end


@implementation Data

+ (NSDictionary *)objectClassInArray{
    return @{@"squareInfo" : [Squareinfo class]};
}

@end


@implementation Squareinfo

+ (NSDictionary *)objectClassInArray{
    return @{@"barContent" : [Barcontent class]};
}

@end


@implementation Module

@end


@implementation Barcontent

@end


