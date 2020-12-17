//
//  UINavigationBar+KMNavigationBarTransition.m
//
//  Copyright (c) 2017 Zhouqi Mo (https://github.com/MoZhouqi)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "UINavigationBar+KMNavigationBarTransition.h"
#import "UINavigationBar+KMNavigationBarTransition_internal.h"
#import "RWWeakObjectContainer.h"
#import "RWSwizzle.h"

#import <objc/runtime.h>


@implementation UINavigationBar (KMNavigationBarTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RWSwizzleMethod([self class],
                        @selector(layoutSubviews),
                        [self class],
                        @selector(km_layoutSubviews));
    });
}

- (void)km_layoutSubviews {
    [self km_layoutSubviews];

    /// 由于自己创建的navigationBar布局与navigationController创建的不一样，所有由这里设置
    CGFloat navigationBarTotalHeight = 0;
    UIView *backgroundView = [self rw_navigationBarBackgroundView];
    CGRect frame = backgroundView.frame;
    frame.size.height = self.frame.size.height + fabs(frame.origin.y);
    backgroundView.frame = frame;
    navigationBarTotalHeight = frame.size.height;
    
    /// 修改自定义navigationBar中ContentView的frame
    if (self.km_isFakeBar && navigationBarTotalHeight >= 44) {
        UIView *contentView = [self rw_navigationBarContentView];
        CGRect frame = contentView.frame;
        frame.origin.y = navigationBarTotalHeight - 44;
        contentView.frame = frame;;
    }
}


- (UIView *)rw_navigationBarBackgroundView {
    __block UIView *tempView = nil;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]||[obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
            tempView = obj;
            *stop = YES;
        }
    }];
    return tempView;
}


- (UIView *)rw_navigationBarContentView {
    __block UIView *tempView = nil;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"_UINavigationBarContentView")]) {
            tempView = obj;
            *stop = YES;
        }
    }];
    return tempView;
}


#pragma mark - Getter/Setter
- (BOOL)km_isFakeBar {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setKm_isFakeBar:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(km_isFakeBar), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)rw_titleViewSuperView {
    return rw_objc_getAssociatedWeakObject(self, _cmd);
}

- (void)setRw_titleViewSuperView:(UIView *)rw_titleViewSuperView {
    rw_objc_setAssociatedWeakObject(self, @selector(rw_titleViewSuperView), rw_titleViewSuperView);
}

@end
