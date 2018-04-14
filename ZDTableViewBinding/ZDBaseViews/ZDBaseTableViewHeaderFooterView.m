//
//  ZDBaseHeaderFooterView.m
//  Demo
//
//  Created by Zero on 16/3/21.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDBaseTableViewHeaderFooterView.h"

@implementation ZDBaseTableViewHeaderFooterView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)bindToSectionViewModel:(ZDHeaderFooterViewModel)viewModel
{
    NSCAssert(NO, @"abstract class，need to implementation in subClass");
}

- (void)deliverSectionEvent:(RACTuple *)parameterTuple
{
    NSCAssert(self.headerFooterCommand, @"command isn't initialization");
    if (self.headerFooterCommand) {
        [self.headerFooterCommand execute:parameterTuple];
    }
}

@end
