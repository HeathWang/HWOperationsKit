//
//  HWGroupOperation.m
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/18.
//

#import "HWGroupOperation.h"
#import "HWOperationQueue.h"

@interface HWGroupOperation () <HWOperationQueueDelegate>

@property (nonatomic, strong) HWOperationQueue *internalQueue;
@property (nonatomic, copy) NSBlockOperation *finishedOperation;
@property (nonatomic, strong) NSMutableArray *aggregatedErrors;

@end

@implementation HWGroupOperation

#pragma mark - init

+ (instancetype)operationWithOperations:(nonnull NSArray <NSOperation *> *)operations {
    return [[HWGroupOperation alloc] initWithOperations:operations];
}

- (instancetype)initWithOperations:(nonnull NSArray <NSOperation *> *)operations {
    self = [super init];
    if (self) {
        _finishedOperation = [NSBlockOperation blockOperationWithBlock:^{

        }];
        _aggregatedErrors = [NSMutableArray array];

        for (NSOperation *operation in operations) {
            [self.internalQueue addOperation:operation];
        }
    }
    return self;
}

#pragma mark - overridden

- (void)cancel {
    self.internalQueue.suspended = YES;
    [self.internalQueue cancelAllOperations];
    self.internalQueue.suspended = NO;
    [super cancel];
}

- (void)execute {
    self.internalQueue.suspended = NO;
    [self.internalQueue addOperation:self.finishedOperation];
}

#pragma mark - public method

- (void)addOperation:(nonnull NSOperation *)operation {
    [self.internalQueue addOperation:operation];
}

- (void)aggregateError:(nonnull NSError *)error {
    [self.aggregatedErrors addObject:error];
}

- (void)operationDidFinish:(nonnull NSOperation *)operation withErrors:(nullable NSArray <NSError *> *)errors {
    // 子类实现
}
#pragma mark - HWOperationQueueDelegate

- (void)operationQueue:(nonnull HWOperationQueue *)operationQueue willAddOperation:(nonnull __kindof NSOperation *)operation {
    NSAssert(!self.finishedOperation.finished && !self.finishedOperation.executing, @"不能添加新的op当operation queue已经完成");
    if (operation != self.finishedOperation) {
        [self.finishedOperation addDependency:operation];
    }
}

- (void)operationQueue:(nonnull HWOperationQueue *)operationQueue operationDidFinish:(nonnull __kindof NSOperation *)operation withErrors:(nullable NSArray<NSError *> *)errors {
    [self.aggregatedErrors addObjectsFromArray:errors];
    if (operation == self.finishedOperation) {
        self.internalQueue.suspended = YES;
        [self finishWithErrors:self.aggregatedErrors];
    } else {
        [self operationDidFinish:operation withErrors:errors];
    }
}

#pragma mark - Getter

- (HWOperationQueue *)internalQueue {
    if (!_internalQueue) {
        _internalQueue = [HWOperationQueue new];
        _internalQueue.suspended = YES;
        _internalQueue.delegate = self;

    }
    return _internalQueue;
}


@end
