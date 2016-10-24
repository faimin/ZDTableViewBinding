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
    [super awakeFromNib];
    self.customBackgroundColor = [UIColor whiteColor];
}

- (void)bindToSectionViewModel:(ZDSectionViewModel *)viewModel
{
    NSLog(@"\n ZDBaseSectionView为抽象类，需要在子类中实现");
    NSAssert(NO, @"abstract class，need to implementation in subClass");
}

- (void)deliverSectionEvent:(RACTuple *)parameterTuple
{
    NSAssert(self.sectionCommand, @"command is't initialization");
    if (self.sectionCommand) {
        [self.sectionCommand execute:parameterTuple];
    }
}

#pragma mark - Setter

- (void)setCustomBackgroundColor:(UIColor *)customBackgroundColor
{
    if (_customBackgroundColor != customBackgroundColor) {
        _customBackgroundColor = customBackgroundColor;
        if (self.backgroundView) {
            self.backgroundView.backgroundColor = customBackgroundColor;
        }
        else {
            self.backgroundView = ({
                UIView *backView = [[UIView alloc] init];
                backView.backgroundColor = customBackgroundColor;
                backView;
            });
        }
    }
}

@end
