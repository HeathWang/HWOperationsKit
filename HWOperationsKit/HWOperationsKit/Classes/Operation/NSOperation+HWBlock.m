//
//  NSOperation+HWBlock.m
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/18.
//

#import "NSOperation+HWBlock.h"

@implementation NSOperation (HWBlock)

- (void)hw_addCompletionBlockInMainQueue:(void (^ __nullable)(__kindof NSOperation *_Nonnull operation))block {
    if (!block)
        return;

    void (^existBlock)(void) = self.completionBlock;
    __weak typeof(self) wkSelf = self;
    if (existBlock) {
        self.completionBlock = ^{
            existBlock();
            __strong typeof(self) strongSelf = wkSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
               block(strongSelf);
            });
        };
    } else {
        self.completionBlock = ^{
            __strong typeof(wkSelf) strongSelf = wkSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                block(strongSelf);
            });
        };
    }
}

- (void)hw_addCompletionBlock:(void (^ __nullable)(__kindof NSOperation *_Nonnull operation))block {
    if (!block)
        return;

    void (^existBlock)(void) = self.completionBlock;
    __weak typeof(self) wkSelf = self;
    if (existBlock) {
        self.completionBlock = ^{
            existBlock();
            block(wkSelf);
        };
    } else {
        self.completionBlock = ^{
            block(wkSelf);
        };
    }
}

- (void)hw_addCancelBlockInMainQueue:(void (^ __nullable)(__kindof NSOperation *_Nonnull operation))cancelBlock {
    if (!cancelBlock)
        return;

    [self hw_addCancelBlockInMainQueue:^(__kindof NSOperation *operation) {
        if ([operation isCancelled]) {
            cancelBlock(operation);
        }
    }];
}

- (void)hw_addCancelBlock:(void (^ __nullable)(__kindof NSOperation *_Nonnull operation))cancelBlock {
    if (!cancelBlock)
        return;

    [self hw_addCompletionBlock:^(__kindof NSOperation *operation) {
        if ([operation isCancelled]) {
            cancelBlock(operation);
        }
    }];
}

- (void)hw_addDependencies:(nonnull NSArray <NSOperation *> *)dependencies {
    for (NSOperation *dependency in dependencies) {
        [self addDependency:dependency];
    }
}


@end
