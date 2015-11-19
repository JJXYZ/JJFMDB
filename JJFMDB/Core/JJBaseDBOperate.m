//
//  JJBaseDBOperate.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "JJBaseDBOperate.h"
#import "JJBaseDBModel.h"

@implementation JJBaseDBOperate

+ (const NSString *)getTableName
{
    return @"base_table";
}

+ (Class)getBindingModelClass
{
    return [JJBaseDBModel class];
}


@end
