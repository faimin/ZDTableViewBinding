//
//  ZDTableViewBindingHelper.m
//  Demo
//
//  Created by Zero on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDTableViewBinding.h"
#if __has_include(<UITableView+FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>)
#import "UITableView+FDTemplateLayoutCell.h"
#endif
#import "ZDCellViewModel.h"
#import "ZDSectionViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface NSObject (Cast)
+ (nullable instancetype)zd_cast:(id)objc;
@end


@interface ZDTableViewBinding ()<UITableViewDelegate, UITableViewDataSource
#if IS_XCODE8_OR_LATER
, UITableViewDataSourcePrefetching
#endif
>
{
    BOOL _isNeedToResetData;
}
@property (nonatomic, readwrite, assign) struct delegateMethodsCaching {
// UITableViewDelegate
//Configuring Rows for the Table View
	uint heightForRowAtIndexPath: 1;
	uint estimatedHeightForRowAtIndexPath: 1;
	uint indentationLevelForRowAtIndexPath: 1;
	uint willDisplayCellForRowAtIndexPath: 1;

//Managing Accessory Views
	uint editActionsForRowAtIndexPath: 1;
	uint accessoryButtonTappedForRowWithIndexPath: 1;

//Managing Selections
	uint willSelectRowAtIndexPath: 1;
	uint didSelectRowAtIndexPath: 1;
	uint willDeselectRowAtIndexPath: 1;
	uint didDeselectRowAtIndexPath: 1;

//Modifying the Header and Footer of Sections
	uint viewForHeaderInSection: 1;
	uint viewForFooterInSection: 1;
	uint heightForHeaderInSection: 1;
	uint estimatedHeightForHeaderInSection: 1;
	uint heightForFooterInSection: 1;
	uint estimatedHeightForFooterInSection: 1;
	uint willDisplayHeaderViewForSection: 1;
	uint willDisplayFooterViewForSection: 1;

//Editing Table Rows
	uint willBeginEditingRowAtIndexPath: 1;
	uint didEndEditingRowAtIndexPath: 1;
	uint editingStyleForRowAtIndexPath: 1;
	uint titleForDeleteConfirmationButtonForRowAtIndexPath: 1;
	uint shouldIndentWhileEditingRowAtIndexPath: 1;

//Reordering Table Rows
	uint targetIndexPathForMoveFromRowAtIndexPathToProposedIndexPath: 1;

//Tracking the Removal of Views
	uint didEndDisplayingCellForRowAtIndexPath: 1;
	uint didEndDisplayingHeaderViewForSection: 1;
	uint didEndDisplayingFooterViewForSection: 1;

//Copying and Pasting Row Content
	uint shouldShowMenuForRowAtIndexPath: 1;
	uint canPerformActionForRowAtIndexPathWithSender: 1;
	uint performActionForRowAtIndexPathWithSender: 1;

//Managing Table View Highlighting
	uint shouldHighlightRowAtIndexPath: 1;
	uint didHighlightRowAtIndexPath: 1;
	uint didUnhighlightRowAtIndexPath: 1;

// UIScrollViewDelegate
//Responding to Scrolling and Dragging
	uint scrollViewDidScroll: 1;
	uint scrollViewWillBeginDragging: 1;
	uint scrollViewWillEndDraggingWithVelocityTargetContentOffset: 1;
	uint scrollViewDidEndDraggingWillDecelerate: 1;
	uint scrollViewShouldScrollToTop: 1;
	uint scrollViewDidScrollToTop: 1;
	uint scrollViewWillBeginDecelerating: 1;
	uint scrollViewDidEndDecelerating: 1;

//Managing Zooming
	uint viewForZoomingInScrollView: 1;
	uint scrollViewWillBeginZoomingWithView: 1;
	uint scrollViewDidEndZoomingWithViewAtScale: 1;
	uint scrollViewDidZoom: 1;

//Responding to Scrolling Animations
	uint scrollViewDidEndScrollingAnimation: 1;
} delegateRespondsTo;

@property (nonatomic, weak, readwrite) UITableView *tableView;
// 外面的command参数是临时变量，需要当前类持有，所以为strong类型
@property (nonatomic, strong) RACCommand *cellCommand;
@property (nonatomic, strong) RACCommand *sectionCommand;
/// 包含sectionViewModel和cellViewModel字典的数组
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *sectionCellDatas;
@property (nonatomic, strong) NSMutableArray <id<ZDCellViewModelProtocol>> *cellViewModels;
/// 下面2个array盛放的是注册过的nibName
@property (nonatomic, strong) NSMutableArray <NSString *> *mutArrNibNameForCell;
@property (nonatomic, strong) NSMutableArray <NSString *> *mutArrClassNameForCell;
@property (nonatomic, strong) NSMutableArray <NSString *> *mutArrNibNameForSection;
@property (nonatomic, strong) NSMutableArray <NSString *> *mutArrClassNameForSection;
/// 是否是multiSection的tableView，只要包含section，就应该为YES
@property (nonatomic, assign) BOOL isMultiSection;
@property (nonatomic, assign) BOOL isFinishedReloadData;

/// 预加载的cell
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, id> *prefetchDict;

@end

@implementation ZDTableViewBinding

- (void)dealloc
{
    ZDBDLog(@"");
}

+ (instancetype)bindingHelperForTableView:(UITableView *)tableView
                             multiSection:(BOOL)multiSection
                             sourceSignal:(RACSignal *)sourceSignal
                              cellCommand:(RACCommand *)cellCommand
                           sectionCommand:(RACCommand *)sectionCommand
{
	return [[self alloc] initWithTableView:tableView
                              multiSection:(BOOL)multiSection
                              sourceSignal:sourceSignal
                               cellCommand:cellCommand
                            sectionCommand:sectionCommand];
}

- (instancetype)initWithTableView:(UITableView *)tableView
                     multiSection:(BOOL)multiSection
                     sourceSignal:(RACSignal *)sourceSignal
                      cellCommand:(RACCommand *)cellCommand
                   sectionCommand:(RACCommand *)sectionCommand
{
	if (self = [super init]) {
		self.tableView = tableView;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
#if IS_XCODE8_OR_LATER
        if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_9_x_Max) {
            self.tableView.prefetchDataSource = self;
        }
#endif
        self.delegate = nil;
        
		self.cellCommand = cellCommand;
		self.sectionCommand = sectionCommand;
        
        [self clearData];
        
		@weakify(self);
		[[sourceSignal filter:^BOOL(id value) {
            return (value != nil);
        }] subscribeNext:^(__kindof NSArray *x) {
			@strongify(self);
			self.isMultiSection = multiSection;

		    /// register cell && header && footer
			if (multiSection) {
				[self registerNibForTableViewWithSectionCellViewModels:x];
                [self.sectionCellDatas addObjectsFromArray:x];
			}
			else {
				[self registerNibForTableViewWithCellViewModels:x];
                [self.cellViewModels addObjectsFromArray:x];
			}

		    /// reloadData on mainQueue
			ZDDispatch_async_on_main_queue(^{
				[self.tableView reloadData];
                self.isFinishedReloadData = YES;
			});
		}];
	}
	return self;
}

#pragma mark - UITableViewDataSourcePrefetching
#pragma mark -
#if IS_XCODE8_OR_LATER
- (void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    //TODO: 预加载
//    for (NSIndexPath *indexPath in indexPaths) {
//        id <ZDCellViewModelProtocol> cellViewModel = [self cellViewModelAtIndexPath:indexPath];
//        NSCAssert(cellViewModel != nil, @"cellViewModel can't be nil");
//        id <ZDCellProtocol> cell = [tableView dequeueReusableCellWithIdentifier:([cellViewModel zd_reuseIdentifier] ? : [cellViewModel zd_nibName]) forIndexPath:indexPath];
//        NSCAssert(cell != nil, @"cell can't be nil");
//    }
}

- (void)tableView:(UITableView *)tableView cancelPrefetchingForRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    //TODO: 取消预加载
}
#endif

#pragma mark - UITableViewDataSource
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (self.isMultiSection) {
		return self.sectionCellDatas.count;
	}
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.isMultiSection) {
		NSArray *cellViewModelArr = self.sectionCellDatas[section][CellViewModelKey];
        return [NSArray zd_cast:cellViewModelArr] ? cellViewModelArr.count : 0;
	}
	return self.cellViewModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	id <ZDCellViewModelProtocol> cellViewModel = [self cellViewModelAtIndexPath:indexPath];
	NSCAssert(cellViewModel != nil, @"cellViewModel can't be nil");
	id <ZDCellProtocol> cell = [tableView dequeueReusableCellWithIdentifier:([cellViewModel zd_reuseIdentifier] ? : [cellViewModel zd_nibName]) forIndexPath:indexPath];
    if (!cell) {
        NSString *reuseIdentifier = [cellViewModel zd_reuseIdentifier];
        Class aCalss = NSClassFromString(reuseIdentifier);
        if (!aCalss) {
            NSCAssert(NO, @"aClass don't exist");
        }
        else if ([[[aCalss alloc] init] isKindOfClass:[UITableViewCell class]]) {
            cell = [[aCalss alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        }
        else {
            NSCAssert(NO, @"aClass isn't `UITableViewCell` class");
        }
    }

    if ([cellViewModel respondsToSelector:@selector(setZd_bindProxy:)]) {
        cellViewModel.zd_bindProxy = self;
    }
    
    if ([cell respondsToSelector:@selector(setBindProxy:)]) {
        cell.bindProxy = self;
    }
    
	if ([cell respondsToSelector:@selector(setCellCommand:)]) {
		cell.cellCommand = self.cellCommand;
	}

    if ([cell respondsToSelector:@selector(setHeight:)]) {
        cell.height = cellViewModel.zd_height;
    }
    
    if ([cell respondsToSelector:@selector(setIndexPath:)]) {
        cell.indexPath = indexPath;
    }
    
	return (__kindof UITableViewCell *)cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.isMultiSection) {
            NSArray *cellViewModelArr = self.sectionCellDatas[indexPath.section][CellViewModelKey];
            NSMutableArray *cellViewModelMutArr = cellViewModelArr.mutableCopy;
            [cellViewModelMutArr removeObjectAtIndex:indexPath.row];
            [self.sectionCellDatas[indexPath.section] setValue:cellViewModelMutArr.copy forKey:CellViewModelKey];
        }
        else {
            [self.cellViewModels removeObjectAtIndex:indexPath.row];
        }
	}
}

#pragma mark - UITableViewDelegate
#pragma mark -
#pragma mark Configuring Rows for the TableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = tableView.rowHeight;
    if (self.delegateRespondsTo.heightForRowAtIndexPath == 1) {
        cellHeight = [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
        return cellHeight;
    }

	id <ZDCellViewModelProtocol> cellViewModel = [self cellViewModelAtIndexPath:indexPath];
    
    if (cellViewModel.zd_fixedHeight > 0) {
        return cellViewModel.zd_fixedHeight;
    }
    else {
#if __has_include(<UITableView+FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>)
        NSString *identifier = [cellViewModel zd_reuseIdentifier];
        cellHeight = [tableView fd_heightForCellWithIdentifier:identifier cacheByIndexPath:indexPath configuration:^(__kindof UITableViewCell <ZDCellProtocol> *cell) {
            if ([cell respondsToSelector:@selector(setModel:)]) {
                cell.model = [cellViewModel zd_model];
            }
        }];
        cellViewModel.zd_height = cellHeight;
        [self updateViewModel:cellViewModel atIndexPath:indexPath];
        return cellHeight;
#else
        //NSCAssert(NO, @"if has not import `UITableView+FDTemplateLayoutCell`, you should calculate the cellHeight by yourself, e.g, set zd_fixedHeight value");
        return UITableViewAutomaticDimension;
#endif
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat estimatedHeightForRowAtIndexPath = tableView.estimatedRowHeight;

	if (self.isMultiSection) {
		NSDictionary *dic = self.sectionCellDatas[indexPath.section];
		NSArray *cellViewModelArr = dic[CellViewModelKey];
		ZDCellViewModel *cellViewModel = cellViewModelArr[indexPath.row];

		if (!ZDNotNilOrEmpty(cellViewModel)) {
			return 0;
		}
		CGFloat estimateHeight = cellViewModel.zd_estimatedHeight;
		return estimateHeight;
	}
	else {
		id <ZDCellViewModelProtocol> cellViewModel = [self cellViewModelAtIndexPath:indexPath];
		estimatedHeightForRowAtIndexPath = [cellViewModel zd_estimatedHeight];
	}

	return estimatedHeightForRowAtIndexPath;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger indentationLevelForRowAtIndexPath = 0;

	if (self.delegateRespondsTo.indentationLevelForRowAtIndexPath == 1) {
		indentationLevelForRowAtIndexPath = [self.delegate tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
	}
	return indentationLevelForRowAtIndexPath;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//	if (self.delegateRespondsTo.willDisplayCellForRowAtIndexPath == 1) {
//		[self.delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
//	}
    
    if (![cell conformsToProtocol:@protocol(ZDCellProtocol)]) {
        NSCAssert(NO, @"cell 需要遵守协议");
        return;
    }
        
    id <ZDCellViewModelProtocol> cellViewModel = [self cellViewModelAtIndexPath:indexPath];
    NSCAssert(cellViewModel != nil, @"cellViewModel can't be nil");
    
    id <ZDCellProtocol> zdCell = (id)cell;
    
    if ([zdCell respondsToSelector:@selector(setModel:)]) {
        zdCell.model = cellViewModel.zd_model;
    }
    
    if ([zdCell respondsToSelector:@selector(setViewModel:)]) {
        zdCell.viewModel = cellViewModel;
    }
    
    /// cell遵循的数据协议
    if ([zdCell respondsToSelector:@selector(bindToCellViewModel:)]) {
        [zdCell bindToCellViewModel:cellViewModel];
    }
}

#pragma mark Managing Accessory Views
- (nullable NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *editActionsForRowAtIndexPath = nil;

	if (_delegateRespondsTo.editActionsForRowAtIndexPath == 1) {
		editActionsForRowAtIndexPath = [self.delegate tableView:tableView editActionsForRowAtIndexPath:indexPath];
	}
	return editActionsForRowAtIndexPath;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	if (_delegateRespondsTo.accessoryButtonTappedForRowWithIndexPath == 1) {
		[self.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
	}
}

#pragma mark Managing Selections
- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath *willSelectRowAtIndexPath = indexPath;

	if (_delegateRespondsTo.willSelectRowAtIndexPath == 1) {
		willSelectRowAtIndexPath = [self.delegate tableView:tableView willSelectRowAtIndexPath:indexPath];
	}
	return willSelectRowAtIndexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell <ZDCellProtocol> *cell = [tableView cellForRowAtIndexPath:indexPath];

	// execute the command
	if ([cell respondsToSelector:@selector(cellCommand)]) {
		/// RACTuplePack(cell, viewModel, event)
		/// 这里的-1默认代表的是点击的cell本身
		[cell.cellCommand execute:[RACTuple tupleWithObjects:cell, [self cellViewModelAtIndexPath:indexPath], @(-1), nil]];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath *willDeselectRowAtIndexPath = indexPath;

	if (_delegateRespondsTo.willDeselectRowAtIndexPath == 1) {
		willDeselectRowAtIndexPath = [self.delegate tableView:tableView willDeselectRowAtIndexPath:indexPath];
	}
	return willDeselectRowAtIndexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_delegateRespondsTo.didDeselectRowAtIndexPath == 1) {
		[self.delegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
	}
}

#pragma mark Modifying the Header and Footer of Sections
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!self.isMultiSection) return nil;
    
	if (self.sectionCellDatas.count > section) {
		ZDSectionViewModel *headerViewModel = self.sectionCellDatas[section][HeaderViewModelKey];

        if (!ZDNotNilOrEmpty(headerViewModel)) return nil;
        
        NSString *headerReuseIdentifier = headerViewModel.zd_sectionReuseIdentifier ? : headerViewModel.zd_sectionNibName;
		UITableViewHeaderFooterView *headerInSectionView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
        
        if (![headerInSectionView conformsToProtocol:@protocol(ZDSectionProtocol)]) {
            NSCAssert(NO, @"headerView需要遵守协议");
            return headerInSectionView;
        }
        
        id <ZDSectionProtocol> viewForHeaderInSection = (id)headerInSectionView;
        
        if ([viewForHeaderInSection respondsToSelector:@selector(setSectionBindProxy:)]) {
            viewForHeaderInSection.sectionBindProxy = self;
        }
        
		if ([viewForHeaderInSection respondsToSelector:@selector(setHeaderHeight:)]) {
            viewForHeaderInSection.headerHeight = headerViewModel.zd_sectionHeight;
		}

		if ([viewForHeaderInSection respondsToSelector:@selector(setSectionCommand:)]) {
			viewForHeaderInSection.sectionCommand = self.sectionCommand;
		}

		return [UIView zd_cast:viewForHeaderInSection];
	}

	return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (!self.isMultiSection) return nil;
    if (section >= self.sectionCellDatas.count) {
        ZDBDLog(@"数组越界");
        return nil;
    }
    
    ZDSectionViewModel *footerViewModel = self.sectionCellDatas[section][FooterViewModelKey];
    
    if (!ZDNotNilOrEmpty(footerViewModel)) return nil;
    
    NSString *footerReuseIdentifier = footerViewModel.zd_sectionReuseIdentifier ? : footerViewModel.zd_sectionNibName;
    UITableViewHeaderFooterView *footerInSectionView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerReuseIdentifier];
    
    if (![footerInSectionView conformsToProtocol:@protocol(ZDSectionProtocol)]) {
        NSCAssert(NO, @"需要遵守协议");
        return footerInSectionView;
    }
    
    id <ZDSectionProtocol> viewForFooterInSection = (id)footerInSectionView;
    
    if ([viewForFooterInSection respondsToSelector:@selector(setSectionBindProxy:)]) {
        viewForFooterInSection.sectionBindProxy = self;
    }
    
    if ([viewForFooterInSection respondsToSelector:@selector(setHeaderHeight:)]) {
        viewForFooterInSection.headerHeight = footerViewModel.zd_sectionHeight;
    }
    
    if ([viewForFooterInSection respondsToSelector:@selector(setSectionCommand:)]) {
        viewForFooterInSection.sectionCommand = self.sectionCommand;
    }
    
    return [UIView zd_cast:viewForFooterInSection];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    CGFloat estimatedHeightForHeaderInSection = 0.0f;
    
    if (self.isMultiSection) {
        NSDictionary *dic = self.sectionCellDatas[section];
        ZDSectionViewModel *sectionViewModel = dic[HeaderViewModelKey];
        
        if (!ZDNotNilOrEmpty(sectionViewModel)) {
            return 0;
        }
        CGFloat estimateHeight = sectionViewModel.zd_estimatedSectionHeight;
        return estimateHeight;
    }
    
    return estimatedHeightForHeaderInSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	CGFloat heightForHeaderInSection = 0.0f;
    
    if (!self.isMultiSection) return heightForHeaderInSection;
    
    NSDictionary *dic = self.sectionCellDatas[section];
    ZDSectionViewModel *sectionViewModel = dic[HeaderViewModelKey];
    
    if (!ZDNotNilOrEmpty(sectionViewModel)) return 0;
    
    NSString *headerReuseIdentifier = sectionViewModel.zd_sectionReuseIdentifier ? : sectionViewModel.zd_sectionNibName;
    id <ZDSectionProtocol> headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
    headerView.sectionModel = sectionViewModel.zd_sectionModel;
    
    if (sectionViewModel.zd_sectionFixedHeight > 0) {   // 固定高度
        heightForHeaderInSection = sectionViewModel.zd_sectionFixedHeight;
    }
    else if (sectionViewModel.zd_sectionHeight > 0) {   // 缓存高度
        heightForHeaderInSection = sectionViewModel.zd_sectionHeight;
    }
    else {
        //NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CGRectGetWidth(headerView.contentView.bounds)];
        //[headerView addConstraint:widthConstraint];
        heightForHeaderInSection = [(__kindof UIView *)headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        //[headerView removeConstraint:widthConstraint];
        
        //更新headerViewModel
        sectionViewModel.zd_sectionHeight = heightForHeaderInSection;
        NSMutableDictionary *mutDic = dic.mutableCopy;
        mutDic[HeaderViewModelKey] = sectionViewModel;
        self.sectionCellDatas[section] = mutDic.copy;
    }

	return heightForHeaderInSection;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
// fix bug：在9.0之前的系统，执行此方法后，tableView:heightForFooterInSection:代理方法会不执行，然后footerHeight用的是header的height
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    CGFloat estimatedHeightForFooterInSection = 0.0;
    
    if (self.isMultiSection) {
        NSDictionary *dic = self.sectionCellDatas[section];
        ZDSectionViewModel *sectionViewModel = dic[FooterViewModelKey];
        
        if (!ZDNotNilOrEmpty(sectionViewModel)) return 0.0;
        
        CGFloat estimateHeight = sectionViewModel.zd_estimatedSectionHeight;
        return estimateHeight;
    }
    
    return estimatedHeightForFooterInSection;
}
#endif

/// The table view does not call this method
/// if it was created in a plain style (UITableViewStylePlain).
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	CGFloat heightForFooterInSection = 0.0f;

    if (!self.isMultiSection) return heightForFooterInSection;
    
    NSDictionary *dic = self.sectionCellDatas[section];
    ZDSectionViewModel *sectionViewModel = dic[FooterViewModelKey];
    
    if (!ZDNotNilOrEmpty(sectionViewModel)) return 0;
    
    NSString *footerReuseIdentifier = sectionViewModel.zd_sectionReuseIdentifier ? : sectionViewModel.zd_sectionNibName;
    id <ZDSectionProtocol> footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerReuseIdentifier];
    footerView.sectionModel = sectionViewModel.zd_sectionModel;
    
    if (sectionViewModel.zd_sectionFixedHeight > 0) {
        heightForFooterInSection = sectionViewModel.zd_sectionFixedHeight;
    }
    else if (sectionViewModel.zd_sectionHeight > 0) {
        heightForFooterInSection = sectionViewModel.zd_sectionHeight;
    }
    else {
        heightForFooterInSection = [(__kindof UIView *)footerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        //更新footerViewModel
        sectionViewModel.zd_sectionHeight = heightForFooterInSection;
        NSMutableDictionary *mutDic = dic.mutableCopy;
        mutDic[FooterViewModelKey] = sectionViewModel;
        self.sectionCellDatas[section] = mutDic.copy;
    }
    
	return heightForFooterInSection;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (!self.isMultiSection) return;
    if (self.sectionCellDatas.count <= section) {
        ZDBDLog(@"数组越界");
        return;
    }
    
    id <ZDSectionProtocol> viewForHeaderInSection = (id)view;
    
    ZDSectionViewModel *headerViewModel = self.sectionCellDatas[section][HeaderViewModelKey];
    if (!ZDNotNilOrEmpty(headerViewModel)) return;
    
    if ([viewForHeaderInSection respondsToSelector:@selector(setSectionViewModel:)]) {
        viewForHeaderInSection.sectionViewModel = headerViewModel;
    }
    
    if ([viewForHeaderInSection respondsToSelector:@selector(setSectionModel:)]) {
        viewForHeaderInSection.sectionModel = headerViewModel.zd_sectionModel;
    }
    
    // section绑定协议
    if ([viewForHeaderInSection respondsToSelector:@selector(bindToSectionViewModel:)]) {
        [viewForHeaderInSection bindToSectionViewModel:headerViewModel];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    if (!self.isMultiSection) return;
    if (self.sectionCellDatas.count <= section) {
        ZDBDLog(@"数组越界");
        return;
    }
    
    id <ZDSectionProtocol> viewForFooterInSection = (id)view;
    
    ZDSectionViewModel *footerViewModel = self.sectionCellDatas[section][FooterViewModelKey];
    if (!ZDNotNilOrEmpty(footerViewModel)) return;
    
    if ([viewForFooterInSection respondsToSelector:@selector(setSectionViewModel:)]) {
        viewForFooterInSection.sectionViewModel = footerViewModel;
    }
    
    if ([viewForFooterInSection respondsToSelector:@selector(setSectionModel:)]) {
        viewForFooterInSection.sectionModel = footerViewModel.zd_sectionModel;
    }
    
    /// section绑定协议
    if ([viewForFooterInSection respondsToSelector:@selector(bindToSectionViewModel:)]) {
        [viewForFooterInSection bindToSectionViewModel:footerViewModel];
    }
}

#pragma mark Editing Table Rows
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_delegateRespondsTo.willBeginEditingRowAtIndexPath == 1) {
		[self.delegate tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(ZD_NULLABLE NSIndexPath *)indexPath
{
	if (_delegateRespondsTo.didEndEditingRowAtIndexPath == 1) {
		[self.delegate tableView:tableView didEndEditingRowAtIndexPath:indexPath];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellEditingStyle editingStyleForRowAtIndexPath = [tableView cellForRowAtIndexPath:indexPath].editing == YES ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;

	if (_delegateRespondsTo.editingStyleForRowAtIndexPath == 1) {
		editingStyleForRowAtIndexPath = [self.delegate tableView:tableView editingStyleForRowAtIndexPath:indexPath];
	}
	return editingStyleForRowAtIndexPath;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *titleForDeleteConfirmationButtonForRowAtIndexPath = NSLocalizedString(@"删除", @"Delete");

	if (_delegateRespondsTo.titleForDeleteConfirmationButtonForRowAtIndexPath == 1) {
		titleForDeleteConfirmationButtonForRowAtIndexPath = [self.delegate tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
	}
	return titleForDeleteConfirmationButtonForRowAtIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL shouldIndentWhileEditingRowAtIndexPath = YES;

	if (_delegateRespondsTo.shouldIndentWhileEditingRowAtIndexPath == 1) {
		shouldIndentWhileEditingRowAtIndexPath = [self.delegate tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
	}
	return shouldIndentWhileEditingRowAtIndexPath;
}

#pragma mark Reordering Table Rows
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	NSIndexPath *toProposedIndexPath = proposedDestinationIndexPath;

	if (_delegateRespondsTo.targetIndexPathForMoveFromRowAtIndexPathToProposedIndexPath == 1) {
		toProposedIndexPath = [self.delegate tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
	}
	return toProposedIndexPath;
}

#pragma mark Tracking the Removal of Views
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_delegateRespondsTo.didEndDisplayingCellForRowAtIndexPath == 1) {
		[self.delegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
{
	if (_delegateRespondsTo.didEndDisplayingHeaderViewForSection == 1) {
		[self.delegate tableView:tableView didEndDisplayingHeaderView:view forSection:section];
	}
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section
{
	if (_delegateRespondsTo.didEndDisplayingFooterViewForSection == 1) {
		[self.delegate tableView:tableView didEndDisplayingFooterView:view forSection:section];
	}
}

#pragma mark Copying and Pasting Row Content
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL shouldShowMenuForRowAtIndexPath = NO;

	if (_delegateRespondsTo.shouldShowMenuForRowAtIndexPath == 1) {
		shouldShowMenuForRowAtIndexPath = [self.delegate tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
	}
	return shouldShowMenuForRowAtIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
{
	BOOL canPerformAction = NO;

	if (_delegateRespondsTo.canPerformActionForRowAtIndexPathWithSender == 1) {
		canPerformAction = [self.delegate tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
	}
	return canPerformAction;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
{
	if (_delegateRespondsTo.performActionForRowAtIndexPathWithSender == 1) {
		[self.delegate tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
	}
}

#pragma mak Managing Table View Highlighting
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL shouldHighlightRowAtIndexPath = YES;

	if (_delegateRespondsTo.shouldHighlightRowAtIndexPath == 1) {
		shouldHighlightRowAtIndexPath = [self.delegate tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
	}
	return shouldHighlightRowAtIndexPath;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_delegateRespondsTo.didHighlightRowAtIndexPath == 1) {
		[self.delegate tableView:tableView didHighlightRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_delegateRespondsTo.didUnhighlightRowAtIndexPath == 1) {
		[self.delegate tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
	}
}

#pragma mark - UIScrollViewDelegate
#pragma mark -
#pragma mark Responding to Scrolling and Dragging
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (_delegateRespondsTo.scrollViewDidScroll) {
		[self.delegate scrollViewDidScroll:scrollView];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if (_delegateRespondsTo.scrollViewWillBeginDragging) {
		[self.delegate scrollViewWillBeginDragging:scrollView];
	}
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
	if (_delegateRespondsTo.scrollViewWillEndDraggingWithVelocityTargetContentOffset) {
		[self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (_delegateRespondsTo.scrollViewDidEndDraggingWillDecelerate) {
		[self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
	}
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
	BOOL scrollViewShouldScrollToTop = YES;

	if (_delegateRespondsTo.scrollViewShouldScrollToTop) {
		scrollViewShouldScrollToTop = [self.delegate scrollViewShouldScrollToTop:scrollView];
	}
	return scrollViewShouldScrollToTop;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
	if (_delegateRespondsTo.scrollViewDidScrollToTop) {
		[self.delegate scrollViewDidScrollToTop:scrollView];
	}
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	if (_delegateRespondsTo.scrollViewWillBeginDecelerating) {
		[self.delegate scrollViewWillBeginDecelerating:scrollView];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (_delegateRespondsTo.scrollViewDidEndDecelerating) {
		[self.delegate scrollViewDidEndDecelerating:scrollView];
	}
}

#pragma mark Managing Zooming
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	UIView *viewForZoomingInScrollView = nil;

	if (_delegateRespondsTo.viewForZoomingInScrollView) {
		viewForZoomingInScrollView = [self.delegate viewForZoomingInScrollView:scrollView];
	}
	return viewForZoomingInScrollView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view
{
	if (_delegateRespondsTo.scrollViewWillBeginZoomingWithView) {
		[self.delegate scrollViewWillBeginZooming:scrollView withView:view];
	}
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
	if (_delegateRespondsTo.scrollViewDidEndZoomingWithViewAtScale) {
		[self.delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
	}
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	if (_delegateRespondsTo.scrollViewDidZoom) {
		[self.delegate scrollViewDidZoom:scrollView];
	}
}

#pragma mark Responding to Scrolling Animations
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	if (_delegateRespondsTo.scrollViewDidEndScrollingAnimation) {
		[self.delegate scrollViewDidEndScrollingAnimation:scrollView];
	}
}

#pragma mark - Public Methods
// MARK: -----------------------获取CellViewModel-----------------------
- (nullable id <ZDCellViewModelProtocol>)cellViewModelAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.isMultiSection) {
		NSInteger section = indexPath.section;
		NSCAssert(section < self.sectionCellDatas.count, @"数组越界了");

		NSArray *cellViewModelArr = self.sectionCellDatas[section][CellViewModelKey];
		ZDCellViewModel *viewModel = cellViewModelArr[indexPath.row];
		NSCAssert(ZDNotNilOrEmpty(viewModel), @"viewModel不能为nil");
		return viewModel;
	}
	else {
		NSInteger index = indexPath.row;

		if (index < 0 || index >= self.cellViewModels.count) {
			return nil;
		}
		else {
			return self.cellViewModels[index];
		}
	}
}

- (void)updateViewModel:(id <ZDCellViewModelProtocol>)viewModel atIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath || !viewModel) return;
    
    if (self.isMultiSection) {
        NSMutableDictionary *sectionMutDict = self.sectionCellDatas[indexPath.section].mutableCopy;
        NSMutableArray *cellViewModelMutArr = [NSArray zd_cast:sectionMutDict[CellViewModelKey]].mutableCopy;
        [cellViewModelMutArr replaceObjectAtIndex:indexPath.row withObject:viewModel];
        [sectionMutDict setValue:cellViewModelMutArr.copy forKey:CellViewModelKey];
        [self.sectionCellDatas replaceObjectAtIndex:indexPath.section withObject:sectionMutDict];
    }
    else {
        [self.cellViewModels replaceObjectAtIndex:indexPath.row withObject:viewModel];
    }
}

- (void)insertViewModel:(id <ZDCellViewModelProtocol>)viewModel atIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath || !viewModel) return;
    
    [self registerNibForTableViewWithCellViewModels:@[viewModel]];

	if (self.isMultiSection) {
		NSArray *cellViewModelArr = self.sectionCellDatas[indexPath.section][CellViewModelKey];
		NSMutableArray *cellViewModelMutArr = cellViewModelArr.mutableCopy;
		[cellViewModelMutArr insertObject:viewModel atIndex:indexPath.row];
		[self.sectionCellDatas[indexPath.section] setValue:cellViewModelMutArr.copy forKey:CellViewModelKey];
	}
	else {
		[self.cellViewModels insertObject:viewModel atIndex:indexPath.row];
	}
    
	[self.tableView beginUpdates];
	[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.tableView endUpdates];
}

- (void)replaceViewModel:(id <ZDCellViewModelProtocol>)viewModel atIndexPath:(NSIndexPath *)indexPath afterDelay:(NSTimeInterval)delay
{
    if (!indexPath || !viewModel) return;
    
    [self registerNibForTableViewWithCellViewModels:@[viewModel]];

	if (self.isMultiSection) {
		NSArray *cellViewModelArr = self.sectionCellDatas[indexPath.section][CellViewModelKey];
		NSMutableArray *cellViewModelMutArr = cellViewModelArr.mutableCopy;
		[cellViewModelMutArr replaceObjectAtIndex:indexPath.row withObject:viewModel];
		[self.sectionCellDatas[indexPath.section] setValue:cellViewModelMutArr.copy forKey:CellViewModelKey];
	}
	else {
		[self.cellViewModels replaceObjectAtIndex:indexPath.row withObject:viewModel];
	}
    
    if (delay < 0) return;
    else if (delay == 0) {
        [self reloadItemsAtIndexPaths:@[indexPath]];
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reloadItemsAtIndexPaths:@[indexPath]];
        });
    }
}

- (void)replaceViewModel:(id<ZDCellViewModelProtocol>)viewModel atIndexPath:(NSIndexPath *)indexPath
{
    [self replaceViewModel:viewModel atIndexPath:indexPath afterDelay:0];
}

// 单section时，fromIndexPath和viewmodel可以只传一个；多section时，fromIndexPath必传，viewmodel可选
- (void)moveViewModel:(nullable id<ZDCellViewModelProtocol>)viewModel fromIndexPath:(nullable NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (self.isMultiSection) {
        NSArray *cellViewModelArr = self.sectionCellDatas[fromIndexPath.section][CellViewModelKey];
        if (!viewModel) {
            viewModel = cellViewModelArr[fromIndexPath.row];
        }
        NSMutableArray *mutRowCellViewModelArr = cellViewModelArr.mutableCopy;
        // 需先移除后添加数据
        [mutRowCellViewModelArr removeObjectAtIndex:fromIndexPath.row];
        [mutRowCellViewModelArr insertObject:viewModel atIndex:toIndexPath.row];
        [self.sectionCellDatas[fromIndexPath.section] setValue:mutRowCellViewModelArr forKey:CellViewModelKey];
    }
    else {
        if (!fromIndexPath) {
            NSUInteger fromIndex = [self.cellViewModels indexOfObject:viewModel];
            [self.cellViewModels removeObjectAtIndex:fromIndex];
            [self.cellViewModels insertObject:viewModel atIndex:toIndexPath.row];
            
            fromIndexPath = [NSIndexPath indexPathForRow:fromIndex inSection:0];
        }
        else if (!viewModel) {
            viewModel = self.cellViewModels[fromIndexPath.row];
        }
    }
        
    [self.tableView beginUpdates];
    [self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    [self.tableView endUpdates];
}

// muti section
- (void)moveViewModelFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self moveViewModel:nil fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

// single section
- (void)moveViewModel:(id<ZDCellViewModelProtocol>)viewModel toIndexPath:(NSIndexPath *)toIndexPath
{
    [self moveViewModel:viewModel fromIndexPath:nil toIndexPath:toIndexPath];
}

- (void)deleteCellViewModelAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) return;

	if (self.isMultiSection) {
		NSArray *cellViewModelArr = self.sectionCellDatas[indexPath.section][CellViewModelKey];
		NSMutableArray *cellViewModelMutArr = cellViewModelArr.mutableCopy;
		[cellViewModelMutArr removeObjectAtIndex:indexPath.row];
		[self.sectionCellDatas[indexPath.section] setValue:cellViewModelMutArr.copy forKey:CellViewModelKey];
	}
	else {
		[self.cellViewModels removeObjectAtIndex:indexPath.row];
	}

	[self.tableView beginUpdates];
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.tableView endUpdates];
}

- (void)reloadItemsAtIndexPaths:(NSArray <NSIndexPath *> *)indexPaths
{
    if (indexPaths.count == 0) return;
    
    [self.tableView beginUpdates];
	[self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.tableView endUpdates];
}

- (void)resetData
{
    _isNeedToResetData = YES;
}

#pragma mark - Private Method
/// 清除所有数据(不需要重置数据时不执行，直接返回)
- (void)clearData
{
    if (!_isNeedToResetData) return;
    
    if (self.isMultiSection) {
        [self.sectionCellDatas removeAllObjects];
    }
    else {
        [self.cellViewModels removeAllObjects];
    }
    _isNeedToResetData = NO;
}

- (void)registerNibForTableViewWithCellViewModels:(NSArray <ZDCellViewModel *> *)cellViewModels
{
	NSCAssert(cellViewModels, @"CellViewModels cann't be nil");

	/// storyBoard里的cell不需要手动注册，只需要设置reuseIdentifier
	for (id <ZDCellViewModelProtocol> cellViewModel in cellViewModels) {
		// register cell
		NSString *cellNibName = [cellViewModel zd_nibName];
		NSString *cellClassName = [cellViewModel zd_className];
		NSString *reuseIdentifier = [cellViewModel zd_reuseIdentifier];
		NSCAssert(reuseIdentifier, @"Cell's reuseIdentifier must be set");

		if (ZDNotNilOrEmpty(cellNibName) && ![self.mutArrNibNameForCell containsObject:cellNibName]) {
            NSString *nibPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.nib", cellNibName] ofType:nil];
			if (nibPath) {
                // create an instance of the template cell and register with the table view
                // UITableViewCell *templateCell = [[nib instantiateWithOwner:nil options:nil] firstObject];
                UINib *cellNib = [UINib nibWithNibName:cellNibName bundle:nil];
				[self.tableView registerNib:cellNib forCellReuseIdentifier:reuseIdentifier ? : cellNibName];
				[self.mutArrNibNameForCell addObject:cellNibName];
			}
		}
		else if (ZDNotNilOrEmpty(cellClassName) && ![self.mutArrClassNameForCell containsObject:cellClassName]) {
			// 通过类名注册Cell
			[self.tableView registerClass:NSClassFromString(cellClassName) forCellReuseIdentifier:reuseIdentifier ? : cellClassName];
			[self.mutArrClassNameForCell addObject:cellClassName];
		}
	}
}

- (void)registerNibForTableViewWithSectionViewModel:(ZDSectionViewModel *)sectionViewModel
{
	// register header && footer (only to mutableSection)
	NSString *sectionNibName = [sectionViewModel zd_sectionNibName];
	NSString *sectionClassName = [sectionViewModel zd_sectionClassName];
	NSString *sectionReuseIdentifier = [sectionViewModel zd_sectionReuseIdentifier];

	NSCAssert(sectionReuseIdentifier, @"SectionView's reuseIdentifier must be set");

	if (ZDNotNilOrEmpty(sectionNibName) && ![self.mutArrNibNameForSection containsObject:sectionNibName]) {
        NSString *nibPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.nib", sectionNibName] ofType:nil];
		if (nibPath) {
            UINib *sectionNib = [UINib nibWithNibName:sectionNibName bundle:nil];
			[self.tableView registerNib:sectionNib forHeaderFooterViewReuseIdentifier:sectionReuseIdentifier ? : sectionNibName];
			[self.mutArrNibNameForSection addObject:sectionNibName];
		}
	}
	else if (ZDNotNilOrEmpty(sectionClassName) && ![self.mutArrClassNameForSection containsObject:sectionClassName]) {
		// 通过类名注册Section
		[self.tableView registerClass:NSClassFromString(sectionClassName) forHeaderFooterViewReuseIdentifier:sectionReuseIdentifier ? : sectionClassName];
		[self.mutArrClassNameForSection addObject:sectionClassName];
	}
}

/// muti Section
- (void)registerNibForTableViewWithSectionCellViewModels:(__kindof NSArray <NSDictionary *> *)sectionCellModels
{
    if (!self.isMultiSection) return;
        
	for (NSDictionary *sectionCellDataDic in sectionCellModels) {
		if (ZDNotNilOrEmpty(sectionCellModels)) {
			ZDSectionViewModel *headerViewModel = sectionCellDataDic[HeaderViewModelKey];
			NSArray *cellViewModels = sectionCellDataDic[CellViewModelKey];
			ZDSectionViewModel *footerViewModel = sectionCellDataDic[FooterViewModelKey];

			if (ZDNotNilOrEmpty(cellViewModels)) {
				[self registerNibForTableViewWithCellViewModels:cellViewModels];
			}

			if (ZDNotNilOrEmpty(headerViewModel)) {
				[self registerNibForTableViewWithSectionViewModel:headerViewModel];
			}

			if (ZDNotNilOrEmpty(footerViewModel)) {
				[self registerNibForTableViewWithSectionViewModel:footerViewModel];
			}
		}
	}
}

- (void)reloadRowsNoAnimationAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (indexPaths.count == 0) return;
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

#pragma mark - Setters
- (void)setDelegate:(nullable id <UITableViewDelegate>)delegate
{
    if (self.delegate != delegate) {
        _delegate = delegate;
        
        /**
         *  Forward the delegate method
         *  refer： https://github.com/ColinEberhardt/CETableViewBinding
         *
         *  如果delegate履行了哪个协议方法，那么这个协议方法就在代理对象的类里执行
         */
        struct delegateMethodsCaching newMethodCaching;
        // UITableViewDelegate
        
        //Configuring Rows for the Table View
        newMethodCaching.heightForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)];
        //newMethodCaching.estimatedHeightForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)];
        newMethodCaching.indentationLevelForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:indentationLevelForRowAtIndexPath:)];
        //newMethodCaching.willDisplayCellForRowAtIndexPath = [delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)];
        
        //Managing Accessory Views
        newMethodCaching.editActionsForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)];
        newMethodCaching.accessoryButtonTappedForRowWithIndexPath = [_delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)];
        
        //Managing Selections
        newMethodCaching.willSelectRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)];
        //newMethodCaching.didSelectRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)];
        newMethodCaching.willDeselectRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)];
        newMethodCaching.didDeselectRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)];
        
        //Modifying the Header and Footer of Sections
        //newMethodCaching.viewForHeaderInSection = [_delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)];
        //newMethodCaching.viewForFooterInSection = [_delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)];
        //newMethodCaching.heightForHeaderInSection = [_delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)];
        //newMethodCaching.estimatedHeightForHeaderInSection = [_delegate respondsToSelector:@selector(tableView:estimatedHeightForHeaderInSection:)];
        //newMethodCaching.heightForFooterInSection = [_delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)];
        //newMethodCaching.estimatedHeightForFooterInSection = [_delegate respondsToSelector:@selector(tableView:estimatedHeightForFooterInSection:)];
        //newMethodCaching.willDisplayHeaderViewForSection = [_delegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)];
        //newMethodCaching.willDisplayFooterViewForSection = [_delegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)];
        
        //Editing Table Rows
        newMethodCaching.willBeginEditingRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:willBeginEditingRowAtIndexPath:)];
        newMethodCaching.didEndEditingRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:didEndEditingRowAtIndexPath:)];
        newMethodCaching.editingStyleForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)];
        newMethodCaching.titleForDeleteConfirmationButtonForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)];
        newMethodCaching.shouldIndentWhileEditingRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)];
        
        //Reordering Table Rows
        newMethodCaching.targetIndexPathForMoveFromRowAtIndexPathToProposedIndexPath = [_delegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)];
        
        //Tracking the Removal of Views
        newMethodCaching.didEndDisplayingCellForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)];
        newMethodCaching.didEndDisplayingHeaderViewForSection = [_delegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)];
        newMethodCaching.didEndDisplayingFooterViewForSection = [_delegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)];
        
        //Copying and Pasting Row Content
        newMethodCaching.shouldShowMenuForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:shouldShowMenuForRowAtIndexPath:)];
        newMethodCaching.canPerformActionForRowAtIndexPathWithSender = [_delegate respondsToSelector:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)];
        newMethodCaching.performActionForRowAtIndexPathWithSender = [_delegate respondsToSelector:@selector(tableView:performAction:forRowAtIndexPath:withSender:)];
        
        //Managing Table View Highlighting
        newMethodCaching.shouldHighlightRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:shouldHighlightRowAtIndexPath:)];
        newMethodCaching.didHighlightRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:didHighlightRowAtIndexPath:)];
        newMethodCaching.didUnhighlightRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:didUnhighlightRowAtIndexPath:)];
        
        // UIScrollViewDelegate
        //Responding to Scrolling and Dragging
        newMethodCaching.scrollViewDidScroll = [_delegate respondsToSelector:@selector(scrollViewDidScroll:)];
        newMethodCaching.scrollViewWillBeginDragging = [_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)];
        newMethodCaching.scrollViewWillEndDraggingWithVelocityTargetContentOffset = [_delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)];
        newMethodCaching.scrollViewDidEndDraggingWillDecelerate = [_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)];
        newMethodCaching.scrollViewShouldScrollToTop = [_delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)];
        newMethodCaching.scrollViewDidScrollToTop = [_delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)];
        newMethodCaching.scrollViewWillBeginDecelerating = [_delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)];
        newMethodCaching.scrollViewDidEndDecelerating = [_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)];
        
        //Managing Zooming
        newMethodCaching.viewForZoomingInScrollView = [_delegate respondsToSelector:@selector(viewForZoomingInScrollView:)];
        newMethodCaching.scrollViewWillBeginZoomingWithView = [_delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)];
        newMethodCaching.scrollViewDidEndZoomingWithViewAtScale = [_delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)];
        newMethodCaching.scrollViewDidZoom = [_delegate respondsToSelector:@selector(scrollViewDidZoom:)];
        
        //Responding to Scrolling Animations
        newMethodCaching.scrollViewDidEndScrollingAnimation = [_delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)];
        
        self.delegateRespondsTo = newMethodCaching;
    }
}

#pragma mark - Getter
- (NSMutableArray<NSDictionary *> *)sectionCellDatas
{
    if (!_sectionCellDatas) {
        _sectionCellDatas = [[NSMutableArray alloc] init];
    }
    return _sectionCellDatas;
}

- (NSMutableArray<id<ZDCellViewModelProtocol>> *)cellViewModels
{
    if (!_cellViewModels) {
        _cellViewModels = [[NSMutableArray alloc] init];
    }
    return _cellViewModels;
}

- (NSMutableArray *)mutArrNibNameForCell
{
	if (!_mutArrNibNameForCell) {
		_mutArrNibNameForCell = [[NSMutableArray alloc] init];
	}
	return _mutArrNibNameForCell;
}

- (NSMutableArray *)mutArrClassNameForCell
{
	if (!_mutArrClassNameForCell) {
		_mutArrClassNameForCell = [[NSMutableArray alloc] init];
	}
	return _mutArrClassNameForCell;
}

- (NSMutableArray *)mutArrNibNameForSection
{
	if (!_mutArrNibNameForSection) {
		_mutArrNibNameForSection = [[NSMutableArray alloc] init];
	}
	return _mutArrNibNameForSection;
}

- (NSMutableArray *)mutArrClassNameForSection
{
	if (!_mutArrClassNameForSection) {
		_mutArrClassNameForSection = [[NSMutableArray alloc] init];
	}
	return _mutArrClassNameForSection;
}

- (NSMutableDictionary<NSIndexPath *, id> *)prefetchDict
{
    if (!_prefetchDict) {
        _prefetchDict = [[NSMutableDictionary alloc] init];
    }
    return _prefetchDict;
}

@end


@implementation NSObject (Cast)

+ (nullable instancetype)zd_cast:(id)objc
{
	if ([objc isKindOfClass:[self class]]) {
		return objc;
	}
	return nil;
}

@end
NS_ASSUME_NONNULL_END
