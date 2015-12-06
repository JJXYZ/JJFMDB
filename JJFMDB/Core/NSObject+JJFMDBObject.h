//
//  NSObject+JJFMDBObject.h
//  JJFMDBDemo
//
//  Created by Jay on 15/12/6.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface NSObject (JJFMDBObject)

/**
 *  主键名称,如果没有rowid,则必须要初始化,跟据此名称update和delete
 *  例:self.primaryKey = @"属性的名称";
 */
@property (nonatomic, copy) NSString *primaryKey;

/** 数据库的rowid */
@property (nonatomic, assign) sqlite_int64 rowid;


@end
