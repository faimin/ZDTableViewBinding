//
//  ZDTableViewCell.m
//  Demo
//
//  Created by 符现超 on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDBaseTableViewCell.h"

@implementation ZDBaseTableViewCell

- (void)awakeFromNib
{
	// Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

- (void)deleverEvent:(RACTuple *)paramTuple
{
	if (self.selectionCommand) {
		[self.selectionCommand execute:paramTuple];
	}
}

- (void)bindToViewModel:(id)viewModel
{
	// TODO:
    NSAssert(NO, @"抽象类，在子类中实现");
}

@end
