//
//  ZDHeaderFooterViewModel.m
//  Demo
//
//  Created by Zero on 16/3/22.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDCommonHeaderFooterViewModel.h"

@implementation ZDCommonHeaderFooterViewModel

- (CGFloat)zd_estimatedHeaderFooterHeight
{
    if (_zd_estimatedHeaderFooterHeight == 0) {
        return 44;
    }
    return _zd_estimatedHeaderFooterHeight;
}

@end
