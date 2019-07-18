//
//  HWOperation.m
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/17.
//

#import "HWOperation.h"
#import "HWOperationObserverProtocol.h"
#import "HWOperationConditionProtocol.h"
#import "HWOperationQueue.h"
#import "HWOperationConditionResult.h"
#import "HWChainCondition.h"
#import "HWBlockObserver.h"

#define LOCK dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
#define UNLOCK dispatch_semaphore_signal(_lock);

@interface HWOperation ()

@property (nonatomic, assign) BOOL hasFinishedAlready;
@property (nonatomic, assign) HWOperationState state;
@property (getter=isCancelled) BOOL cancelled;

@property (nonatomic, weak) HWOperationQueue *enqueuedOperationQueue;

@property (nonatomic, copy) NSArray <NSObject <HWOperationConditionProtocol> *> *conditions;
@property (nonatomic, copy) NSArray <NSObject <HWOperationObserverProtocol> *> *observers;
@property (nonatomic, copy) NSArray <NSError *> *internalErrors;

@property (nonatomic, strong) NSHashTable <HWOperation <HWChainableOperationProtocol> *> *chainedOperations;

@property (nonatomic, strong) dispatch_semaphore_t lock;

@end

@implementation HWOperation

@synthesize cancelled = _cancelled;
@synthesize userInitiated = _userInitiated;
@synthesize state = _state;
@synthesize hasFinishedAlready = _hasFinishedAlready;

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = dispatch_semaphore_create(1);
    }

    return self;
}

#pragma mark - kvo

/**
 * 通过配置kvo，目标key会自动被返回的set中的key值影响，进而触发kvo
 * 我们通过属性state来判断op的状态
 * 对于NSOperation来说，`cancelled` `executing` `finished` `ready`等属性是只读的，所以我们需要重写其Getter方法
 * 具体可以参见苹果文档-> KVO-Compliant Properties
 */
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([@[@"isReady"] containsObject:key]) {
        return [NSSet setWithArray:@[@"state", @"cancelledState"]];
    }
    if ([@[@"isExecuting", @"isFinished"] containsObject:key]) {
        return [NSSet setWithArray:@[@"state"]];
    }
    if ([@[@"isCancelled"] containsObject:key]) {
        return [NSSet setWithArray:@[@"cancelledState"]];
    }

    return [super keyPathsForValuesAffectingValueForKey:key];
}

/**
 * 不自动触发kvo，改用手动
 */
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([@[@"state", @"cancelledState"] containsObject:key]) {
        return NO;
    }

    return [super automaticallyNotifiesObserversForKey:key];
}

#pragma mark - prop

- (void)setState:(HWOperationState)state {
     [self willChangeValueForKey:@"state"];
    LOCK
    NSAssert(_state != state, @"state状态转化错误，请检查！");
    _state = state;
    UNLOCK
    [self didChangeValueForKey:@"state"];
    
}

- (HWOperationState)state {
    HWOperationState state;
    UNLOCK
    state = _state;
    LOCK
    return state;
}

- (BOOL)isCancelled {
    BOOL cancel;
    LOCK
    cancel = _cancelled;
    UNLOCK
    return cancel;
}

/**
 * 为什么这里要额外手动出发cancelledState的kvo？
 * 根据官方文档：
 * Support for cancellation is voluntary but encouraged and your own code should not have to send KVO notifications for this key path.
 */
- (void)setCancelled:(BOOL)cancelled {
    [self willChangeValueForKey:@"cancelledState"];
    LOCK
    _cancelled = cancelled;
    UNLOCK
    [self didChangeValueForKey:@"cancelledState"];
}

/**
 * your custom implementation must get the default property value from super and incorporate that readiness value into the new value of the property.
 */
- (BOOL)isReady {
    BOOL ready = NO;
    
    @synchronized (self) {
        switch (self.state) {
            case HWOperationStateInitialized:
                ready = [self isCancelled];
                break;
            case HWOperationStatePending: {
                
                if ([self isCancelled]) {
                    [self setState:HWOperationStateReady];
                    ready = YES;
                    break;
                }
                
                if ([super isReady]) {
                    [self evaluateConditions];
                }
                ready = (self.state == HWOperationStateReady && ([super isReady] || [self isCancelled]));
                break;
            }
            case HWOperationStateReady:
                ready = [super isReady] || [self isCancelled];
                break;
            default:
                ready = NO;
        }
    }
    
    return ready;
}

- (BOOL)isExecuting {
    return self.state == HWOperationStateExecuting;
}

 - (BOOL)isFinished {
     return self.state == HWOperationStateFinished;
 }

- (BOOL)userInitiated {
    if ([self respondsToSelector:@selector(qualityOfService)]) {
        return self.qualityOfService == NSQualityOfServiceUserInitiated;
    }

    return _userInitiated;
}

- (void)setUserInitiated:(BOOL)newValue {
    NSAssert(self.state < HWOperationStateExecuting, @"不能变更userInitiated当operation开始执行后");
    if ([self respondsToSelector:@selector(setQualityOfService:)]) {
        self.qualityOfService = newValue ? NSQualityOfServiceUserInitiated : NSQualityOfServiceDefault;
    }
    _userInitiated = newValue;
}

#pragma mark - observer

- (NSArray<NSObject <HWOperationObserverProtocol> *> *)observers {
    if (!_observers) {
        _observers = @[];
    }
    return _observers;
}

- (void)addObserver:(nonnull NSObject <HWOperationObserverProtocol> *)observer {
    NSAssert(self.state < HWOperationStateExecuting, @"不能添加observer当operation开始执行后");
    self.observers = [self.observers arrayByAddingObject:observer];
}

#pragma mark - condition

- (NSArray<NSObject <HWOperationConditionProtocol> *> *)conditions {
    if (!_conditions) {
        _conditions = @[];
    }
    return _conditions;
}

- (void)addCondition:(nonnull NSObject <HWOperationConditionProtocol> *)condition {
    NSAssert(self.state < HWOperationStateExecuting, @"不能添加condition当operation开始执行后");
    self.conditions = [self.conditions arrayByAddingObject:condition];
}

#pragma mark - overridden

- (void)addDependency:(NSOperation *)op {
    NSAssert(self.state < HWOperationStateExecuting, @"不能添加依赖op当operation开始执行后");
    [super addDependency:op];
}

- (void)start {
    if ([self isCancelled]) {
        [self finish];
        return;
    }

    self.state = HWOperationStateExecuting;

    for (NSObject<HWOperationObserverProtocol> * observer in self.observers) {
        if ([observer respondsToSelector:@selector(operationDidStart:)]) {
            [observer operationDidStart:self];
        }
    }

    [self execute];
}

- (void)cancel {
    if ([self isFinished]) {
        return;
    }

    self.cancelled = YES;
    if (self.state > HWOperationStateReady) {
        [self finish];
    } else if (self.state < HWOperationStateReady) {
        self.state = HWOperationStateReady;
    }
}

- (void)waitUntilFinished {
    NSAssert(NO, @"调用`waitUntilFinished`是一种错误的设计模式，会造成线程阻塞。我们可以有很多其他的方式来实现同步操作，比如：`dispatch_semaphore_t` `dispatch_group_t` `NSLock`等。除非你清楚你在干什么，否则不要移除该方法!");
}

#pragma mark - chain

- (void)produceOperation:(nonnull NSOperation *)operation {

}

- (void)chainWithOperation:(nonnull HWOperation <HWChainableOperationProtocol> *)operation {
    [self.chainedOperations addObject:operation];
    [operation addCondition:[HWChainCondition conditionWithChainOperation:self]];

    __weak typeof(operation) wkOP = operation;
    [self addObserver:[[HWBlockObserver alloc] initWithWillStartCallback:nil didStart:nil produce:nil finish:^(HWOperation *finishOperation, NSArray<NSError *> *errors) {
        [wkOP chainedOperation:finishOperation didFinishWithErrors:errors passingAdditionalData:[finishOperation additionalDataToPassForChainedOperation]];
    }]];
}

+ (void)chainOperations:(nonnull NSArray <HWOperation <HWChainableOperationProtocol> *> *)operations {
    [operations enumerateObjectsUsingBlock:^(HWOperation <HWChainableOperationProtocol> *obj, NSUInteger idx, BOOL *stop) {
        NSUInteger nextIndex = ++idx;
        if (nextIndex < operations.count) {
            [obj chainWithOperation:operations[nextIndex]];
        }
    }];
}

- (NSHashTable<HWOperation<HWChainableOperationProtocol> *> *)chainedOperations {
    if (!_chainedOperations) {
        _chainedOperations = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _chainedOperations;
}

#pragma mark - HWChainableOperationProtocol

- (void)chainedOperation:(nonnull NSOperation *)operation didFinishWithErrors:(nullable NSArray <NSError *> *)errors passingAdditionalData:(nullable id)data {
    // 子类实现
}

- (nullable id)additionalDataToPassForChainedOperation {
    // 子类实现
    return nil;
}


#pragma mark - public method

- (void)willEnqueueInOperationQueue:(nonnull HWOperationQueue *)operationQueue {
    self.enqueuedOperationQueue = operationQueue;

    for (id<HWOperationObserverProtocol> observer in self.observers) {
        if ([observer respondsToSelector:@selector(operationWillStart:inOperationQueue:)]) {
            [observer operationWillStart:self inOperationQueue:operationQueue];
        }
    }

    self.state = HWOperationStatePending;
}

- (void)execute {
    // 子类必须重写该方法并调用finish
    NSString *reason = [NSString stringWithFormat:@"%@ must be overridden by subclasses", NSStringFromSelector(_cmd)];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

- (instancetype)runInGlobalQueue {
    [[HWOperationQueue globalQueue] addOperation:self];
    return self;
}

#pragma mark - cancel

- (void)cancelWithError:(nullable NSError *)error {
    if (error) {
        self.internalErrors = [self.internalErrors arrayByAddingObject:error];
        [self cancel];
    }
}

- (void)cancelWithErrors:(nullable NSArray <NSError *> *)errors {
    self.internalErrors = [self.internalErrors arrayByAddingObjectsFromArray:errors];
    [self cancel];
}

#pragma mark - finish

- (void)finish {
    [self finishWithError:nil];
}

- (void)finishWithErrors:(nullable NSArray <NSError *> *)errors {
    if (!self.hasFinishedAlready) {
        self.hasFinishedAlready = YES;
        self.state = HWOperationStateFinishing;

        self.internalErrors = [self.internalErrors arrayByAddingObjectsFromArray:errors];
        [self handleWithErrors:self.internalErrors];

        // 先把状态置为完成，再通知所有的observer回调完成
        self.state = HWOperationStateFinished;
        for (id<HWOperationObserverProtocol> observer in self.observers) {
            if ([observer respondsToSelector:@selector(operationDidFinish:withErrors:)]) {
                [observer operationDidFinish:self withErrors:self.internalErrors];
            }
        }
    }
}

- (void)finishWithError:(nullable NSError *)error {
    if (error) {
        [self finishWithErrors:@[error]];
    } else {
        [self finishWithErrors:nil];
    }

}

- (void)handleWithErrors:(nonnull NSArray <NSError *> *)errors {
    // do nothing.
}

- (BOOL)hasFinishedAlready {
    BOOL hasFinish;
    LOCK
    hasFinish = _hasFinishedAlready;
    UNLOCK
    return hasFinish;
}

- (void)setHasFinishedAlready:(BOOL)hasFinishedAlready {
    LOCK
    _hasFinishedAlready = hasFinishedAlready;
    UNLOCK
}

#pragma mark - private method

- (void)evaluateConditions {
    NSAssert(self.state == HWOperationStatePending, @"evaluateConditions() 执行顺序错误");
    self.state = HWOperationStateEvaluatingCondition;

    if (self.conditions.count <= 0) {
        self.state = HWOperationStateReady;
        return;
    }

    __weak typeof(self) wkSelf = self;
    [HWOperationConditionResult evaluateConditions:self.conditions operation:self completion:^(NSArray<NSError *> *errors) {
        if ([wkSelf isCancelled]) {
            return;
        }

        if (errors.count > 0) {
            [wkSelf cancelWithErrors:errors];
        } else if (wkSelf.state < HWOperationStateReady) {
            wkSelf.state = HWOperationStateReady;
        }
    }];
}

#pragma mark - Getter

- (NSArray<NSError *> *)internalErrors {
    if (!_internalErrors) {
        _internalErrors = @[];
    }
    return _internalErrors;
}

- (void)dealloc {
    NSLog(@"%@ dealloc", NSStringFromClass(self.class));
}

@end
