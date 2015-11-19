//
//  JJBaseDBOperate+Methods.h
//  JJFMDBDemo
//
//  Created by Jay on 15/11/17.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "JJBaseDBOperate.h"


@class JJDatabaseQueue;
@interface JJBaseDBOperate (Methods)

/** 队列 */
@property (nonatomic, retain) JJDatabaseQueue *bindingQueue;

/** 绑定的model属性集合 */
@property (nonatomic, retain) NSMutableDictionary *propertys;

/** 列名 */
@property (nonatomic, retain) NSMutableArray *columeNames;

/** 列类型 */
@property (nonatomic, retain) NSMutableArray *columeTypes;

#pragma mark - Init

/**
 *  初始化 这一步会创建表
 *
 *  @param queue 队列
 *
 *  @return 操作数据库的DBOperate
 */
- (instancetype)initWithDBQueue:(JJDatabaseQueue *)queue;

#pragma mark - Methods


/**
 *  给SQL语句增加列
 *
 *  @param name 名字
 *  @param type 类型
 */
- (void)addColume:(NSString *)name type:(NSString*)type;
- (void)addColumePrimary:(NSString *)name type:(NSString *)type;

/** 返回 create table parameter 语句 */
- (NSString *)appendTableSql;


/**
 *  把OC/C类型转换为sqlite类型
 *  char/short/int/long     --> INTEGER
 *  long long               --> BIGINT
 *  float/double            --> REAL
 *  NSData/UIImage          --> BLOB
 *  其他                     --> TEXT
 *
 *  @param type OC/C类型(见方法getPropertys)
 *
 *  @return sqlite类型
 */
+ (NSString *)toDBType:(NSString *)type;

#pragma mark - Create

//创建表
- (void)createTable;

#pragma mark - Update Table
//给表增加一列
- (void)tableAddColumn:(NSString *)column type:(NSString *)type callback:(void (^)(BOOL))block;

//SQLite不支持删除列
- (void)tableDropColumn:(NSString *)column callback:(void (^)(BOOL))block;

//读取表所有的列名
- (void)readTableColumns:(void (^)(NSArray *))block;

#pragma mark - Search

/**
 *  查询有多少数据
 */
- (void)searchCount:(void(^)(int))block;

/**
 *  返回所有的数据
 *
 *  @param callback 返回结果,对应的models
 */
- (void)searchAll:(void(^)(NSArray *))callback;

/**
 *  返回count条数据
 *
 *  @param count    count
 *  @param callback 返回结果,对应的models
 */
- (void)searchCount:(int)count callback:(void(^)(NSArray *))callback;

/**
 *  返回count条数据
 *
 *  @param orderBy  条件,例:time DESC(按time排序)
 *  @param count    count
 *  @param callback 返回结果,对应的models
 */
- (void)searchOrderBy:(NSString *)orderBy count:(int)count callback:(void(^)(NSArray *))callback;

/**
 *  返回所有的数据
 *
 *  @param where where条件,自定义,例where:@"rowid = 2"或者@"string = 'Jay'"
 *  @param block 返回结果,对应的models
 */
- (void)searchAllWhere:(NSString *)where callback:(void(^)(NSArray *))block;

#pragma mark Search Page

/**
 *  默认返回 SEARCH_COUNT条数据
 *
 *  @param pageNum 第几页(0是首页)
 *  @param block  返回结果,对应的models
 */
- (void)searchPageNum:(int)pageNum callback:(void (^)(NSArray *))block;

/**
 *  默认返回 SEARCH_COUNT条数据
 *
 *  @param orderBy 条件,例:time DESC(按time排序)
 *  @param pageNum 第几页(0是首页)
 *  @param block   返回结果,对应的models
 */
- (void)searchOrderBy:(NSString *)orderBy pageNum:(int)pageNum callback:(void (^)(NSArray *))block;

#pragma mark Search 自定义Where

/**
 *  默认返回 SEARCH_COUNT条数据
 *
 *  @param where  where条件,自定义,例where:@"rowid = 2"或者@"string = 'Jay'"
 *  @param pageNum 第几页(0是首页)
 *  @param block  返回结果,对应的models
 */
- (void)searchWhere:(NSString *)where pageNum:(int)pageNum callback:(void (^)(NSArray *))block;

/**
 *  返回count条数据
 *
 *  @param where   where条件,自定义,例where:@"rowid = 2"或者@"string = 'Jay'"
 *  @param orderBy 条件,例:time DESC(按time排序)
 *  @param count   count
 *  @param block   返回结果,对应的models
 */
- (void)searchWhere:(NSString *)where orderBy:(NSString *)orderBy count:(int)count callback:(void (^)(NSArray *))block;


/**
 *  默认返回 SEARCH_COUNT条数据
 *
 *  @param where   where条件,自定义,例where:@"rowid = 2"或者@"string = 'Jay'"
 *  @param orderBy 条件,例:time DESC(按time排序)
 *  @param pageNum 第几页(0是首页)
 *  @param block   返回结果,对应的models
 */
- (void)searchWhere:(NSString *)where orderBy:(NSString *)orderBy pageNum:(int)pageNum callback:(void (^)(NSArray *))block;

#pragma mark Search key-value模式传入
/**
 *  返回SEARCH_COUNT条数据
 *
 *  @param whereDic where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param pageNum  第几页(0是首页)
 *  @param block    返回结果,对应的models
 */
- (void)searchWhereDic:(NSDictionary *)whereDic pageNum:(int)pageNum callback:(void(^)(NSArray*))block;

/**
 *  返回SEARCH_COUNT条数据
 *
 *  @param whereDic where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param orderBy  例:time DESC(按time排序)
 *  @param pageNum  第几页(0是首页)
 *  @param block    返回结果,对应的models
 */
- (void)searchWhereDic:(NSDictionary *)whereDic orderBy:(NSString *)orderBy pageNum:(int)pageNum callback:(void (^)(NSArray *))block;


#pragma mark - Insert

/**
 *  把model直接插入到数据库
 *
 *  @param model model
 *  @param block block
 */
- (void)insertToDB:(id)model callback:(void(^)(BOOL))block;

/**
 *  把model插入到数据库,如果存在(用primaryKey来判断),就更新(通过rowid或者primarykey来更新)
 *
 *  @param model model
 *  @param block block
 */
- (void)insertToDBNotExistsOrUpdate:(id)model callback:(void (^)(BOOL))block;

#pragma mark Insert 自定义Where

/**
 *  把model插入到数据库,如果存在(where语句来判断),就更新(where语句来更新)
 *
 *  @param model model
 *  @param where where条件,自定义,例where:@"rowid = 2"或者@"string = 'Jay'"
 *  @param block block
 */
- (void)insertToDBNotExistsOrUpdate:(id)model WithWhere:(NSString *)where callback:(void (^)(BOOL))block;

/**
 *  把model插入到数据库,如果存在(where语句来判断),就更新(where语句来更新对应的updateKey)
 *
 *  @param model     model
 *  @param updateKey 需要更新的字段,例: @"name='Jay', age=10, height=1.8"
 *  @param where     where条件,自定义,例where:@"rowid = 2"或者@"string = 'Jay'"
 *  @param block     block
 */
- (void)insertToDBNotExistsOrUpdate:(id)model withUpdateKey:(NSString *)updateKey withWhere:(NSString *)where callback:(void (^)(BOOL))block;



#pragma mark Insert key-value

/**
 *  把model插入到数据库,如果存在(whereDic语句来判断),就更新(whereDic语句来更新)
 *
 *  @param model    model
 *  @param whereDic where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param block    block
 */
- (void)insertToDBNotExistsOrUpdate:(id)model WithWhereDic:(NSDictionary *)whereDic callback:(void (^)(BOOL))block;

/**
 *  把model插入到数据库,如果存在(whereDic语句来判断),就更新(whereDic语句来更新对应的updateKey)
 *
 *  @param model        model
 *  @param updateKeyDic Update的数据,例:@{@"height":@1.8, @"weight":@60}
 *  @param whereDic     where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param block        block
 */
- (void)insertToDBNotExistsOrUpdate:(id)model withUpdateKey:(NSDictionary *)updateKeyDic withWhereDic:(NSDictionary *)whereDic callback:(void (^)(BOOL))block;


#pragma mark - Update

/**
 *  更新model,更新全部,通过rowid或者primarykey来更新数据
 *
 *  @param model model
 *  @param block block
 */
- (void)updateToDB:(id)model callback:(void(^)(BOOL))block;



#pragma mark Update 自定义Where

/**
 *  更新model,更新全部,自定义where
 *
 *  @param model model
 *  @param where 更新的条件,例: @"uid=100"
 *  @param block block
 */
- (void)updateToDB:(id)model withWhere:(NSString *)where callback:(void (^)(BOOL))block;


/**
 *  更新model,自定义updateKey和where
 *
 *  @param updateKey 需要更新的字段,例: @"name='Jay', age=10, height=1.8"
 *  @param where     更新的条件,例: @"uid=100"
 *  @param block     block
 */
- (void)updateToDBWithUpdateKey:(NSString *)updateKey withWhere:(NSString *)where callback:(void (^)(BOOL))block;

#pragma mark Update key-value


/**
 *  更新model,更新全部,自定义whereDic
 *
 *  @param model    model
 *  @param whereDic where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param block    block
 */
- (void)updateToDB:(id)model withWhereDic:(NSDictionary *)whereDic callback:(void (^)(BOOL))block;

/**
 *  更新model,自定义whereDic
 *
 *  @param UpdateKeyDic Update的数据,例:@{@"height":@1.8, @"weight":@60}
 *  @param whereDic     where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param block        block
 */
- (void)updateToDBWithUpdateKey:(NSDictionary *)UpdateKeyDic withWhereDic:(NSDictionary *)whereDic callback:(void (^)(BOOL))block;

#pragma mark - Delete

/**
 *  删除model,通过rowid或者primarykey来删除数据
 *
 *  @param model model
 *  @param block block
 */
- (void)deleteToDB:(id)model callback:(void(^)(BOOL))block;


/**
 *  根据where条件删除数据
 *
 *  @param where where条件,自定义,例where:@"rowid = 2"或者@"string = 'Jay'"
 *  @param block block
 */
- (void)deleteToDBWithWhere:(NSString *)where callback:(void (^)(BOOL))block;

/**
 *  根据where条件删除数据
 *
 *  @param where where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param block block
 */
- (void)deleteToDBWithWhereDic:(NSDictionary *)where callback:(void (^)(BOOL))block;


/** 清空表数据 */
- (void)clearTableWithCallback:(void (^)(BOOL))block;


#pragma mark - isExist

/**
 *  是否存在model(用primaryKey来判断)
 *
 *  @param model
 *  @param block 返回YES存在,NO不存在
 */
- (void)isExistsModel:(id)model callback:(void(^)(BOOL))block;

/**
 *  是否存在model
 *
 *  @param where 自定义的SQL语句,例: @"uid=100"
 *  @param block 返回YES存在,NO不存在
 */
- (void)isExistsModelWithWhere:(NSString *)where callback:(void (^)(BOOL))block;

/**
 *  是否存在model
 *
 *  @param whereDic where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param block    返回YES存在,NO不存在
 */
- (void)isExistsModelWithWhereDic:(NSDictionary *)whereDic callback:(void (^)(BOOL))block;


@end
