//
//  ZDBaseHeaderFooterView.m
//  Demo
//
//  Created by 符现超 on 16/3/21.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDBaseSectionView.h"

@implementation ZDBaseSectionView

- (void)awakeFromNib
{
    self.contentView.backgroundColor = [UIColor magentaColor];
}

- (void)bindToSectionViewModel:(ZDSectionViewModel *)viewModel
{
    NSAssert(NO, @"抽象类，需要在子类中实现");
}

@end
