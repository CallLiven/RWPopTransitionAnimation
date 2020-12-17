//
//  RWTranstion.m
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/11.
//

#import "RWTranstionManager.h"
#import "RWBaseAnimation.h"
#import "RWTouTiaoAnimation.h"

@interface RWTranstionManager()
@property (nonatomic, assign, readwrite) RWTransitionType type;
@end


@implementation RWTranstionManager

+ (instancetype)shareInstance {
    static RWTranstionManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [RWTranstionManager new];
        _instance.type = RWTransitionType_TuoTiao;
    });
    return _instance;
}

- (void)defaultPushTransitionAnimation:(RWTransitionType)type {
    self.type = type;
}


#pragma mark - UINavigationControllerDelegate
/// 交互手势
- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(RWBaseAnimation *) animationController API_AVAILABLE(ios(7.0)) {
    return animationController.interactivePopTransition;
}



/// 普通手势
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC  API_AVAILABLE(ios(7.0)) {
    RWTransitionType type;
    NSTimeInterval duration;
    if (operation == UINavigationControllerOperationPush) {
        type = toVC.transitionType;
        duration = toVC.duration;
    }else{
        type = fromVC.transitionType;
        duration = fromVC.duration;
    }
        
    RWBaseAnimation *animation = [self transitionAnimationObjcWithType:type];
    animation.opeartion = operation;
    animation.duration = duration;
    animation.interactivePopTransition = fromVC.interactivePopTransition;
    return animation;
}


#pragma mark - Private Method
/// 返回转场动画实例
/// @param type 转场样式
- (nullable RWBaseAnimation *)transitionAnimationObjcWithType:(RWTransitionType)type {
    /// viewController的type，优先级比较高
    if (self.type != 0 && type == 0) {
        type = self.type;
    }
    if (self.type == 0 && type == 0) {
        type = RWTransitionType_TuoTiao;
    }
    
    switch (type) {
        case RWTransitionType_TuoTiao:
            return [RWTouTiaoAnimation new];
            break;

        default:
            return nil;
            break;
    }
}



@end
