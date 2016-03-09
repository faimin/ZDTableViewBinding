//
//  ZDModel.h
//  Demo
//
//  Created by 符现超 on 16/3/9.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Module,Barcontent;
@interface ZDModel : NSObject

@property (nonatomic, strong) NSArray<Barcontent *> *barContent;

@property (nonatomic, strong) Module *module;

@end



@interface Module : NSObject

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, assign) NSInteger showNum;

@property (nonatomic, copy) NSString *moduleName;

@property (nonatomic, assign) NSInteger barModuleId;

@property (nonatomic, assign) NSInteger templateNo;

@end



@interface Barcontent : NSObject

@property (nonatomic, copy) NSString *barImgUrl;

@property (nonatomic, assign) NSInteger isActivity;

@property (nonatomic, copy) NSString *articleNum;

@property (nonatomic, copy) NSString *barDesc;

@property (nonatomic, copy) NSString *barName;

@property (nonatomic, copy) NSString *memberNum;

@property (nonatomic, assign) NSInteger barId;

@property (nonatomic, copy  ) NSString *recommendReason;

@end

