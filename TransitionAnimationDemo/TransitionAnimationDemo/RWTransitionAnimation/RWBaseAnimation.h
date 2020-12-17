//
//  RWTransitionAnimation.h
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIViewController+RWTransition.h"

NS_ASSUME_NONNULL_BEGIN

@interface RWBaseAnimation : NSObject<UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) NSTimeInterval  duration;
@property (nonatomic, assign) UINavigationControllerOperation  opeartion;
@property (nonatomic, strong, nullable) UIPercentDrivenInteractiveTransition *interactivePopTransition;


/// 自定义push和pol转场动画
/// @param transitionContext 转场上下文
- (void)pushTransition:(id<UIViewControllerContextTransitioning>)transitionContext;
- (void)popTransition:(id<UIViewControllerContextTransitioning>)transitionContext;
@end

NS_ASSUME_NONNULL_END
