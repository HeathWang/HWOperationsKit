//
//  HWBlockObserver.h
//  HWOperationsKit
//
//  Created by heath wang on 2019/7/17.
//

#import <Foundation/Foundation.h>
#import "HWOperationObserverProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^HWOperationWillStartCallback)(HWOperation *_Nonnull operation, HWOperationQueue *_Nonnull operationQueue);

typedef void(^HWOperationStartCallback)(HWOperation *_Nonnull operation);

typedef void(^HWOperationProduceCallback)(HWOperation *_Nonnull operation, NSOperation *_Nonnull newOperation);

typedef void(^HWOperationFinishCallback)(HWOperation *_Nonnull operation, NSArray<NSError *> *_Nullable errors);

@interface HWBlockObserver : NSObject <HWOperationObserverProtocol>

/**
 * 初始化operation observer
 * @param willStartCallback 即将开始block回调
 * @param startCallback 开始block回调
 * @param produceCallback 产生新的op block回调
 * @param finishCallback 完成op回调
 * @return HWBlockObserver
 */
- (nonnull instancetype)initWithWillStartCallback:(nullable HWOperationWillStartCallback)willStartCallback
                                         didStart:(nullable HWOperationStartCallback)startCallback
                                          produce:(nullable HWOperationProduceCallback)produceCallback
                                           finish:(nullable HWOperationFinishCallback)finishCallback;

/**
 * 初始化operation observer
 * @param startCallback op开始回调
 * @param finishCallback op完成block回调
 * @return HWBlockObserver
 */
- (nonnull instancetype)initWithDidStartCallback:(nullable HWOperationStartCallback)startCallback
                                          finish:(nullable HWOperationFinishCallback)finishCallback;

@end

NS_ASSUME_NONNULL_END
