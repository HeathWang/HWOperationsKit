# HWOperationsKit

<p style="align: left">
    <a href="https://cocoapods.org/pods/HWOperationsKit">
       <img src="https://img.shields.io/cocoapods/v/HWOperationsKit.svg?style=flat">
    </a>
    <a href="https://cocoapods.org/pods/HWOperationsKit">
       <img src="https://img.shields.io/cocoapods/p/HWOperationsKit.svg?style=flat">
    </a>
    <a href="https://cocoapods.org/pods/HWOperationsKit">
       <img src="https://img.shields.io/badge/support-ios%208%2B-orange.svg">
    </a>
    <a href="https://cocoapods.org/pods/HWOperationsKit">
       <img src="https://img.shields.io/badge/language-objective--c-blue.svg">
    </a>
    <a href="https://cocoapods.org/pods/HWOperationsKit">
       <img src="https://img.shields.io/cocoapods/l/HWOperationsKit.svg?style=flat">
    </a>
</p>

HWOperationsKit针对WWDC 2015 Advanced NSOperations进行了简单封装，以便于能够简单高效的使用NSOperation。

## When To Use

1. 多个任务都完成后再处理某个任务。可以用 `dispatch_group_t` ，但代码比较繁琐。
2. 多个任务之间产生依赖，特别的异步任务（如网络请求），如果使用block嵌套，会陷入`回调地狱`。而使用 `dispatch_group_t` 加 `dispatch_semaphore_t` 可以实现异步任务依赖，但是代码很不美观，而且相关复用率低。
3. 有一系列链式任务，顺序执行，每个任务执行完成会产生错误和数据，需要传递给下一个任务，如何处理？

以上几种情况使用NSOperation可以很好的解决。
该框架对 `NSOperation` 和 `NSOperationQueue` 进行了简单封装，使用更加简单。

## How To Use

### HWOperation

该类继承自NSOperation，使用时可以继承自HWOperation。

#### 如何开始，结束operation？

子类实现 `- (void)execute` 方法，在方法中可以执行同步/异步代码，当任务完成后，**必须**调用相关的finish或者cancel方法。

```Objective-C
#pragma mark - finish
/**
 * 子类必须在合适的实际调用一下几个`finish`方法来使op finish
 * 最终调用`- (void)finishWithErrors:(nullable NSArray <NSError *> *)errors`
 */
- (void)finish NS_REQUIRES_SUPER;
/**
 * 子类可重写该方法，但必须调用super
 */
- (void)finishWithErrors:(nullable NSArray <NSError *> *)errors NS_REQUIRES_SUPER;

#pragma mark - cancel
- (void)cancel NS_REQUIRES_SUPER;
- (void)cancelWithErrors:(nullable NSArray <NSError *> *)errors NS_REQUIRES_SUPER;
```

#### 如何监听operation各种状态？

`HWOperation` 可添加observer：`HWBlockObserver`，监听op即将加入operation Queue，开始，产生新的op，结束等几种状态。

或者使用 `NSOperation` 的category，参见 `NSOperation+HWBlock.h`

### HWOperation派生类HWChainOperation，HWGroupOperation

`HWChainOperation` 会依次（one-by-one）执行一组op，不用设置依赖，并且每个op完成后，可以传递数据到下一个op。

`HWGroupOperation` 会初始化一组op，异步执行，顺序不定。

### HWOperationQueue

用法同NSOperationQueue

`+ (nonnull instancetype)globalQueue` 是一个全局单例queue，通常情况下operation可以直接加入到queue中。

`HWOperation` 中有方法 `- (nonnull instancetype)runInGlobalQueue` 可直接加入queue。

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

`HWViewController.m` 中提供了几种简单的使用。

## Requirements

iOS8.0 +

## Installation

HWOperationsKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HWOperationsKit'
```

## Author

HeathWang, yishu.jay@gmail.com

## License

HWOperationsKit is available under the MIT license. See the LICENSE file for more info.
