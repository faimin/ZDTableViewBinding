//
//  ZDViewModelWrap.h
//  Demo
//
//  Created by Zero on 16/3/7.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZDBindingProtocols.h"

/**
 *  把cell统一封装成cellViewModel格式
 */
NS_ASSUME_NONNULL_BEGIN

@interface ZDBaseCellViewModel : NSObject <ZDCellViewModelProtocol>

///------------------- Require -------------------
@property (nonatomic, copy  ) NSString *zd_reuseIdentifier;
@property (nonatomic, strong) id       zd_model;
///------------------- Option -------------------
// nib and class altenative select one
@property (nonatomic, copy, nullable) NSString *zd_nibName; ///< xib创建的nib才需要设置此属性
@property (nonatomic, copy, nullable) NSString *zd_className;
@property (nonatomic, assign) CGFloat zd_estimatedHeight;   ///< 不能设置太小（>2），默认为44
@property (nonatomic, assign) CGFloat zd_height;
@property (nonatomic, assign) CGFloat zd_fixedHeight;       ///< 固定高度
@property (nonatomic, assign) BOOL    zd_canEditRow;        ///< 是否能够编辑
@property (nonatomic, weak, nullable) ZDTableViewBinding *zd_bindProxy;

@end

NS_ASSUME_NONNULL_END
