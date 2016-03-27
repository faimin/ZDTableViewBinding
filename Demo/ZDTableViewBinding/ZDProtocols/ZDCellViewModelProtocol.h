//
//  ZDCellViewModelProtocol.h
//  Demo
//
//  Created by 符现超 on 16/3/7.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@class ZDSectionViewModel;

/**
 *  ViewModel需要实现的协议，为了与cellProtocol区分，协议方法前都加了zd前缀
 */
@protocol ZDCellViewModelProtocol <NSObject>

@property (nonatomic, copy  ) NSString *zd_reuseIdentifier;
@property (nonatomic, copy  ) NSString *zd_nibName;
@property (nonatomic, copy  ) NSString *zd_className;
@property (nonatomic, strong) id       zd_model;
@property (nonatomic, assign) CGFloat  zd_estimatedHeight;
@property (nonatomic, assign) CGFloat  zd_height;

//@optional
//@property (nonatomic, copy  ) NSString *zd_titleViewReuseIdentifier;

@end


