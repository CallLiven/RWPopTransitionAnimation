//
//  RWTuoTiaoAnimation.m
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/14.
//

#import "RWTouTiaoAnimation.h"

@interface RWTouTiaoAnimation()
@property(nonatomic,assign)BOOL tabbarFlag;
@end

@implementation RWTouTiaoAnimation

- (void)pushTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController * fromVC   = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toVC     = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSTimeInterval duration     = [self transitionDuration:transitionContext];
    /// 屏幕尺寸
    CGRect bounds               = [[UIScreen mainScreen] bounds];
    /// 将fromVC.view.hidden隐藏
    fromVC.view.hidden          = YES;
    /// 将要切入的视图，展示出来
    [[transitionContext containerView] addSubview:toVC.view];
    /// 将要fromVC的截图添加到底部
    [[toVC.navigationController.view superview] insertSubview:fromVC.snapshot belowSubview:toVC.navigationController.view];

    [toVC.navigationController.view superview].backgroundColor = UIColor.blackColor;
    fromVC.navigationController.view.backgroundColor = UIColor.blackColor;
    
    /// 设置切入视图的初始位置：屏幕最右边
    toVC.navigationController.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(bounds), 0);
    /// 如果切出的视图是有tabBarController，那么就将其隐藏
    if (fromVC.tabBarController) {
        fromVC.tabBarController.tabBar.hidden = YES;
    }
    
    /// 添加左滑动画
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:1.0
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         fromVC.snapshot.transform = CGAffineTransformMakeScale(0.95, 0.95);
                         fromVC.snapshot.alpha = 0.7;
                         toVC.navigationController.view.transform = CGAffineTransformMakeTranslation(0, 0);
                     }
                     completion:^(BOOL finished) {
                         fromVC.view.hidden = NO;
                         [fromVC.snapshot removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
}


- (void)popTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.tabbarFlag                 = NO;
    UIViewController * fromVC       = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toVC         = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSTimeInterval duration         = [self transitionDuration:transitionContext];
    
    CGRect bounds                   = [[UIScreen mainScreen] bounds];
    
    /// 如果是可交互转场的话，添加阴影效果
    if (transitionContext.isInteractive)
    {
        fromVC.view.layer.shadowColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.8].CGColor;
        fromVC.view.layer.shadowOffset = CGSizeMake(-3, 0);
        fromVC.view.layer.shadowOpacity = 0.6;
    }
    
    /// 还原，不做任何的变换
    fromVC.view.transform = CGAffineTransformIdentity;
    
    /// 将toVC隐藏，转为显示其截图，并设置其初始状态
    toVC.view.hidden                = YES;
    toVC.snapshot.transform         = CGAffineTransformMakeScale(0.95, 0.95);
    toVC.snapshot.alpha             = transitionContext.isInteractive ? 0.7 : 1;
    
    [[transitionContext containerView] addSubview:toVC.view];
    [[transitionContext containerView] addSubview:toVC.snapshot];
    [[transitionContext containerView] sendSubviewToBack:toVC.snapshot];
    
    /// 如果是有tabBar的，则将其隐藏
    if (toVC.tabBarController && toVC ==[toVC.navigationController viewControllers].firstObject)
    {
        toVC.tabBarController.tabBar.hidden = YES;
        self.tabbarFlag = YES;
    }
    
    /// 可交互转场
    if (fromVC.interactivePopTransition)
    {
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             fromVC.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(bounds), 0.0);
                             toVC.snapshot.transform = CGAffineTransformIdentity;
                             toVC.snapshot.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             toVC.navigationController.navigationBar.hidden = NO;
                             toVC.view.hidden = NO;
                             [toVC.snapshot removeFromSuperview];
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             if (![transitionContext transitionWasCancelled])
                             {
                                 toVC.snapshot = nil;
                                 if (self.tabbarFlag)
                                 {
                                     toVC.tabBarController.tabBar.hidden = NO;
                                 }
                             }
                             
                         }];
        
    }
    else
    {
        /// 普通转场
        [UIView animateWithDuration:duration
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             fromVC.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(bounds), 0.0);
                             toVC.snapshot.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             toVC.navigationController.navigationBar.hidden = NO;
                             toVC.view.hidden = NO;
                             [toVC.snapshot removeFromSuperview];
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             if (![transitionContext transitionWasCancelled]) {
                                 toVC.snapshot = nil;
                                 if (self.tabbarFlag)
                                 {
                                     toVC.tabBarController.tabBar.hidden = NO;
                                 }
                             }

                         }];
    }
}

@end
