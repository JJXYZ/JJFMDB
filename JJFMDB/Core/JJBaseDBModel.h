//
//  JJBaseDBModel.h
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//


/**
 *  数据库基类Model
 *  1.Model继承于JJBaseDBModel
 *  2.Operate继承于JJBaseDBOperate
 *  3.重写JJBaseDBOperate的getBindingModelClass和getTableName方法
 *  4.重写JJBaseDBModel的getBindingOperateClass方法
 *
 *  注意:支持的类型,NSString,NSNumber,NSInteger,char,int,short,
 *  long long,float,CGFloat,BOOL,NSData,UIImage
 */


#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface JJBaseDBModel : NSObject

/**
 *  主键名称,如果没有rowid,则跟据此名称update和delete,必须要初始化
 *  例:self.primaryKey = @"属性的名称";
 */
@property (copy, nonatomic) NSString *primaryKey;

/** 数据库的rowid */
@property (assign, nonatomic) sqlite_int64 rowid;

/**
 *  返回绑定的OperateClass,子类重写
 *
 *  @return JJBaseDBOperate
 */
+ (Class)getBindingOperateClass;

@end
