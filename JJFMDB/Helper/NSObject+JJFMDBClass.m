//
//  NSObject+JJFMDBClass.m
//  JJFMDBDemo
//
//  Created by Jay on 15/12/7.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "NSObject+JJFMDBClass.h"

/** system */
#import <objc/runtime.h>

@implementation NSObject (JJFMDBClass)

#pragma mark - Public Methods

/** 只遍历当前的类 */
+ (void)enumerateClass:(JJFMDBClassesEnumeration)enumeration {
    
    // 1.没有block就直接返回
    if (enumeration == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = self;
    
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);
        break;
    }
}

/** 遍历到NSObject */
+ (void)enumerateClasses:(JJFMDBClassesEnumeration)enumeration {
    [self enumerateClasses:enumeration superClass:[NSObject class]];
}

/** 遍历到superClass */
+ (void)enumerateClasses:(JJFMDBClassesEnumeration)enumeration superClass:(Class)superClass {
    
    // 1.没有block就直接返回
    if (enumeration == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = self;
    
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);
        
        // 4.2.获得父类
        c = class_getSuperclass(c);
        
        if (c == superClass) break;
    }
}

+ (void)enumerateAllClasses:(JJFMDBClassesEnumeration)enumeration
{
    // 1.没有block就直接返回
    if (enumeration == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = self;
    
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);
        
        // 4.2.获得父类
        c = class_getSuperclass(c);
    }
}


#pragma mark - Private Methods

@end
