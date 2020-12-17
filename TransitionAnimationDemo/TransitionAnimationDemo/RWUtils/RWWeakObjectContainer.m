//
//  RWWeakObjectContainer.m
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/16.
//

#import "RWWeakObjectContainer.h"
#import <objc/runtime.h>

@interface RWWeakObjectContainer : NSObject
@property (nonatomic, weak) id object;
@end


@implementation RWWeakObjectContainer
extern void rw_objc_setAssociatedWeakObject(id container, void *key, id value)
{
    RWWeakObjectContainer *wrapper = [[RWWeakObjectContainer alloc]init];
    wrapper.object = value;
    objc_setAssociatedObject(container, key, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


extern id rw_objc_getAssociatedWeakObject(id container, void *key)
{
    return [(RWWeakObjectContainer *)objc_getAssociatedObject(container, key) object];
}
@end
