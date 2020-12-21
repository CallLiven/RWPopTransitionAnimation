//
//  UIViewController+RWTransition.m
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/11.
//

#import "UIViewController+RWTransition.h"
#import "RWSwizzle.h"
#import "RWTranstionManager.h"
#import "RWWeakObjectContainer.h"

#import <objc/runtime.h>

#define TransitionTypeKey           @"TransitionTypeKey"
#define TransitionDurationKey       @"TransitionDurationKey"
#define TransitionSnapsShotKey      @"TransitionSnapsShotKey"
#define InteractivePopTransitionKey @"InteractivePopTransitionKey"
#define InteractivePopTransitionDelegateKey @"InteractivePopTransitionDelegateKey"

@implementation UIViewController (RWTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RWSwizzleMethod([self class], @selector(viewDidLoad), [self class], @selector(rw_viewDidLoad));
    });
}

/// 添加全局返回手势
- (void)rw_viewDidLoad {
    if (self.navigationController && self != self.navigationController.viewControllers.firstObject) {
        /// 虽然会有多个ViewController，但是入栈的肯定只有最外层的ViewController
        if (self.navigationController.viewControllers.lastObject == self) {
            [self.navigationController.view addGestureRecognizer:self.rw_fullScreenPopGestureRecognizer];
            [self.rw_fullScreenPopGestureRecognizer addTarget:self action:@selector(handleGesture:)];
        }
    }
    [self rw_viewDidLoad];
}

/// 更新交互转场状态
- (void)handleGesture:(UIPanGestureRecognizer *)pan {
    static BOOL _isDragging = NO;
    CGFloat progress = [pan translationInView:self.view].x / CGRectGetWidth(self.view.frame);
    progress = MIN(1.0, MAX(0.0, progress));
    if (progress <= 0 && !_isDragging && pan.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    if (self.interActiveTransitionDelegate && [self.interActiveTransitionDelegate respondsToSelector:@selector(isEnableStartPopTransition)]) {
        if (![self.interActiveTransitionDelegate isEnableStartPopTransition]) {
            return;
        }
    }

    if (pan.state == UIGestureRecognizerStateBegan) {
        _isDragging = YES;
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc]init];
        [self interactivePopStartAction];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (pan.state == UIGestureRecognizerStateChanged) {
        _isDragging = YES;
        [self interactivePopChangeAction];
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    else if (pan.state == UIGestureRecognizerStateEnded ||
             pan.state == UIGestureRecognizerStateCancelled) {
        _isDragging = NO;
        if (progress > 0.25) {
            [self interactivePopCompletionAction];
            [self.interactivePopTransition finishInteractiveTransition];
        }else{
            [self interactivePopCancleAction];
            [self.interactivePopTransition cancelInteractiveTransition];
        }
        self.interactivePopTransition = nil;
    }
}


#pragma mark - Action
- (void)interactivePopStartAction {
    if (self.interActiveTransitionDelegate && [self.interActiveTransitionDelegate respondsToSelector:@selector(interactivePopTransitionStart)]) {
        [self.interActiveTransitionDelegate interactivePopTransitionStart];
    }
}

- (void)interactivePopChangeAction {
    if (self.interActiveTransitionDelegate && [self.interActiveTransitionDelegate respondsToSelector:@selector(interactivePopTransitionChanging)]) {
        [self.interActiveTransitionDelegate interactivePopTransitionChanging];
    }
}

- (void)interactivePopCompletionAction {
    if (self.interActiveTransitionDelegate && [self.interActiveTransitionDelegate respondsToSelector:@selector(interactivePopTransitionCompleted)]) {
        [self.interActiveTransitionDelegate interactivePopTransitionCompleted];
    }
}

- (void)interactivePopCancleAction {
    if (self.interActiveTransitionDelegate && [self.interActiveTransitionDelegate respondsToSelector:@selector(interactivePopTransitionCancled)]) {
        [self.interActiveTransitionDelegate interactivePopTransitionCancled];
    }
}


#pragma mark - getter、setter
/// 转场动画样式
- (RWTransitionType)transitionType {
    NSNumber *value = objc_getAssociatedObject(self, TransitionTypeKey);
    if (value == nil) {
        value = @(0);
        [self setTransitionType:value.integerValue];
    }
    return value.integerValue;
}
- (void)setTransitionType:(RWTransitionType)transitionType {
    objc_setAssociatedObject(self, TransitionTypeKey, @(transitionType), OBJC_ASSOCIATION_ASSIGN);
}


/// 屏幕截图
- (UIView *)snapshot {
    UIView *view = objc_getAssociatedObject(self, TransitionSnapsShotKey);
    if (view == nil) {
        view = self.tabBarController ?
        [self.tabBarController.view snapshotViewAfterScreenUpdates:NO] :
        [self.navigationController.view snapshotViewAfterScreenUpdates:NO];
        [self setSnapshot:view];
    }
    return view;
}
- (void)setSnapshot:(UIView *)snapshot {
    objc_setAssociatedObject(self, TransitionSnapsShotKey, snapshot, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


/// 可交互转场
- (UIPercentDrivenInteractiveTransition *)interactivePopTransition {
    return objc_getAssociatedObject(self, InteractivePopTransitionKey);
}
- (void)setInteractivePopTransition:(UIPercentDrivenInteractiveTransition *)interactivePopTransition {
    objc_setAssociatedObject(self, InteractivePopTransitionKey, interactivePopTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


/// 转场时间
- (NSTimeInterval)duration {
    NSNumber *time = objc_getAssociatedObject(self, TransitionDurationKey);
    if (time == nil) {
        time = @(0.4);
        [self setDuration:time.floatValue];
    }
    return time.floatValue;
}
- (void)setDuration:(NSTimeInterval)duration {
    objc_setAssociatedObject(self, TransitionDurationKey, @(duration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


/// 代理
- (void)setInterActiveTransitionDelegate:(id<RWInteractivePopTransitionStateUpdateDelegate>)interActiveTransitionDelegate {
    rw_objc_setAssociatedWeakObject(self, InteractivePopTransitionDelegateKey, interActiveTransitionDelegate);
}

- (id<RWInteractivePopTransitionStateUpdateDelegate>)interActiveTransitionDelegate {
    return rw_objc_getAssociatedWeakObject(self, InteractivePopTransitionDelegateKey);
}


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
