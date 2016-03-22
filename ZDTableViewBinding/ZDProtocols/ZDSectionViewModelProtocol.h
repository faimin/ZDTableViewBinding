//
//  ZDSectionViewModelProtocol.h
//  Demo
//
//  Created by 符现超 on 16/3/22.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZDSectionViewModelProtocol <NSObject>

@optional
@property (nonatomic, copy  ) NSString *zd_headerNibName;
@property (nonatomic, copy  ) NSString *zd_footerNibName;
@property (nonatomic, copy  ) NSString *zd_headerReuseIdentifier;
@property (nonatomic, copy  ) NSString *zd_footerReuseIdentifier;
@property (nonatomic, strong) id       zd_headerModel;
@property (nonatomic, strong) id       zd_footerModel;
@property (nonatomic, assign) CGFloat  zd_estimatedHeaderHeight;
@property (nonatomic, assign) CGFloat  zd_estimatedFooterHeight;
@property (nonatomic, assign) CGFloat  zd_headerHeight;
@property (nonatomic, assign) CGFloat  zd_footerHeight;

@end
