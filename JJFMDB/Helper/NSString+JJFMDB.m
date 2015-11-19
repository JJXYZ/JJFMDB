//
//  NSString+JJFMDB.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "NSString+JJFMDB.h"

@implementation NSString (JJFMDB)

- (BOOL)isEmptyWithTrim
{
    return [[self stringWithTrim] isEqualToString:@""];
}

- (NSString *)stringWithTrim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


@end
