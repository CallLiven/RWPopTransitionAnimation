//
//  ViewController.m
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/10.
//

#import "ViewController.h"
#import "BController.h"

@interface ViewController ()<UIGestureRecognizerDelegate>

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.purpleColor;
    
    /// 在一个View上添加多个手势对象，默认手势是互斥的，一个手势触发了就会默认屏蔽其他相似的手势动作
    /// 前提是在同一个View上，也就是说在传递链的同一个位置
    /// 对于传递链上不同位置的手势，即使是相似的手势动作，是不会互斥的
    /// 举个例子：比如touchesBegan与添加的tap1和tap2，是可以同时响应的
    /// 如何中断传递链继续向下传递了？
    /// 只要设置tap1 和 tap2 的cancelsTouchesInView属性为NO，那么就不会继续往下传递
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(oneAction)];
    tap1.delegate = self;
    [self.view addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(twoAction)];
    tap2.delegate = self;
    [self.view addGestureRecognizer:tap2];
    
    /// 设置手势互斥，优先处理
    /// 只有手势tap1触发失败，才会触tap2
    /// 也可以通过代理的方式处理互斥的手势
//    [tap2 requireGestureRecognizerToFail:tap1];
}


#pragma mark - Delegate
/// 第一步：收到系统点击事件，如果返回YES，则进行第二步处理
// 手指触摸屏幕后回调的方法，返回NO则不再进行手势识别，方法触发等
// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

/// 第二步：判断是否要处理手势，如果返回YES，则进行第三步处理
// 开始进行手势识别时调用的方法，返回NO则结束，不再触发手势
// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

/// 第三步：如果有多个手势互斥，那么则会触发这个方法，返回YES则允许同时处理多个手势，然后会进入第四步
// 是否支持多时候触发，返回YES，则可以多个手势一起触发方法，返回NO则为互斥; 默认是NO
// 提示：返回YES保证允许同时识别多个手势。但是返回NO不能保证防止同时识别，因为其他手势的委托可能返回YES。
// 比如系统默认的手势触发touchesBegan，应该默认是返回YES
// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


/**
    第四步：
    只有shouldRecognizeSimultaneouslyWithGestureRecognizer多手势处理返回YES，支持多手势的时候才会起作用
    如果实现了下面两个方法之一，那么在多个手势互斥的时候，就只能识别一个了
 */
// 下面这个两个方法也是用来控制手势的互斥执行的
// 这个方法返回YES，第一个手势和第二个互斥时，第一个会失效
// called once per attempt to recognize, so failure requirements can be determined lazily and may be set up between recognizers across view hierarchies
// return YES to set up a dynamic failure requirement between gestureRecognizer and otherGestureRecognizer
//
// note: returning YES is guaranteed to set up the failure requirement. returning NO does not guarantee that there will not be a failure requirement as the other gesture's counterpart delegate or subclass methods may return YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer API_AVAILABLE(ios(7.0)) {
    return YES;
}

// 这个方法返回YES，第一个和第二个互斥时，第二个会失效
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer API_AVAILABLE(ios(7.0)) {
    return YES;
}


// called before pressesBegan:withEvent: is called on the gesture recognizer for a new press. return NO to prevent the gesture recognizer from seeing this press
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceivePress:(UIPress *)press {
    return YES;
}

// called once before either -gestureRecognizer:shouldReceiveTouch: or -gestureRecognizer:shouldReceivePress:
// return NO to prevent the gesture recognizer from seeing this event
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveEvent:(UIEvent *)event API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos) {
    return YES;
}



#pragma mark - Action
- (void)oneAction {
    NSLog(@"第一个手势触发");
}

- (void)twoAction {
    NSLog(@"第二个手势触发");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"屏幕被点击了");
}





- (IBAction)pushAction:(id)sender {
    BController *bvc = [BController new];
    [self.navigationController pushViewController:bvc animated:YES];
}


@end
