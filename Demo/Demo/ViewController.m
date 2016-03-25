//
//  ViewController.m
//  Demo
//
//  Created by 符现超 on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ViewController.h"
#import "ZDTableViewBindingHelper.h"
#import "ZDCellViewModel.h"
#import "ZDSectionViewModel.h"
#import "ZDBindingDefine.h"
#import "MJExtension.h"
#import "ZDModel.h"
#import "ZDCustomCell.h"
#import "ZDHeaderView.h"
#import "ZDFooterView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) ZDTableViewBindingHelper *helper;
@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self requestData];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)requestData
{
    NSString *urlStr = @"http://e.dangdang.com/media/api2.go?action=squareV2&channelId=10020&clientOs=iPhone%20OS8.3&clientVersionNo=5.4.0&deviceSerialNo=1CCA512B-2BBD-428A-8211-DA6423266C82&deviceType=iphone&fromPlatform=101&macAddr=020000000000&moduleLocation=square&orderSource=30000&permanentId=20151223121712403116807875249950073&platform=2&platformSource=DDDS-P&resolution=750x1334&returnType=json&serverVersionNo=1.0&token=51a99d375890c6b1c8efc27f46fc0985";
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSError *zderror;
            NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&zderror];
            NSMutableArray *mutArr = [ZDModel mj_objectArrayWithKeyValuesArray:obj[@"data"][@"squareInfo"]];
            
            NSMutableArray *sectionCellViewModels = [NSMutableArray array];
            for (ZDModel *zdModel in mutArr) {
                NSMutableArray *cellViewModels = [NSMutableArray array];
                for (id model in zdModel.barContent) {
                    if ([model isKindOfClass:[Barcontent class]]) {
                        ZDCellViewModel *viewModel = [ZDCellViewModel new];
                        viewModel.zd_model = model;
                        viewModel.zd_reuseIdentifier = NSStringFromClass([ZDCustomCell class]);
                        viewModel.zd_estimatedHeight = 460;
                        [cellViewModels addObject:viewModel];
                    }
                }
                ZDSectionViewModel *sectionViewModel = [ZDSectionViewModel new];
                NSString *headerName = NSStringFromClass([ZDHeaderView class]);
                sectionViewModel.zd_sectionReuseIdentifier = headerName;
                sectionViewModel.zd_sectionNibName = headerName;
                sectionViewModel.zd_sectionModel = zdModel.module;
                sectionViewModel.zd_estimatedSectionHeight = 100;
                
                
                ZDSectionViewModel *footerViewModel = [ZDSectionViewModel new];
                NSString *footerName = NSStringFromClass([ZDFooterView class]);
                footerViewModel.zd_sectionReuseIdentifier = footerName;
                footerViewModel.zd_sectionNibName = footerName;
                footerViewModel.zd_sectionModel = zdModel.module;
                footerViewModel.zd_estimatedSectionHeight = 60;
                
                NSDictionary *sectionDic = ZDSectionCellDictionary(sectionViewModel, cellViewModels, footerViewModel);
                [sectionCellViewModels addObject:sectionDic];
            }
            self.models = sectionCellViewModels;
        }
    }];
    [dataTask resume];

    
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *input) {
        ZDCellViewModel *viewModel = input.second;
        NSLog(@"\n 点击的cell的高度 = %lf", viewModel.zd_height);
        return [RACSignal empty];
    }];
    
    RACCommand *sectionCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *input) {
        NSLog(@"\n 按钮被点击了: %@", input.second);
        return [RACSignal empty];
    }];
    
    // 不要忘记让当前类持有helper，否则，出了当前作用域就会被释放
    self.helper = [ZDTableViewBindingHelper bindingHelperForTableView:self.tableView
                                                       mutableSection:YES
                                                         sourceSignal:RACObserve(self, models)
                                                          cellCommand:command
                                                       sectionCommand:sectionCommand];
    
    
}

@end



















