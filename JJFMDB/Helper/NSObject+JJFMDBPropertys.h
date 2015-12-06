//
//  NSObject+JJFMDBPropertys.h
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JJFMDBProperty;

/**
 *  遍历成员变量用的block
 *
 *  @param property 成员的包装对象
 *  @param stop   YES代表停止遍历，NO代表继续遍历
 */
typedef void(^JJFMDBPropertysEnumeration)(JJFMDBProperty *property, BOOL *stop);

@interface NSObject (JJFMDBPropertys)

/**
 *  遍历所有的成员
 */
+ (void)enumerateProperties:(JJFMDBPropertysEnumeration)enumeration;

/**
 *  成员变量转换成JJFMDBProperty数组
 */
+ (NSMutableArray *)properties;


@end
