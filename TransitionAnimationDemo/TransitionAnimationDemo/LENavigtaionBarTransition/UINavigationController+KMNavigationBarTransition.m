//
//  UINavigationController+KMNavigationBarTransition.m
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

#import "UINavigationController+KMNavigationBarTransition.h"
#import "UINavigationController+KMNavigationBarTransition_internal.h"
#import "UIViewController+KMNavigationBarTransition.h"
#import "UIViewController+KMNavigationBarTransition_internal.h"
#import "UINavigationBar+KMNavigationBarTransition_internal.h"
#import "RWWeakObjectContainer.h"
#import "RWSwizzle.h"

#import <objc/runtime.h>

@implementation UINavigationController (KMNavigationBarTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RWSwizzleMethod([self class],
                        @selector(pushViewController:animated:),
                        [self class],
                        @selector(km_pushViewController:animated:));
        
        RWSwizzleMethod([self class],
                        @selector(popViewControllerAnimated:),
                        [self class],
                        @selector(km_popViewControllerAnimated:));
        
        RWSwizzleMethod([self class],
                        @selector(popToViewController:animated:),
                        [self class],
                        @selector(km_popToViewController:animated:));
        
        RWSwizzleMethod([self class],
                        @selector(popToRootViewControllerAnimated:),
                        [self class],
                        @selector(km_popToRootViewControllerAnimated:));
        
        RWSwizzleMethod([self class],
                        @selector(setViewControllers:animated:),
                        [self class],
                        @selector(km_setViewControllers:animated:));
    });
}

/// Push
/// 导航栏跳转下一级
- (void)km_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    /// 跳转的页面，界面A
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    /// 如果是栈的第一个VC的话，就直接调用PUSH
    if (!disappearingViewController) {
        return [self km_pushViewController:viewController animated:animated];
    }

    /// A界面，添加一个假的导航栏
    if (!self.km_transitionContextToViewController || !disappearingViewController.km_transitionNavigationBar) {
        [disappearingViewController km_addTransitionNavigationBarIfNeeded];
    }
    
    /// 将A界面的 真导航栏隐藏
    if (animated) {
        self.km_transitionContextToViewController = viewController;
        if (disappearingViewController.km_transitionNavigationBar) {
            disappearingViewController.navigationController.km_backgroundViewHidden = YES;
        }
    }
    return [self km_pushViewController:viewController animated:animated];
}

/// Pop
/// 返回上一级
- (UIViewController *)km_popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count < 2) {
        return [self km_popViewControllerAnimated:animated];
    }
    /// 即将消失的VC，比如B界面
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    [disappearingViewController km_addTransitionNavigationBarIfNeeded];
    /// 切入的VC，比如A界面
    UIViewController *appearingViewController = self.viewControllers[self.viewControllers.count - 2];
    if (appearingViewController.km_transitionNavigationBar) {
        UINavigationBar *appearingNavigationBar = appearingViewController.km_transitionNavigationBar;
        self.navigationBar.tintColor = appearingNavigationBar.tintColor;
        [self.navigationBar setBackgroundImage:[appearingNavigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = appearingNavigationBar.shadowImage;
    }
    if (animated) {
        disappearingViewController.navigationController.km_backgroundViewHidden = YES;
    }
    return [self km_popViewControllerAnimated:animated];
}


/// Pop 跳转到指定界面
- (NSArray<UIViewController *> *)km_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (![self.viewControllers containsObject:viewController] || self.viewControllers.count < 2) {
        return [self km_popToViewController:viewController animated:animated];
    }
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    [disappearingViewController km_addTransitionNavigationBarIfNeeded];
    if (viewController.km_transitionNavigationBar) {
        UINavigationBar *appearingNavigationBar = viewController.km_transitionNavigationBar;
        self.navigationBar.tintColor = appearingNavigationBar.tintColor;
        [self.navigationBar setBackgroundImage:[appearingNavigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = appearingNavigationBar.shadowImage;
    }
    if (animated) {
        disappearingViewController.navigationController.km_backgroundViewHidden = YES;
    }
    return [self km_popToViewController:viewController animated:animated];
}


/// Pop 导航栏根视图
- (NSArray<UIViewController *> *)km_popToRootViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count < 2) {
        return [self km_popToRootViewControllerAnimated:animated];
    }
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    [disappearingViewController km_addTransitionNavigationBarIfNeeded];
    UIViewController *rootViewController = self.viewControllers.firstObject;
    if (rootViewController.km_transitionNavigationBar) {
        UINavigationBar *appearingNavigationBar = rootViewController.km_transitionNavigationBar;
        self.navigationBar.tintColor = appearingNavigationBar.tintColor;
        [self.navigationBar setBackgroundImage:[appearingNavigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = appearingNavigationBar.shadowImage;
    }
    if (animated) {
        disappearingViewController.navigationController.km_backgroundViewHidden = YES;
    }
    return [self km_popToRootViewControllerAnimated:animated];
}


- (void)km_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (animated && disappearingViewController && ![disappearingViewController isEqual:viewControllers.lastObject]) {
        [disappearingViewController km_addTransitionNavigationBarIfNeeded];
        if (disappearingViewController.km_transitionNavigationBar) {
            disappearingViewController.navigationController.km_backgroundViewHidden = YES;
        }
    }
    return [self km_setViewControllers:viewControllers animated:animated];
}


#pragma mark - Getter/Setter
/// 导航栏背景视图是否隐藏hidden
- (BOOL)km_backgroundViewHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setKm_backgroundViewHidden:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(km_backgroundViewHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UIView *backgroundView = [self.navigationBar rw_navigationBarBackgroundView];
    UIView *contentView = [self.navigationBar rw_navigationBarContentView];
    backgroundView.alpha = hidden?0:1;
    contentView.hidden = hidden;
}

- (UIViewController *)km_transitionContextToViewController {
    return rw_objc_getAssociatedWeakObject(self, _cmd);
}

- (void)setKm_transitionContextToViewController:(UIViewController *)viewController {
    rw_objc_setAssociatedWeakObject(self, @selector(km_transitionContextToViewController), viewController);
}

@end
