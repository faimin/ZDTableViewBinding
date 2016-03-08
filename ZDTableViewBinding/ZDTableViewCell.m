//
//  ZDTableViewCell.m
//  Demo
//
//  Created by 符现超 on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDTableViewCell.h"
//#import "RACCommand.h"
#import "RACTuple.h"

@implementation ZDTableViewCell

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
}

@end
