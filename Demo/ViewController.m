//
//  ViewController.m
//  Demo
//
//  Created by 符现超 on 16/3/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ViewController.h"
#import "ZDTableViewBindingHelper.h"
#import "ZDAFNetWorkHelper.h"
#import "MJExtension.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *models;
@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
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
    [[ZDAFNetWorkHelper shareInstance] requestWithURL:urlStr params:nil httpMethod:HttpMethod_GET success:^(id  _Nullable responseObject) {
        // TODO:
        //NSArray *arr = [responseObject mj_keyValues];
        NSLog(@"%@", responseObject);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
    
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        // TODO:
        
        return [RACSignal empty];
    }];
    [ZDTableViewBindingHelper bindingHelperForTableView:self.tableView
                                        estimatedHeight:44
                                           sourceSignal:RACObserve(self, models)
                                       selectionCommand:command];
    
    
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    [session dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (!error) {
//            NSError *zderror;
//            id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&zderror];
//            NSLog(@"%@", obj);
//        }
//    }];
}

@end
