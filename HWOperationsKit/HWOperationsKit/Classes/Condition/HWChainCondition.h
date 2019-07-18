//
//  HWChainCondition.h
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/17.
//

#import <Foundation/Foundation.h>
#import "HWOperationConditionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * chain链condition
 */
@interface HWChainCondition : NSObject <HWOperationConditionProtocol>

// 被依赖的op
@property (nonnull, nonatomic, readonly) NSOperation *chainOperation;

/**
 * 根据目标chainOperation来初始化condition
 * @param chainOperation 持有该condition的op会添加chainOperation为自身的依赖
 */
- (instancetype)initWithChainOperation:(NSOperation *)chainOperation;

+ (instancetype)conditionWithChainOperation:(NSOperation *)chainOperation;

@end

NS_ASSUME_NONNULL_END
