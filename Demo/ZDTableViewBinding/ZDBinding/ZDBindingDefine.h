//
//  ZDBindingDefine.h
//  Demo
//
//  Created by 符现超 on 16/3/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifndef ZDBindingDefine_h
#define ZDBindingDefine_h

#define HeaderViewModelKey @"HeaderViewModelKey"
#define CellViewModelKey   @"CellViewModelKey"
#define FooterViewModelKey @"FooterViewModelKey"

#define ZDSectionCellDictionary(_headerViewModel, _cellViewModels, _footerViewModel)                           \
[NSDictionary dictionaryWithObjectsAndKeys:(_headerViewModel ?: [NSNull null]) , HeaderViewModelKey,           \
                                                               _cellViewModels , CellViewModelKey,             \
                                           (_footerViewModel ?: [NSNull null]) , FooterViewModelKey, nil]

static inline BOOL ZDNotNilOrEmpty(id _objc)
{
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

#endif /* ZDBindingDefine_h */
