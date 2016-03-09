//
//  ZDCellProtocol.h
//  Demo
//
//  Created by 符现超 on 16/3/7.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZDCellViewModelProtocol.h"
@class RACCommand;

@protocol ZDCellProtocol <NSObject>

@optional
@property (nonatomic, assign) CGFloat estimateHeight;

@required
@property (nonatomic, strong) id model;
@property (nonatomic, strong) id<ZDCellViewModelProtocol> viewModel;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) RACCommand *selectionCommand;

/// Binds the given view model to the view
- (void)bindToViewModel:(id)viewModel;

@end
