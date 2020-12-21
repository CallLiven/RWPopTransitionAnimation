//
//  UINavigationController+RWTransition.m
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/11.
//

#import "UINavigationController+RWTransition.h"
#import "RWTranstionManager.h"
#import "RWSwizzle.h"
#import <objc/runtime.h>

@implementation UINavigationController (RWTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RWSwizzleMethod([self class],
                        @selector(initWithNibName:bundle:),
                        [self class],
                        @selector(rw_initWithNibName:bundle:));
        
        RWSwizzleMethod([self class],
                        @selector(initWithRootViewController:),
                        [self class],
                        @selector(rw_initWithRootViewController:));
        
        RWSwizzleMethod([self class],
                        @selector(initWithCoder:),
                        [self class],
                        @selector(rw_initWithCoder:));
    });
    
}


- (instancetype)rw_initWithCoder:(NSCoder *)aDecoder {
    UINavigationController *nvc = [self rw_initWithCoder:aDecoder];
    [nvc navigationControllerDelegate];
    return nvc;
}

- (instancetype)rw_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UINavigationController *nvc = [self rw_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [nvc navigationControllerDelegate];
    return nvc;
}

- (instancetype)rw_initWithRootViewController:(UIViewController *)rootViewController {
    UINavigationController *nvc = [self rw_initWithRootViewController:rootViewController];
    [nvc navigationControllerDelegate];
    return nvc;
}

- (void)navigationControllerDelegate {
    self.delegate = [RWTranstionManager shareInstance];
    [self.view addGestureRecognizer:self.rw_fullScreenPopGestureRecognizer];
}

#pragma mark - Getter/Setter
/// 全局手势
- (UIPanGestureRecognizer *)rw_fullScreenPopGestureRecognizer {
    UIPanGestureRecognizer *pan = objc_getAssociatedObject(self, _cmd);
    if (!pan) {
        pan = [[UIPanGestureRecognizer alloc]init];
        pan.maximumNumberOfTouches = 1;
        [self setRw_fullScreenPopGestureRecognizer:pan];
    }
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRw_fullScreenPopGestureRecognizer:(UIPanGestureRecognizer *)rw_fullScreenPopGestureRecognizer {
    objc_setAssociatedObject(self, @selector(rw_fullScreenPopGestureRecognizer), rw_fullScreenPopGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
