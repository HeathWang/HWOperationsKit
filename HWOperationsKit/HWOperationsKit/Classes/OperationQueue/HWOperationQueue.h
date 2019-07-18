//
//  HWOperationQueue.h
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/17.
//

#import <Foundation/Foundation.h>

@class HWOperation;
@class HWOperationQueue;

NS_ASSUME_NONNULL_BEGIN

@protocol HWOperationQueueDelegate <NSObject>

@optional
- (void)operationQueue:(nonnull HWOperationQueue *)operationQueue willAddOperation:(nonnull __kindof  NSOperation *)operation;
- (void)operationQueue:(nonnull HWOperationQueue *)operationQueue operationDidFinish:(nonnull __kindof NSOperation *)operation withErrors:(nullable NSArray<NSError *> *)errors;

@end

@interface NSOperationQueue (HWOperationKit)

/**
 * add op，所有op执行完成后，block回调会调用，默认情况会切换到主线程
 */
+ (void)addOperations:(NSArray<NSOperation *> *)ops onFinish:(void (^ __nullable)(void))block;

/**
 * add op，所有op执行完成后，block回调会调用，默认情况会切换到主线程
 */
- (void)addOperations:(nonnull NSArray<NSOperation *> *)ops onFinish:(void (^ __nullable)(void))block;

@end

@interface HWOperationQueue : NSOperationQueue

@property (nullable, nonatomic, weak) id <HWOperationQueueDelegate> delegate;

+ (nonnull instancetype)globalQueue;

@end

NS_ASSUME_NONNULL_END
