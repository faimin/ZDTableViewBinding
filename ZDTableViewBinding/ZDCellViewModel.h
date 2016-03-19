//
//  ZDViewModelWrap.h
//  Demo
//
//  Created by 符现超 on 16/3/7.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZDCellViewModelProtocol.h"

@interface ZDCellViewModel : NSObject<ZDCellViewModelProtocol>

@property (nonatomic, copy  ) NSString *zd_reuseIdentifier;
@property (nonatomic, copy  ) NSString *zd_nibName;
@property (nonatomic, strong) id       zd_model;
@property (nonatomic, assign) CGFloat  zd_estimatedHeight;
@property (nonatomic, assign) CGFloat  zd_height;

@property (nonatomic, copy  ) NSString *zd_headerNibName;
@property (nonatomic, copy  ) NSString *zd_footerNibName;
@property (nonatomic, copy  ) NSString *zd_headerReuseIdentifier;
@property (nonatomic, copy  ) NSString *zd_footerReuseIdentifier;

@end
