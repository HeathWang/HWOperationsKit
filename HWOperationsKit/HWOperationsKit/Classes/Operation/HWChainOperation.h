//
//  HWChainOperation.h
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/18.
//

#import "HWOperation.h"
NS_ASSUME_NONNULL_BEGIN

/**
 * 链式执行所有的operations，一个一个按照加入的顺序执行，不用去手动设置依赖，内部自动添加依赖
 * 同时如果operation实现了`HWChainableOperationProtocol`协议的话，会自动将错误信息errors和额外data传递到下一个执行的op中去。
 */
@interface HWChainOperation : HWOperation

/**
 * 是否只要出现错误就完成该chain op，内部会取消掉所有op
 * 默认为YES
 */
@property (nonatomic, assign) BOOL finishIfProducedAnyError;

+ (nonnull instancetype)operationWithOperations:(nonnull NSArray <NSOperation <HWChainableOperationProtocol> *>*)operations;
- (nonnull instancetype)initWithOperations:(nonnull NSArray <NSOperation <HWChainableOperationProtocol> *>*)operations;
/**
 * 加入新的operation到chain链中
 * 注意必须在该ChainOperation没有开始执行之前
 */
- (void)addOperation:(__kindof NSOperation * __nonnull)operation;

/**
 * 添加错误信息
 */
- (void)aggregateError:(nonnull NSError *)error;

@end

NS_ASSUME_NONNULL_END
