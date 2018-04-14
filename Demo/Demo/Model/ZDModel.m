//
//  ZDModel.m
//  Demo
//
//  Created by Zero.D.Saber on 16/3/9.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDModel.h"

@implementation ZDModel

+ (NSDictionary *)objectClassInArray {
    return @{@"barContent" : [Barcontent class]};
}

//+ (NSDictionary *)modelCustomPropertyMapper {
//    return @{
//             @"name" : @"n",
//             @"page" : @"p",
//             @"desc" : @"ext.desc",
//             @"bookID" : @[@"id",@"ID",@"book_id"]
//             };
//}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{
             @"squareInfo" : [ZDModel class],
             @"barContent" : @"Barcontent"
             };
}

@end

@implementation Barcontent

@end

@implementation Module

@end
