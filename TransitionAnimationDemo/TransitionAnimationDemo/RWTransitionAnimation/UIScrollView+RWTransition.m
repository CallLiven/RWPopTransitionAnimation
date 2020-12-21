//
//  UIScrollView+RWTransition.m
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/21.
//

#import "UIScrollView+RWTransition.h"

@implementation UIScrollView (RWTransition)

/// 本手势是否和other另外一个手势共存
/// 只有有一个手势，这个代理方法返回了YES，那么就是共存（也就是都有效）
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    /// 首先判断otherGestureRecognizer是不是系统pop手势
    if ([otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UILayoutContainerView")]) {
        /// 再判断系统手势的state是began还是fail，同时判断scrollView的位置是不是正好在最左边
        if (otherGestureRecognizer.state == UIGestureRecognizerStateBegan || otherGestureRecognizer.state == UIGestureRecognizerStatePossible) {
            UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)otherGestureRecognizer;
            CGPoint point = [pan translationInView:otherGestureRecognizer.view];
            /// 为了解决上下滑动触发返回手势的 误触发
            /// 添加 fabs(point.x) >= fabs(point.y)条件
            /// 判断上下滑动还是左右滑动：x方向的滑动距离 大于等于 y方向的滑动距离 则是左右滑动
            if (point.x > 0 && (fabs(point.x) >= fabs(point.y)) && self.contentOffset.x <= 0) {
                return YES;
            }
        }
    }
    return NO;
}


/// 处理兼容多手势的时候
/// 在右滑返回的时候，ScrollView也会滑动
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [pan translationInView:self];
        UIGestureRecognizerState state = gestureRecognizer.state;
        if (UIGestureRecognizerStateBegan == state || UIGestureRecognizerStatePossible == state) {
            if (point.x > 0 && self.contentOffset.x <= 0) {
                return NO;
            }
        }
    }
    return YES;
}

@end
