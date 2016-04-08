//
//  ZDTableViewBindingHelper.h
//  Demo
//
//  Created by 符现超 on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

/**
 *  如果是多个section，需要把数据包装成（header或footer只存其一的话，则把sectionViewModel设置成nil或者[NSNull null]对象）
 *  [
 *        {
 *            HeaderViewModelKey : sectionViewMoel,
 *              CellViewModelKey : [cellViewModel, cellViewModel, ...],
 *            FooterViewModelKey : sectionViewModel
 *        },
 *
 *        {
 *            HeaderViewModelKey : sectionViewMoel,
 *              CellViewModelKey : [cellViewModel, cellViewModel, ...],
 *            FooterViewModelKey : sectionViewModel
 *        },
 *
 *        ...
 *   ]
 *
 *  单个section，则包装成
 *  [cellViewModel, cellViewModel, ...]
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "ZDBindingDefine.h"
#import "ZDCellViewModelProtocol.h"
#import "ZDCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface ZDTableViewBinding : NSObject

/// used to forward the delegate method
@property (nonatomic, weak, nullable) id <UITableViewDelegate> delegate;

+ (instancetype)bindingHelperForTableView:(UITableView *)tableView
                           mutableSection:(BOOL)mutableSection
                             sourceSignal:(RACSignal *)sourceSignal
                              cellCommand:(RACCommand *)cellCommand
                           sectionCommand:(RACCommand *)sectionCommand;

- (instancetype)initWithTableView:(UITableView *)tableView
                   mutableSection:(BOOL)mutableSection
                     sourceSignal:(RACSignal *)sourceSignal
                      cellCommand:(RACCommand *)cellCommand
                   sectionCommand:(RACCommand *)sectionCommand;

- (nullable id <ZDCellViewModelProtocol>)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;

- (void)insertViewModel:(id <ZDCellViewModelProtocol>)viewModel atIndexPath:(NSIndexPath *)indexPath;
- (void)replaceViewModel:(id <ZDCellViewModelProtocol>)model atIndexPath:(NSIndexPath *)indexPath;
- (void)deleteCellViewModelAtIndexPath:(NSIndexPath *)indexPath;
- (void)reloadItemsAtIndexPaths:(NSArray <NSIndexPath *> *)indexPaths;

- (void)clearData;

@end
NS_ASSUME_NONNULL_END
