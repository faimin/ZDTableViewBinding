//
//  ZDTableViewBindingHelper.m
//  Demo
//
//  Created by 符现超 on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDTableViewBindingHelper.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ZDCellViewModel.h"

@interface ZDTableViewBindingHelper ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, readwrite, assign) struct delegateMethodsCaching {
// UITableViewDelegate
//Configuring Rows for the Table View
uint heightForRowAtIndexPath:1;
uint estimatedHeightForRowAtIndexPath:1;
uint indentationLevelForRowAtIndexPath:1;
uint willDisplayCellForRowAtIndexPath:1;

//Managing Accessory Views
uint editActionsForRowAtIndexPath:1;
uint accessoryButtonTappedForRowWithIndexPath:1;

//Managing Selections
uint willSelectRowAtIndexPath:1;
uint didSelectRowAtIndexPath:1;
uint willDeselectRowAtIndexPath:1;
uint didDeselectRowAtIndexPath:1;

//Modifying the Header and Footer of Sections
uint viewForHeaderInSection:1;
uint viewForFooterInSection:1;
uint heightForHeaderInSection:1;
uint estimatedHeightForHeaderInSection:1;
uint heightForFooterInSection:1;
uint estimatedHeightForFooterInSection:1;
uint willDisplayHeaderViewForSection:1;
uint willDisplayFooterViewForSection:1;

//Editing Table Rows
uint willBeginEditingRowAtIndexPath:1;
uint didEndEditingRowAtIndexPath:1;
uint editingStyleForRowAtIndexPath:1;
uint titleForDeleteConfirmationButtonForRowAtIndexPath:1;
uint shouldIndentWhileEditingRowAtIndexPath:1;

//Reordering Table Rows
uint targetIndexPathForMoveFromRowAtIndexPathToProposedIndexPath:1;

//Tracking the Removal of Views
uint didEndDisplayingCellForRowAtIndexPath:1;
uint didEndDisplayingHeaderViewForSection:1;
uint didEndDisplayingFooterViewForSection:1;

//Copying and Pasting Row Content
uint shouldShowMenuForRowAtIndexPath:1;
uint canPerformActionForRowAtIndexPathWithSender:1;
uint performActionForRowAtIndexPathWithSender:1;

//Managing Table View Highlighting
uint shouldHighlightRowAtIndexPath:1;
uint didHighlightRowAtIndexPath:1;
uint didUnhighlightRowAtIndexPath:1;


// UIScrollViewDelegate
//Responding to Scrolling and Dragging
uint scrollViewDidScroll:1;
uint scrollViewWillBeginDragging:1;
uint scrollViewWillEndDraggingWithVelocityTargetContentOffset:1;
uint scrollViewDidEndDraggingWillDecelerate:1;
uint scrollViewShouldScrollToTop:1;
uint scrollViewDidScrollToTop:1;
uint scrollViewWillBeginDecelerating:1;
uint scrollViewDidEndDecelerating:1;

//Managing Zooming
uint viewForZoomingInScrollView:1;
uint scrollViewWillBeginZoomingWithView:1;
uint scrollViewDidEndZoomingWithViewAtScale:1;
uint scrollViewDidZoom:1;

//Responding to Scrolling Animations
uint scrollViewDidEndScrollingAnimation:1;
} delegateRespondsTo;
/// 外面的command是临时变量，所以需要helper持有
@property (nonatomic, strong) RACCommand *command;
@property (nonatomic, strong) NSMutableArray *cellViewModels;
@property (nonatomic, strong) NSMutableSet *mutSetForCell;
@property (nonatomic, assign) BOOL isMutSection;

@end

@implementation ZDTableViewBindingHelper

- (void)dealloc
{
    NSLog(@"\n【类名：%s】【行数：%d】", __PRETTY_FUNCTION__, __LINE__);
}

+ (instancetype)bindingHelperForTableView:(UITableView *)tableView
                           mutableSection:(BOOL)mutableSection
                             sourceSignal:(RACSignal *)sourceSignal
                         selectionCommand:(RACCommand *)selectCommand;
{
    return [[self alloc] initWithTableView:tableView
                            mutableSection:(BOOL)mutableSection
                              sourceSignal:sourceSignal
                          selectionCommand:selectCommand];
}

- (instancetype)initWithTableView:(UITableView *)tableView
                   mutableSection:(BOOL)mutableSection
                     sourceSignal:(RACSignal *)sourceSignal
                 selectionCommand:(RACCommand *)selectCommand
{
    if (self = [super init]) {
        self.tableView = tableView;
        self.command = selectCommand;
        
        @weakify(self);
        [[sourceSignal ignore:nil] subscribeNext:^(__kindof NSArray<ZDCellViewModel*> *x) {
            @strongify(self);
            ///是否有section
            NSAssert([self dataIsMutDimensionalArray:x] == mutableSection, @"请检查所传数据是不是多section类型");
            self.isMutSection = mutableSection;
            ///注册cell
            [self registerNibForTableViewWithCellViewModels:x];
            self.cellViewModels = x;
            
            // reloadData on mainQueue
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
            else {
                [self.tableView reloadData];
            }
        }];
        
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.delegate = nil;
    }
    return self;
}

#pragma mark - Setters
- (void)setDelegate:(id<UITableViewDelegate>)delegate
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
        //newMethodCaching.heightForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)];
        //newMethodCaching.estimatedHeightForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)];
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
        newMethodCaching.viewForHeaderInSection = [_delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)];
        newMethodCaching.viewForFooterInSection = [_delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)];
        newMethodCaching.heightForHeaderInSection = [_delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)];
        newMethodCaching.estimatedHeightForHeaderInSection = [_delegate respondsToSelector:@selector(tableView:estimatedHeightForHeaderInSection:)];
        newMethodCaching.heightForFooterInSection = [_delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)];
        newMethodCaching.estimatedHeightForFooterInSection = [_delegate respondsToSelector:@selector(tableView:estimatedHeightForFooterInSection:)];
        newMethodCaching.willDisplayHeaderViewForSection = [_delegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)];
        newMethodCaching.willDisplayFooterViewForSection = [_delegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)];
        
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

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isMutSection) {
        return self.cellViewModels.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellViewModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<ZDCellViewModelProtocol> cellViewModel = [self viewModelAtIndexPath:indexPath];
    id<ZDCellProtocol> cell = [tableView dequeueReusableCellWithIdentifier:[cellViewModel zd_reuseIdentifier] forIndexPath:indexPath];
    NSAssert(cell != nil, @"Cell can not be nil");
    
    if ([cell respondsToSelector:@selector(setSelectionCommand:)]) {
        cell.selectionCommand = self.command;
    }
    if ([cell respondsToSelector:@selector(setModel:)]) {
        cell.model = cellViewModel.zd_model;
    }
    if ([cell respondsToSelector:@selector(setViewModel:)]) {
        cell.viewModel = cellViewModel;
    }
    if ([cell respondsToSelector:@selector(setHeight:)]) {
        cell.height = cellViewModel.zd_height;
    }
    
    /// cell遵循的数据协议
    [cell bindToViewModel:cellViewModel];
        
    return (__kindof UITableViewCell *)cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([self.cellViewModels isKindOfClass:[NSArray class]]) {
            [self.cellViewModels removeObjectAtIndex:indexPath.row];
        }
    }
}

#pragma mark - UITableViewDelegate methods
#pragma mark Configuring Rows for the Table View
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = tableView.rowHeight;
    
    id<ZDCellViewModelProtocol> cellViewModel = [self viewModelAtIndexPath:indexPath];
    NSString *identifier = [cellViewModel zd_reuseIdentifier];
    
    cellHeight = [tableView fd_heightForCellWithIdentifier:identifier cacheByIndexPath:indexPath configuration:^(__kindof UITableViewCell<ZDCellProtocol> *cell) {
        if ([cell respondsToSelector:@selector(setModel:)]) {
            cell.model = [cellViewModel zd_model];
        }
    }];

    [cellViewModel setZd_height:cellHeight];

    return cellHeight;
}

// MARK: ----> estimatedHeightForRowAtIndexPath
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat estimatedHeightForRowAtIndexPath = tableView.estimatedRowHeight;
    
    id<ZDCellViewModelProtocol> cellViewModel = [self viewModelAtIndexPath:indexPath];
    estimatedHeightForRowAtIndexPath = [cellViewModel zd_estimatedHeight];

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
    if (self.delegateRespondsTo.willDisplayCellForRowAtIndexPath == 1) {
        [self.delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

#pragma mark Managing Accessory Views
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
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
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *willSelectRowAtIndexPath = indexPath;
    
    if (_delegateRespondsTo.willSelectRowAtIndexPath == 1) {
        willSelectRowAtIndexPath = [self.delegate tableView:tableView willSelectRowAtIndexPath:indexPath];
    }
    return willSelectRowAtIndexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell<ZDCellProtocol> *cell = [tableView cellForRowAtIndexPath:indexPath];
    // execute the command
    if ([cell respondsToSelector:@selector(selectionCommand)]) {
        /// RACTuplePack(cell, viewModel, event)
        /// 这里的-1默认代表的是点击的cell本身
        [cell.selectionCommand execute:[RACTuple tupleWithObjects:cell, [self viewModelAtIndexPath:indexPath], @(-1), nil]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
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
//TODO: sectionHeaderView
#pragma mark Modifying the Header and Footer of Sections
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *viewForHeaderInSection = nil;
    
    if (_delegateRespondsTo.viewForHeaderInSection == 1) {
        viewForHeaderInSection = [self.delegate tableView:tableView viewForHeaderInSection:section];
    }
    return viewForHeaderInSection;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *viewForFooterInSection = nil;
    
    if (_delegateRespondsTo.viewForFooterInSection == 1) {
        viewForFooterInSection = [self.delegate tableView:tableView viewForFooterInSection:section];
    }
    return viewForFooterInSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat heightForHeaderInSection = 0.0f;
    
    if (_delegateRespondsTo.heightForHeaderInSection == 1) {
        heightForHeaderInSection = [self.delegate tableView:tableView heightForHeaderInSection:section];
    }
    return heightForHeaderInSection;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    CGFloat estimatedHeightForHeaderInSection = 0.0f;
    
    if (_delegateRespondsTo.estimatedHeightForHeaderInSection == 1) {
        estimatedHeightForHeaderInSection = [self.delegate tableView:tableView estimatedHeightForHeaderInSection:section];
    }
    return estimatedHeightForHeaderInSection;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat heightForFooterInSection = 0.0f;
    
    if (_delegateRespondsTo.heightForFooterInSection == 1) {
        heightForFooterInSection = [self.delegate tableView:tableView heightForFooterInSection:section];
    }
    return heightForFooterInSection;
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    CGFloat estimatedHeightForFooterInSection = 0.0f;
    
    if (_delegateRespondsTo.estimatedHeightForFooterInSection == 1) {
        estimatedHeightForFooterInSection = [self.delegate tableView:tableView estimatedHeightForFooterInSection:section];
    }
    return estimatedHeightForFooterInSection;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (_delegateRespondsTo.willDisplayHeaderViewForSection == 1) {
        [self.delegate tableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    if (_delegateRespondsTo.willDisplayFooterViewForSection == 1) {
        [self.delegate tableView:tableView willDisplayFooterView:view forSection:section];
    }
}

#pragma mark Editing Table Rows
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegateRespondsTo.willBeginEditingRowAtIndexPath == 1) {
        [self.delegate tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
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

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
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

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    BOOL canPerformAction  = NO;
    
    if (_delegateRespondsTo.canPerformActionForRowAtIndexPathWithSender == 1) {
        canPerformAction = [self.delegate tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
    return canPerformAction;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
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
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    UIView *viewForZoomingInScrollView = nil;
    
    if (_delegateRespondsTo.viewForZoomingInScrollView) {
        viewForZoomingInScrollView = [self.delegate viewForZoomingInScrollView:scrollView];
    }
    return  viewForZoomingInScrollView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if (_delegateRespondsTo.scrollViewWillBeginZoomingWithView) {
        [self.delegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
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

- (void)insertViewModel:(id<ZDCellViewModelProtocol>)viewModel atIndexPath:(NSIndexPath*)indexPath
{
    if (!indexPath || !viewModel) {
        return;
    }
    [self registerNibForTableViewWithCellViewModels:@[viewModel]];
    [self.cellViewModels insertObject:viewModel atIndex:indexPath.row];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)replaceViewModel:(id<ZDCellViewModelProtocol>)viewModel atIndexPath:(NSIndexPath*)indexPath
{
    if (!indexPath || !viewModel) {
        return;
    }
    [self registerNibForTableViewWithCellViewModels:@[viewModel]];
    [self.cellViewModels replaceObjectAtIndex:indexPath.row withObject:viewModel];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)deleteViewModelAtIndexPath:(NSIndexPath*)indexPath
{
    if (!indexPath) {
        return;
    }
    [self.cellViewModels removeObjectAtIndex:indexPath.row];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView beginUpdates];
}

- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (indexPaths.count == 0) {
        return;
    }
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

#pragma mark - Private Method
//TODO: 注册cell和sectionView
- (void)registerNibForTableViewWithCellViewModels:(NSArray<ZDCellViewModel*> *)cellViewModels
{
    NSAssert(cellViewModels, @"CellViewModels cann't be nil");
    /// storyBoard里的cell不需要手动注册，只需要设置reuseIdentifier
    for (id<ZDCellViewModelProtocol>cellViewModel in cellViewModels) {
        NSString *nibName = [cellViewModel zd_nibName];
        NSString *reuseIdentifier = [cellViewModel zd_reuseIdentifier];
        
        NSAssert(reuseIdentifier, @"Cell重用标识符必须设置");
        if (nibName && ![self.mutSetForCell containsObject:nibName]) {
            UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
            // create an instance of the template cell and register with the table view
            //UITableViewCell *templateCell = [[nib instantiateWithOwner:nil options:nil] firstObject];
            if (nib) {
                [self.tableView registerNib:nib forCellReuseIdentifier:reuseIdentifier ?: nibName];
                [self.mutSetForCell addObject:nibName];
            }
        }
        else if (0) {
            // TODO: 通过类名注册Cell
        }
    }
}

- (id)viewModelAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    if (index < 0) {
        return nil;
    }
    
    if (index >= self.cellViewModels.count) {
        return nil;
    }
    else {
        return [self.cellViewModels objectAtIndex:index];
    }
}

/// 判断是否是二维数组
- (BOOL)dataIsMutDimensionalArray:(__kindof NSArray *)data
{
    if ([data.firstObject isKindOfClass:[NSArray class]]) {
        return YES;
    }
    return NO;
}

#pragma mark - Getter

- (NSMutableSet *)mutSetForCell
{
    if (!_mutSetForCell) {
        _mutSetForCell = [[NSMutableSet alloc] init];
    }
    return _mutSetForCell;
}

@end


