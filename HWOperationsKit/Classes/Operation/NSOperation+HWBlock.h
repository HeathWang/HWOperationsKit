//
//  NSOperation+HWBlock.h
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSOperation (HWBlock)

- (void)hw_addCompletionBlockInMainQueue:(void (^ __nullable)(__kindof NSOperation * _Nonnull operation))block;
- (void)hw_addCompletionBlock:(void (^ __nullable)(__kindof NSOperation * _Nonnull operation))block;

- (void)hw_addCancelBlockInMainQueue:(void(^ __nullable)(__kindof NSOperation * _Nonnull operation))cancelBlock;
- (void)hw_addCancelBlock:(void(^ __nullable)(__kindof NSOperation * _Nonnull operation))cancelBlock;

- (void)hw_addDependencies:(nonnull NSArray <NSOperation *> *)dependencies;

@end

NS_ASSUME_NONNULL_END
