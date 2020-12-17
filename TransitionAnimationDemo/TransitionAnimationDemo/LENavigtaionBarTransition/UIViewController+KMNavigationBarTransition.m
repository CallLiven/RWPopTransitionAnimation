//
//  UIViewController+KMNavigationBarTransition.m
//
//  Copyright (c) 2017 Zhouqi Mo (https://github.com/MoZhouqi)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "UIViewController+KMNavigationBarTransition.h"
#import "UINavigationController+KMNavigationBarTransition.h"
#import "UINavigationController+KMNavigationBarTransition_internal.h"
#import "UINavigationBar+KMNavigationBarTransition_internal.h"
#import "UIViewController+KMNavigationBarTransition_internal.h"
#import "RWSwizzle.h"

#import <objc/runtime.h>


@implementation UIViewController (KMNavigationBarTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RWSwizzleMethod([self class],
                        @selector(viewWillLayoutSubviews),
                        [self class],
                        @selector(km_viewWillLayoutSubviews));
        RWSwizzleMethod([self class],
                        @selector(viewDidAppear:),
                        [self class],
                        @selector(km_viewDidAppear:));
    });
}

/// 为B界面添加假导航栏
/// 将真的导航栏隐藏，添加一个假的导航栏
- (void)km_viewWillLayoutSubviews {
    id<UIViewControllerTransitionCoordinator> tc = self.transitionCoordinator;
    /// PUSH的原界面，比如：A界面
    UIViewController *fromViewController = [tc viewControllerForKey:UITransitionContextFromViewControllerKey];
    /// PUSH出来的界面，比如：B界面
    UIViewController *toViewController = [tc viewControllerForKey:UITransitionContextToViewControllerKey];
    
    /// 要PUSH的界面，比如：B界面
    if ([self isEqual:self.navigationController.viewControllers.lastObject] && [toViewController isEqual:self] && tc.presentationStyle == UIModalPresentationNone) {
        fromViewController.view.clipsToBounds = NO;
        toViewController.view.clipsToBounds = NO;
        /// 如果没有过渡navigatonBar
        if (!self.km_transitionNavigationBar) {
            /// 添加一个过渡navigationBar
            [self km_addTransitionNavigationBarIfNeeded];
            /// 设置导航栏的backgroundImage隐藏
            self.navigationController.km_backgroundViewHidden = YES;
        }
        /// 重置过渡navigationBar的frame
        [self km_resizeTransitionNavigationBarFrame];
    }
    
    /// 将过渡navigationBar置顶
    if (self.km_transitionNavigationBar) {
        [self.view bringSubviewToFront:self.km_transitionNavigationBar];
    }
    [self km_viewWillLayoutSubviews];
}


/// 将真的导航栏显示，并将假的导航栏移除
/// @param animated animated
- (void)km_viewDidAppear:(BOOL)animated {
    /// PUSH的界面VC，比如：界面B
    UIViewController *transitionViewController = self.navigationController.km_transitionContextToViewController;
    if (self.km_transitionNavigationBar) {
        /// （2）将titleView添加到原来的导航栏上
        if (self.km_transitionNavigationBar.topItem.titleView) {
            [self.km_transitionNavigationBar.rw_titleViewSuperView addSubview:self.km_transitionNavigationBar.topItem.titleView];
        }
        self.navigationController.navigationBar.titleTextAttributes = self.km_transitionNavigationBar.titleTextAttributes;
        self.navigationController.navigationBar.barTintColor = self.km_transitionNavigationBar.barTintColor;
        self.navigationController.navigationBar.tintColor = self.km_transitionNavigationBar.tintColor;
        [self.navigationController.navigationBar setBackgroundImage:[self.km_transitionNavigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:self.km_transitionNavigationBar.shadowImage];
        
        if (!transitionViewController || [transitionViewController isEqual:self]) {
//            NSLog(@"移除假的导航栏 %@",NSStringFromClass(self.class));
            [self.km_transitionNavigationBar removeFromSuperview];
            self.km_transitionNavigationBar = nil;
        }
    }
    if ([transitionViewController isEqual:self]) {
        self.navigationController.km_transitionContextToViewController = nil;
    }
    
    if ([self.navigationController.viewControllers.lastObject isEqual:self]) {
        self.navigationController.km_backgroundViewHidden = NO;
    }
    [self km_viewDidAppear:animated];
}



/// 重置过渡导航栏的frame
- (void)km_resizeTransitionNavigationBarFrame {
    /// 只有当self.view被添加到window时，才会继续
    if (!self.view.window) {
        return;
    }
    /// frame的切换
    UIView *backgroundView = [self.navigationController.navigationBar rw_navigationBarBackgroundView];
    CGRect rect = [backgroundView.superview convertRect:backgroundView.frame toView:self.view];
//    NSLog(@"设置 %@ 的 假导航栏 frame是 %@, _backgroundView的alpha %f",NSStringFromClass(self.class),NSStringFromCGRect(rect),backgroundView.alpha);
    self.km_transitionNavigationBar.frame = rect;
}


/// 创建一个过渡navigationBar（是添加到self.view上的）
- (void)km_addTransitionNavigationBarIfNeeded {
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }
    if (!self.navigationController.navigationBar) {
        return;
    }
    /// 根据导航栏的内容创建一个一模一样的自定义导航栏
//    NSLog(@"添加假的导航栏 %@",NSStringFromClass(self.class));
    UINavigationBar *bar = [[UINavigationBar alloc] init];
    bar.km_isFakeBar = YES;
    bar.barStyle = self.navigationController.navigationBar.barStyle;
    bar.tintColor = self.navigationController.navigationBar.tintColor;
    bar.barTintColor = self.navigationController.navigationBar.barTintColor;
    bar.shadowImage = self.navigationController.navigationBar.shadowImage;
    bar.titleTextAttributes = self.navigationController.navigationBar.titleTextAttributes;
    [bar setBackgroundImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    
    UINavigationItem *orginBackItem = self.navigationController.navigationBar.backItem;
    UINavigationItem *orginTopItem = self.navigationController.navigationBar.topItem;
    /// （1）这里需要将titleView原先的superView对象指针保存起来，因为下面通过自定义的navigationBar pushNavigationItem，会将titleView移到自定义的bar上，
    ///     这样会导致移除自定义的过渡导航栏时，原来导航栏navigationController.navigationBar不会显示titleView
    bar.rw_titleViewSuperView = self.navigationItem.titleView.superview;
    if (orginBackItem) {
        [bar pushNavigationItem:orginBackItem animated:NO];
    }
    if (orginTopItem) {
        [bar pushNavigationItem:orginTopItem animated:NO];
    }
    
    [self.km_transitionNavigationBar removeFromSuperview];
    self.km_transitionNavigationBar = bar;
    /// 重置过渡导航栏的frame
    [self km_resizeTransitionNavigationBarFrame];
    /// 原配的导航栏没隐藏的时候，添加过渡导航栏
    if (!self.navigationController.navigationBarHidden && !self.navigationController.navigationBar.hidden) {
        [self.view addSubview:self.km_transitionNavigationBar];
    }
}


#pragma mark - Getter/Setter
/// 转场导航栏自定义的
- (UINavigationBar *)km_transitionNavigationBar {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setKm_transitionNavigationBar:(UINavigationBar *)navigationBar {
    objc_setAssociatedObject(self, @selector(km_transitionNavigationBar), navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
