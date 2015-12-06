//
//  JJPropertyCache.h
//  JJFMDBDemo
//
//  Created by Jay on 15/12/6.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JJFMDBPropertyCache : NSObject

/**
 *  缓存数据
 *
 *  @param dictId 字典标识
 *
 *  @return 缓存的字典
 */
+ (id)setObject:(id)object forKey:(id<NSCopying>)key forDictId:(const void *)dictId;

/**
 *  获得缓存的数据
 *
 *  @param dictId 字典标识
 */
+ (id)objectForKey:(id<NSCopying>)key forDictId:(const void *)dictId;

/**
 *  获得缓存的字典
 *
 *  @param dictId 字典标识
 */
+ (id)dictWithDictId:(const void *)dictId;

@end
