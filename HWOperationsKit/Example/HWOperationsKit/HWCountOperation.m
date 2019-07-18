//
//  HWCountOperation.m
//  HWOperationsKit_Example
//
//  Created by heath wang on 2019/7/18.
//  Copyright © 2019 wangcongling. All rights reserved.
//

#import "HWCountOperation.h"

@implementation HWCountOperation

- (void)execute {
    NSLog(@"-> %ld", (long) self.value);
    
    [self finish];
}

- (void)chainedOperation:(__kindof NSOperation *)operation didFinishWithErrors:(NSArray<NSError *> *)errors passingAdditionalData:(id)data {
    NSNumber *num = data;
    self.value = num.integerValue * self.value;
}

- (id)additionalDataToPassForChainedOperation {
    return @(self.value + 10);
}

@end
