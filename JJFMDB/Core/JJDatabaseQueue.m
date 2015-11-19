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

+ (id)databaseQueueWithPath:(NSString*)aPath
{
    JJDatabaseQueue *queue = [[self alloc] initWithPath:aPath];
    FMDBAutorelease(queue);
    return queue;
}


- (id)initWithPath:(NSString*)aPath
{
    self = [super initWithPath:aPath];
    if(self){
        
    }
    return self;
}


/**
 *  重写父类的方法,和父类一样
 *  注意:如果FMDBDataBaseQueue这个方法有更新,再Copy过来
 *
 *  @return FMDatabase
 */
- (FMDatabase *)database {
    if (!_db) {
        _db = FMDBReturnRetained([FMDatabase databaseWithPath:_path]);
        
#if SQLITE_VERSION_NUMBER >= 3005000
        BOOL success = [_db openWithFlags:_openFlags];
#else
        BOOL success = [db open];
#endif
        if (!success) {
            NSLog(@"FMDatabaseQueue could not reopen database for path %@", _path);
            FMDBRelease(_db);
            _db  = 0x00;
            return 0x00;
        }
    }
    return _db;
}




#pragma mark - Async

- (void)inDatabaseAsync:(void (^)(FMDatabase *db))block {
    
    FMDBRetain(self);
    dispatch_async(_queue, ^() {
//        NSLog(@"数据库执行的线程:%@", [NSThread currentThread]);
        
        FMDatabase *db = [self database];
        block(db);
        
        if ([db hasOpenResultSets]) {
            NSLog(@"Warning: there is at least one open result set around after performing [FMDatabaseQueue inDatabase:]");
            
#if defined(DEBUG) && DEBUG
            NSSet *openSetCopy = FMDBReturnAutoreleased([[db valueForKey:@"_openResultSets"] copy]);
            for (NSValue *rsInWrappedInATastyValueMeal in openSetCopy) {
                FMResultSet *rs = (FMResultSet *)[rsInWrappedInATastyValueMeal pointerValue];
                NSLog(@"query: '%@'", [rs query]);
            }
#endif
        }
    });
    
    FMDBRelease(self);
}


- (void)beginTransactionAsync:(BOOL)useDeferred withBlock:(void (^)(FMDatabase *db, BOOL *rollback))block {
    FMDBRetain(self);
    dispatch_async(_queue, ^() {
        
        BOOL shouldRollback = NO;
        
        if (useDeferred) {
            [[self database] beginDeferredTransaction];
        }
        else {
            [[self database] beginTransaction];
        }
        
        block([self database], &shouldRollback);
        
        if (shouldRollback) {
            [[self database] rollback];
        }
        else {
            [[self database] commit];
        }
    });
    
    FMDBRelease(self);
}

- (void)inDeferredTransactionAsync:(void (^)(FMDatabase *db, BOOL *rollback))block {
    [self beginTransactionAsync:YES withBlock:block];
}

- (void)inTransactionAsync:(void (^)(FMDatabase *db, BOOL *rollback))block {
    [self beginTransactionAsync:NO withBlock:block];
}


#pragma mark - NotInQueue

- (void)inDatabaseNotInQueue:(void (^)(FMDatabase *db))block {
    FMDBRetain(self);
    
    FMDatabase *db = [self database];
    block(db);
    
    if ([db hasOpenResultSets]) {
        NSLog(@"Warning: there is at least one open result set around after performing [FMDatabaseQueue inDatabase:]");
        
#if defined(DEBUG) && DEBUG
        NSSet *openSetCopy = FMDBReturnAutoreleased([[db valueForKey:@"_openResultSets"] copy]);
        for (NSValue *rsInWrappedInATastyValueMeal in openSetCopy) {
            FMResultSet *rs = (FMResultSet *)[rsInWrappedInATastyValueMeal pointerValue];
            NSLog(@"query: '%@'", [rs query]);
        }
#endif
    }
    
    FMDBRelease(self);
}


- (void)beginTransactionNotInQueue:(BOOL)useDeferred withBlock:(void (^)(FMDatabase *db, BOOL *rollback))block {
    FMDBRetain(self);
    
    BOOL shouldRollback = NO;
    
    if (useDeferred) {
        [[self database] beginDeferredTransaction];
    }
    else {
        [[self database] beginTransaction];
    }
    
    block([self database], &shouldRollback);
    
    if (shouldRollback) {
        [[self database] rollback];
    }
    else {
        [[self database] commit];
    }
    
    FMDBRelease(self);
}

- (void)inDeferredTransactionNotInQueue:(void (^)(FMDatabase *db, BOOL *rollback))block {
    [self beginTransactionNotInQueue:YES withBlock:block];
}

- (void)inTransactionNotInQueue:(void (^)(FMDatabase *db, BOOL *rollback))block {
    [self beginTransactionNotInQueue:NO withBlock:block];
}


#pragma mark - CurrentQueue

- (dispatch_queue_t)currentQueue {
    return _queue;
}

@end
