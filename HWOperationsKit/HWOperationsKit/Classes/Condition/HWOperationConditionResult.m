//
//  HWOperationConditionResult.m
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/17.
//

#import "HWOperationConditionResult.h"
#import "HWOperation.h"
#import "HWOperationConditionProtocol.h"
#import "NSError+HWOperation.h"

@interface HWOperationConditionResult ()

@property (nonatomic, assign) BOOL success;
@property (nullable, nonatomic, strong) NSError *error;

@end

@implementation HWOperationConditionResult

+ (instancetype)successResult {
    return [self resultWithSuccess:YES error:nil];
}

+ (instancetype)failedResultWithError:(NSError *)error {
    return [self resultWithSuccess:NO error:error];
}

- (instancetype)initWithSuccess:(BOOL)success error:(nullable NSError *)error {
    self = [super init];
    if (self) {
        _success = success;
        _error = error;
    }

    return self;
}

+ (instancetype)resultWithSuccess:(BOOL)success error:(nullable NSError *)error {
    return [[self alloc] initWithSuccess:success error:error];
}

#pragma mark - public method

+ (void)evaluateConditions:(nonnull NSArray<NSObject<HWOperationConditionProtocol> *> *)conditions operation:(nonnull HWOperation *)operation completion:(void (^ __nullable)(NSArray<NSError *> *_Nullable errors))completion {
    dispatch_group_t group = dispatch_group_create();
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:conditions.count];

    // 对所有的condition进行评估校验
    [conditions enumerateObjectsUsingBlock:^(NSObject <HWOperationConditionProtocol> *obj, NSUInteger idx, BOOL *stop) {
        dispatch_group_enter(group);
        [obj evaluateForOperation:operation completion:^(HWOperationConditionResult *result) {
            [results addObject:result];
            dispatch_group_leave(group);
        }];
    }];

    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSArray *errors = [[results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"error != nil"]] valueForKey:@"error"];

        // 当在评估过程中造成operation cancel，添加错误信息
        if (operation.isCancelled) {
            NSError *conditionFailed = [NSError hw_operationErrorWithCode:HWOperationErrorCodeConditionFailed];
            errors = [errors arrayByAddingObject:conditionFailed];
        }

        if (completion) {
            completion(errors);
        }
    });
}

@end
