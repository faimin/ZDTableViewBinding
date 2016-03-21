//
//  ZDBaseHeaderFooterView.h
//  Demo
//
//  Created by 符现超 on 16/3/21.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZDBaseHeaderFooterView : UITableViewHeaderFooterView

@property (nonatomic, strong) id sectionModel;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;

@end
