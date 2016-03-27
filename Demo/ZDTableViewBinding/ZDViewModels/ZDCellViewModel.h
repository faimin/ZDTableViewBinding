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

/**
 *  把cell统一封装成cellViewModel格式
 */
NS_ASSUME_NONNULL_BEGIN
@interface ZDCellViewModel : NSObject<ZDCellViewModelProtocol>

@property (nonatomic, copy, nullable) NSString *zd_titleViewReuseIdentifier;
///------------------- 必传参数 -------------------
@property (nonatomic, copy  ) NSString *zd_nibName;
@property (nonatomic, copy  ) NSString *zd_reuseIdentifier;
@property (nonatomic, strong) id       zd_model;
///------------------- 必传参数 -------------------
@property (nonatomic, copy  ) NSString *zd_className;
@property (nonatomic, assign) CGFloat  zd_estimatedHeight;  ///< 不能设置太小（>2），默认为44
@property (nonatomic, assign) CGFloat  zd_height;

@end
NS_ASSUME_NONNULL_END