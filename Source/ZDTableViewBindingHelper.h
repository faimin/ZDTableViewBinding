//
//  ZDTableViewBindingHelper.h
//  Demo
//
//  Created by 符现超 on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ZDTableViewBindingHelper : NSObject

@property (nonatomic, weak) IBInspectable UITableView *tableView;
@property (nonatomic, weak) id<UITableViewDelegate> delegate;

- (instancetype)initWithTableView:(UITableView *)tableView
                     templateCell:(UINib *)templateCellNib
                  estimatedHeight:(CGFloat)estimatedHeight
                     sourceSignal:(RACSignal *)sourceSignal
                 selectionCommand:(RACCommand *)selectCommand;

+ (instancetype)bindingHelperForTableView:(UITableView *)tableView
                             sourceSignal:(RACSignal *)sourceSignal
                         selectionCommand:(RACCommand *)selectCommand
                             templateCell:(UINib *)templateCellNib;

@end
