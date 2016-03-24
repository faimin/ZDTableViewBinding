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
    self.customBackgroundColor = [UIColor whiteColor];
}

- (void)bindToSectionViewModel:(ZDSectionViewModel *)viewModel
{
    NSLog(@"\n ZDBaseSectionView为抽象类，需要在子类中实现");
    NSAssert(NO, @"抽象类，需要在子类中实现");
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
