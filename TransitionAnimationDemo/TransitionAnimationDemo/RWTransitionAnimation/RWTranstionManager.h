//
//  RWTranstion.h
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/11.
//  RW：转场动画管理类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIViewController+RWTransition.h"
NS_ASSUME_NONNULL_BEGIN

@interface RWTranstionManager : NSObject<UINavigationControllerDelegate>
/// 当前转场动画样式
/// 默认：系统转场样式
/// viewController的type属性优先级更高
@property (nonatomic, assign, readonly) RWTransitionType type;

/// 单例对象
+ (instancetype)shareInstance;

/// 修改默认转场样式
/// @param type type
- (void)defaultPushTransitionAnimation:(RWTransitionType)type;

@end

NS_ASSUME_NONNULL_END
