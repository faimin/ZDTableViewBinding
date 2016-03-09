//
//  ZDCustomCell.m
//  Demo
//
//  Created by 符现超 on 16/3/9.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDCustomCell.h"
#import "UIImageView+AFNetworking.h"
#import "ZDModel.h"

@implementation ZDCustomCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    @weakify(self);
//    [RACObserve(self, model) subscribeNext:^(Barcontent *x) {
//        @strongify(self);
//        self.articleCount.text = x.articleNum;
//        self.articleBrief.text = x.barDesc;
//        self.barID.text = [NSString stringWithFormat:@"%ld", x.barId];
//        self.barName.text = x.barName;
//        self.recommendReason.text = x.recommendReason;
//        [self.barImage setImageWithURL:[NSURL URLWithString:x.barImgUrl]];
//    }];
    
    RAC(self, articleCount.text) = [RACObserve(((Barcontent *)self.model), articleNum) takeUntil:self.rac_prepareForReuseSignal];
    RAC(self, articleBrief.text) = [RACObserve(((Barcontent *)self.model), barDesc) takeUntil:self.rac_prepareForReuseSignal];
    RAC(self, barID.text) = [[RACObserve(((Barcontent *)self.model), barId) takeUntil:self.rac_prepareForReuseSignal] map:^id(id value) {
        return [value stringValue];
    }];
    RAC(self, recommendReason.text) = [RACObserve(((Barcontent *)self.model), recommendReason) takeUntil:self.rac_prepareForReuseSignal];
    [[RACObserve(((Barcontent *)self.model), barImgUrl) ignore:nil] subscribeNext:^(NSString *x) {
        @strongify(self);
        [self.barImage setImageWithURL:[NSURL URLWithString:x]];
    }];
}

- (void)bindToViewModel:(ZDCellViewModel *)viewModel
{
    Barcontent *x = viewModel.model;
    self.articleCount.text = x.articleNum;
    self.articleBrief.text = x.barDesc;
    self.barID.text = [NSString stringWithFormat:@"%ld", x.barId];
    self.barName.text = x.barName;
    self.recommendReason.text = x.recommendReason;
    [self.barImage setImageWithURL:[NSURL URLWithString:x.barImgUrl]];
}

@end
