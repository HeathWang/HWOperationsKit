//
//  HWChainOperation.m
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/18.
//

#import "HWChainOperation.h"
#import "HWOperationQueue.h"

@interface HWChainOperation () <HWOperationQueueDelegate>

@property (nonatomic, strong) HWOperationQueue *internalQueue;
@property (nonatomic, copy) NSBlockOperation *finishedOperation;
@property (nonatomic, strong) NSMutableArray *aggregatedErrors;
@property (nonatomic, copy) NSArray <NSOperation *> *operations;

@end

@implementation HWChainOperation

#pragma mark - init

+ (instancetype)operationWithOperations:(nonnull NSArray <NSOperation <HWChainableOperationProtocol> *> *)operations {
    return [[HWChainOperation alloc] initWithOperations:operations];
}

- (instancetype)initWithOperations:(nonnull NSArray <NSOperation <HWChainableOperationProtocol> *> *)operations {
    self = [super init];
    if (self) {
        _finishIfProducedAnyError = YES;
        _finishedOperation = [NSBlockOperation blockOperationWithBlock:^{

        }];
        _aggregatedErrors = [NSMutableArray array];
        _operations = operations ?: @[];

    }

    return self;
}

#pragma mark - overridden

- (void)cancel {
    [self.internalQueue cancelAllOperations];
    self.internalQueue.suspended = NO;
    [super cancel];
}

- (void)execute {
    if (self.operations.count <= 0) {
        [self finish];
        return;
    }

    // 依次取出所有的op，按顺序添加依赖
    [self.operations enumerateObjectsUsingBlock:^(NSOperation *obj, NSUInteger idx, BOOL *stop) {
        NSUInteger nextIdx = idx + 1;
        if (nextIdx < self.operations.count) {
            NSOperation *nextOP = self.operations[nextIdx];
            [nextOP addDependency:obj];
        }

        [self.internalQueue addOperation:obj];
    }];

    [self.internalQueue addOperation:self.finishedOperation];
    self.internalQueue.suspended = NO;
}

#pragma mark - public method

- (void)addOperation:(nonnull NSOperation *)operation {
    if ([self isCancelled] || [self isFinished]) {
        return;
    }

    NSAssert(self.state < HWOperationStateExecuting, @"不能在开始执行的operation中添加额外的op");
    self.operations = [self.operations arrayByAddingObject:operation];
}

/**
 *  传递数据到下一个op
 */
- (void)operationDidFinish:(nonnull NSOperation *)operation withErrors:(nonnull NSArray *)errors {
    NSOperation<HWChainableOperationProtocol> *nextOP = self.internalQueue.operations.firstObject;
    if ([nextOP conformsToProtocol:@protocol(HWChainableOperationProtocol)] && [nextOP.dependencies containsObject:operation]) {

        id additionalData;
        if ([operation conformsToProtocol:@protocol(HWChainableOperationProtocol)] && [operation respondsToSelector:@selector(additionalDataToPassForChainedOperation)]) {
            additionalData = [(id<HWChainableOperationProtocol>)operation additionalDataToPassForChainedOperation];
        }

        if ([nextOP respondsToSelector:@selector(chainedOperation:didFinishWithErrors:passingAdditionalData:)]) {
            [nextOP chainedOperation:operation didFinishWithErrors:errors passingAdditionalData:additionalData];
        }
    }
}

- (void)aggregateError:(nonnull NSError *)error {
    [self.aggregatedErrors addObject:error];
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
        [self finishWithErrors:[self.aggregatedErrors copy]];
        if (self.internalQueue.operations.count > 0) {
            [self.internalQueue cancelAllOperations];
        }
    } else if (self.finishIfProducedAnyError && self.aggregatedErrors.count > 0) {
        // 这里需要注意一下，先暂停queue，那么所有任务不会再继续执行，再cancel所有ops，之后再开始queue
        self.internalQueue.suspended = YES;
        [self.internalQueue cancelAllOperations];
        self.internalQueue.suspended = NO;
        [self finishWithErrors:[self.aggregatedErrors copy]];
    } else {
        [self operationDidFinish:operation withErrors:errors];
    }
}


#pragma mark - Getter

- (HWOperationQueue *)internalQueue {
    if (!_internalQueue) {
        _internalQueue = [HWOperationQueue new];
        _internalQueue.maxConcurrentOperationCount = 1;
        _internalQueue.suspended = YES;
        _internalQueue.delegate = self;
    }
    return _internalQueue;
}


@end
