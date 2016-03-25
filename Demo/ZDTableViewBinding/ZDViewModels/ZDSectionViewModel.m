//
//  ZDHeaderFooterViewModel.m
//  Demo
//
//  Created by 符现超 on 16/3/22.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDSectionViewModel.h"

@implementation ZDSectionViewModel

- (CGFloat)zd_estimatedSectionHeight
{
    if (_zd_estimatedSectionHeight == 0) {
        return 44;
    }
    return _zd_estimatedSectionHeight;
}

@end
