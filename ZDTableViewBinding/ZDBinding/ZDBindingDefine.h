//
//  ZDBindingDefine.h
//  Demo
//
//  Created by Zero on 16/3/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifndef ZDBindingDefine_h
#define ZDBindingDefine_h

#if (DEBUG && 1)
#define ZDBDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define ZDBDLog(...)
#endif

#ifndef ZD_INCLUDE_FD
#define ZD_INCLUDE_FD (__has_include(<UITableView+FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>) || __has_include("UITableView+FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h"))
#endif

#ifndef ZD_BATCH_UPDATE
#define ZD_BATCH_UPDATE(tableView, stuff)           \
do {                                                \
    if (@available(iOS 11.0, *)) {                  \
        [tableView performBatchUpdates:^{           \
            stuff;                                  \
        } completion:^(BOOL finished) {             \
                                                    \
        }];                                         \
    } else {                                        \
        [tableView beginUpdates];                   \
        stuff;                                      \
        [tableView endUpdates];                     \
    }                                               \
} while (0);
#endif

#define ZDSectionCellDictionary(_headerViewModel, _cellViewModels, _footerViewModel)    \
({                                                                                      \
    NSMutableDictionary *sectionAndCellDict = @{}.mutableCopy;                          \
    sectionAndCellDict[HeaderViewModelKey] = _headerViewModel;                          \
    sectionAndCellDict[CellViewModelKey] = _cellViewModels;                             \
    sectionAndCellDict[FooterViewModelKey] = _footerViewModel;                          \
    sectionAndCellDict;                                                                 \
})

#define ZDSynthesizeCellProperty                                                        \
@synthesize model = _model, viewModel = _viewModel, cellCommand = _cellCommand, height = _height, indexPath = _indexPath, bindProxy = _bindProxy;

#define ZDSynthesizeHeaderFooterProperty                                                \
@synthesize headerFooterViewModel = _headerFooterViewModel, headerFooterModel = _headerFooterModel, headerFooterCommand = _headerFooterCommand, headerFooterHeight = _headerFooterHeight, headerFooterBindProxy = _headerFooterBindProxy;

static NSString * const HeaderViewModelKey = @"HeaderViewModelKey";
static NSString * const CellViewModelKey   = @"CellViewModelKey";
static NSString * const FooterViewModelKey = @"FooterViewModelKey";

NS_INLINE BOOL ZDBD_NotNilOrEmpty(NSString *_objc) {
    if (_objc == nil || _objc == NULL) {
        return NO;
    }
    
    if ([_objc isKindOfClass:[NSString class]] &&
        [[_objc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
        return YES;
    }
    
    return NO;
}

NS_INLINE void ZDBD_Dispatch_async_on_main_queue(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

NS_INLINE NSMutableArray *ZDBD_MutableArray(__kindof NSArray *array) {
    if (!array || ![array isKindOfClass:[NSArray class]]) return nil;
    
    if ([array isKindOfClass:[NSMutableArray class]]) {
        return array;
    }
    else {
        return [NSMutableArray arrayWithArray:array];
    }
}

NS_INLINE NSMutableDictionary *ZDBD_MutableDictionary(__kindof NSDictionary *dict) {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    if ([dict isKindOfClass:[NSMutableDictionary class]]) {
        return dict;
    }
    else {
        return [NSMutableDictionary dictionaryWithDictionary:dict];
    }
}

#endif /* ZDBindingDefine_h */
