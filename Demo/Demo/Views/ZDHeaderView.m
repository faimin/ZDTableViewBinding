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
    self.contentView.backgroundColor = [UIColor purpleColor];
    @weakify(self);
    [[RACObserve(self, headerFooterModel) ignore:nil] subscribeNext:^(Module *x) {
        @strongify(self);
        self.titleLabel.text = x.moduleName;
    }];
}

- (void)bindToHeaderFooterViewModel:(ZDHeaderFooterViewModel)viewModel
{
    /** 方案2
    Module *x = viewModel.zd_headerModel;
    self.titleLabel.text = x.moduleName;
     */
}

- (IBAction)click:(UIButton *)sender
{
    //[self.headerFooterCommand execute:RACTuplePack(sender, self.headerFooterModel)];
    [self deliverSectionEvent:RACTuplePack(sender, self.headerFooterModel)];
}

@end
