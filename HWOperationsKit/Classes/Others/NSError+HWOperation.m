//
//  NSError+HWOperation.m
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/17.
//

#import "NSError+HWOperation.h"

NSString *const HWOperationErrorDomain = @"com.heath.HWOperationErrorDomain";

@implementation NSError (HWOperation)

+ (instancetype)hw_operationErrorWithCode:(NSInteger)code {
    return [[NSError alloc] initWithDomain:HWOperationErrorDomain code:code userInfo:nil];
}

+ (instancetype)hw_operationErrorWithCode:(NSInteger)code userinfo:(nullable NSDictionary *)userInfo {
    return [[NSError alloc] initWithDomain:HWOperationErrorDomain code:code userInfo:userInfo];
}

@end
