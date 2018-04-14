//
//  ZDCustomCell.m
//  Demo
//
//  Created by Zero.D.Saber on 16/3/9.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//
//  http://devetc.org/code/2014/07/07/auto-layout-and-views-that-wrap.html

#import "ZDCustomCell.h"
#import "UIImageView+AFNetworking.h"
#import "ZDModel.h"
#import <ReactiveObjC/ReactiveObjC.h>

#define STRINGFORMATE(objc, ...) [NSString stringWithFormat:objc, __VA_ARGS__]

@implementation ZDCustomCell
@synthesize model, cellCommand, bindProxy, height, viewModel, indexPath;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.articleBrief.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 20.f;
    
    //** 方案1
    @weakify(self);
    [[RACObserve(self, model) ignore:nil] subscribeNext:^(Barcontent *x) {
        @strongify(self);
        [self updateUIWithModel:x];
    }];
}

- (void)bindToCellViewModel:(ZDCellViewModel)viewModel
{
    //** 方案2
    //[self updateUIWithModel:viewModel.zd_model];
}

/// Note: 这里我们会发现cell接收了2次相同的model值，你可能会认为视图会无故多刷新一次，
/// 但是其实不是你想象的那样，因为你打印self会发现，虽然是同一个model，但是接收的对象一般情况下却是不相同的，其中第一次的model是发送给用来计算高度的cell的
- (void)updateUIWithModel:(Barcontent *)x
{
    self.articleCount.text = STRINGFORMATE(@"文章数量：%@", x.articleNum);
    self.articleBrief.text = STRINGFORMATE(@"文章简介：%@", x.barDesc);
    self.barID.text = STRINGFORMATE(@"吧ID：%zd", x.barId);
    self.barName.text = STRINGFORMATE(@"吧名称：%@", x.barName);
    self.recommendReason.text = x.recommendReason;
    [self.barImage setImageWithURL:[NSURL URLWithString:x.barImgUrl]];
}

#pragma mark - Override

// 设置每个cell之间的间距
// 左滑cell时这种设置分割线的方式的bug：
// http://www.tuicool.com/articles/YzqYZbM
- (void)setFrame:(CGRect)frame
{
    if (self.frame.size.height != frame.size.height) {
        frame.origin.y += 5;    // 上面的间距
        frame.size.height -= 5; // 下面的分割线
    }
    [super setFrame:frame];
}

@end
