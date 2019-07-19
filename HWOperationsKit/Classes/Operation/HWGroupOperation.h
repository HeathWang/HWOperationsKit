//
//  HWGroupOperation.h
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/18.
//
#import "HWOperation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 一组需要执行的operation，并发执行，当所有的op执行完成后，自身会完成
 */
@interface HWGroupOperation : HWOperation

@property (nonnull, nonatomic, strong, readonly) HWOperationQueue *internalQueue;

+ (nonnull instancetype)operationWithOperations:(nonnull NSArray <NSOperation *> *)operations;
- (nonnull instancetype)initWithOperations:(nonnull NSArray <NSOperation *> *)operations;

- (void)addOperation:(nonnull NSOperation *)operation;
/**
 * 添加错误信息
 */
- (void)aggregateError:(nonnull NSError *)error;

/**
 * 当子operation完成后，该方法会执行，默认实现是空，子类可以实现其该方法，添加处理逻辑，比如：
 * 子op生成的数据、错误处理等
 * @param operation 子op
 */
- (void)operationDidFinish:(nonnull NSOperation *)operation withErrors:(nullable NSArray <NSError *>*)errors;

@end

NS_ASSUME_NONNULL_END
