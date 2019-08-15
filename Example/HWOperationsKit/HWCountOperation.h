//
//  HWCountOperation.h
//  HWOperationsKit_Example
//
//  Created by heath wang on 2019/7/18.
//  Copyright © 2019 heathwang. All rights reserved.
//

#import <HWOperationsKit/HWOperationsKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HWCountOperation : HWOperation

@property (nonatomic, assign) NSInteger value;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) NSTimeInterval delay;

@end

NS_ASSUME_NONNULL_END
