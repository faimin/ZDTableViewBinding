//
//  ZDTableViewBindingHelper.m
//  Demo
//
//  Created by Zero on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDTableViewBinding.h"
#if ZD_INCLUEDE_FD
#import "UITableView+FDTemplateLayoutCell.h"
#endif

NS_ASSUME_NONNULL_BEGIN

NSInteger const ZDBD_Event_DidSelectRow = -1;

//****************************************************************

@interface NSObject (Cast)
+ (nullable instancetype)zdbd_cast:(id)objc;
@end

//****************************************************************

@interface ZDTableViewBinding ()<UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching> {
    BOOL _isNeedToResetData;
}

// 位域: http://c.biancheng.net/cpp/html/102.html
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

@property (nonatomic, weak, readwrite) __kindof UITableView *tableView;
// 外面的command参数是临时变量，需要当前类持有，所以为strong类型
@property (nonatomic, strong) RACCommand *cellCommand;
@property (nonatomic, strong) RACCommand *headerFooterCommand;
/// 包含sectionViewModel和cellViewModel字典的数组
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *sectionCellDatas;
@property (nonatomic, strong) NSMutableArray<ZDCellViewModel> *cellViewModels;
/// 下面2个array盛放的是注册过的nibName
@property (nonatomic, strong) NSMutableSet<NSString *> *mutSetNibNameForCell;
@property (nonatomic, strong) NSMutableSet<NSString *> *mutSetClassNameForCell;
@property (nonatomic, strong) NSMutableSet<NSString *> *mutSetNibNameForSection;
@property (nonatomic, strong) NSMutableSet<NSString *> *mutSetClassNameForSection;
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
                         dataSourceSignal:(RACSignal *)dataSourceSignal
                              cellCommand:(nullable RACCommand *)cellCommand
                      headerFooterCommand:(nullable RACCommand *)headerFooterCommand
{
	return [[self alloc] initWithTableView:tableView
                              multiSection:multiSection
                          dataSourceSignal:dataSourceSignal
                               cellCommand:cellCommand
                       headerFooterCommand:headerFooterCommand];
}

- (instancetype)initWithTableView:(__kindof UITableView *)tableView
                     multiSection:(BOOL)multiSection
                 dataSourceSignal:(__kindof RACSignal *)dataSourceSignal
                      cellCommand:(nullable RACCommand *)cellCommand
              headerFooterCommand:(nullable RACCommand *)headerFooterCommand
{
    self = [super init];
	if (!self) return nil;
    
    self.tableView = tableView;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    //if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_9_x_Max)
    if (@available(iOS 10.0, *)) {
        self.tableView.prefetchDataSource = self;
    }
    self.delegate = nil;
    
    self.isMultiSection = multiSection;
    self.cellCommand = cellCommand;
    self.headerFooterCommand = headerFooterCommand;
    
    @weakify(self);
    [[[dataSourceSignal filter:^BOOL(id value) {
        return (value != nil);
    }] deliverOnMainThread] subscribeNext:^(__kindof NSArray *x) {
        @strongify(self);
        // 清空数据源(只有调用resetData后才会清空数据源,否则下面方法没作用)
        [self clearDataIfNeeded];
        
        // register cell && header && footer
        if (multiSection) {
            [self registerNibForTableViewWithSectionCellViewModels:x];
            [self.sectionCellDatas addObjectsFromArray:x];
        }
        else {
            [self registerNibForTableViewWithCellViewModels:x];
            [self.cellViewModels addObjectsFromArray:x];
        }
        
        /// reloadData on mainThread
        [self.tableView reloadData];
        
        self.isFinishedReloadData = YES;
    }];
    
	return self;
}

#pragma mark - UITableViewDataSourcePrefetching
#pragma mark -
- (void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    //TODO: 预加载
//    for (NSIndexPath *indexPath in indexPaths) {
//        ZDCellViewModel cellViewModel = [self cellViewModelAtIndexPath:indexPath];
//        NSCAssert(cellViewModel != nil, @"cellViewModel can't be nil");
//        ZDCell cell = [tableView dequeueReusableCellWithIdentifier:([cellViewModel zd_reuseIdentifier] ?: [cellViewModel zd_nibName]) forIndexPath:indexPath];
//        NSCAssert(cell != nil, @"cell can't be nil");
//    }
}

- (void)tableView:(UITableView *)tableView cancelPrefetchingForRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    //TODO: 取消预加载
}

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
        if (section >= self.sectionCellDatas.count) return 0;
        
		NSArray *cellViewModelArr = self.sectionCellDatas[section][CellViewModelKey];
        return [NSArray zdbd_cast:cellViewModelArr].count;
	}
	return self.cellViewModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	ZDCellViewModel cellViewModel = [self cellViewModelAtIndexPath:indexPath];
	NSCAssert(cellViewModel != nil, @"cellViewModel can't be nil");
    NSString *reuseIdentifier = ({
        NSString *reuseId = nil;
        if ([cellViewModel respondsToSelector:@selector(zd_reuseIdentifier)]) {
            reuseId = [cellViewModel zd_reuseIdentifier];
        }
        reuseId;
    });
    NSString *className = ({
        NSString *classNameString = nil;
        if ([cellViewModel respondsToSelector:@selector(zd_className)]) {
            classNameString = [cellViewModel zd_className];
        }
        classNameString;
    });
    NSString *nibName = ({
        NSString *nibNameString = nil;
        if ([cellViewModel respondsToSelector:@selector(zd_nibName)]) {
            nibNameString = [cellViewModel zd_nibName];
        }
        nibNameString;
    });
    
    NSString *identifier = reuseIdentifier ?: (nibName ?: className);
    ZDCell cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (!cell) {
        Class aCalss = NSClassFromString(className ?: reuseIdentifier);
        if (!aCalss) {
            NSCAssert(NO, @"aClass don't exist");
        }
        else if ([aCalss isSubclassOfClass:[UITableViewCell class]]) {
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

// 如果不实现此代理,那么在iOS8系统无法左滑
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
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
     */
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray<ZDCellViewModel> *cellViewModels = self.cellViewModels;
    if (self.isMultiSection) {
        if (indexPath.section >= self.sectionCellDatas.count) return NO;
        cellViewModels = self.sectionCellDatas[indexPath.section][CellViewModelKey];
    }

    if (cellViewModels.count > indexPath.row) {
        ZDCellViewModel cellViewModel = cellViewModels[indexPath.row];
        if ([cellViewModel respondsToSelector:@selector(zd_canEditRow)]) {
            return cellViewModel.zd_canEditRow;
        }
    }
    return NO;
}

#pragma mark - UITableViewDelegate
#pragma mark -
#pragma mark Configuring Rows for the TableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = tableView.rowHeight;
    if (_delegateRespondsTo.heightForRowAtIndexPath == 1) {
        cellHeight = [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
        return cellHeight;
    }

	ZDCellViewModel cellViewModel = [self cellViewModelAtIndexPath:indexPath];
    
    if (cellViewModel.zd_fixedHeight > 0) {
        return cellViewModel.zd_fixedHeight;
    }
    else {
#if ZD_INCLUEDE_FD
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
		NSDictionary *dict = self.sectionCellDatas[indexPath.section];
		NSArray *cellViewModelArr = dict[CellViewModelKey];
		ZDCellViewModel cellViewModel = cellViewModelArr[indexPath.row];
        
        if (!cellViewModel) return 0.f;
        
		CGFloat estimateHeight = cellViewModel.zd_estimatedHeight;
		return estimateHeight;
	}
	else {
		ZDCellViewModel cellViewModel = [self cellViewModelAtIndexPath:indexPath];
		estimatedHeightForRowAtIndexPath = [cellViewModel zd_estimatedHeight];
	}

	return estimatedHeightForRowAtIndexPath;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger indentationLevelForRowAtIndexPath = 0;

	if (_delegateRespondsTo.indentationLevelForRowAtIndexPath == 1) {
		indentationLevelForRowAtIndexPath = [self.delegate tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
	}
	return indentationLevelForRowAtIndexPath;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![cell conformsToProtocol:@protocol(ZDCellProtocol)]) {
        NSCAssert(NO, @"cell need confrom ZDCellProtocol");
        return;
    }
        
    ZDCellViewModel cellViewModel = [self cellViewModelAtIndexPath:indexPath];
    NSCAssert(cellViewModel != nil, @"cellViewModel can't be nil");
    
    ZDCell zdCell = (id)cell;
    
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
    
    if (_delegateRespondsTo.willDisplayCellForRowAtIndexPath == 1) {
        [self.delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
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
		[cell.cellCommand execute:[RACTuple tupleWithObjects:cell, [self cellViewModelAtIndexPath:indexPath], @(ZDBD_Event_DidSelectRow), nil]];
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
    if (section >= self.sectionCellDatas.count) return nil;
    
    ZDHeaderFooterViewModel headerViewModel = self.sectionCellDatas[section][HeaderViewModelKey];
    if (!headerViewModel) return nil;
    
    if ([headerViewModel respondsToSelector:@selector(setZd_sectionBindProxy:)]) {
        headerViewModel.zd_headerFooterBindProxy = self;
    }
    
    NSString *headerReuseIdentifier = headerViewModel.zd_headerFooterReuseIdentifier ?: headerViewModel.zd_headerFooterNibName;
    UITableViewHeaderFooterView *headerInSectionView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
    
    if (![headerInSectionView conformsToProtocol:@protocol(ZDHeaderFooterProtocol)]) {
        NSCAssert(NO, @"headerView need to conform ZDHeaderFooterProtocol");
        return headerInSectionView;
    }
    
    ZDHeaderFooter viewForHeaderInSection = (id)headerInSectionView;
    
    if ([viewForHeaderInSection respondsToSelector:@selector(setHeaderFooterBindProxy:)]) {
        viewForHeaderInSection.headerFooterBindProxy = self;
    }
    
    if ([viewForHeaderInSection respondsToSelector:@selector(setHeaderFooterHeight:)]) {
        viewForHeaderInSection.headerFooterHeight = headerViewModel.zd_headerFooterHeight;
    }
    
    if ([viewForHeaderInSection respondsToSelector:@selector(setHeaderFooterCommand:)]) {
        viewForHeaderInSection.headerFooterCommand = self.headerFooterCommand;
    }
    
    return viewForHeaderInSection;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (!self.isMultiSection) return nil;
    if (section >= self.sectionCellDatas.count) {
        ZDBDLog(@"Array out of bounds");
        return nil;
    }
    
    ZDHeaderFooterViewModel footerViewModel = self.sectionCellDatas[section][FooterViewModelKey];
    if (!footerViewModel) return nil;
    
    if ([footerViewModel respondsToSelector:@selector(setZd_headerFooterBindProxy:)]) {
        footerViewModel.zd_headerFooterBindProxy = self;
    }
    
    NSString *footerReuseIdentifier = footerViewModel.zd_headerFooterReuseIdentifier ?: footerViewModel.zd_headerFooterNibName;
    UITableViewHeaderFooterView *footerInSectionView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerReuseIdentifier];
    
    if (![footerInSectionView conformsToProtocol:@protocol(ZDHeaderFooterProtocol)]) {
        NSCAssert(NO, @"footerView need to conform ZDHeaderFooterProtocol");
        return footerInSectionView;
    }
    
    ZDHeaderFooter viewForFooterInSection = (id)footerInSectionView;
    
    if ([viewForFooterInSection respondsToSelector:@selector(setHeaderFooterBindProxy:)]) {
        viewForFooterInSection.headerFooterBindProxy = self;
    }
    
    if ([viewForFooterInSection respondsToSelector:@selector(setHeaderFooterHeight:)]) {
        viewForFooterInSection.headerFooterHeight = footerViewModel.zd_headerFooterHeight;
    }
    
    if ([viewForFooterInSection respondsToSelector:@selector(setHeaderFooterCommand:)]) {
        viewForFooterInSection.headerFooterCommand = self.headerFooterCommand;
    }
    
    return viewForFooterInSection;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    CGFloat estimatedHeightForHeaderInSection = 0.0f;
    
    if (self.isMultiSection) {
        NSDictionary *dic = self.sectionCellDatas[section];
        ZDHeaderFooterViewModel sectionViewModel = dic[HeaderViewModelKey];
        
        if (!sectionViewModel) return 0.f;
        
        CGFloat estimateHeight = sectionViewModel.zd_estimatedHeaderFooterHeight;
        return estimateHeight;
    }
    
    return estimatedHeightForHeaderInSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	CGFloat heightForHeaderInSection = 0.f;
    
    if (!self.isMultiSection) return heightForHeaderInSection;
    
    NSDictionary *dict = self.sectionCellDatas[section];
    ZDHeaderFooterViewModel headerFooterViewModel = dict[HeaderViewModelKey];
    
    if (!headerFooterViewModel) return 0.f;
    
    NSString *headerReuseIdentifier = headerFooterViewModel.zd_headerFooterReuseIdentifier ?: headerFooterViewModel.zd_headerFooterNibName;
    ZDHeaderFooter headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
    headerView.headerFooterModel = headerFooterViewModel.zd_headerFooterModel;
    
    if (headerFooterViewModel.zd_headerFooterFixedHeight > 0) {   // 固定高度
        heightForHeaderInSection = headerFooterViewModel.zd_headerFooterFixedHeight;
    }
    else if (headerFooterViewModel.zd_headerFooterHeight > 0) {   // 缓存高度
        heightForHeaderInSection = headerFooterViewModel.zd_headerFooterHeight;
    }
    else {
        //NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CGRectGetWidth(headerView.contentView.bounds)];
        //[headerView addConstraint:widthConstraint];
        heightForHeaderInSection = [(__kindof UIView *)headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        //[headerView removeConstraint:widthConstraint];
        
        //更新headerViewModel
        headerFooterViewModel.zd_headerFooterHeight = heightForHeaderInSection;
        NSMutableDictionary *mutDict = dict.mutableCopy;
        mutDict[HeaderViewModelKey] = headerFooterViewModel;
        self.sectionCellDatas[section] = mutDict.copy;
    }

	return heightForHeaderInSection;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
// fix bug：在9.0之前的系统，执行此方法后，tableView:heightForFooterInSection:代理方法会不执行，然后footerHeight用的是header的height
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    CGFloat estimatedHeightForFooterInSection = 0.f;
    
    if (self.isMultiSection) {
        NSDictionary *dic = self.sectionCellDatas[section];
        ZDHeaderFooterViewModel sectionViewModel = dic[FooterViewModelKey];
        
        if (!sectionViewModel) return 0.f;
        
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
	CGFloat heightForFooterInSection = 0.f;

    if (!self.isMultiSection) return heightForFooterInSection;
    
    NSDictionary *dic = self.sectionCellDatas[section];
    ZDHeaderFooterViewModel sectionViewModel = dic[FooterViewModelKey];
    
    if (!sectionViewModel) return 0.f;
    
    NSString *footerReuseIdentifier = sectionViewModel.zd_headerFooterReuseIdentifier ?: sectionViewModel.zd_headerFooterNibName;
    ZDHeaderFooter footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerReuseIdentifier];
    footerView.headerFooterModel = sectionViewModel.zd_headerFooterModel;
    
    if (sectionViewModel.zd_headerFooterFixedHeight > 0) {
        heightForFooterInSection = sectionViewModel.zd_headerFooterFixedHeight;
    }
    else if (sectionViewModel.zd_headerFooterHeight > 0) {
        heightForFooterInSection = sectionViewModel.zd_headerFooterHeight;
    }
    else {
        heightForFooterInSection = [(__kindof UIView *)footerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        //更新footerViewModel
        sectionViewModel.zd_headerFooterHeight = heightForFooterInSection;
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
        ZDBDLog(@"Array out of bounds");
        return;
    }
    
    ZDHeaderFooterViewModel headerViewModel = self.sectionCellDatas[section][HeaderViewModelKey];
    if (!headerViewModel) return;
    
    ZDHeaderFooter viewForHeaderInSection = (id)view;
    if ([viewForHeaderInSection respondsToSelector:@selector(setHeaderFooterModel:)]) {
        viewForHeaderInSection.headerFooterViewModel = headerViewModel;
    }
    
    if ([viewForHeaderInSection respondsToSelector:@selector(setHeaderFooterModel:)]) {
        viewForHeaderInSection.headerFooterModel = headerViewModel.zd_headerFooterModel;
    }
    
    // section绑定协议
    if ([viewForHeaderInSection respondsToSelector:@selector(bindToSectionViewModel:)]) {
        [viewForHeaderInSection bindToHeaderFooterViewModel:headerViewModel];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    if (!self.isMultiSection) return;
    if (self.sectionCellDatas.count <= section) {
        ZDBDLog(@"Array out of bounds");
        return;
    }
    
    ZDHeaderFooterViewModel footerViewModel = self.sectionCellDatas[section][FooterViewModelKey];
    if (!footerViewModel) return;
    
    ZDHeaderFooter viewForFooterInSection = (id)view;
    if ([viewForFooterInSection respondsToSelector:@selector(setHeaderFooterViewModel:)]) {
        viewForFooterInSection.headerFooterViewModel = footerViewModel;
    }
    
    if ([viewForFooterInSection respondsToSelector:@selector(setHeaderFooterModel:)]) {
        viewForFooterInSection.headerFooterModel = footerViewModel.zd_headerFooterModel;
    }
    
    /// section绑定协议
    if ([viewForFooterInSection respondsToSelector:@selector(bindToHeaderFooterViewModel:)]) {
        [viewForFooterInSection bindToHeaderFooterViewModel:footerViewModel];
    }
}

#pragma mark Editing Table Rows
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_delegateRespondsTo.willBeginEditingRowAtIndexPath == 1) {
		[self.delegate tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nullable NSIndexPath *)indexPath
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
- (nullable ZDCellViewModel)cellViewModelAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.isMultiSection) {
		NSInteger section = indexPath.section;
        if (section >= self.sectionCellDatas.count) {
            NSCAssert(NO, @"Array out of bounds");
            return nil;
        }
        
		NSArray<ZDCellViewModel> *cellViewModelArr = self.sectionCellDatas[section][CellViewModelKey];
        if (indexPath.row >= cellViewModelArr.count) {
            NSCAssert(NO, @"Array out of bounds");
            return nil;
        }
		ZDCellViewModel viewModel = cellViewModelArr[indexPath.row];
		NSCAssert(viewModel, @"viewModel can't be nil");
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

- (void)updateViewModel:(ZDCellViewModel)viewModel atIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath || !viewModel) return;
    
    if (self.isMultiSection) {
        NSMutableDictionary *sectionMutDict = self.sectionCellDatas[indexPath.section].mutableCopy;
        NSMutableArray *cellViewModelMutArr = [NSArray zdbd_cast:sectionMutDict[CellViewModelKey]].mutableCopy;
        [cellViewModelMutArr replaceObjectAtIndex:indexPath.row withObject:viewModel];
        [sectionMutDict setValue:cellViewModelMutArr.copy forKey:CellViewModelKey];
        [self.sectionCellDatas replaceObjectAtIndex:indexPath.section withObject:sectionMutDict];
    }
    else {
        [self.cellViewModels replaceObjectAtIndex:indexPath.row withObject:viewModel];
    }
}

- (void)insertViewModel:(ZDCellViewModel)viewModel atIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath || !viewModel) return;
    
    [self registerNibForTableViewWithCellViewModels:@[viewModel]];

	if (self.isMultiSection) {
        if (indexPath.section >= self.sectionCellDatas.count) return;
        
		NSArray *cellViewModelArr = self.sectionCellDatas[indexPath.section][CellViewModelKey];
		NSMutableArray *cellViewModelMutArr = cellViewModelArr.mutableCopy;
		[cellViewModelMutArr insertObject:viewModel atIndex:indexPath.row];
		[self.sectionCellDatas[indexPath.section] setValue:cellViewModelMutArr.copy forKey:CellViewModelKey];
	}
	else {
		[self.cellViewModels insertObject:viewModel atIndex:indexPath.row];
	}
    
    ZD_BATCH_UPDATE(self.tableView, [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];)
}

- (void)replaceViewModel:(ZDCellViewModel)viewModel atIndexPath:(NSIndexPath *)indexPath afterDelay:(NSTimeInterval)delay
{
    if (!indexPath || !viewModel) return;
    
    [self registerNibForTableViewWithCellViewModels:@[viewModel]];

	if (self.isMultiSection) {
        if (indexPath.section >= self.sectionCellDatas.count) return;
        
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

- (void)replaceViewModel:(ZDCellViewModel)viewModel atIndexPath:(NSIndexPath *)indexPath
{
    [self replaceViewModel:viewModel atIndexPath:indexPath afterDelay:0];
}

// 单section时，fromIndexPath和viewmodel可以只传一个；多section时，fromIndexPath必传，viewmodel可选
- (void)moveViewModel:(nullable ZDCellViewModel)viewModel fromIndexPath:(nullable NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (self.isMultiSection) {
        if (fromIndexPath.section >= self.sectionCellDatas.count) return;
        
        NSArray *cellViewModelArr = self.sectionCellDatas[fromIndexPath.section][CellViewModelKey];
        if (!viewModel && (fromIndexPath.row < cellViewModelArr.count)) {
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
    
    ZD_BATCH_UPDATE(self.tableView, [self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];)
}

// muti section
- (void)moveViewModelFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self moveViewModel:nil fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

// single section
- (void)moveViewModel:(ZDCellViewModel)viewModel toIndexPath:(NSIndexPath *)toIndexPath
{
    [self moveViewModel:viewModel fromIndexPath:nil toIndexPath:toIndexPath];
}

- (void)deleteCellViewModelAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) return;

	if (self.isMultiSection) {
        if (indexPath.section >= self.sectionCellDatas.count) return;
            
		NSArray *cellViewModelArr = self.sectionCellDatas[indexPath.section][CellViewModelKey];
		NSMutableArray *cellViewModelMutArr = cellViewModelArr.mutableCopy;
		[cellViewModelMutArr removeObjectAtIndex:indexPath.row];
		[self.sectionCellDatas[indexPath.section] setValue:cellViewModelMutArr.copy forKey:CellViewModelKey];
	}
	else {
		[self.cellViewModels removeObjectAtIndex:indexPath.row];
	}
    
    ZD_BATCH_UPDATE(self.tableView, [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];)
}

- (void)reloadItemsAtIndexPaths:(NSArray <NSIndexPath *> *)indexPaths
{
    if (indexPaths.count == 0) return;
    
    ZD_BATCH_UPDATE(self.tableView, [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];)
}

- (void)setNeedsResetData
{
    _isNeedToResetData = YES;
}

#pragma mark - Private Method
/// 清除所有数据(不需要重置数据时不执行，直接返回)
- (void)clearDataIfNeeded
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

- (void)registerNibForTableViewWithCellViewModels:(NSArray<ZDCellViewModel> *)cellViewModels
{
    if (![NSArray zdbd_cast:cellViewModels]) {
        NSCAssert(cellViewModels, @"CellViewModels cann't be nil");
        return;
    };

	/// storyBoard里的cell不需要手动注册，只需要设置reuseIdentifier
	for (ZDCellViewModel cellViewModel in cellViewModels) {
		// register cell
		NSString *cellNibName = [cellViewModel zd_nibName];
		NSString *cellClassName = [cellViewModel zd_className];
		NSString *reuseIdentifier = [cellViewModel zd_reuseIdentifier];
		NSCAssert(reuseIdentifier, @"Cell's reuseIdentifier must be set");

		if (ZDBD_NotNilOrEmpty(cellNibName) && ![self.mutSetNibNameForCell containsObject:cellNibName]) {
            NSString *nibPath = [[NSBundle mainBundle] pathForResource:cellNibName ofType:@"nib"];
			if (nibPath) {
                // create an instance of the template cell and register with the table view
                // UITableViewCell *templateCell = [[nib instantiateWithOwner:nil options:nil] firstObject];
                UINib *cellNib = [UINib nibWithNibName:cellNibName bundle:nil];
				[self.tableView registerNib:cellNib forCellReuseIdentifier:reuseIdentifier ?: cellNibName];
				[self.mutSetNibNameForCell addObject:cellNibName];
			}
		}
		else if (ZDBD_NotNilOrEmpty(cellClassName) && ![self.mutSetClassNameForCell containsObject:cellClassName]) {
			// 通过类名注册Cell
			[self.tableView registerClass:NSClassFromString(cellClassName) forCellReuseIdentifier:reuseIdentifier ?: cellClassName];
			[self.mutSetClassNameForCell addObject:cellClassName];
		}
	}
}

- (void)registerNibForTableViewWithSectionViewModel:(ZDHeaderFooterViewModel)sectionViewModel
{
    if (!sectionViewModel) return;
    if (![sectionViewModel conformsToProtocol:@protocol(ZDHeaderFooterViewModelProtocol)]) {
        NSCAssert(NO, @"sectionViewModel need conform ZDHeaderFooterViewModelProtocol");
        return;
    }
    
	// register header && footer (only to mutableSection)
	NSString *sectionNibName = [sectionViewModel zd_headerFooterNibName];
	NSString *sectionClassName = [sectionViewModel zd_headerFooterClassName];
	NSString *sectionReuseIdentifier = [sectionViewModel zd_headerFooterReuseIdentifier];

	NSCAssert(sectionReuseIdentifier, @"SectionView's reuseIdentifier must be set");

	if (ZDBD_NotNilOrEmpty(sectionNibName) && ![self.mutSetNibNameForSection containsObject:sectionNibName]) {
        NSString *nibPath = [[NSBundle mainBundle] pathForResource:sectionNibName ofType:@"nib"];
		if (nibPath) {
            UINib *sectionNib = [UINib nibWithNibName:sectionNibName bundle:nil];
			[self.tableView registerNib:sectionNib forHeaderFooterViewReuseIdentifier:sectionReuseIdentifier ?: sectionNibName];
			[self.mutSetNibNameForSection addObject:sectionNibName];
		}
	}
	else if (ZDBD_NotNilOrEmpty(sectionClassName) && ![self.mutSetClassNameForSection containsObject:sectionClassName]) {
		// 通过类名注册Section
		[self.tableView registerClass:NSClassFromString(sectionClassName) forHeaderFooterViewReuseIdentifier:sectionReuseIdentifier ?: sectionClassName];
		[self.mutSetClassNameForSection addObject:sectionClassName];
	}
}

/// muti Section
- (void)registerNibForTableViewWithSectionCellViewModels:(__kindof NSArray<NSDictionary *> *)sectionCellModels
{
    if (!self.isMultiSection) return;
        
	for (NSDictionary *sectionCellDataDic in sectionCellModels) {
        ZDHeaderFooterViewModel headerViewModel = sectionCellDataDic[HeaderViewModelKey];
        NSArray *cellViewModels = sectionCellDataDic[CellViewModelKey];
        ZDHeaderFooterViewModel footerViewModel = sectionCellDataDic[FooterViewModelKey];
        
        [self registerNibForTableViewWithCellViewModels:cellViewModels];
        
        if (headerViewModel) {
            [self registerNibForTableViewWithSectionViewModel:headerViewModel];
        }
        
        if (footerViewModel) {
            [self registerNibForTableViewWithSectionViewModel:footerViewModel];
        }
	}
}

- (void)reloadRowsNoAnimationAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (indexPaths.count == 0) return;
    
    ZD_BATCH_UPDATE(self.tableView, [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];)
}

#pragma mark - Setters
- (void)setDelegate:(nullable id<UITableViewDelegate>)delegate
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
        newMethodCaching.estimatedHeightForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)];
        newMethodCaching.indentationLevelForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:indentationLevelForRowAtIndexPath:)];
        newMethodCaching.willDisplayCellForRowAtIndexPath = [delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)];
        
        //Managing Accessory Views
        newMethodCaching.editActionsForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)];
        newMethodCaching.accessoryButtonTappedForRowWithIndexPath = [_delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)];
        
        //Managing Selections
        newMethodCaching.willSelectRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)];
        newMethodCaching.didSelectRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)];
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

- (NSMutableArray<ZDCellViewModel> *)cellViewModels
{
    if (!_cellViewModels) {
        _cellViewModels = [[NSMutableArray alloc] init];
    }
    return _cellViewModels;
}

- (NSMutableSet<NSString *> *)mutSetNibNameForCell
{
	if (!_mutSetNibNameForCell) {
		_mutSetNibNameForCell = [[NSMutableSet alloc] init];
	}
	return _mutSetNibNameForCell;
}

- (NSMutableSet<NSString *> *)mutSetClassNameForCell
{
	if (!_mutSetClassNameForCell) {
		_mutSetClassNameForCell = [[NSMutableSet alloc] init];
	}
	return _mutSetClassNameForCell;
}

- (NSMutableSet<NSString *> *)mutSetNibNameForSection
{
	if (!_mutSetNibNameForSection) {
		_mutSetNibNameForSection = [[NSMutableSet alloc] init];
	}
	return _mutSetNibNameForSection;
}

- (NSMutableSet<NSString *> *)mutSetClassNameForSection
{
	if (!_mutSetClassNameForSection) {
		_mutSetClassNameForSection = [[NSMutableSet alloc] init];
	}
	return _mutSetClassNameForSection;
}

- (NSMutableDictionary<NSIndexPath *, id> *)prefetchDict
{
    if (!_prefetchDict) {
        _prefetchDict = [[NSMutableDictionary alloc] init];
    }
    return _prefetchDict;
}

@end

//****************************************************************

@implementation NSObject (Cast)

+ (nullable instancetype)zdbd_cast:(id)objc
{
    if (!objc) return nil;
	if ([objc isKindOfClass:[self class]]) {
		return objc;
	}
	return nil;
}

@end

NS_ASSUME_NONNULL_END
