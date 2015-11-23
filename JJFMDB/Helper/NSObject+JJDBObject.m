//
//  NSObject+JJDBObject.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/23.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "NSObject+JJDBObject.h"
#import <objc/runtime.h>

@implementation NSObject (JJDBObject)

#pragma mark - Property

static char *kPrimaryKeyKey;
- (void)setPrimaryKey:(NSString *)primaryKey {
    objc_setAssociatedObject(self, &kPrimaryKeyKey, primaryKey, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)primaryKey {
    NSString *primaryKey = objc_getAssociatedObject(self, &kPrimaryKeyKey);
    return primaryKey;
}

static char *kRowidKey;
- (void)setRowid:(sqlite_int64)rowid {
    objc_setAssociatedObject(self, &kRowidKey, @(rowid), OBJC_ASSOCIATION_ASSIGN);
}

- (sqlite_int64)rowid {
    NSNumber *rowidNum = objc_getAssociatedObject(self, &kRowidKey);
    sqlite_int64 rowid = rowidNum.longLongValue;
    return rowid;
}


@end
