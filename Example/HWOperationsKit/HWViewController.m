//
//  HWViewController.m
//  HWOperationsKit
//
//  Created by heathwang on 07/17/2019.
//  Copyright (c) 2019 heathwang. All rights reserved.
//

#import "HWViewController.h"
#import <HWOperationsKit/HWOperationsKit.h>
#import "HWCountOperation.h"
#import "HWCountCondition.h"

@interface HWViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) NSInteger queueTag;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *testActions;

@end

@implementation HWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.tableView];
    self.queueTag = 0;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect rect = self.view.bounds;
    self.tableView.frame = rect;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testActions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
    cell.textLabel.text = self.testActions[indexPath.row];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0: {
            [self testDefaultOperationUseage];
        }
            break;
        case 1: {
            [self testChainOperation];
        }
            break;
        case 2: {
            [self testGroupOperation];
        }
            break;
        case 3: {

        }
            break;
        default:
            break;
    }
}

- (void)testDefaultOperationUseage {

    // 初始化一个观察者，可以接收到op各个状态的回调
    HWBlockObserver *observer = [[HWBlockObserver alloc] initWithWillStartCallback:^(HWOperation *operation, HWOperationQueue *operationQueue) {
        NSLog(@"op 即将开始，说明op即将加入到queue");
    } didStart:^(HWOperation *operation) {
        NSLog(@"op开始执行");
    } produce:^(HWOperation *operation, NSOperation *newOperation) {
        NSLog(@"该op产生了一个新的op: %@", newOperation);
    } finish:^(HWOperation *operation, NSArray<NSError *> *errors) {
        NSLog(@"op完成");
        if (errors) {
            NSLog(@"出现错误, 错误为：%@", errors);
        }
    }];


    HWCountOperation *countOperation = [HWCountOperation new];
    countOperation.value = 100;
    countOperation.identifier = @"基础功能测试";
    // 使用category中的方法来捕获op完成或者取消的回调
    [countOperation hw_addCompletionBlock:^(__kindof NSOperation *operation) {
        NSLog(@"op完成操作，从category方法中捕获。");
    }];

    HWCountCondition *condition = [HWCountCondition conditionWithCountOperation:countOperation];
    [countOperation addCondition:condition];

    [countOperation addObserver:observer];
    [countOperation runInGlobalQueue];
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
        op.delay = 1;
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

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
        _tableView.rowHeight = 56;

        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSArray *)testActions {
    if (!_testActions) {
        _testActions = @[@"基本功能测试", @"chain链operation测试", @"group operation测试", @"混合op测试"];
    }
    return _testActions;
}


@end
