//
//  UIViewController+RWTransition.h
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/11.
//  RW：添加一个属性RWTransitionType，这样必须选择转场动画的样式

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RWBaseAnimation;

@protocol RWInteractivePopTransitionStateUpdateDelegate <NSObject>
@optional;
/// 是否允许Pop转场
- (BOOL)isEnableStartPopTransition;
/// 开始转场
- (void)interactivePopTransitionStart;
/// 正在交互中
- (void)interactivePopTransitionChanging;
/// 转场完成
- (void)interactivePopTransitionCompleted;
/// 转场取消
- (void)interactivePopTransitionCancled;
@end


typedef NS_ENUM(NSInteger,RWTransitionType){
    RWTransitionType_TuoTiao = 1 << 0,
};


@interface UIViewController (RWTransition)
/// 自定义的全局返回手势，替换系统的返回手势
@property (nonatomic, strong) UIPanGestureRecognizer *rw_fullScreenPopGestureRecognizer;
/// 转场动画类型： 默认是RWTransitionType_TuoTiao
@property (nonatomic, assign) RWTransitionType  transitionType;
/// 动画执行时间：默认是 0.4f
@property (nonatomic, assign) NSTimeInterval  duration;
/// 屏幕截图
@property (nonatomic, strong, nullable) UIView *snapshot;
/// Pop交互转场动画
@property (nonatomic, strong, nullable) UIPercentDrivenInteractiveTransition *interactivePopTransition;
/// 可交互状态代理
@property (nonatomic, weak  , nullable) id<RWInteractivePopTransitionStateUpdateDelegate>  interActiveTransitionDelegate;
@end

NS_ASSUME_NONNULL_END
