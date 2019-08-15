//
//  HWCountCondition.h
//  HWOperationsKit_Example
//
//  Created by heath wang on 2019/7/22.
//  Copyright © 2019 heathwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HWOperationsKit/HWOperationsKit.h>
@class HWCountOperation;

NS_ASSUME_NONNULL_BEGIN

@interface HWCountCondition : NSObject <HWOperationConditionProtocol>

@property (nonatomic, readonly) HWCountOperation *countOperation;

- (instancetype)initWithCountOperation:(HWCountOperation *)countOperation;

+ (instancetype)conditionWithCountOperation:(HWCountOperation *)countOperation;


@end

NS_ASSUME_NONNULL_END
