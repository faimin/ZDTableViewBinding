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

#ifndef ZD_INCLUEDE_FD
#define ZD_INCLUEDE_FD (__has_include(<UITableView+FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>))
#endif

#ifndef ZD_BATCH_UPDATE
#define ZD_BATCH_UPDATE(tableView, stuff)           \
do {                                                \
    if (@available(iOS 11.0, *)) {                  \
        [self.tableView performBatchUpdates:^{      \
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


static NSString * const HeaderViewModelKey = @"HeaderViewModelKey";
static NSString * const CellViewModelKey   = @"CellViewModelKey";
static NSString * const FooterViewModelKey = @"FooterViewModelKey";

#define ZDCellDictionary(_cellViewModels) ZDSectionCellDictionary(nil, _cellViewModels, nil)

#define ZDSectionCellDictionary(_headerViewModel, _cellViewModels, _footerViewModel)                           \
[NSDictionary dictionaryWithObjectsAndKeys:(_headerViewModel ?: [NSNull null]) , HeaderViewModelKey,           \
                                                               _cellViewModels , CellViewModelKey,             \
                                           (_footerViewModel ?: [NSNull null]) , FooterViewModelKey, nil]

NS_INLINE BOOL ZDNotNilOrEmpty(id _objc) {
    if (_objc == nil || _objc == NULL) {
        return NO;
    }
    
    if ([_objc isKindOfClass:[NSNull class]]) {
        return NO;
    }
    
    if ([_objc isKindOfClass:[NSString class]]) {
        if ([[_objc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
            return NO;
        }
    }
    
    return YES;
}

NS_INLINE void ZDDispatch_async_on_main_queue(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

#endif /* ZDBindingDefine_h */
