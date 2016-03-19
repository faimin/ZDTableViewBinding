//
//  ZDCellViewModelProtocol.h
//  Demo
//
//  Created by 符现超 on 16/3/7.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 *  ViewModel需要实现的协议，为了与cellProtocol区分，协议方法前都加了zd前缀
 */
@protocol ZDCellViewModelProtocol <NSObject>

@property (nonatomic, copy  ) NSString *zd_reuseIdentifier;
@property (nonatomic, copy  ) NSString *zd_nibName;
@property (nonatomic, strong) id zd_model;
@property (nonatomic, assign) CGFloat zd_estimatedHeight;

@optional
@property (nonatomic, assign) CGFloat zd_height;
//@property (nonatomic, strong) __kindof UIView *zd_sectionHeader;
//@property (nonatomic, strong) __kindof UIView *zd_sectionFooter;
@property (nonatomic, copy  ) NSString *zd_headerNibName;
@property (nonatomic, copy  ) NSString *zd_footerNibName;
@property (nonatomic, copy  ) NSString *zd_headerReuseIdentifier;
@property (nonatomic, copy  ) NSString *zd_footerReuseIdentifier;

@end
