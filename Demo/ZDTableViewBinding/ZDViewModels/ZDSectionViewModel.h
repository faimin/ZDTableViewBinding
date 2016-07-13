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

NS_ASSUME_NONNULL_BEGIN
@interface ZDSectionViewModel : NSObject<ZDSectionViewModelProtocol>

///------------------- Require -------------------
@property (nonatomic, copy, nullable) NSString *zd_sectionNibName;
@property (nonatomic, copy  ) NSString *zd_sectionReuseIdentifier;
@property (nonatomic, strong) id       zd_sectionModel;
///------------------- Option -------------------
@property (nonatomic, assign) CGFloat  zd_estimatedSectionHeight;///< 不能设置太小(>2)，默认为44
@property (nonatomic, assign) CGFloat  zd_sectionHeight;
@property (nonatomic, assign) CGFloat  zd_sectionFixedHeight;
@property (nonatomic, copy, nullable) NSString *zd_sectionClassName;
@property (nonatomic, weak, nullable) ZDTableViewBinding *zd_sectionBindProxy;

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
NS_ASSUME_NONNULL_END
