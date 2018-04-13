//
//  ZDTableViewBindingHelper.h
//  Demo
//
//  Created by Zero on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

/** Usage
 *  1. 多个section，需要把数据包装成（header或footer只存其一的话，则把sectionViewModel设置成nil或者[NSNull null]对象）
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
 *  2. 单个section，则包装成
 *  [cellViewModel, cellViewModel, ...]
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#if __has_include(<ReactiveObjC/ReactiveObjC.h>)
#import <ReactiveObjC/ReactiveObjC.h>
#else
#import <ReactiveCocoa/ReactiveCocoa.h>
#endif
#import "ZDBindingDefine.h"
#import "ZDBindingProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZDTableViewBinding : NSObject

@property (nonatomic, weak, readonly) UITableView *tableView;
/// used to forward the delegate method
@property (nonatomic, weak, nullable) id<UITableViewDelegate> delegate;
/// datas had be reloaded
@property (nonatomic, assign, readonly) BOOL isFinishedReloadData;

/**
 TableView数据绑定

 @param tableView tableView
 @param multiSection 只要包含section,此参数就需要设置为`YES`
 @param sourceSignal 数据源信号
 @param cellCommand cell上的事件
 @param sectionCommand section上的事件
 @return tableView代理
 */
+ (instancetype)bindingHelperForTableView:(__kindof UITableView *)tableView
                             multiSection:(BOOL)multiSection
                         dataSourceSignal:(__kindof RACSignal *)dataSourceSignal
                              cellCommand:(nullable RACCommand *)cellCommand
                           sectionCommand:(nullable RACCommand *)sectionCommand;

- (nullable ZDCellViewModel)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;

- (void)updateViewModel:(ZDCellViewModel)viewModel atIndexPath:(NSIndexPath *)indexPath;
- (void)insertViewModel:(ZDCellViewModel)viewModel atIndexPath:(NSIndexPath *)indexPath;
/// `delay < 0`,don't reloadCell; `= 0`,reload immediately
- (void)replaceViewModel:(ZDCellViewModel)viewModel atIndexPath:(NSIndexPath *)indexPath afterDelay:(NSTimeInterval)delay;
- (void)replaceViewModel:(ZDCellViewModel)model atIndexPath:(NSIndexPath *)indexPath;
- (void)moveViewModelFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;    ///< multi section
- (void)moveViewModel:(ZDCellViewModel)viewModel toIndexPath:(NSIndexPath *)toIndexPath;    ///< single section
- (void)deleteCellViewModelAtIndexPath:(NSIndexPath *)indexPath;
- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

/// clear all existing datas when the next new datas coming
- (void)setNeedsResetData;

@end

NS_ASSUME_NONNULL_END
