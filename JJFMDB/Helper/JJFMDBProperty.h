//
//  JJProperty.h
//  JJFMDBDemo
//
//  Created by Jay on 15/12/6.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import <Foundation/Foundation.h>

/** system */
#import <objc/runtime.h>

@interface JJFMDBProperty : NSObject

/** 成员属性 */
@property (nonatomic, assign) objc_property_t property;

/** 成员属性的名字 例:@"name",@"age",@"height" */
@property (nonatomic, readonly) NSString *name;

/** 原始的类型 例:@"long long" */
@property (nonatomic, readonly) NSString *orignType;

/** 转换成数据库的类型 例:@"TEXT" */
@property (nonatomic, readonly) NSString *dbType;

#pragma mark - Public Methods

/** 初始化 */
+ (instancetype)cachedProperty:(objc_property_t)property;

@end
