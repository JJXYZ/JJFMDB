//
//  NSString+JJFMDB.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "NSString+JJFMDB.h"

@implementation NSString (JJFMDB)

- (BOOL)jj_isEmptyWithTrim
{
    return [[self jj_stringWithTrim] isEqualToString:@""];
}

- (NSString *)jj_stringWithTrim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


@end
