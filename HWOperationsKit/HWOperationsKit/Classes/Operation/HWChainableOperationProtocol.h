//
//  HWChainableOperationProtocol.h
//  Pods
//
//  Created by heath wang on 2019/7/17.
//

@protocol HWChainableOperationProtocol <NSObject>

@optional

- (void)chainedOperation:(nonnull NSOperation *)operation didFinishWithErrors:(nullable NSArray <NSError *>*)errors passingAdditionalData:(nullable id)data;
- (nullable id)additionalDataToPassForChainedOperation;

@end
