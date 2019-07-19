//
//  HWBlockObserver.m
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/17.
//

#import "HWBlockObserver.h"

@interface HWBlockObserver ()

@property (nonatomic, copy) HWOperationWillStartCallback willStartCallback;
@property (nonatomic, copy) HWOperationStartCallback startCallback;
@property (nonatomic, copy) HWOperationProduceCallback produceCallback;
@property (nonatomic, copy) HWOperationFinishCallback finishCallback;

@end

@implementation HWBlockObserver

- (instancetype)initWithWillStartCallback:(nullable HWOperationWillStartCallback)willStartCallback didStart:(nullable HWOperationStartCallback)startCallback produce:(nullable HWOperationProduceCallback)produceCallback finish:(nullable HWOperationFinishCallback)finishCallback {
    self = [super init];
    if (self) {
        _willStartCallback = willStartCallback;
        _startCallback = startCallback;
        _produceCallback = produceCallback;
        _finishCallback = finishCallback;
    }
    return self;
}

- (instancetype)initWithDidStartCallback:(nullable HWOperationStartCallback)startCallback finish:(nullable HWOperationFinishCallback)finishCallback {
    return [[HWBlockObserver alloc] initWithWillStartCallback:nil didStart:startCallback produce:nil finish:finishCallback];
}

- (void)operationWillStart:(nonnull HWOperation *)operation inOperationQueue:(nonnull HWOperationQueue *)queue {
    if (self.willStartCallback) {
        self.willStartCallback(operation, queue);
    }
}

- (void)operationDidStart:(nonnull HWOperation *)operation {
    if (self.startCallback) {
        self.startCallback(operation);
    }
}

- (void)operation:(nonnull HWOperation *)operation didProduceOperation:(nonnull __kindof NSOperation *)newOperation {
    if (self.produceCallback) {
        self.produceCallback(operation, newOperation);
    }
}

- (void)operationDidFinish:(nonnull HWOperation *)operation withErrors:(nullable NSArray<__kindof NSError *> *)errors {
    if (self.finishCallback) {
        self.finishCallback(operation, errors);
    }
}


@end
