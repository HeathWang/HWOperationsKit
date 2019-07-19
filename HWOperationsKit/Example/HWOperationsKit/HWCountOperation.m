//
//  HWCountOperation.m
//  HWOperationsKit_Example
//
//  Created by heath wang on 2019/7/18.
//  Copyright © 2019 wangcongling. All rights reserved.
//

#import "HWCountOperation.h"
#import <HWOperationsKit/HWOperationsKit.h>

@implementation HWCountOperation

- (void)execute {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"-> chain op<%@>开始执行, data:%ld", self.identifier, (long)self.value);
        
        if (self.value % 5 == 0) {
            HWCountOperation *op = [HWCountOperation new];
            op.value = 1024;
            op.identifier = @"binggo!";
            [self produceOperation:op];
        }
        [self finish];
    });

}

- (void)chainedOperation:(__kindof NSOperation *)operation didFinishWithErrors:(NSArray<NSError *> *)errors passingAdditionalData:(id)data {
    if ([operation isKindOfClass:HWCountOperation.class]) {
        HWCountOperation *countOP = operation;
        NSLog(@"-> chain op<%@> 已完成，开始传递回调到响应链op<%@>", countOP.identifier, self.identifier);
    }
    
    NSNumber *num = data;
    self.value = num.integerValue + self.value;
}

- (id)additionalDataToPassForChainedOperation {
    NSLog(@"-> chain op<%@> 处理传递数据", self.identifier);
    return @(self.value);
}

@end
