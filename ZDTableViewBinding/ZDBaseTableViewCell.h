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

@interface ZDBaseTableViewCell : UITableViewCell <ZDCellProtocol>

/// 协议方法
@property (nonatomic, strong) id model;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) id <ZDCellViewModelProtocol> viewModel;
@property (nonatomic, strong) RACCommand *selectionCommand;

/// 把cell中的事件传出去
//- (void)deleverEvent:(RACTuple *)paramTuple;

@end
