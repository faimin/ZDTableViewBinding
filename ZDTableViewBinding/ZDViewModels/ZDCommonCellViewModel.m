//
//  ZDViewModelWrap.m
//  Demo
//
//  Created by Zero on 16/3/7.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDCommonCellViewModel.h"

@implementation ZDCommonCellViewModel

- (CGFloat)zd_estimatedHeight
{
    if (_zd_estimatedHeight == 0) {
        return 44;
    }
    return _zd_estimatedHeight;
}

@end
