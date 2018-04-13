//
//  ZDBaseHeaderFooterView.m
//  Demo
//
//  Created by Zero on 16/3/21.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDBaseSectionView.h"

@implementation ZDBaseSectionView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)bindToSectionViewModel:(ZDSectionViewModel)viewModel
{
    NSCAssert(NO, @"abstract class，need to implementation in subClass");
}

- (void)deliverSectionEvent:(RACTuple *)parameterTuple
{
    NSCAssert(self.sectionCommand, @"command isn't initialization");
    if (self.sectionCommand) {
        [self.sectionCommand execute:parameterTuple];
    }
}

@end
