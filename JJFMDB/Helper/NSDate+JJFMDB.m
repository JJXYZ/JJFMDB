//
//  NSDate+JJFMDB.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "NSDate+JJFMDB.h"

@implementation NSDate (JJFMDB)

+ (NSString *)stringWithDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *datestr = [formatter stringFromDate:date];
    return datestr;
}

+ (NSDate *)dateWithString:(NSString *)str
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:str];
    return date;
}


@end
