//
//  JJPropertyCache.m
//  JJFMDBDemo
//
//  Created by Jay on 15/12/6.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "JJFMDBPropertyCache.h"

/** system */
#import <objc/runtime.h>

@implementation JJFMDBPropertyCache

+ (id)setObject:(id)object forKey:(id<NSCopying>)key forDictId:(const void *)dictId
{
    // 获得字典
    NSMutableDictionary *dict = [self dictWithDictId:dictId];
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, dictId, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // 存储数据
    dict[key] = object;
    
    return dict;
}

+ (id)objectForKey:(id<NSCopying>)key forDictId:(const void *)dictId
{
    return [self dictWithDictId:dictId][key];
}


+ (id)dictWithDictId:(const void *)dictId
{
    return objc_getAssociatedObject(self, dictId);
}

@end
