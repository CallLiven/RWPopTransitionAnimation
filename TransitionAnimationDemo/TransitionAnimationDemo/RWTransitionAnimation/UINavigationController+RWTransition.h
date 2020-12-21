//
//  UINavigationController+RWTransition.h
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/11.
//  RW：作用 将UINavigationController的Delegate设置为RWTransition单例
//  目标：只要添加项目的界面，转场方式都统一设置

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (RWTransition)
/// 自定义的全局返回手势，替换系统的返回手势
@property (nonatomic, strong) UIPanGestureRecognizer *rw_fullScreenPopGestureRecognizer;
@end

NS_ASSUME_NONNULL_END
