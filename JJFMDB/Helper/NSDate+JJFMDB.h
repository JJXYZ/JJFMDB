//
//  NSDate+JJFMDB.h
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (JJFMDB)

/**
 *  把Date转换成String,格式yyyy-MM-dd HH:mm:ss
 *
 *  @param date Date
 *
 *  @return String
 */
+ (NSString *)stringWithDate:(NSDate *)date;

/**
 *  把String转换成Date,格式yyyy-MM-dd HH:mm:ss
 *
 *  @param str String
 *
 *  @return Date
 */
+ (NSDate *)dateWithString:(NSString *)str;


@end
