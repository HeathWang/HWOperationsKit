//
//  HWOperationQueue.m
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/17.
//

#import "HWOperationQueue.h"
#import "HWOperation.h"
#import "HWBlockObserver.h"
#import "HWOperationConditionProtocol.h"
#import "NSOperation+HWBlock.h"

@interface HWOperationQueue ()

@property (nonatomic, strong) NSMutableSet *chainOperationsCache;

@end

@implementation HWOperationQueue

+ (instancetype)globalQueue {
    static HWOperationQueue *_sharedHWOperationQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHWOperationQueue = [HWOperationQueue new];
    });
    return _sharedHWOperationQueue;
}

- (void)addOperation:(NSOperation *)op {
    if ([self.operations containsObject:op])
        return;

    if ([op isKindOfClass:HWOperation.class]) {
        HWOperation *operation = (HWOperation *) op;

        // 如果一个待加入的op chainedOperations不为空，那么说明这个op是有链式op关系的，我们需要先把这些chain op取出来，一次加入到op queue中。
        if (operation.chainedOperations.count > 0 && ![self.chainOperationsCache containsObject:operation]) {
            [self.chainOperationsCache addObject:operation];

            [[operation.chainedOperations allObjects] enumerateObjectsUsingBlock:^(HWOperation <HWChainableOperationProtocol> *chainOP, NSUInteger idx, BOOL *stop) {
                [self addOperation:chainOP];
            }];
            [self addOperation:operation];
            return;
        }

        /**
         以下处理了没有chainedOperations的情况或许op有chainedOperations但已经被加入到chainOperationsCache中的情况
         1. 首先创建了一个监听用于delegate回调
         2. 其次拿到op所需要依赖的op，遍历并且`addDependency`
         3. 如果依赖的op chainedOperations存在，那么加入到cache中。
         */
         __weak typeof(self) wkSelf = self;
         HWBlockObserver *observer = [[HWBlockObserver alloc] initWithWillStartCallback:nil didStart:nil produce:^(HWOperation *operation, NSOperation *newOperation) {
             [wkSelf addOperation:newOperation];
         } finish:^(HWOperation *operation, NSArray<NSError *> *errors) {
             [wkSelf.chainOperationsCache removeObject:operation];

             if (wkSelf.delegate && [wkSelf.delegate respondsToSelector:@selector(operationQueue:operationDidFinish:withErrors:)]) {
                 [wkSelf.delegate operationQueue:wkSelf operationDidFinish:operation withErrors:errors];
             }
         }];

        [operation addObserver:observer];

        // 处理chain op依赖
        for (id<HWOperationConditionProtocol> condition in operation.conditions) {
            NSOperation *dependency = [condition dependencyForOperation:operation];
            if (dependency) {
                [operation addDependency:dependency];
            }
        }

        /*for (NSOperation *dependency in dependencies) {
            [operation addDependency:dependency];

            // TODO: 先按照自己的逻辑写
            if ([dependency isKindOfClass:HWOperation.class]) {
                HWOperation *hwOperation = (HWOperation *) dependency;

            }
        }*/

        // 调用op的即将加入queue放大，触发监听
        [operation willEnqueueInOperationQueue:self];
    } else {
        // 原生的NSOperation我们需要知道它完成了，然后触发delegate回调
        __weak typeof(self) wkSelf = self;
        __weak typeof(op) wkOP = op;
        [op hw_addCompletionBlock:^(__kindof NSOperation *operation) {
            if (wkSelf && wkOP) {
                if (wkSelf.delegate && [wkSelf.delegate respondsToSelector:@selector(operationQueue:operationDidFinish:withErrors:)]) {
                    [wkSelf.delegate operationQueue:wkSelf operationDidFinish:wkOP withErrors:nil];
                }
            }
        }];
    }

    // 即将加入
    if (self.delegate && [self.delegate respondsToSelector:@selector(operationQueue:willAddOperation:)]) {
        [self.delegate operationQueue:self willAddOperation:op];
    }

    // 调用父类的方法，真正被加入到queue
    [super addOperation:op];
}

- (void)addOperations:(NSArray<NSOperation *> *)ops waitUntilFinished:(BOOL)wait {
    for (NSOperation *op in ops) {
        [self addOperation:op];
    }

    if (wait) {
        NSLog(@"不建议waitUntilFinished设置为YES，我们有更多其他的方式来处理完成后的操作。");
    }
}

#pragma mark - Getter

- (NSMutableSet *)chainOperationsCache {
    if (!_chainOperationsCache) {
        _chainOperationsCache = [NSMutableSet set];
    }
    return _chainOperationsCache;
}

@end

@implementation NSOperationQueue (HWOperationKit)

- (void)addOperations:(NSArray<NSOperation *> *)ops onFinish:(void (^)(void))block {
    NSBlockOperation *finishOP = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            block ? block() : nil;
        });
    }];
    for (NSOperation *op in ops) {
        [finishOP addDependency:op];
    }
    NSMutableArray<NSOperation *> *tmp = [NSMutableArray arrayWithArray:ops];
    [tmp addObject:finishOP];

    [self addOperations:[tmp copy] waitUntilFinished:NO];
}

+ (void)addOperations:(NSArray<NSOperation *> *)ops onFinish:(void (^)(void))block {
    NSOperationQueue *queue = [NSOperationQueue new];
    [queue addOperations:ops onFinish:block];
}

@end
