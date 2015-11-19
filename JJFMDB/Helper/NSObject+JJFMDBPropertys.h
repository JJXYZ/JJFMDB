//
//  NSObject+JJFMDBPropertys.h
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JJFMDBPropertys)

/**
 *  返回该类的所有属性,不上溯到父类,
 *  value-key:pronames - @"name", protypes - @"type"
 *
 *  @return 该类的所有属性
 */
+ (NSDictionary *)getPropertys;

/**
 *  返回 该类以及父类的所有属性
 *
 *  @return 该类以及父类的所有属性
 */
+ (NSDictionary *)getPropertysWithSuper;


@end
