//
//  NSObject+JJFMDBMethods.h
//  JJFMDBDemo
//
//  Created by Jay on 15/12/5.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^JJFMDBResults)(NSArray *results);
typedef void(^JJFMDBSuccess)(BOOL isSuccess);
typedef void(^JJFMDBCount)(int count);


@interface NSObject (JJFMDBMethods)

#pragma mark - Init

/** 启动DB */
+ (void)startToDB;

#pragma mark - Update Table

/** 给表增加一列 */
+ (void)tableAddColumn:(NSString *)column type:(NSString *)type results:(JJFMDBSuccess)block;

/** SQLite不支持删除列 */
+ (void)tableDropColumn:(NSString *)column results:(JJFMDBSuccess)block NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "SQLite不支持删除列");

/** 读取表所有的列名 */
+ (void)readTableColumns:(JJFMDBResults)block;


#pragma mark - Search

/**
 *  查询有多少数据
 */
+ (void)searchCount:(JJFMDBCount)block;

/**
 *  返回所有的数据
 *
 *  @param block 返回结果,对应的models
 */
+ (void)searchAll:(JJFMDBResults)block;

/**
 *  返回count条数据
 *
 *  @param count    count
 *  @param block 返回结果,对应的models
 */
+ (void)searchCount:(int)count results:(JJFMDBResults)block;

/**
 *  返回count条数据
 *
 *  @param orderBy  条件,例:time DESC(按time排序)
 *  @param count    count
 *  @param block 返回结果,对应的models
 */
+ (void)searchOrderBy:(NSString *)orderBy count:(int)count results:(JJFMDBResults)block;

/**
 *  返回所有的数据
 *
 *  @param where where条件,自定义,例where:@"rowid = 2"或者@"string = 'Jay'"
 *  @param block 返回结果,对应的models
 */
+ (void)searchAllWhere:(NSString *)where results:(JJFMDBResults)block;

#pragma mark Search Page

/**
 *  默认返回 SEARCH_COUNT条数据
 *
 *  @param pageNum 第几页(0是首页)
 *  @param block  返回结果,对应的models
 */
+ (void)searchPageNum:(int)pageNum results:(JJFMDBResults)block;

/**
 *  默认返回 SEARCH_COUNT条数据
 *
 *  @param orderBy 条件,例:time DESC(按time排序)
 *  @param pageNum 第几页(0是首页)
 *  @param block   返回结果,对应的models
 */
+ (void)searchOrderBy:(NSString *)orderBy pageNum:(int)pageNum results:(JJFMDBResults)block;

#pragma mark Search 自定义Where

/**
 *  默认返回 SEARCH_COUNT条数据
 *
 *  @param where  where条件,自定义,例where:@"rowid = 2"或者@"string = 'Jay'"
 *  @param pageNum 第几页(0是首页)
 *  @param block  返回结果,对应的models
 */
+ (void)searchWhere:(NSString *)where pageNum:(int)pageNum results:(JJFMDBResults)block;

/**
 *  返回count条数据
 *
 *  @param where   where条件,自定义,例where:@"rowid = 2"或者@"string = 'Jay'"
 *  @param orderBy 条件,例:time DESC(按time排序)
 *  @param count   count
 *  @param block   返回结果,对应的models
 */
+ (void)searchWhere:(NSString *)where orderBy:(NSString *)orderBy count:(int)count results:(JJFMDBResults)block;


/**
 *  默认返回 SEARCH_COUNT条数据
 *
 *  @param where   where条件,自定义,例where:@"rowid = 2"或者@"string = 'Jay'"
 *  @param orderBy 条件,例:time DESC(按time排序)
 *  @param pageNum 第几页(0是首页)
 *  @param block   返回结果,对应的models
 */
+ (void)searchWhere:(NSString *)where orderBy:(NSString *)orderBy pageNum:(int)pageNum results:(JJFMDBResults)block;

#pragma mark Search key-value模式传入

/**
 *  返回SEARCH_COUNT条数据
 *
 *  @param whereDic where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param pageNum  第几页(0是首页)
 *  @param block    返回结果,对应的models
 */
+ (void)searchWhereDic:(NSDictionary *)whereDic pageNum:(int)pageNum results:(JJFMDBResults)block;

/**
 *  返回SEARCH_COUNT条数据
 *
 *  @param whereDic where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param orderBy  例:time DESC(按time排序)
 *  @param pageNum  第几页(0是首页)
 *  @param block    返回结果,对应的models
 */
+ (void)searchWhereDic:(NSDictionary *)whereDic orderBy:(NSString *)orderBy pageNum:(int)pageNum results:(JJFMDBResults)block;

#pragma mark - Insert

/**
 *  把model直接插入到数据库
 *
 *  @param model model
 *  @param block block
 */
- (void)insertToDB:(JJFMDBSuccess)block;

/**
 *  把model插入到数据库,如果存在(用primaryKey来判断),就更新(通过rowid或者primarykey来更新)
 *
 *  @param model model
 *  @param block block
 */
- (void)insertUpdateToDB:(JJFMDBSuccess)block;

#pragma mark Insert 自定义Where

/**
 *  把model插入到数据库,如果存在(where语句来判断),就更新(where语句来更新)
 *
 *  @param model model
 *  @param where where条件,自定义,例where:@"rowid = 2"或者@"string = 'Jay'"
 *  @param block block
 */
- (void)insertUpdateToDB:(NSString *)where result:(JJFMDBSuccess)block;

/**
 *  把model插入到数据库,如果存在(where语句来判断),就更新(where语句来更新对应的updateKey)
 *
 *  @param model     model
 *  @param updateKey 需要更新的字段,例: @"name='Jay', age=10, height=1.8"
 *  @param where     where条件,自定义,例where:@"rowid = 2"或者@"string = 'Jay'"
 *  @param block     block
 */
- (void)insertUpdateToDB:(NSString *)updateKey where:(NSString *)where result:(JJFMDBSuccess)block;

#pragma mark Insert key-value

/**
 *  把model插入到数据库,如果存在(whereDic语句来判断),就更新(whereDic语句来更新)
 *
 *  @param model    model
 *  @param whereDic where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param block    block
 */
- (void)insertUpdateToDBDic:(NSDictionary *)whereDic result:(JJFMDBSuccess)block;

/**
 *  把model插入到数据库,如果存在(whereDic语句来判断),就更新(whereDic语句来更新对应的updateKey)
 *
 *  @param model        model
 *  @param updateKeyDic Update的数据,例:@{@"height":@1.8, @"weight":@60}
 *  @param whereDic     where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param block        block
 */
- (void)insertUpdateToDBDic:(NSDictionary *)updateKeyDic whereDic:(NSDictionary *)whereDic result:(JJFMDBSuccess)block;

#pragma mark - Update

/**
 *  更新model,更新全部,通过rowid或者primarykey来更新数据
 *
 *  @param model model
 *  @param block block
 */
- (void)updateToDB:(JJFMDBSuccess)block;

#pragma mark Update 自定义Where

/**
 *  更新model,更新全部,自定义where
 *
 *  @param model model
 *  @param where 更新的条件,例: @"height=100"
 *  @param block block
 */
- (void)updateToDB:(NSString *)where result:(JJFMDBSuccess)block;


/**
 *  更新model,自定义updateKey和where
 *
 *  @param updateKey 需要更新的字段,例: @"name='Jay', age=10, height=1.8"
 *  @param where     更新的条件,例: @"height=100"
 *  @param block     block
 */
+ (void)updateToDB:(NSString *)updateKey where:(NSString *)where result:(JJFMDBSuccess)block;

#pragma mark Update key-value

/**
 *  更新model,更新全部,自定义whereDic
 *
 *  @param model    model
 *  @param whereDic where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param block    block
 */
- (void)updateToDBDic:(NSDictionary *)whereDic result:(JJFMDBSuccess)block;

/**
 *  更新model,自定义whereDic
 *
 *  @param UpdateKeyDic Update的数据,例:@{@"height":@1.8, @"weight":@60}
 *  @param whereDic     where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param block        block
 */
+ (void)updateToDBDic:(NSDictionary *)updateKeyDic whereDic:(NSDictionary *)whereDic result:(JJFMDBSuccess)block;

#pragma mark - Delete

/**
 *  删除model,通过rowid或者primarykey来删除数据
 *
 *  @param model model
 *  @param block block
 */
- (void)deleteToDB:(JJFMDBSuccess)block;


/**
 *  根据where条件删除数据
 *
 *  @param where where条件,自定义,例where:@"rowid = 2"或者@"string = 'Jay'"
 *  @param block block
 */
- (void)deleteToDB:(NSString *)where result:(JJFMDBSuccess)block;

/**
 *  根据where条件删除数据
 *
 *  @param where where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param block block
 */
- (void)deleteToDBDic:(NSDictionary *)whereDic result:(JJFMDBSuccess)block;


/** 清空表数据 */
- (void)clearTable:(JJFMDBSuccess)block;


#pragma mark - isExist

/**
 *  是否存在model(用primaryKey来判断)
 *
 *  @param model
 *  @param block 返回YES存在,NO不存在
 */
- (void)isExistsToDB:(JJFMDBSuccess)block;

/**
 *  是否存在model
 *
 *  @param where 自定义的SQL语句,例: @"height=100"
 *  @param block 返回YES存在,NO不存在
 */
- (void)isExistsToDB:(NSString *)where result:(JJFMDBSuccess)block;

/**
 *  是否存在model
 *
 *  @param whereDic where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param block    返回YES存在,NO不存在
 */
- (void)isExistsToDBDic:(NSDictionary *)whereDic result:(JJFMDBSuccess)block;

@end
