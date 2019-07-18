//
//  HWChainCondition.m
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/17.
//

#import "HWChainCondition.h"
#import "HWOperationConditionResult.h"

@interface HWChainCondition ()

@property (nonatomic, strong) NSOperation *chainOperation;

@end

@implementation HWChainCondition

- (instancetype)initWithChainOperation:(NSOperation *)chainOperation {
    self = [super init];
    if (self) {
        _chainOperation = chainOperation;
    }

    return self;
}

+ (instancetype)conditionWithChainOperation:(NSOperation *)chainOperation {
    return [[self alloc] initWithChainOperation:chainOperation];
}

#pragma mark - HWOperationConditionProtocol

- (nonnull NSString *)name {
    return NSStringFromClass(self.class);
}

- (nonnull __kindof NSOperation *)dependencyForOperation:(nonnull HWOperation *)operation {
    return self.chainOperation;
}

- (void)evaluateForOperation:(nonnull HWOperation *)operation completion:(void (^ _Nonnull)(HWOperationConditionResult *_Nonnull result))completion {
    completion([HWOperationConditionResult successResult]);
}

@end
