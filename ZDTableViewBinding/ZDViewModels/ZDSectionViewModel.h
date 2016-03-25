//
//  ZDHeaderFooterViewModel.h
//  Demo
//
//  Created by 符现超 on 16/3/22.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ZDSectionViewModelProtocol.h"

@interface ZDSectionViewModel : NSObject<ZDSectionViewModelProtocol>

///------------------- 必传参数 -------------------
@property (nonatomic, copy  ) NSString *zd_sectionNibName;
@property (nonatomic, copy  ) NSString *zd_sectionReuseIdentifier;
///------------------- 必传参数 -------------------
@property (nonatomic, strong) id       zd_sectionModel;
@property (nonatomic, assign) CGFloat  zd_estimatedSectionHeight;   ///< 不能设置太小(>2)，默认为44
@property (nonatomic, assign) CGFloat  zd_sectionHeight;

//@property (nonatomic, copy  ) NSString *zd_headerNibName;
//@property (nonatomic, copy  ) NSString *zd_headerReuseIdentifier;
//@property (nonatomic, strong) id       zd_headerModel;
//@property (nonatomic, assign) CGFloat  zd_estimatedHeaderHeight;
//@property (nonatomic, assign) CGFloat  zd_headerHeight;
//
//@property (nonatomic, copy  ) NSString *zd_footerNibName;
//@property (nonatomic, copy  ) NSString *zd_footerReuseIdentifier;
//@property (nonatomic, strong) id       zd_footerModel;
//@property (nonatomic, assign) CGFloat  zd_estimatedFooterHeight;
//@property (nonatomic, assign) CGFloat  zd_footerHeight;

@end
