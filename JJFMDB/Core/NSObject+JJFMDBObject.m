//
//  NSObject+JJFMDBObject.m
//  JJFMDBDemo
//
//  Created by Jay on 15/12/6.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "NSObject+JJFMDBObject.h"
#import <objc/runtime.h>

@implementation NSObject (JJFMDBObject)

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
