# RWPopTransitionAnimation
轻松接入各种转场动画



![](https://upload-images.jianshu.io/upload_images/1923392-e3be9f916cfb4c20.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



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



# **如果框架定义的转场动画，不能满足需求，可以自定义轻松添加转场动画效果**

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



