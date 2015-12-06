//
//  NSObject+JJFMDBProtocol.h
//  JJFMDBDemo
//
//  Created by Jay on 15/12/6.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JJDatabaseQueue;

@protocol JJFMDBProtocol <NSObject>

@optional

/** 返回表名 */
+ (const NSString *)jj_tableName;

/** 返回数据库路径 */
+ (NSString *)jj_databasePath;

@end


@interface NSObject (JJFMDBProtocol) <JJFMDBProtocol>

/** 数据库操作队列 */
+ (JJDatabaseQueue *)dbQueue;

/** 设置数据库操作队列 */
+ (void)setDbQueue:(JJDatabaseQueue *)dbQueue;

@end
