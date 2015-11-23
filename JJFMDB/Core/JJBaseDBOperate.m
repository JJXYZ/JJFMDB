//
//  JJBaseDBOperate.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "JJBaseDBOperate.h"

@implementation JJBaseDBOperate

+ (const NSString *)getTableName {
    NSCAssert(NO, @"子类必须重载方法 %s",__FUNCTION__);
    return @"base_table";
}

+ (Class)getBindingModelClass {
    NSCAssert(NO, @"子类必须重载方法 %s",__FUNCTION__);
    return nil;
}


@end
