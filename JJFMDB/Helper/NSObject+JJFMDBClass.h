//
//  NSObject+JJFMDBClass.h
//  JJFMDBDemo
//
//  Created by Jay on 15/12/7.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  遍历所有类的block（父类）
 */
typedef void (^JJFMDBClassesEnumeration)(Class c, BOOL *stop);


@interface NSObject (JJFMDBClass)

/** 只遍历当前的类 */
+ (void)enumerateClass:(JJFMDBClassesEnumeration)enumeration;

/** 遍历到NSObject */
+ (void)enumerateClasses:(JJFMDBClassesEnumeration)enumeration;

/** 遍历到superClass */
+ (void)enumerateClasses:(JJFMDBClassesEnumeration)enumeration superClass:(Class)superClass;

/** 遍历所有的类 */
+ (void)enumerateAllClasses:(JJFMDBClassesEnumeration)enumeration;


@end
