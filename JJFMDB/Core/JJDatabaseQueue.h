//
//  JJDatabaseQueue.h
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "FMDatabaseQueue.h"

@interface JJDatabaseQueue : FMDatabaseQueue

/**
 *  创建JJDatabaseQueue
 *
 *  @param aPath 路径
 *
 *  @return JJDatabaseQueue
 */
+ (instancetype)databaseQueueWithPath:(NSString *)aPath;


#pragma mark - Async

/**
 *  异步操作,在线程里面执行(后台执行)
 *
 *  @param block block
 */
- (void)inDatabaseAsync:(void (^)(FMDatabase *db))block;

/** Asynchronously perform database operations on queue, using transactions.
 *  @param block The code to be run on the queue of `FMDatabaseQueue`
 */
- (void)inTransactionAsync:(void (^)(FMDatabase *db, BOOL *rollback))block;

/** Asynchronously perform database operations on queue, using deferred transactions.
 *  @param block The code to be run on the queue of `FMDatabaseQueue`
 */
- (void)inDeferredTransactionAsync:(void (^)(FMDatabase *, BOOL *))block;


#pragma mark - NotInQueue

/**
 *  不在队列里面执行,即同步操作(有些操作是要等数据库查询完在操作,用此方法)
 *
 *  @param block block
 */
- (void)inDatabaseNotInQueue:(void (^)(FMDatabase *db))block;
- (void)inDeferredTransactionNotInQueue:(void (^)(FMDatabase *db, BOOL *rollback))block;
- (void)inTransactionNotInQueue:(void (^)(FMDatabase *db, BOOL *rollback))block;

#pragma mark - CurrentQueue

- (dispatch_queue_t)currentQueue;


@end
