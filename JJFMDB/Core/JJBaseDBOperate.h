//
//  JJBaseDBOperate.h
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

/**
 *  数据库Model操作基类
 */

#import <Foundation/Foundation.h>


@interface JJBaseDBOperate : NSObject

/** 返回表名  所有 DBOperate 都必须重载此方法 */
+ (const NSString *)getTableName;

/** 返回绑定的Model Class 都必须重载此方法 */
+ (Class)getBindingModelClass;


@end
