//
//  ZDTableViewBindingHelper.h
//  Demo
//
//  Created by 符现超 on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "ZDCellViewModelProtocol.h"
#import "ZDCellProtocol.h"

@interface ZDTableViewBindingHelper : NSObject

/// 设置之后tableView的代理方法会在外面执行
@property (nonatomic, weak) id<UITableViewDelegate> delegate;

+ (instancetype)bindingHelperForTableView:(UITableView *)tableView
                          estimatedHeight:(CGFloat)estimatedHeight
                             sourceSignal:(RACSignal *)sourceSignal
                         selectionCommand:(RACCommand *)selectCommand;

- (instancetype)initWithTableView:(UITableView *)tableView
                  estimatedHeight:(CGFloat)estimatedHeight
                     sourceSignal:(RACSignal *)sourceSignal
                 selectionCommand:(RACCommand *)selectCommand;

- (void)insertViewModel:(id<ZDCellViewModelProtocol>)viewModel atIndexPath:(NSIndexPath*)indexPath;
- (void)replaceViewModel:(id<ZDCellViewModelProtocol>)model atIndexPath:(NSIndexPath *)indexPath;
- (void)deleteViewModelAtIndexPath:(NSIndexPath *)indexPath;
- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

@end
