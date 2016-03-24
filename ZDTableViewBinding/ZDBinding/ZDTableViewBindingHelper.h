//
//  ZDTableViewBindingHelper.h
//  Demo
//
//  Created by 符现超 on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

/**
 *  如果是多个section，需要把数据封装成（header或footer只存其一的话，则把sectionViewModel设置成[NSNull null]对象）
 *  [
         {
             HeaderViewModelKey : sectionViewMoel,
               CellViewModelKey : [cellViewModel, cellViewModel, ...],
             FooterViewModelKey : sectionViewModel
         },
 
         {
             HeaderViewModelKey : sectionViewMoel,
               CellViewModelKey : [cellViewModel, cellViewModel, ...],
             FooterViewModelKey : sectionViewModel
         },
 
         ...
    ]
 *
 *  单个section，则封装成
 *  [cellViewModel, cellViewModel, ...]
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZDBindingDefine.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "ZDCellViewModelProtocol.h"
#import "ZDCellProtocol.h"

@interface ZDTableViewBindingHelper : NSObject

/// 用来转发代理方法
@property (nonatomic, weak) id<UITableViewDelegate> delegate;

+ (instancetype)bindingHelperForTableView:(UITableView *)tableView
                           mutableSection:(BOOL)mutableSection
                             sourceSignal:(RACSignal *)sourceSignal
                         selectionCommand:(RACCommand *)selectCommand;

- (instancetype)initWithTableView:(UITableView *)tableView
                   mutableSection:(BOOL)mutableSection
                     sourceSignal:(RACSignal *)sourceSignal
                 selectionCommand:(RACCommand *)selectCommand;

- (void)insertViewModel:(id<ZDCellViewModelProtocol>)viewModel atIndexPath:(NSIndexPath*)indexPath;
- (void)replaceViewModel:(id<ZDCellViewModelProtocol>)model atIndexPath:(NSIndexPath *)indexPath;
- (void)deleteViewModelAtIndexPath:(NSIndexPath *)indexPath;
- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

@end





