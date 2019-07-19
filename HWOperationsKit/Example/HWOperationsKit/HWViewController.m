//
//  HWViewController.m
//  HWOperationsKit
//
//  Created by wangcongling on 07/17/2019.
//  Copyright (c) 2019 wangcongling. All rights reserved.
//

#import "HWViewController.h"
#import <HWOperationsKit/HWOperationsKit.h>
#import "HWCountOperation.h"

@interface HWViewController ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, assign) NSInteger queueTag;

@end

@implementation HWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorWithRed:0.000 green:0.200 blue:0.800 alpha:1.00];
    [button setTitle:@"测试" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 6;
    [button addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    self.button = button;
    
    self.queueTag = 0;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGSize size = CGSizeMake(100, 60);
    CGRect rect = self.view.bounds;
    self.button.frame = CGRectMake((CGRectGetWidth(rect) - size.width) / 2, (CGRectGetHeight(rect) - size.height) / 2, size.width, size.height);
}

- (void)testAction {
//    [self testNormalAddChainOP];
    [self testChainOperation];
//    [self testGroupOperation];
}

- (void)testNormalAddChainOP {

    [[HWOperationQueue globalQueue] cancelAllOperations];
    
    self.queueTag ++;
    NSMutableArray *opList = [NSMutableArray array];
    for (int i = 1; i < 11; i ++) {
        HWCountOperation *op = [HWCountOperation new];
        op.value = i;
        op.identifier = [NSString stringWithFormat:@"#%ld-%ld号", (long)self.queueTag, (long) i];
        [opList addObject:op];
    }
    
    [HWOperation chainOperations:opList];
    
    [[HWOperationQueue globalQueue] addOperations:opList waitUntilFinished:NO];
    
}

- (void)testChainOperation {
    self.queueTag ++;
    NSMutableArray *opList = [NSMutableArray array];
    for (int i = 1; i < 11; i ++) {
        HWCountOperation *op = [HWCountOperation new];
        op.value = i;
        op.identifier = [NSString stringWithFormat:@"#%ld-%ld号", (long)self.queueTag, (long) i];
        [opList addObject:op];
    }

    HWChainOperation *chainOperation = [[HWChainOperation alloc] initWithOperations:opList];
    chainOperation.finishIfProducedAnyError = YES;

    [chainOperation hw_addCompletionBlockInMainQueue:^(__kindof NSOperation * _Nonnull operation) {
        NSLog(@"all chain ops done.");
    }];
        
    [chainOperation runInGlobalQueue];
    
}

-  (void)testGroupOperation {
    self.queueTag ++;
    NSMutableArray *opList = [NSMutableArray array];
    for (int i = 1; i < 11; i ++) {
        HWCountOperation *op = [HWCountOperation new];
        op.value = i;
        op.identifier = [NSString stringWithFormat:@"#%ld-%ld号", (long)self.queueTag, (long) i];
        [opList addObject:op];
    }
    HWGroupOperation *groupOperation = [[HWGroupOperation alloc] initWithOperations:opList];
    [groupOperation hw_addCancelBlockInMainQueue:^(__kindof NSOperation *operation) {
        NSLog(@"all group op done.");
    }];
    [groupOperation runInGlobalQueue];
}

@end
