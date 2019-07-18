//
//  NSError+HWOperation.h
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/17.
//

#import <Foundation/Foundation.h>

extern NSString *const _Nonnull HWOperationErrorDomain;

typedef NS_ENUM(NSInteger, HWOperationErrorCode) {
    HWOperationErrorCodeConditionFailed = 1024,    // op状态校验失败
    HWOperationErrorCodeExecuteFailed   = 1025,    // op在执行时失败
};

NS_ASSUME_NONNULL_BEGIN

@interface NSError (HWOperation)

+ (nonnull instancetype)hw_operationErrorWithCode:(NSInteger)code;
+ (nonnull instancetype)hw_operationErrorWithCode:(NSInteger)code userinfo:(nullable NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
