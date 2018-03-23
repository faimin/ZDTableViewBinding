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

- (void)bindToSectionViewModel:(ZDSectionViewModel)viewModel
{
    
}

- (IBAction)bottomButtonAction:(UIButton *)sender
{
    NSLog(@"尾视图响应了");
    //[self.sectionCommand execute:RACTuplePack(sender, self.sectionModel)];
    [self deliverSectionEvent:RACTuplePack(sender, self.sectionModel)];
}


@end
