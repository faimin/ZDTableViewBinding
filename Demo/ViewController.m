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
#import "MJExtension.h"
#import "ZDModel.h"
#import "ZDCustomCell.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *models;
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
            
            NSMutableArray *viewModels = [NSMutableArray array];
            for (ZDModel *zdModel in mutArr) {
                for (id model in zdModel.barContent) {
                    if ([model isKindOfClass:[Barcontent class]]) {
                        ZDCellViewModel *viewModel = [ZDCellViewModel new];
                        viewModel.model = model;
                        viewModel.zd_reuseIdentifier = NSStringFromClass([ZDCustomCell class]);
                        //viewModel.zd_nibName = NSStringFromClass([ZDCustomCell class]);
                        [viewModels addObject:viewModel];
                    }
                }
            }
            self.models = viewModels;
            NSLog(@"\n\n\n%@", mutArr);
        }
    }];
    [dataTask resume];

    
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        // TODO:
        NSLog(@"\n%@", input);
        return [RACSignal empty];
    }];
    [ZDTableViewBindingHelper bindingHelperForTableView:self.tableView
                                        estimatedHeight:44
                                           sourceSignal:RACObserve(self, models)
                                       selectionCommand:command];
    
    
}

@end




















