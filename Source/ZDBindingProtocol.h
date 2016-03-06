//
//  ZDViewBindingProtocol.h
//  Demo
//
//  Created by 符现超 on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZDBindingProtocol <NSObject>

/// Binds the given view model to the view
- (void)bindViewModel:(id)viewModel;

@end
