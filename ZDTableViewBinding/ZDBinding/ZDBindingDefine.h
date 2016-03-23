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

#define ZDSectionCellDictionary(_headerViewModel, _cellViewModels, _footerViewModel)    \
[NSDictionary dictionaryWithObjectsAndKeys:HeaderViewModelKey : _headerViewModel,       \
                         CellViewModelKey : _cellViewModels,                            \
                       FooterViewModelKey : _footerViewModel, nil]

#define ZDNotNilOrEmpty(_objc) (_objc && ![_objc isKindOfClass:[NSNull class]])

#endif /* ZDBindingDefine_h */
