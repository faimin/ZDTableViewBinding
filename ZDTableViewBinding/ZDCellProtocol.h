//
//  ZDCellProtocol.h
//  Demo
//
//  Created by 符现超 on 16/3/7.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZDCellViewModelProtocol.h"
@class RACCommand, ZDCellViewModel;

/**
 *  TableViewCell需要实现的协议
 */
@protocol ZDCellProtocol <NSObject>

@required
@property (nonatomic, strong) id model;
@property (nonatomic, strong) id<ZDCellViewModelProtocol> viewModel;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) RACCommand *selectionCommand;

@optional
@property (nonatomic, assign) CGFloat estimateHeight;
/// Binds the given view model to the view
- (void)bindToViewModel:(ZDCellViewModel *)viewModel;

@end
