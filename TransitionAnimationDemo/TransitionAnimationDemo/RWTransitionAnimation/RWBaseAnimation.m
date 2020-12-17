//
//  RWTransitionAnimation.m
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/14.
//

#import "RWBaseAnimation.h"

@implementation RWBaseAnimation

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}


- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.opeartion == UINavigationControllerOperationPush) {
        [self pushTransition:transitionContext];
    }
    else if (self.opeartion == UINavigationControllerOperationPop) {
        [self popTransition:transitionContext];
    }
}


- (void)pushTransition:(id<UIViewControllerContextTransitioning>)transitionContext {}
- (void)popTransition:(id<UIViewControllerContextTransitioning>)transitionContext {}

@end
