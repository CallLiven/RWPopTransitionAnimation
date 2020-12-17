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
    
    CGRect bounds               = [[UIScreen mainScreen] bounds];
    
    
    /// 将fromVC.view.hidden隐藏
    fromVC.view.hidden          = YES;
    
    
    /// 将toVC.view 添加到视图容器中containerView
//    NSLog(@"%@",toVC.view.superview);
//    NSLog(@"----------");
    /// Push： 这个时候 fromVC 与 toVC 已经入栈，在navigationViewController.viewControllers中
//    NSLog(@"%@",fromVC.navigationController.viewControllers);
    
    [[transitionContext containerView] addSubview:toVC.view];
    
//    UIView *navigationControllerView = toVC.navigationController.view;
//    NSLog(@"%@",[transitionContext containerView]);
//    NSLog(@"%@",navigationControllerView);
//    NSLog(@"%@",toVC.view);
//    NSLog(@"%@",toVC.view.superview);
//    NSLog(@"%@",toVC.navigationController.view.superview);
//    [toVC.navigationController.view insertSubview:fromVC.snapshot belowSubview:toVC.navigationController.view];
    [[toVC.navigationController.view superview] insertSubview:fromVC.snapshot belowSubview:toVC.navigationController.view];
    
    
    /// 初始位置：屏幕右边
    toVC.navigationController.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(bounds), 0);
    if (fromVC.tabBarController)
    {
        fromVC.tabBarController.tabBar.hidden = YES;
    }
    
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
    
//    if ([WTKTransition shareManager].isShowShadow)
//    {
        fromVC.snapshot.layer.shadowColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8].CGColor;
        fromVC.snapshot.layer.shadowOffset = CGSizeMake(-3, 0);
        fromVC.snapshot.layer.shadowOpacity = 0.5;
//    }
    
    fromVC.view.hidden              = YES;
    fromVC.navigationController.navigationBar.hidden = YES;
    fromVC.view.transform = CGAffineTransformIdentity;
    
    toVC.view.hidden                = YES;
    toVC.snapshot.transform         = CGAffineTransformMakeScale(0.95, 0.95);
    toVC.snapshot.alpha             = 0.7;
    
    [[transitionContext containerView] addSubview:toVC.view];
    [[transitionContext containerView] addSubview:toVC.snapshot];
    [[transitionContext containerView] sendSubviewToBack:toVC.snapshot];
    [[transitionContext containerView] addSubview:fromVC.snapshot];
    
    if (toVC.tabBarController && toVC ==[toVC.navigationController viewControllers].firstObject)
    {
        toVC.tabBarController.tabBar.hidden = YES;
        self.tabbarFlag = YES;
    }
    
    if (fromVC.interactivePopTransition)
    {
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             fromVC.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(bounds), 0.0);
                             fromVC.snapshot.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(bounds), 0.0);
                             toVC.snapshot.transform = CGAffineTransformIdentity;
                             toVC.snapshot.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             
                             toVC.navigationController.navigationBar.hidden = NO;
                             toVC.view.hidden = NO;
                             fromVC.view.hidden              = NO;
                             [fromVC.snapshot removeFromSuperview];
                             [toVC.snapshot removeFromSuperview];
                             fromVC.snapshot = nil;
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             if (![transitionContext transitionWasCancelled])
                             {
                                 toVC.snapshot = nil;
                                 if (_tabbarFlag)
                                 {
                                     toVC.tabBarController.tabBar.hidden = NO;
                                 }
                             }
//                             else
//                             {
//                                 [[NSNotificationCenter defaultCenter] postNotificationName:WTK_CANCEL_POP object:nil];
//                             }
                             
                         }];
        
    }
    else
    {
        [UIView animateWithDuration:duration
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             fromVC.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(bounds), 0.0);
                             fromVC.snapshot.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(bounds), 0.0);
                             toVC.snapshot.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             
                             toVC.navigationController.navigationBar.hidden = NO;
                             toVC.view.hidden = NO;
                             fromVC.view.hidden              = NO;
                             [fromVC.snapshot removeFromSuperview];
                             [toVC.snapshot removeFromSuperview];
                             fromVC.snapshot = nil;
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             if (![transitionContext transitionWasCancelled]) {
                                 toVC.snapshot = nil;
                                 if (_tabbarFlag)
                                 {
                                     toVC.tabBarController.tabBar.hidden = NO;
                                 }
                             }
//                             else
//                             {
//                                 [[NSNotificationCenter defaultCenter] postNotificationName:WTK_CANCEL_POP object:nil];
//                             }
                             
                             
                         }];
    }
}

@end
