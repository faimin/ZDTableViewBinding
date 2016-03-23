//
//  ZDSectionProtocol.h
//  Demo
//
//  Created by 符现超 on 16/3/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZDSectionViewModel;

@protocol ZDSectionProtocol <NSObject>

- (void)bindToSectionViewModel:(ZDSectionViewModel *)viewModel;

@end
