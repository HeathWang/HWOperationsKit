//
//  HWOperationObserverProtocol.h
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/17.
//

@class HWOperation;
@class HWOperationQueue;

@protocol HWOperationObserverProtocol <NSObject>

/**
 * Operation 即将开始执行时回调
 * @param operation HWOperation
 * @param queue operation加入的operation queue
 */
- (void)operationWillStart:(nonnull HWOperation *)operation inOperationQueue:(nonnull HWOperationQueue *)queue;

/**
 * Operation开始回调
 * @param operation HWOperation
 */
- (void)operationDidStart:(nonnull HWOperation *)operation;

/**
 * 目标Operation产生一个新的operation回调
 * @param operation 目标op
 * @param newOperation 新的op
 */
- (void)operation:(nonnull HWOperation *)operation didProduceOperation:(nonnull __kindof NSOperation *)newOperation;

/**
 * operation完成回调
 * @param operation HWOperation
 * @param errors 完成时的错误信息
 */
- (void)operationDidFinish:(nonnull HWOperation *)operation withErrors:(nullable NSArray<__kindof NSError *> *)errors;

@end
