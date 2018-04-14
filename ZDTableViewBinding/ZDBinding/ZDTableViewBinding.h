//
//  ZDTableViewBindingHelper.h
//  Demo
//
//  Created by Zero on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

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

extern NSInteger const ZDBD_Event_DidSelectRow;

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
 @param dataSourceSignal 数据源信号
 @param cellCommand cell上的事件
 @param headerFooterCommand headerView/footerView上的事件
 @return tableView代理
 */
+ (instancetype)bindingHelperForTableView:(__kindof UITableView *)tableView
                             multiSection:(BOOL)multiSection
                         dataSourceSignal:(__kindof RACSignal *)dataSourceSignal
                              cellCommand:(nullable RACCommand *)cellCommand
                      headerFooterCommand:(nullable RACCommand *)headerFooterCommand;

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


/** Usage
 *  1. 多个section，需要把数据包装成字典数组，一个字典对应一个section下的数据；
 *     每个`section`数据由`headerViewModel、cellViewModel数组、footerViewModel`3部分组成，如果`header`或`footer`只存其一的话，那么把对应的`sectionViewModel`设置成`nil`
 *
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
 *  2. 单个section，则只需要包装成一个`cellViewModel`数组
 *  [
 *      cellViewModel,
 *      cellViewModel,
 *      ...
 *  ]
 */
