//
//  NSObject+JJFMDBPropertys.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "NSObject+JJFMDBPropertys.h"

/** system */
#import <objc/runtime.h>

/** Helper */
#import "JJFMDBProperty.h"
#import "JJFMDBPropertyCache.h"
#import "NSObject+JJFMDBClass.h"

static const char JJCachedPropertiesKey = '\0';

@implementation NSObject (JJFMDBPropertys)


#pragma mark - Public Methods
/**
 *  遍历所有的成员
 */
+ (void)enumerateProperties:(JJFMDBPropertysEnumeration)enumeration
{
    // 获得成员变量
    NSArray *cachedProperties = [self properties];
    
    // 遍历成员变量
    BOOL stop = NO;
    for (JJFMDBProperty *property in cachedProperties) {
        enumeration(property, &stop);
        if (stop) break;
    }
}

/**
 *  成员变量转换成JJFMDBProperty数组
 */
+ (NSMutableArray *)properties
{
    NSMutableArray *cachedProperties = [JJFMDBPropertyCache objectForKey:NSStringFromClass(self) forDictId:&JJCachedPropertiesKey];
    
    if (cachedProperties == nil) {
        cachedProperties = [NSMutableArray array];
        
        [self enumerateClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            // 1.获得所有的成员变量
            unsigned int outCount = 0;
            objc_property_t *properties = class_copyPropertyList(c, &outCount);
            
            // 2.遍历每一个成员变量
            for (unsigned int i = 0; i<outCount; i++) {
                JJFMDBProperty *property = [JJFMDBProperty cachedProperty:properties[i]];
                // 过滤掉系统自动添加的元素
                if ([property.name isEqualToString:@"hash"]
                    || [property.name isEqualToString:@"superclass"]
                    || [property.name isEqualToString:@"description"]
                    || [property.name isEqualToString:@"debugDescription"]) {
                    continue;
                }
                [cachedProperties addObject:property];
            }
            
            // 3.释放内存
            free(properties);
        }];
        
        [JJFMDBPropertyCache setObject:cachedProperties forKey:NSStringFromClass(self) forDictId:&JJCachedPropertiesKey];
    }
    
    return cachedProperties;
}

@end
