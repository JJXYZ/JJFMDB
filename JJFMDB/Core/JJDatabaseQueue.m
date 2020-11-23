//
//  JJDatabaseQueue.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "JJDatabaseQueue.h"
#import "FMDatabase.h"

@implementation JJDatabaseQueue

#pragma mark - Async

- (void)inDatabaseAsync:(void (^)(FMDatabase *db))block {
    [self inDatabase:block];
}

@end
