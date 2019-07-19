//
//  HWOperationConditionResult.h
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/17.
//

#import <Foundation/Foundation.h>

@class HWOperation;
@protocol HWOperationConditionProtocol;

NS_ASSUME_NONNULL_BEGIN

/**
 * `HWOperationConditionResult`是服务于OperationCondition的
 * conditionProtocol校验输出结果
 */
@interface HWOperationConditionResult : NSObject

@property (nonatomic, assign, readonly, getter=isSuccess) BOOL success;
@property (nullable, nonatomic, readonly) NSError *error;

+ (nonnull instancetype)successResult;

+ (nonnull instancetype)failedResultWithError:(NSError *)error;

+ (void)evaluateConditions:(nonnull NSArray<NSObject<HWOperationConditionProtocol> *> *)conditions operation:(nonnull HWOperation *)operation completion:(void (^ __nullable)(NSArray<NSError *> *_Nullable errors))completion;

@end

NS_ASSUME_NONNULL_END
