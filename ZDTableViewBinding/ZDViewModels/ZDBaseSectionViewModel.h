//
//  ZDHeaderFooterViewModel.h
//  Demo
//
//  Created by Zero on 16/3/22.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZDBindingProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZDBaseSectionViewModel : NSObject<ZDSectionViewModelProtocol>

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

@end

NS_ASSUME_NONNULL_END
