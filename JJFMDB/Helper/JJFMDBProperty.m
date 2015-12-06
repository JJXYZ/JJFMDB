//
//  JJProperty.m
//  JJFMDBDemo
//
//  Created by Jay on 15/12/6.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "JJFMDBProperty.h"

/** Core */
#import "JJFMDBDefine.h"

@implementation JJFMDBProperty

#pragma mark - Public Methods

+ (instancetype)cachedProperty:(objc_property_t)property
{
    JJFMDBProperty *propertyObj = objc_getAssociatedObject(self, property);
    if (propertyObj == nil) {
        propertyObj = [[self alloc] init];
        propertyObj.property = property;
        objc_setAssociatedObject(self, property, propertyObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return propertyObj;
}

#pragma mark - Private Methods
/**
 propertyType = T@"NSString",&,N,V_pString    --> NSString //@ id 指针 对象
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

- (NSString *)convertToType:(objc_property_t)property {
    
    NSString *attributes = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
    
    NSString *type = nil;
    if ([attributes hasPrefix:@"T@"]) {
        type = [attributes substringWithRange:NSMakeRange(3, [attributes rangeOfString:@","].location-4)];
    }
    else if ([attributes hasPrefix:@"Ti"] || [attributes hasPrefix:@"Tq"]) {
        type = @"long long";
    }
    else if ([attributes hasPrefix:@"Tf"]) {
        type = @"float";
    }
    else if([attributes hasPrefix:@"Td"]) {
        type = @"double";
    }
    else if([attributes hasPrefix:@"Tl"]) {
        type = @"long";
    }
    else if ([attributes hasPrefix:@"Tc"]) {
        type = @"char";
    }
    else if([attributes hasPrefix:@"Ts"]) {
        type = @"short";
    }
    else {
        type = @"NSString";
    }
    return type;
}


/**
 *  把Model的属性类型转换成数据库的类型
 *
 *  @param type type
 *
 *  @return JJSQLXXX
 */
- (NSString *)convertToDBType:(NSString *)type
{
    if ([type isEqualToString:@"NSString"]) {
        return JJ_SQL_TEXT;
    }
    else if ([type isEqualToString:@"char"] ||
             [type isEqualToString:@"short"] ||
             [type isEqualToString:@"int"] ||
             [type isEqualToString:@"long"]) {
        return JJ_SQL_INTEGER;
    }
    else if ([type isEqualToString:@"float"] ||
             [type isEqualToString:@"double"]) {
        return JJ_SQL_FLOAT;
    }
    else if ([type isEqualToString:@"long long"]) {
        return JJ_SQL_BIGINT;
    }
    else if ([type isEqualToString:@"NSData"] ||
             [type isEqualToString:@"UIImage"]) {
        return JJ_SQL_BLOB;
    }
    
    return JJ_SQL_TEXT;
}

#pragma mark - Property

- (void)setProperty:(objc_property_t)property
{
    _property = property;
    _name = @(property_getName(property));
    _orignType = [self convertToType:property];
    _dbType = [self convertToDBType:_orignType];
}

@end
