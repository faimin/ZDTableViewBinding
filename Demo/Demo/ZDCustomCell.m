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

#define STRINGFORMATE(objc, ...) [NSString stringWithFormat:objc, __VA_ARGS__]

@implementation ZDCustomCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //** 方案1
    @weakify(self);
    [[RACObserve(self, model) ignore:nil] subscribeNext:^(Barcontent *x) {
        @strongify(self);
        self.articleCount.text = STRINGFORMATE(@"文章数量：%@", x.articleNum);
        self.articleBrief.text = STRINGFORMATE(@"文章简介：%@", x.barDesc);
        self.barID.text = STRINGFORMATE(@"吧ID：%ld", x.barId);
        self.barName.text = STRINGFORMATE(@"吧名称：%@", x.barName);
        self.recommendReason.text = x.recommendReason;
        [self.barImage setImageWithURL:[NSURL URLWithString:x.barImgUrl]];
    }];
     //*/
}

- (void)bindToCellViewModel:(ZDCellViewModel *)viewModel
{
    /** 方案2
    Barcontent *x = viewModel.model;
    self.articleCount.text = STRINGFORMATE(@"文章数量：%@", x.articleNum);
    self.articleBrief.text = STRINGFORMATE(@"文章简介：%@", x.barDesc);
    self.barID.text = STRINGFORMATE(@"吧ID：%ld", x.barId);
    self.barName.text = STRINGFORMATE(@"吧名称：%@", x.barName);
    self.recommendReason.text = x.recommendReason;
    [self.barImage setImageWithURL:[NSURL URLWithString:x.barImgUrl]];
     */
}

@end
