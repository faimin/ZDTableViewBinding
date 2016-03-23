//
//  ZDSectionProtocol.h
//  Demo
//
//  Created by 符现超 on 16/3/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZDSectionViewModel;

@protocol ZDSectionProtocol <NSObject>

@property (nonatomic, strong) ZDSectionViewModel<ZDSectionViewModelProtocol> *sectionViewModel;
@property (nonatomic, strong) id sectionModel;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;

- (void)bindToSectionViewModel:(ZDSectionViewModel *)viewModel;

@end
