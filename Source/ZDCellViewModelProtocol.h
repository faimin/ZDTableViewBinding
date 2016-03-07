//
//  ZDCellViewModelProtocol.h
//  Demo
//
//  Created by 符现超 on 16/3/7.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZDCellViewModelProtocol <NSObject>

- (NSString *)zd_reuseIdentifier;
- (NSString *)zd_nibName;

- (id)model;

- (CGFloat)height;

//@property (nonatomic, copy  ) NSString *reuseIdentifier;
//@property (nonatomic, copy  ) NSString *nibName;
//@property (nonatomic, strong) id model;

@end
