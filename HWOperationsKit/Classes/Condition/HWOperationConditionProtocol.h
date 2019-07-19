//
//  HWOperationConditionProtocol.h
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/17.
//

@class HWOperation;
@class HWOperationConditionResult;

/**
 * Operation condition 协议
 */
@protocol HWOperationConditionProtocol <NSObject>

/**
 * condition name
 * @return string
 */
- (nonnull NSString *)name;

/**
 * 返回目标operation所依赖的`NSOperation`
 * @param operation 目标op
 * @return 依赖的operation，即`- (void)addDependency:(NSOperation *)op;`中的op
 */
- (nonnull __kindof NSOperation *)dependencyForOperation:(nonnull HWOperation *)operation;

/**
 * 对目标参数op进行状态评估
 * @param operation 目标op
 * @param completion 评估回调
 */
- (void)evaluateForOperation:(nonnull HWOperation *)operation completion:(void (^ _Nonnull)(HWOperationConditionResult * _Nonnull result))completion;

@end
