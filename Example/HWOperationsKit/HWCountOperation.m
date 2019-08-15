//
//  HWCountOperation.m
//  HWOperationsKit_Example
//
//  Created by heath wang on 2019/7/18.
//  Copyright © 2019 heathwang. All rights reserved.
//

#import "HWCountOperation.h"
#import <HWOperationsKit/HWOperationsKit.h>

@implementation HWCountOperation

- (void)execute {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delay * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"-> chain op<%@>开始执行, data:%ld", self.identifier, (long)self.value);
        [self finish];
    });
}

- (void)cancelWithErrors:(nullable NSArray <NSError *> *)errors {

    HWCountOperation *countOperation = [HWCountOperation new];
    countOperation.identifier = self.identifier;
    countOperation.value = self.value + 2;
    [self produceOperation:countOperation];

    [super cancelWithErrors:errors];
}

#pragma mark - chain

- (void)chainedOperation:(__kindof NSOperation *)operation didFinishWithErrors:(NSArray<NSError *> *)errors passingAdditionalData:(id)data {
    if ([operation isKindOfClass:HWCountOperation.class]) {
        HWCountOperation *countOP = operation;
        NSLog(@"-> chain op<%@> 已完成，开始传递回调到响应链op<%@>\n", countOP.identifier, self.identifier);
    }
    
    NSNumber *num = data;
    self.value = num.integerValue + self.value;
}


- (id)additionalDataToPassForChainedOperation {
    NSLog(@"-> chain op<%@> 处理传递数据:%ld", self.identifier, (long) self.value);
    return @(self.value);
}

@end
