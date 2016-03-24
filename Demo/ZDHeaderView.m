//
//  ZDHeaderView.m
//  Demo
//
//  Created by 符现超 on 16/3/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDHeaderView.h"
#import "ZDModel.h"

@interface ZDHeaderView ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@end

@implementation ZDHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.customBackgroundColor = [UIColor redColor];
    @weakify(self);
    [[RACObserve(self, sectionModel) ignore:nil] subscribeNext:^(Module *x) {
        @strongify(self);
        self.titleLabel.text = x.moduleName;
    }];
}

- (void)bindToSectionViewModel:(ZDSectionViewModel *)viewModel
{
    Module *x = viewModel.zd_headerModel;
    self.titleLabel.text = x.moduleName;
}

@end
