//
//  ZDTableViewBindingHelper.h
//  Demo
//
//  Created by 符现超 on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//
/**
 *  有兴趣的童鞋可以看看这个lib： https://github.com/Raizlabs/RZCellSizeManager
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "ZDCellViewModelProtocol.h"
#import "ZDCellProtocol.h"

@interface ZDTableViewBindingHelper : NSObject

/// 用来转发代理方法
@property (nonatomic, weak) id<UITableViewDelegate> delegate;

+ (instancetype)bindingHelperForTableView:(UITableView *)tableView
                             sourceSignal:(RACSignal *)sourceSignal
                         selectionCommand:(RACCommand *)selectCommand;

- (instancetype)initWithTableView:(UITableView *)tableView
                     sourceSignal:(RACSignal *)sourceSignal
                 selectionCommand:(RACCommand *)selectCommand;

- (void)insertViewModel:(id<ZDCellViewModelProtocol>)viewModel atIndexPath:(NSIndexPath*)indexPath;
- (void)replaceViewModel:(id<ZDCellViewModelProtocol>)model atIndexPath:(NSIndexPath *)indexPath;
- (void)deleteViewModelAtIndexPath:(NSIndexPath *)indexPath;
- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

@end





