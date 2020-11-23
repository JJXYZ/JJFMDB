//
//  JJDatabaseQueue.h
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "FMDatabaseQueue.h"

@interface JJDatabaseQueue : FMDatabaseQueue

#pragma mark - Async

/**
 *  异步操作,在线程里面执行(后台执行)
 *
 *  @param block block
 */
- (void)inDatabaseAsync:(void (^)(FMDatabase *db))block;


@end
