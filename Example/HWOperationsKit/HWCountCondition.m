//
//  HWCountCondition.m
//  HWOperationsKit_Example
//
//  Created by heath wang on 2019/7/22.
//  Copyright © 2019 heathwang. All rights reserved.
//

#import "HWCountCondition.h"
#import "HWCountOperation.h"

@interface HWCountCondition ()

@property (nonatomic, strong) HWCountOperation *countOperation;

@end

@implementation HWCountCondition
- (instancetype)initWithCountOperation:(HWCountOperation *)countOperation {
    self = [super init];
    if (self) {
        _countOperation = countOperation;
    }

    return self;
}

+ (instancetype)conditionWithCountOperation:(HWCountOperation *)countOperation {
    return [[self alloc] initWithCountOperation:countOperation];
}

- (nonnull NSString *)name {
    return NSStringFromClass(self.class);
}

- (nullable __kindof NSOperation *)dependencyForOperation:(nonnull HWOperation *)operation {
    return nil;
}

- (void)evaluateForOperation:(nonnull HWOperation *)operation completion:(void (^ _Nonnull)(HWOperationConditionResult *_Nonnull result))completion {
    if (self.countOperation) {
        if (self.countOperation.value >= 100) {
            HWOperationConditionResult *result = [HWOperationConditionResult failedResultWithError:[NSError hw_operationErrorWithCode:HWOperationErrorCodeConditionFailed]];
            completion(result);
        }
    }
}


@end
