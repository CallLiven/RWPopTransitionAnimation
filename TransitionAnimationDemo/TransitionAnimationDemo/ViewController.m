//
//  ViewController.m
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/10.
//

#import "ViewController.h"
#import "BController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.purpleColor;
//    [self.navigationController.navigationBar setBackgroundImage:[UIImageView imageWithColor:UIColor.blueColor] forBarMetrics:UIBarMetricsDefault];
}

- (IBAction)pushAction:(id)sender {
    BController *bvc = [BController new];
//    bvc.duration = 10.0f;
//    bvc.transitionType = RWTransitionType_TuoTiao;
    [self.navigationController pushViewController:bvc animated:YES];
}


@end
