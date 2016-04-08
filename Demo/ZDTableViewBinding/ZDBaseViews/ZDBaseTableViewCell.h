//
//  ZDTableViewCell.h
//  Demo
//
//  Created by 符现超 on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZDCellProtocol.h"
#import "ZDCellViewModelProtocol.h"
#import "ZDCellViewModel.h"
#import "ReactiveCocoa/ReactiveCocoa.h"

NS_ASSUME_NONNULL_BEGIN
@interface ZDBaseTableViewCell : UITableViewCell <ZDCellProtocol>

/// 协议方法
@property (nonatomic, strong) id model;
@property (nonatomic, strong) id <ZDCellViewModelProtocol> viewModel;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) RACCommand *cellCommand;

- (void)deliverCellEvent:(RACTuple *)parameterTuple;

@end
NS_ASSUME_NONNULL_END

