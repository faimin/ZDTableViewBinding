//
//  ZDBaseHeaderFooterView.h
//  Demo
//
//  Created by 符现超 on 16/3/21.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZDSectionViewModel.h"
#import "ZDSectionProtocol.h"
#import "ReactiveCocoa/ReactiveCocoa.h"

NS_ASSUME_NONNULL_BEGIN
@interface ZDBaseSectionView : UITableViewHeaderFooterView<ZDSectionProtocol>

@property (nonatomic, strong) ZDSectionViewModel<ZDSectionViewModelProtocol> *sectionViewModel;
@property (nonatomic, strong) id sectionModel;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;
@property (nonatomic, strong) RACCommand *sectionCommand;
@property (nonatomic, strong, nullable) UIColor *customBackgroundColor;

- (void)deliverSectionEvent:(RACTuple *)parameterTuple;

@end
NS_ASSUME_NONNULL_END