//
//  ZDBaseHeaderFooterView.h
//  Demo
//
//  Created by Zero on 16/3/21.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<ReactiveObjC/ReactiveObjC.h>)
#import <ReactiveObjC/ReactiveObjC.h>
#else
#import <ReactiveCocoa/ReactiveCocoa.h>
#endif
#import "ZDBindingProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZDBaseSectionView : UITableViewHeaderFooterView <ZDHeaderFooterProtocol>

@property (nonatomic, strong) id<ZDHeaderFooterViewModelProtocol> headerFooterViewModel;
@property (nonatomic, strong) id headerFooterModel;
@property (nonatomic, assign) CGFloat headerFooterHeight;
@property (nonatomic, strong) RACCommand *headerFooterCommand;
@property (nonatomic, weak, nullable) ZDTableViewBinding *headerFooterBindProxy;

///外传section中的事件
- (void)deliverSectionEvent:(RACTuple *)parameterTuple;

@end

NS_ASSUME_NONNULL_END
