//
//  ZDFooterView.m
//  Demo
//
//  Created by 符现超 on 16/3/24.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDFooterView.h"

@implementation ZDFooterView

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)bindToHeaderFooterViewModel:(ZDHeaderFooterViewModel)viewModel
{
    
}

- (IBAction)bottomButtonAction:(UIButton *)sender
{
    NSLog(@"尾视图响应了");
    //[self.headerFooterCommand execute:RACTuplePack(sender, self.headerFooterModel)];
    [self deliverSectionEvent:RACTuplePack(sender, self.headerFooterModel)];
}


@end
