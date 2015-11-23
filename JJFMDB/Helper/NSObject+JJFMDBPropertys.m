//
//  NSObject+JJFMDBPropertys.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "NSObject+JJFMDBPropertys.h"
#import <objc/runtime.h>
#import "JJBaseDBModel.h"

@implementation NSObject (JJFMDBPropertys)

#pragma mark - Private Methods

+ (NSDictionary *)getPropertys
{
    NSMutableArray *pronames = [NSMutableArray array];
    NSMutableArray *protypes = [NSMutableArray array];
    NSDictionary *props = [NSDictionary dictionaryWithObjectsAndKeys:pronames,@"name",protypes,@"type",nil];
    [self getSelfPropertys:pronames protypes:protypes isGetSuper:NO];
    return props;
}

+ (NSDictionary *)getPropertysWithSuper
{
    NSMutableArray *pronames = [NSMutableArray array];
    NSMutableArray *protypes = [NSMutableArray array];
    NSDictionary *props = [NSDictionary dictionaryWithObjectsAndKeys:pronames,@"name",protypes,@"type",nil];
    [self getSelfPropertys:pronames protypes:protypes isGetSuper:YES];
    return props;
}



+ (void)getSelfPropertys:(NSMutableArray *)pronames protypes:(NSMutableArray *)protypes isGetSuper:(BOOL)isGetSuper {
    
//    NSLog(@"[self class] = %@", NSStringFromClass([self class]));
    
    unsigned int outCount = 0;
    
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        /** 如果有Class遵守了协议,系统就会把以下方法认为是属性,故排除 */
        if([propertyName isEqualToString:@"hash"]||
           [propertyName isEqualToString:@"superclass"]||
           [propertyName isEqualToString:@"description"]||
           [propertyName isEqualToString:@"debugDescription"]) {
            continue;
        }
        
        /**
         *  如果属性是"primaryKey"和"rowid"排除(JJBaseDBModel里面的)
         if([propertyName isEqualToString:@"primaryKey"]||
         [propertyName isEqualToString:@"rowid"])
         {
         continue;
         }
         */
        
//        NSLog(@"propertyName = %@",propertyName);
        [pronames addObject:propertyName];
        [self convertPropertyType:protypes withProperty:property];
    }
    free(properties);
    
    if(isGetSuper &&
       ([self superclass] != [JJBaseDBModel class]) &&
       ([self superclass] != [NSObject class]))
    {
        
        //        NSLog(@"%@ getSelfPropertys", NSStringFromClass([self superclass]));
        [[self superclass] getSelfPropertys:pronames protypes:protypes isGetSuper:isGetSuper];
    }
}

#pragma mark - Private Methods

/**
 
 *  propertyType = T@"NSString",&,N,V_pString    --> NSString //@ id 指针 对象
 propertyType = T@"NSNumber",&,N,V_pNumber    --> NSNumber
 propertyType = Ti,N,V_pInteger               --> long long
 propertyType = Ti,N,V_pint                  --> long long
 propertyType = Tq,N,V_plonglong             --> long long
 propertyType = Tc,N,V_pchar                 --> char
 propertyType = Tc,N,V_pBool                 --> char
 propertyType = Ts,N,V_pshort                --> short
 propertyType = Tf,N,V_pfloat                --> float
 propertyType = Tf,N,V_pCGFloat              --> float
 propertyType = Td,N,V_pdouble               --> double
 
 
 .... ^i 表示  int*  一般都不会用到
 *
 *  @param protypes 转换后存到protypes数组中
 *  @param property 属性
 */
+ (void)convertPropertyType:(NSMutableArray *)protypes withProperty:(objc_property_t)property
{
    
    NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
    //    NSLog(@"propertyType = %@", propertyType);
    
    if ([propertyType hasPrefix:@"T@"]) {
        NSString *subType = [propertyType substringWithRange:NSMakeRange(3, [propertyType rangeOfString:@","].location-4)];
        [protypes addObject:subType];
    }
    else if ([propertyType hasPrefix:@"Ti"] || [propertyType hasPrefix:@"Tq"]) {
        [protypes addObject:@"long long"];
    }
    else if ([propertyType hasPrefix:@"Tf"]) {
        [protypes addObject:@"float"];
    }
    else if([propertyType hasPrefix:@"Td"]) {
        [protypes addObject:@"double"];
    }
    else if([propertyType hasPrefix:@"Tl"]) {
        [protypes addObject:@"long"];
    }
    else if ([propertyType hasPrefix:@"Tc"]) {
        [protypes addObject:@"char"];
    }
    else if([propertyType hasPrefix:@"Ts"]) {
        [protypes addObject:@"short"];
    }
    else {
        [protypes addObject:@"NSString"];
    }
}

@end
