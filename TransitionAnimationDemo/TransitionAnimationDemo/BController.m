//
//  BController.m
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/11.
//

#import "BController.h"
#import "RWTitleView.h"
#import "UIViewController+RWTransition.h"
@interface BController ()<RWInteractivePopTransitionStateUpdateDelegate>

@end


@implementation BController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.yellowColor;
    self.interActiveTransitionDelegate = self;
    
    UILabel *titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    titleView.text = @"titleView";
    titleView.textColor = UIColor.blueColor;
    
    /// 调试titleView添加到自定义导航栏后，navigationController上的titleView不显示的问题
    RWTitleView *redView = [[RWTitleView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    redView.backgroundColor = UIColor.redColor;
    
    /// 这里有一个BUG
    /// 如果通过navigationItem.titleView 来设置导航头部内容，那么在转场后就会变没了（问题已解决：通过保存titleView原来的父视图，然后在要显示导航栏时，将其移动到其上面就可以了）
    /// 如果这是设置title，就没什么问题
    self.navigationItem.titleView = redView;
    /// self.navigationItem.title = @"1234";
    
    /// 对于自定义UINavigationBar有一个巨坑，貌似是从iOS13之后才有的
    /// 如果navigationBar实例中没有NavigationItem，那么其是透明色的，即使设置barTintColor也是无效的
    UINavigationItem * item = [[UINavigationItem alloc]initWithTitle:@"这里有个巨坑"];
    UINavigationBar *bar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 200, 320, 80)];
    bar.barTintColor = UIColor.redColor;
    bar.tintColor = UIColor.blueColor;
    [bar pushNavigationItem:item animated:YES];
    [self.view addSubview:bar];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"test" style:UIBarButtonItemStyleDone target:self action:@selector(test)];
}


- (void)test {
    NSLog(@"===== test ====");
}


#pragma mark - InteractiveDelegate
- (void)interactivePopTransitionStart {
//    NSLog(@"开始转场");
}

- (void)interactivePopTransitionChanging {
//    NSLog(@"转场中");
}

- (void)interactivePopTransitionCompleted {
//    NSLog(@"转场完成");
}

- (void)interactivePopTransitionCancled {
//    NSLog(@"转场取消");
}

- (BOOL)isEnableStartPopTransition {
    return YES;
}




@end
