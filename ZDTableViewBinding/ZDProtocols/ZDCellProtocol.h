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

/// Protocol the tableViewCell need to implement
@protocol ZDCellProtocol <NSObject>
@required
@property (nonatomic, strong) id model;
@property (nonatomic, strong) id<ZDCellViewModelProtocol> viewModel;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) RACCommand *cellCommand;
@property (nonatomic, weak  ) ZDTableViewBinding *bindProxy;

/// Binds the given viewModel to the view
- (void)bindToCellViewModel:(ZDCellViewModel *)viewModel;

@end
