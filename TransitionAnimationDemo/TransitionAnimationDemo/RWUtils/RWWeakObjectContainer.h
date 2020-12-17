//
//  RWWeakObjectContainer.h
//  TransitionAnimationDemo
//
//  Created by Liven on 2020/12/16.
//

#import <Foundation/Foundation.h>

extern void rw_objc_setAssociatedWeakObject(id container, void *key, id value);
extern id rw_objc_getAssociatedWeakObject(id container, void *key);
