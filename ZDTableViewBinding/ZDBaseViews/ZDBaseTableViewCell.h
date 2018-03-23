//
//  ZDTableViewCell.h
//  Demo
//
//  Created by Zero on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<ReactiveObjC/ReactiveObjC.h>)
#import <ReactiveObjC/ReactiveObjC.h>
#else
#import <ReactiveCocoa/ReactiveCocoa.h>
#endif
#import "ZDBindingProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZDBaseTableViewCell : UITableViewCell <ZDCellProtocol>

/// 协议方法，在tableview代理方法里被赋值
@property (nonatomic, strong) id model;
@property (nonatomic, strong) id <ZDCellViewModelProtocol> viewModel;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) RACCommand *cellCommand;
@property (nonatomic, weak, nullable) ZDTableViewBinding *bindProxy;

///外传cell中的事件
- (void)deliverCellEvent:(RACTuple *)parameterTuple;

@end

NS_ASSUME_NONNULL_END

