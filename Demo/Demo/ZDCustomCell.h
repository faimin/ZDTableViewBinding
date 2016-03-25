//
//  ZDCustomCell.h
//  Demo
//
//  Created by 符现超 on 16/3/9.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDBaseTableViewCell.h"

@interface ZDCustomCell : ZDBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *articleCount;
@property (weak, nonatomic) IBOutlet UILabel *articleBrief;
@property (weak, nonatomic) IBOutlet UILabel *barID;
@property (weak, nonatomic) IBOutlet UILabel *barName;
@property (weak, nonatomic) IBOutlet UILabel *recommendReason;
@property (weak, nonatomic) IBOutlet UIImageView *barImage;

@end
