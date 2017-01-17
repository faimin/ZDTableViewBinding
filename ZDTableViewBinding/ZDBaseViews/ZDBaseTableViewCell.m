//
//  ZDTableViewCell.m
//  Demo
//
//  Created by Zero on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDBaseTableViewCell.h"

/**
 *  如果是cell中的某些控件的点击事件，可以通过self.selectCommand方法传递出去
     if (self.selectionCommand) {
        [self.selectionCommand execute:paramTuple];
     }
 */
@implementation ZDBaseTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
	// Initialization code
}

- (void)bindToCellViewModel:(ZDCellViewModel *)viewModel
{
    NSLog(@"\n ZDBaseTableViewCell为抽象类，需要在子类中实现");
    NSAssert(NO, @"abstract class，need to implementation in subClass");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)deliverCellEvent:(RACTuple *)parameterTuple
{
    NSAssert(self.cellCommand, @"command isn't initialization");
    if (self.cellCommand) {
        [self.cellCommand execute:parameterTuple];
    }
}

@end
