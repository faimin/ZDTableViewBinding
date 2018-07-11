//
//  ZDFooterView.m
//  Demo
//
//  Created by Zero.D.Saber on 16/3/24.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDFooterView.h"
#import <ReactiveObjC/RACTuple.h>

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
