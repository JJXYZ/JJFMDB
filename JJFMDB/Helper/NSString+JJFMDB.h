//
//  NSString+JJFMDB.h
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JJFMDB)

/**
 *  判断字符串是否为空
 *
 *  @return YES/NO
 */
- (BOOL)isEmptyWithTrim;

/**
 *  去掉空格
 *
 *  @return NSString
 */
- (NSString *)stringWithTrim;


@end
