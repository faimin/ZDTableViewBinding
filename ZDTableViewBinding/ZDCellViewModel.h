//
//  ZDViewModelWrap.h
//  Demo
//
//  Created by 符现超 on 16/3/7.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ZDCellViewModelProtocol.h"

@interface ZDCellViewModel : NSObject<ZDCellViewModelProtocol>

@property (nonatomic, copy  ) NSString *zd_reuseIdentifier;
@property (nonatomic, copy  ) NSString *zd_nibName;
@property (nonatomic, strong) id       zd_model;
@property (nonatomic, assign) CGFloat  zd_estimatedHeight;
@property (nonatomic, assign) CGFloat  zd_height;

@end
