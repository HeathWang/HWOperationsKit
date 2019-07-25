//
//  HWOperation.h
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/17.
//

#import <Foundation/Foundation.h>
#import "HWChainableOperationProtocol.h"

@protocol HWOperationObserverProtocol;
@protocol HWOperationConditionProtocol;
@class HWOperationQueue;

typedef NS_ENUM(NSInteger, HWOperationState) {
    HWOperationStateInitialized,        // 初始化
    HWOperationStatePending,            // 阻塞，即将评估condition
    HWOperationStateEvaluatingCondition,// 正在评估校验condition
    HWOperationStateReady,              // 所有condition评估完成，准备执行任务
    HWOperationStateExecuting,          // 正在执行
    HWOperationStateFinishing,          // 正在完成状态
    HWOperationStateFinished            // 已经完成
};

NS_ASSUME_NONNULL_BEGIN

/**
 * 继承自NSOperation并实现了HWChainableOperationProtocol协议
 * 可添加多个实现了HWOperationObserverProtocol协议的observer
 * 在op执行前会对所有的conditions进行评估校验，如果有HWOperationConditionProtocol出现error，则cancel该op
 */
@interface HWOperation : NSOperation <HWChainableOperationProtocol>

@property(readonly, getter=isCancelled) BOOL cancelled;
@property(nonatomic, assign) BOOL userInitiated;
@property(nonatomic, readonly) HWOperationState state;

// operation被加入的op queue
@property(nonatomic, weak, readonly, nullable) HWOperationQueue *enqueuedOperationQueue;

// 所有的conditions
@property(nonatomic, nonnull, copy, readonly) NSArray <NSObject <HWOperationConditionProtocol> *> *conditions;
// op observers
@property(nonatomic, nonnull, copy, readonly) NSArray <NSObject <HWOperationObserverProtocol> *> *observers;
// 执行该op所产生的错误list
@property(nonatomic, nonnull, copy, readonly) NSArray <NSError *> *internalErrors;
// chain链op list该op的响应链op集合，即这些集合中的op会依赖该op
@property(nonatomic, strong, nonnull, readonly) NSHashTable <HWOperation <HWChainableOperationProtocol> *> *chainedOperations;

- (void)addObserver:(nonnull NSObject <HWOperationObserverProtocol> *)observer;
- (void)addCondition:(nonnull NSObject <HWOperationConditionProtocol> *)condition;

/**
 * 即将加入到op queue时调用， 子类可重写该方法，但必须调用super
 */
- (void)willEnqueueInOperationQueue:(nonnull HWOperationQueue *)operationQueue NS_REQUIRES_SUPER;

#pragma mark - finish
/**
 * 子类必须在合适的实际调用一下几个`finish`方法来使op finish
 * 最终调用`- (void)finishWithErrors:(nullable NSArray <NSError *> *)errors`
 */
- (void)finish NS_REQUIRES_SUPER;
/**
 * 子类可重写该方法，但必须调用super
 */
- (void)finishWithErrors:(nullable NSArray <NSError *> *)errors NS_REQUIRES_SUPER;
/**
 * 默认该方法什么都没有做，子类可重写，针对op即将完成的情况，对所有的errors进行处理。
 * @param errors op执行时产生的错误list
 */
- (void)handleWithErrors:(nonnull NSArray <NSError *> *)errors;

#pragma mark - cancel
- (void)cancel NS_REQUIRES_SUPER;
- (void)cancelWithErrors:(nullable NSArray <NSError *> *)errors NS_REQUIRES_SUPER;

#pragma mark - run
/**
 * 子类必须实现该方法，op执行的任务需要在该方法实现，当所执行的代码完成后，必须调用任意一个`finish`方法
 */
- (void)execute;

/**
 * 将该op加入到全局的op queue中去执行
 */
- (nonnull instancetype)runInGlobalQueue;

/**
 * 产生一个新的op，子类如果重写该方法，必须call super
 */
- (void)produceOperation:(nonnull NSOperation *)operation NS_REQUIRES_SUPER;

/**
 * 添加一个响应链op
 */
- (void)chainWithOperation:(nonnull HWOperation <HWChainableOperationProtocol> *)operation;

/**
 * 处理链式op
 * 例如op数组为op A B C，那么op链为A B C，也就是说B 依赖 A ， C 依赖 B
 * A B C会依次执行，每个op执行完成后会执行HWChainableOperationProtocol协议方法，并可以传递data到下一个chain op
 */
+ (void)chainOperations:(nonnull NSArray <HWOperation <HWChainableOperationProtocol> *> *)operations;


@end

NS_ASSUME_NONNULL_END
