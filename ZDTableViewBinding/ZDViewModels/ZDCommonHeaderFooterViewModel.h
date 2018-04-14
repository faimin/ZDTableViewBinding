//
//  ZDHeaderFooterViewModel.h
//  Demo
//
//  Created by Zero on 16/3/22.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZDBindingProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZDCommonHeaderFooterViewModel : NSObject <ZDHeaderFooterViewModelProtocol>

///------------------- Require -------------------
@property (nonatomic, copy, nullable) NSString *zd_headerFooterNibName;
@property (nonatomic, copy  ) NSString *zd_headerFooterReuseIdentifier;
@property (nonatomic, strong) id       zd_headerFooterModel;
///------------------- Option -------------------
@property (nonatomic, assign) CGFloat  zd_estimatedHeaderFooterHeight;///< 不能设置太小(>2)，默认为44
@property (nonatomic, assign) CGFloat  zd_headerFooterHeight;
@property (nonatomic, assign) CGFloat  zd_headerFooterFixedHeight;
@property (nonatomic, copy, nullable) NSString *zd_headerFooterClassName;
@property (nonatomic, weak, nullable) ZDTableViewBinding *zd_headerFooterBindProxy;

@end

NS_ASSUME_NONNULL_END
