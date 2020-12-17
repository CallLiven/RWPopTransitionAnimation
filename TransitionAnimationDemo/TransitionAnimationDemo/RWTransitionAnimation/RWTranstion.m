//
//  RWTranstion.m
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/11.
//

#import "RWTranstionManager.h"
#import "RWTranstion.h"

@implementation RWTranstionManager

+ (instancetype)shareInstance {
    static RWTranstionManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [RWTranstionManager new];
    });
    return _instance;
}


- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController API_AVAILABLE(ios(7.0)) {
    return nil;
}



- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC  API_AVAILABLE(ios(7.0)) {
    return nil;
}



@end
