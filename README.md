# RWPopTransitionAnimation
轻松接入各种转场动画

![](https://upload-images.jianshu.io/upload_images/1923392-e3be9f916cfb4c20.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**2020年12月21日更新（详情请看最底部）**

***

RWPopTransitionAnimation框架实现讲解请查看[文章](https://www.jianshu.com/p/79ef0866c707)

为了降低使用成本和项目的耦合性，很多使用了Runtime的方式植入转场效果。

<img src="https://upload-images.jianshu.io/upload_images/1923392-ed7b3b761eb46b71.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" style="zoom:50%;" />

**PS : DEMO中LENavigationBarTransition也是一个完整的独立框架，能够很好的完成转场过程中，导航栏的友好过渡（比如两个导航栏颜色不一致，或者其中一个是透明的）**



## 使用方式如下：

**第一步：将DEMO的三个文件夹添加到项目目录中**

<img src="https://upload-images.jianshu.io/upload_images/1923392-e7bfef27d4902673.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" style="zoom:50%;" />



**第二步： 框架默认转场效果是头条转场效果（RWTransitionType_TuoTiao）**

修改转场效果样式，有两个方式

**（1）全局设置**

```objc
#import "RWTranstionManager.h"

[[RWTranstionManager shareInstance] defaultPushTransitionAnimation:RWTransitionType_TuoTiao];
```

**（2）ViewController**（优先级更高）

```objc
#import "UIViewController+RWTransition.h"

BController *bvc = [BController new];
bvc.transitionType = RWTransitionType_TuoTiao;
[self.navigationController pushViewController:bvc animated:YES];
```



# **监听转场状态**

导入`UIViewController+RWTransition.h`文件，实现`interActiveTransitionDelegate`代理

```objc
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
```



# **如果框架定义的转场动画，不能满足需求，可以自定义，轻松添加转场动画效果**

（1）创建动画类继承于`RWBaseAnimation`

（2）在以下两个方法中实现具体的动画内容

```objc
/// 自定义push和pol转场动画
/// @param transitionContext 转场上下文
- (void)pushTransition:(id<UIViewControllerContextTransitioning>)transitionContext;
- (void)popTransition:(id<UIViewControllerContextTransitioning>)transitionContext;
```

（3）在文件`UIViewController+RWTransition.h`添加多一种转场类型

```objc
typedef NS_ENUM(NSInteger,RWTransitionType){
    RWTransitionType_TuoTiao = 1 << 0,
};
```

（4）在文件`RWTranstionManager`中，根据转场类型，返回对应的转场动画对象

```objc
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
        case 自定义的类型：
        		return 自定义的转场动画对象;
						break;
        default:
            return nil;
            break;
    }
}
```





## **2020年12月21日** 更新

内容：

**（1）兼容多个分页滑动，比如像头条。**

**（2）手势冲突解决**

**（3）正确识别滑动动作，避免上下滑动出现返回转场的误动作**

代码：

**（1）创建一个UIScrollView的分类（UIScrollView+RWTransition），处理手势互斥及识别滑动动作**

```objc
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
```

**（2）在给ViewController添加滑动手势的时候，添加多一个条件。目的出现多个ViewController的时候不会重复添加滑动返回手势**

```objc
@implementation UIViewController (RWTransition)
  
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

@end
```





## **2020年12月21日** 再次更新

内容：修复全局手势多次PUSH之后失效的BUG

致命错误：每一个ViewController都创建一个返回手势添加到navigationController.view上，导致navigationController.view上的手势越来越多，并且这些手势互斥，最终只有最上面的手势会响应

解决方法：

根据系统定义的全局返回手势方式，其生命周期应该跟navigationController一致的，所以返回手势不再是viewController的生命周期内创建，会在navigationController创建的时候一并创建，而且返回手势的target是在viewDidAppear的时候修改为当前ViewController的事件，然后再viewDidDisappear的时候，再移除。必须做到一加一除，才能避免同时有多个target响应返回手势。



代码：

```objc
@interface UINavigationController (RWTransition)
/// 自定义的全局返回手势，替换系统的返回手势
@property (nonatomic, strong) UIPanGestureRecognizer *rw_fullScreenPopGestureRecognizer;
@end
```

```objc
@implementation UIViewController (RWTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RWSwizzleMethod([self class],
                        @selector(viewDidAppear:),
                        [self class],
                        @selector(rw_viewDidAppear:));
        RWSwizzleMethod([self class],
                        @selector(viewDidDisappear:),
                        [self class],
                        @selector(rw_viewDidDisappear:));
    });
}

/// 添加全局手势响应target
- (void)rw_viewDidAppear:(BOOL)animated {
    if (self.navigationController && self.navigationController.viewControllers.count >= 2 && self.navigationController.viewControllers.lastObject == self) {
        [self.navigationController.rw_fullScreenPopGestureRecognizer addTarget:self action:@selector(rw_handleGesture:)];
    }
    [self rw_viewDidAppear:animated];
}

/// 移除全局手势响应target
- (void)rw_viewDidDisappear:(BOOL)animated {
    if (self.navigationController) {
        [self.navigationController.rw_fullScreenPopGestureRecognizer removeTarget:self action:@selector(rw_handleGesture:)];
    }
    [self rw_viewDidDisappear:animated];
}


@end
```

