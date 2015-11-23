//
//  JJBaseDBOperate+Methods.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/17.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "JJBaseDBOperate+Methods.h"
#import "JJDatabaseQueue.h"
#import "NSDate+JJFMDB.h"
#import "NSString+JJFMDB.h"
#import "NSObject+JJFMDBPropertys.h"
#import "NSObject+JJDBObject.h"
#import "FMDB.h"
#import "JJSandBox.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

//数据库的数据类型
#define JJ_SQL_TEXT @"TEXT"
#define JJ_SQL_INTEGER @"INTEGER"
#define JJ_SQL_BIGINT @"BIGINT"
#define JJ_SQL_FLOAT @"DECIMAL"    //DECIMAL/FLOAT/REAL
#define JJ_SQL_BLOB @"BLOB"
#define JJ_SQL_NULL @"NULL"
#define JJ_SQL_INTEGER_PRIMARY_KEY @"INTEGER PRIMARY KEY"

/** 查询数据库一页能查询到的个数 */
#define DB_SEARCH_COUNT 10

@implementation JJBaseDBOperate (Methods)

#pragma mark - Init

- (instancetype)initWithDBQueue:(JJDatabaseQueue *)queue
{
    self = [super init];
    if (self) {
        self.bindingQueue = queue;
        [self createProtypesAndColume];
        [self createTable];
    }
    return self;
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self createProtypesAndColume];
        [self createTable];
    }
    return self;
}

#pragma mark - Private Methods

/** 获取数据库路径 */
- (NSString *)getDataBasePath
{
    //数据库名称
    return [JJSandBox getPathForDocuments:[NSString stringWithFormat:@"database.db"] inDir:@"DataBase"];
}

/** 创建属性字典,名字数组,类型数组 */
- (void)createProtypesAndColume
{
    self.columeNames = [NSMutableArray arrayWithCapacity:0];
    self.columeTypes = [NSMutableArray arrayWithCapacity:0];
    
    //获取绑定的Model,并保存Model的属性信息
    NSDictionary *dic  = [[self.class getBindingModelClass] getPropertysWithSuper];
    NSArray *pronames = [dic objectForKey:@"name"];
    NSArray *protypes = [dic objectForKey:@"type"];
    
    if (pronames.count == protypes.count) {
        self.propertys = [NSMutableDictionary dictionaryWithObjects:protypes forKeys:pronames];
    }
    
    for (int i=0; i<pronames.count; i++) {
        [self addColume:[pronames objectAtIndex:i] type:[protypes objectAtIndex:i]];
    }
}


/**
 *  名字数组,例:[@"name", @"age", @"uid"]
 *  类型数组,例:@[@"TEXT", @"BIGINT", @"INTEGER"]
 *
 *  @param name name,例:name
 *  @param type type,例:TEXT
 */
- (void)addColume:(NSString *)name type:(NSString *)type
{
    [self.columeNames addObject:name];
    [self.columeTypes addObject:[JJBaseDBOperate toDBType:type]];
}

- (void)addColumePrimary:(NSString *)name type:(NSString *)type
{
    [self.columeNames addObject:name];
    [self.columeTypes addObject:[NSString stringWithFormat:@"%@ primary key",[JJBaseDBOperate toDBType:type]]];
}


- (void)dealloc
{
    self.bindingQueue = nil;
    self.propertys = nil;
    self.columeNames = nil;
    self.columeTypes = nil;
}

#pragma mark - Methods



/**
 *  把Model的属性类型转换成数据库的类型
 *
 *  @param type type
 *
 *  @return JJSQLXXX
 */
+ (NSString *)toDBType:(NSString *)type
{
    if ([type isEqualToString:@"char"] ||
       [type isEqualToString:@"short"] ||
       [type isEqualToString:@"int"] ||
       [type isEqualToString:@"long"]) {
        return JJ_SQL_INTEGER;
    }
    else if ([type isEqualToString:@"float"] ||
            [type isEqualToString:@"double"]) {
        return JJ_SQL_FLOAT;
    }
    else if ([type isEqualToString:@"long long"]) {
        return JJ_SQL_BIGINT;
    }
    else if ([type isEqualToString:@"NSData"] ||
            [type isEqualToString:@"UIImage"]) {
        return JJ_SQL_BLOB;
    }
    
    return JJ_SQL_TEXT;
}

/**
 *  根据bindingModel的类型,把数据库的值转换过来
 *
 *  @param bindingModel 继承JJBaseDBModel
 *  @param set          FMResultSet
 *  @param columeName   属性的Name
 *  @param columeType   属性的类型
 */
- (void)bindingModelSetValue:(id)bindingModel WithSet:(FMResultSet *)set columeName:(NSString *)columeName columeType:(NSString *)columeType
{
    if ([columeType isEqualToString:@"NSString"])
    {
        [bindingModel setValue:[set stringForColumn:columeName] forKey:columeName];
    }
    else if ([columeType isEqualToString:@"int"] ||
            [columeType isEqualToString:@"long"] ||
            [columeType isEqualToString:@"long long"])
    {
        [bindingModel setValue:[NSNumber numberWithLongLong:[set longLongIntForColumn:columeName]] forKey:columeName];
    }
    else if ([columeType isEqualToString:@"BOOL"] ||
             [columeType isEqualToString:@"bool"])
    {
        [bindingModel setValue:[NSNumber numberWithBool:[set boolForColumn:columeName]] forKey:columeName];
    }
    else if ([columeType isEqualToString:@"char"])
    {
        [bindingModel setValue:[NSNumber numberWithInt:[set intForColumn:columeName]] forKey:columeName];
    }
    else if ([columeType isEqualToString:@"float"] ||
             [columeType isEqualToString:@"double"])
    {
        [bindingModel setValue:[NSNumber numberWithDouble:[set doubleForColumn:columeName]] forKey:columeName];
    }
    else if ([columeType isEqualToString:@"NSNumber"])
    {
        [bindingModel setValue:[NSNumber numberWithLongLong:[set stringForColumn:columeName].longLongValue] forKey:columeName];
    }
    else if ([columeType isEqualToString:@"UIImage"])
    {
        NSString* filename = [set stringForColumn:columeName];
        if ([JJSandBox isFileExists:[JJSandBox getPathForDocuments:filename inDir:@"dbImages"]])
        {
            UIImage *img = [UIImage imageWithContentsOfFile:[JJSandBox getPathForDocuments:filename inDir:@"dbImages"]];
            [bindingModel setValue:img forKey:columeName];
        }
    }
    else if ([columeType isEqualToString:@"NSDate"])
    {
        NSString* datestr = [set stringForColumn:columeName];
        [bindingModel setValue:[NSDate dateWithString:datestr] forKey:columeName];
    }
    else if ([columeType isEqualToString:@"NSData"])
    {
        NSString *filename = [set stringForColumn:columeName];
        if ([JJSandBox isFileExists:[JJSandBox getPathForDocuments:filename inDir:@"dbData"]])
        {
            NSData* data = [NSData dataWithContentsOfFile:[JJSandBox getPathForDocuments:filename inDir:@"dbData"]];
            [bindingModel setValue:data forKey:columeName];
        }
    }
    
}

/**
 *  数据库value存文件对应的名字使用(UIImage, NSData, NSDate)
 *
 *  @param value 文件的名字
 */
- (void)valueForFileName:(id)value
{
    if (!value) {
        return ;
    }
    
    NSDate *date = [NSDate date];
    
    if ([value isKindOfClass:[UIImage class]])
    {
        NSString *filename = [NSString stringWithFormat:@"img%f",[date timeIntervalSince1970]];
        [UIImageJPEGRepresentation(value, 1) writeToFile:[JJSandBox getPathForDocuments:filename inDir:@"dbImages"] atomically:YES];
        value = filename;
    }
    else if ([value isKindOfClass:[NSData class]])
    {
        NSString *filename = [NSString stringWithFormat:@"data%f",[date timeIntervalSince1970]];
        [value writeToFile:[JJSandBox getPathForDocuments:filename inDir:@"dbdata"] atomically:YES];
        value = filename;
    }
    else if ([value isKindOfClass:[NSDate class]])
    {
        value = [NSDate stringWithDate:value];
    }
}

#pragma mark - Append SQL
/**
 *  根据modle,返回创建表SQL,例:@"name TEXT,age INTEGER,uid BIGINT"
 *
 *  @return NSString
 */
- (NSString *)appendTableSql
{
    NSMutableString *tableSql = [NSMutableString string];
    for (int i=0; i<self.columeNames.count; i++) {
        [tableSql appendFormat:@"%@ %@",[self.columeNames objectAtIndex:i],[self.columeTypes objectAtIndex:i]];
        if (i+1 !=self.columeNames.count)
        {
            [tableSql appendString:@","];
        }
    }
    return tableSql;
}


/**
 *  字典转SQL的where语句,
 *
 *  @param dic    where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param values 数组:@[@"Jay",@18]
 *
 *  @return where语句,例:@" name = ? AND age = ? OR height = ?"
 */
- (NSString *)dictionaryToSqlWhere:(NSDictionary *)dic andValues:(NSMutableArray  *)values
{
    NSMutableString *whereKey = [NSMutableString stringWithCapacity:0];
    if (dic != nil && dic.count >0 )
    {
        NSArray *keys = dic.allKeys;
        for (int i=0; i< keys.count;i++) {
            
            NSString *key = [keys objectAtIndex:i];
            id va = [dic objectForKey:key];
            
            if ([va isKindOfClass:[NSArray class]])
            {
                //当NSDictionary的value是NSArray类型时,使用or当中间值
                NSArray* vlist = va;
                for (int j=0; j<vlist.count; j++) {
                    id subvalue = [vlist objectAtIndex:j];
                    if (whereKey.length > 0)
                    {
                        if (j > 0)
                        {
                            [whereKey appendFormat:@"OR %@=? ",key];
                        }
                        else{
                            [whereKey appendFormat:@"AND %@=? ",key];
                        }
                    }
                    else
                    {
                        [whereKey appendFormat:@"%@=? ",key];
                    }
                    [values addObject:subvalue];
                }
            }
            else
            {
                if (whereKey.length > 0)
                {
                    [whereKey appendFormat:@"AND %@=? ",key];
                }
                else
                {
                    [whereKey appendFormat:@"%@=? ",key];
                }
                [values addObject:va];
            }
            
        }
    }
    return whereKey;
}


/**
 *  拼接SQL语句的条件,例:@"ORDER BY %@ LIMIT %d OFFSET %d "
 *
 *  @param sql     sql
 *  @param orderby orderby
 *  @param offset  offset
 *  @param count   count
 */
- (void)sqlString:(NSMutableString *)sql AddOder:(NSString *)orderby offset:(int)offset count:(int)count
{
    if (!sql || !count) {
        return ;
    }
    
    if (orderby != nil && ![orderby isEmptyWithTrim])
    {
        [sql appendFormat:@"ORDER BY %@ ",orderby];
    }
    [sql appendFormat:@"LIMIT %d OFFSET %d ",count, offset];
}

/**
 *  通过model创建setKey和setValues
 *
 *  @param setKey    SQL语句中的"SET %@"这个%@,例:@"name=?,age=?"
 *  @param setValues 要更新的值,例:@[@"Jay", @18]
 *  @param model        model
 */
- (void)createSetKey:(NSMutableString *)setKey andSetValues:(NSMutableArray *)setValues withModel:(NSObject *)model
{
    
    for (int i=0; i<self.columeNames.count; i++) {
        
        NSString *pName = [self.columeNames objectAtIndex:i];
        [setKey appendFormat:@"%@=?,", pName];
        
        id value = [model valueForKey:pName];
        
        [self valueForFileName:value];
        
        [setValues addObject:value];
    }
    
    if (setKey.length > 0) {
        [setKey deleteCharactersInRange:NSMakeRange(setKey.length - 1, 1)];
    }
    
}


/**
 *  通过setDic创建setKey和setValues
 *
 *  @param setKey    SQL语句中的"SET %@"这个%@,例:@"name=?,age=?"
 *  @param setValues 要更新的值,例:@[@"Jay", @18]
 *  @param setDic    setDic,例:@{@"height":@1.8, @"weight":@60}
 */
- (void)createSetKey:(NSMutableString *)setKey andSetValues:(NSMutableArray *)setValues withupdateKeyDic:(NSDictionary *)setDic
{
    
    NSArray *keyArr = setDic.allKeys;
    for (NSInteger i=0; i<keyArr.count; i++) {
        NSString *key = [keyArr objectAtIndex:i];
        id value = [setDic objectForKey:key];
        
        [setKey appendFormat:@"%@=?,", key];
        
        [self valueForFileName:value];
        
        [setValues addObject:value];
        
    }
    
    if (setKey.length > 0) {
        [setKey deleteCharactersInRange:NSMakeRange(setKey.length - 1, 1)];
    }
}


/**
 *  根据model创建插入语句
 *
 *  @param insertKey       例:(name,age,height,weight)
 *  @param insertValuesStr 例:(?,?,?,?)
 *  @param insertValues    @[@"Jay", @18, @1.8, @60]
 *  @param model           model
 */
- (void)createInsertKey:(NSMutableString *)insertKey
     andInsertValuesStr:(NSMutableString *)insertValuesStr
        andinsertValues:(NSMutableArray *)insertValues
              withModel:(NSObject *)model
{
    for (int i=0; i<self.columeNames.count; i++) {
        
        NSString *pName = [self.columeNames objectAtIndex:i];
        [insertKey appendFormat:@"%@,", pName];
        [insertValuesStr appendString:@"?,"];
        id value = [model valueForKey:pName];
        
        [self valueForFileName:value];
        
        [insertValues addObject:value];
    }
    
    if (insertKey.length > 0) {
        [insertKey deleteCharactersInRange:NSMakeRange(insertKey.length - 1, 1)];
    }
    
    if (insertValuesStr.length > 0) {
        [insertValuesStr deleteCharactersInRange:NSMakeRange(insertValuesStr.length - 1, 1)];
    }
    
}




#pragma mark - Table
/** 创建表 */
- (void)createTable
{
    if ([[self.class getTableName] isEmptyWithTrim]) {
        NSLog(@"TableName is None!");
        return;
    }
    
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        NSString *createTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,%@)",[self.class getTableName],[self appendTableSql]];
        [db executeUpdate:createTableSql];
    }];
}


- (void)tableAddColumn:(NSString *)column type:(NSString *)type callback:(void (^)(BOOL))block {
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        
        NSString *updateTableSql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@",[self.class getTableName], column, type];
        
        BOOL execute = [db executeUpdate:updateTableSql];
        
        if (block) {
            block(execute);
        }
    }];
}

//SQLite不支持删除列
- (void)tableDropColumn:(NSString *)column callback:(void (^)(BOOL))block {
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        
        NSString *updateTableSql = [NSString stringWithFormat:@"ALTER TABLE %@ DROP COLUMN %@",[self.class getTableName], column];
        
        BOOL execute = [db executeUpdate:updateTableSql];
        
        if (block) {
            block(execute);
        }
    }];
}


/**
 *  查询数据库内的表名
 *  select * from sqlite_master where type='table' order by name
 */
- (void)readTableNames:(void (^)(NSArray *))block {
    
}



- (void)readTableColumns:(void (^)(NSArray *))block {
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        
        NSMutableString *searchSql = [NSMutableString stringWithFormat:@"PRAGMA TABLE_INFO(%@)",[self.class getTableName]];
        
        FMResultSet *set =[db executeQuery:searchSql];
        
        NSMutableArray *columnArr = [[NSMutableArray alloc] initWithCapacity:0];
        /**
         *  columnIdx:  0:cid,序号 1:name,列名 2:type,类型
         */
        while ([set next]) {
            [columnArr addObject:[set stringForColumnIndex:1]];
        }
        [set close];
        
        if (block) {
            block(columnArr);
        }
        
    }];
}



#pragma mark - Search

- (void)executeResult:(FMResultSet *)set block:(void (^)(NSArray *))block
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    
    while ([set next]) {
        
        NSObject *model = [[[self.class getBindingModelClass] alloc] init];
        model.rowid = [set intForColumnIndex:0];
        
        for (int i=0; i<self.columeNames.count; i++) {
            
            NSString *columeName = [self.columeNames objectAtIndex:i];
            NSString *columeType = [self.propertys objectForKey:columeName];
            
            [self bindingModelSetValue:model WithSet:set columeName:columeName columeType:columeType];
            
        }
        [array addObject:model];
    }
    [set close];
    
    if (block) {
        block(array);
    }
    
}


- (void)searchCount:(void(^)(int))block
{
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        
        NSMutableString *searchSql = [NSMutableString stringWithFormat:@"SELECT count(*) FROM %@",[self.class getTableName]];
        
        FMResultSet *set =[db executeQuery:searchSql];
        
        int count = 0;
        
        if ([set next]) {
            count = [set intForColumnIndex:0];
        }
        [set close];
        
        if (block) {
            block(count);
        }
        
    }];
}

#pragma mark Search All
- (void)searchAll:(void(^)(NSArray *))callback{
    [self searchWhere:nil orderBy:nil offset:0 count:0 callback:callback];
}

- (void)searchCount:(int)count callback:(void(^)(NSArray *))callback{
    [self searchWhere:nil orderBy:nil offset:0 count:count callback:callback];
}

- (void)searchOrderBy:(NSString *)orderBy count:(int)count callback:(void(^)(NSArray *))callback {
    [self searchWhere:nil orderBy:orderBy offset:0 count:count callback:callback];
}


- (void)searchAllWhere:(NSString *)where callback:(void(^)(NSArray *))block{
    [self searchWhere:where orderBy:nil offset:0 count:0 callback:block];
}

#pragma mark Search Page
- (void)searchPageNum:(int)pageNum callback:(void (^)(NSArray *))block
{
    [self searchWhere:nil orderBy:nil offset:(pageNum * DB_SEARCH_COUNT) count:DB_SEARCH_COUNT callback:block];
}

- (void)searchOrderBy:(NSString *)orderBy pageNum:(int)pageNum callback:(void (^)(NSArray *))block
{
    [self searchWhere:nil orderBy:orderBy offset:(pageNum * DB_SEARCH_COUNT) count:DB_SEARCH_COUNT callback:block];
}

#pragma mark Search 自定义Where

- (void)searchWhere:(NSString *)where pageNum:(int)pageNum callback:(void (^)(NSArray *))block
{
    [self searchWhere:where orderBy:nil offset:(pageNum * DB_SEARCH_COUNT) count:DB_SEARCH_COUNT callback:block];
}


- (void)searchWhere:(NSString *)where orderBy:(NSString *)orderBy pageNum:(int)pageNum callback:(void (^)(NSArray *))block
{
    [self searchWhere:where orderBy:orderBy offset:(pageNum * DB_SEARCH_COUNT) count:DB_SEARCH_COUNT callback:block];
}

- (void)searchWhere:(NSString *)where orderBy:(NSString *)orderBy count:(int)count callback:(void (^)(NSArray *))block
{
    [self searchWhere:where orderBy:orderBy offset:0 count:count callback:block];
}


- (void)searchWhere:(NSString *)where orderBy:(NSString *)orderBy offset:(int)offset count:(int)count callback:(void (^)(NSArray *))block
{
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        
        NSMutableString *searchSql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ",[self.class getTableName]];
        if (where != nil && ![where isEmptyWithTrim])
        {
            [searchSql appendFormat:@"WHERE %@ ",where];
        }
        [self sqlString:searchSql AddOder:orderBy offset:offset count:count];
        FMResultSet *set =[db executeQuery:searchSql];
        
        [self executeResult:set block:block];
    }];
}

#pragma mark Search key-value模式传入
- (void)searchWhereDic:(NSDictionary *)whereDic pageNum:(int)pageNum callback:(void(^)(NSArray*))block
{
    [self searchWhereDic:whereDic orderBy:nil offset:(pageNum * DB_SEARCH_COUNT) count:DB_SEARCH_COUNT callback:block];
}

- (void)searchWhereDic:(NSDictionary *)whereDic orderBy:(NSString *)orderBy pageNum:(int)pageNum callback:(void (^)(NSArray *))block
{
    [self searchWhereDic:whereDic orderBy:orderBy offset:(pageNum * DB_SEARCH_COUNT) count:DB_SEARCH_COUNT callback:block];
}

- (void)searchWhereDic:(NSDictionary *)whereDic orderBy:(NSString *)orderby offset:(int)offset count:(int)count callback:(void (^)(NSArray *))block
{
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ",[self.class getTableName]];
        
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:0];
        
        if (whereDic !=nil && whereDic.count>0)
        {
            NSString *whereKey = [self dictionaryToSqlWhere:whereDic andValues:values];
            [query appendFormat:@"WHERE %@ ",whereKey];
        }
        [self sqlString:query AddOder:orderby offset:offset count:count];
        FMResultSet *set =[db executeQuery:query withArgumentsInArray:values];
        
        [self executeResult:set block:block];
    }];
}


#pragma mark - Insert

- (void)executeInsertToDB:(NSObject *)model withDatabase:(FMDatabase *)db callback:(void (^)(BOOL))block
{
    //    NSLog(@"=========================");
    //    NSLog(@"开始插入数据");
    NSMutableString *insertKey = [NSMutableString stringWithCapacity:0];
    NSMutableString *insertValuesStr = [NSMutableString stringWithCapacity:0];
    NSMutableArray *insertValues = [NSMutableArray arrayWithCapacity:0];
    
    [self createInsertKey:insertKey andInsertValuesStr:insertValuesStr andinsertValues:insertValues withModel:model];
    
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@)",[self.class getTableName],insertKey,insertValuesStr];
    BOOL execute = [db executeUpdate:insertSQL withArgumentsInArray:insertValues];
    model.rowid = db.lastInsertRowId;
    
    if (block != nil) {
        block(execute);
    }
    
    if (execute == NO) {
        NSLog(@"database insert fail %@",NSStringFromClass(model.class));
    }
}

#pragma mark Insert model

- (void)insertToDB:(NSObject *)model callback:(void (^)(BOOL))block{
    
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeInsertToDB:model withDatabase:db callback:block];
    }];
}



- (void)insertToDBNotExistsOrUpdate:(NSObject *)model callback:(void (^)(BOOL))block{
    
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        BOOL isExists = [self executeIsExistsModel:model withDatabase:db callback:nil];
        if (isExists) {
            [self executeUpdateToDB:model withDatabase:db callback:block];
        }
        else{
            [self executeInsertToDB:model withDatabase:db callback:block];
        }
        
    }];
}

#pragma mark Insert 自定义Where

- (void)insertToDBNotExistsOrUpdate:(NSObject *)model WithWhere:(NSString *)where callback:(void (^)(BOOL))block{
    
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        BOOL isExists = [self executeIsExistsModelWithWhere:where withDatabase:db callback:nil];
        if (isExists) {
            [self executeUpdateToDB:model withDatabase:db withWhere:where callback:block];
        }
        else{
            [self executeInsertToDB:model withDatabase:db callback:block];
        }
        
    }];
}

- (void)insertToDBNotExistsOrUpdate:(NSObject *)model withUpdateKey:(NSString *)updateKey withWhere:(NSString *)where callback:(void (^)(BOOL))block{
    
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        BOOL isExists = [self executeIsExistsModelWithWhere:where withDatabase:db callback:nil];
        if (isExists) {
            [self executeUpdateToDBWithUpdateKey:updateKey withDatabase:db withWhere:where callback:block];
        }
        else{
            [self executeInsertToDB:model withDatabase:db callback:block];
        }
        
    }];
}

#pragma mark Insert key-value

- (void)insertToDBNotExistsOrUpdate:(NSObject *)model WithWhereDic:(NSDictionary *)whereDic callback:(void (^)(BOOL))block{
    
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        BOOL isExists = [self executeIsExistsModelWithWhereDic:whereDic withDatabase:db callback:block];
        if (isExists) {
            [self executeUpdateToDB:model withDatabase:db withWhereDic:whereDic callback:block];
        }
        else{
            [self executeInsertToDB:model withDatabase:db callback:block];
        }
        
    }];
}

- (void)insertToDBNotExistsOrUpdate:(NSObject *)model withUpdateKey:(NSDictionary *)updateKeyDic withWhereDic:(NSDictionary *)whereDic callback:(void (^)(BOOL))block{
    
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        BOOL isExists = [self executeIsExistsModelWithWhereDic:whereDic withDatabase:db callback:block];
        if (isExists) {
            [self executeUpdateToDBWithDatabase:db orUpdateKeyDic:updateKeyDic withWhereDic:whereDic callback:block];
        }
        else{
            [self executeInsertToDB:model withDatabase:db callback:block];
        }
        
    }];
}





#pragma mark - Update

- (void)executeUpdateToDB:(NSObject *)model withDatabase:(FMDatabase *)db callback:(void (^)(BOOL))block
{
    [self executeUpdateToDB:model withDatabase:db withWhere:nil callback:block];
}

- (void)executeUpdateToDB:(NSObject *)model withDatabase:(FMDatabase *)db withWhere:(NSString *)where callback:(void (^)(BOOL))block
{
    NSMutableString *updateKey = [NSMutableString stringWithCapacity:0];
    
    NSMutableArray *updateValues = [NSMutableArray arrayWithCapacity:self.columeNames.count];
    
    //创建updateKey 和 UpdateValues
    [self createSetKey:updateKey andSetValues:updateValues withModel:model];
    
    NSString *updateSql = nil;
    if (where) {
        updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@", [self.class getTableName], updateKey, where];
    }
    else{
        //通过rowid来更新数据
        if (model.rowid > 0) {
            updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE rowid=%lld",[self.class getTableName],updateKey,model.rowid];
        }
        else{
            if (!model.primaryKey) {
                if (block) {
                    block(NO);
                }
                return ;
            }
            
            //通过primarykey来更新数据
            updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@=?",[self.class getTableName],updateKey,model.primaryKey];
            
            [updateValues addObject:[model valueForKey:model.primaryKey]];
        }
    }
    
    BOOL execute = [db executeUpdate:updateSql withArgumentsInArray:updateValues];
    
    if (block) {
        block(execute);
    }
}


- (void)executeUpdateToDBWithUpdateKey:(NSString *)updateKey withDatabase:(FMDatabase *)db withWhere:(NSString *)where callback:(void (^)(BOOL))block
{
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@", [self.class getTableName], updateKey, where];
    
    BOOL execute = [db executeUpdate:updateSql];
    
    if (block) {
        block(execute);
    }
}


- (void)executeUpdateToDB:(NSObject *)model withDatabase:(FMDatabase *)db withWhereDic:(NSDictionary *)whereDic callback:(void (^)(BOOL))block
{
    [self executeUpdateToDB:model withDatabase:db orUpdateKeyDic:nil withWhereDic:whereDic callback:block];
}

- (void)executeUpdateToDBWithDatabase:(FMDatabase *)db orUpdateKeyDic:(NSDictionary *)updateKeyDic withWhereDic:(NSDictionary *)whereDic callback:(void (^)(BOOL))block
{
    [self executeUpdateToDB:nil withDatabase:db orUpdateKeyDic:updateKeyDic withWhereDic:whereDic callback:block];
}

- (void)executeUpdateToDB:(NSObject *)model withDatabase:(FMDatabase *)db orUpdateKeyDic:(NSDictionary *)updateKeyDic withWhereDic:(NSDictionary *)whereDic callback:(void (^)(BOOL))block
{
    NSMutableString *setKey = [NSMutableString stringWithCapacity:0];
    
    NSMutableArray *setValues = [NSMutableArray arrayWithCapacity:0];
    
    //创建updateKey 和 UpdateValues
    if (model) {
        [self createSetKey:setKey andSetValues:setValues withModel:model];
    }
    else if (updateKeyDic && updateKeyDic.count) {
        [self createSetKey:setKey andSetValues:setValues withupdateKeyDic:updateKeyDic];
    }
    
    
    NSString *updateSql = [NSString string];
    
    if (whereDic && whereDic.count)
    {
        //whereDic对应的值继续放在updateValues里面,只要?和value对应
        NSString *where = [self dictionaryToSqlWhere:whereDic andValues:setValues];
        updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",[self.class getTableName], setKey, where];
    }
    
    BOOL execute = [db executeUpdate:updateSql withArgumentsInArray:setValues];
    
    if (block) {
        block(execute);
    }
}

#pragma mark Update model

- (void)updateToDB:(NSObject *)model callback:(void (^)(BOOL))block
{
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeUpdateToDB:model withDatabase:db callback:block];
    }];
}

#pragma mark Update 自定义Where

- (void)updateToDB:(NSObject *)model withWhere:(NSString *)where callback:(void (^)(BOOL))block
{
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeUpdateToDB:model withDatabase:db withWhere:where callback:block];
    }];
}

- (void)updateToDBWithUpdateKey:(NSString *)updateKey withWhere:(NSString *)where callback:(void (^)(BOOL))block
{
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeUpdateToDBWithUpdateKey:updateKey withDatabase:db withWhere:where callback:block];
    }];
}



#pragma mark Update key-value

- (void)updateToDB:(NSObject *)model withWhereDic:(NSDictionary *)whereDic callback:(void (^)(BOOL))block
{
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeUpdateToDB:model withDatabase:db withWhereDic:whereDic callback:block];
    }];
}

- (void)updateToDBWithUpdateKey:(NSDictionary *)UpdateKeyDic withWhereDic:(NSDictionary *)whereDic callback:(void (^)(BOOL))block
{
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeUpdateToDBWithDatabase:db orUpdateKeyDic:UpdateKeyDic withWhereDic:whereDic callback:block];
    }];
}


- (void)updateToDB:(NSObject *)model orUpdateKey:(NSDictionary *)updateKeyDic withWhereDic:(NSDictionary *)whereDic callback:(void (^)(BOOL))block
{
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeUpdateToDB:model withDatabase:db orUpdateKeyDic:updateKeyDic withWhereDic:whereDic callback:block];
    }];
}





#pragma mark - Delete

- (void)deleteToDB:(NSObject *)model callback:(void (^)(BOOL))block{
    
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        NSString *deleteSql = nil;
        BOOL result = NO;
        if (model.rowid > 0) {
            deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE rowid=%lld",[self.class getTableName],model.rowid];
            result = [db executeUpdate:deleteSql];
        }
        else {
            if (!model.primaryKey) {
                if (block) {
                    block(result);
                }
                return ;
            }
            deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@=?",[self.class getTableName],model.primaryKey];
            result = [db executeUpdate:deleteSql, [model valueForKey:model.primaryKey]];
        }
        
        if (block != nil) {
            block(result);
        }
        
    }];
}

- (void)deleteToDBWithWhere:(NSString *)where callback:(void (^)(BOOL))block
{
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",[self.class getTableName],where];
        BOOL result = [db executeUpdate:deleteSql];
        if (block != nil)
        {
            block(result);
        }
    }];
}


- (void)deleteToDBWithWhereDic:(NSDictionary *)where callback:(void (^)(BOOL))block
{
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:0];
        
        NSString *whereKey = [self dictionaryToSqlWhere:where andValues:values];
        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",[self.class getTableName],whereKey];
        
        BOOL result = [db executeUpdate:deleteSql withArgumentsInArray:values];
        
        if (block != nil) {
            block(result);
        }
    }];
}

- (void)clearTableWithCallback:(void (^)(BOOL))block
{
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        NSString *delete = [NSString stringWithFormat:@"DELETE FROM %@",[self.class getTableName]];
        BOOL result = [db executeUpdate:delete];
        
        if (block != nil) {
            block(result);
        }
    }];
}

#pragma mark - isExist

- (BOOL)executeIsExistsModel:(NSObject *)model withDatabase:(FMDatabase *)db callback:(void (^)(BOOL))block
{
    if (!model.primaryKey) {
        if (block) {
            block(NO);
        }
        return NO;
    }
    
    NSString *where = [NSString stringWithFormat:@"%@='%@'",model.primaryKey,[model valueForKey:model.primaryKey]];
    
    BOOL isExists = [self executeIsExistsModelWithWhere:where withDatabase:db callback:block];
    
    return isExists;
}

- (BOOL)executeIsExistsModelWithWhere:(NSString *)where withDatabase:(FMDatabase *)db callback:(void (^)(BOOL))block
{
    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",[self.class getTableName],where];
    FMResultSet *resultSet = [db executeQuery:querySql];
    
    //结果有多少个
    //        int resultNum =  [resultSet intForColumnIndex:0];
    
    BOOL isExists = [resultSet next];
    
    [resultSet close];
    
    if (block) {
        block(isExists);
    }
    
    return isExists;
}

- (BOOL)executeIsExistsModelWithWhereDic:(NSDictionary *)whereDic withDatabase:(FMDatabase *)db callback:(void (^)(BOOL))block
{
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:0];
    NSString *whereKey = [self dictionaryToSqlWhere:whereDic andValues:values];
    
    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",[self.class getTableName], whereKey];
    FMResultSet *resultSet = [db executeQuery:querySql withArgumentsInArray:values];
    
    BOOL isExists = [resultSet next];
    
    [resultSet close];
    
    if (block != nil) {
        block(isExists);
    }
    
    return isExists;
}


- (void)isExistsModel:(NSObject *)model callback:(void(^)(BOOL))block{
    
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeIsExistsModel:model withDatabase:db callback:block];
    }];
}

- (void)isExistsModelWithWhere:(NSString *)where callback:(void (^)(BOOL))block
{
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeIsExistsModelWithWhere:where withDatabase:db callback:block];
    }];
}


- (void)isExistsModelWithWhereDic:(NSDictionary *)whereDic callback:(void (^)(BOOL))block
{
    [self.bindingQueue inDatabaseAsync:^(FMDatabase *db) {
        
        [self executeIsExistsModelWithWhereDic:whereDic withDatabase:db callback:block];
    }];
}

#pragma mark - Property

static char *kBindingQueueKey;
- (void)setBindingQueue:(JJDatabaseQueue *)bindingQueue {
    objc_setAssociatedObject(self, &kBindingQueueKey, bindingQueue, OBJC_ASSOCIATION_RETAIN);
}

- (JJDatabaseQueue *)bindingQueue {
    JJDatabaseQueue *queue = objc_getAssociatedObject(self, &kBindingQueueKey);
    if (!queue) {
        queue = [[JJDatabaseQueue alloc] initWithPath:[self getDataBasePath]];
        objc_setAssociatedObject(self, &kBindingQueueKey, queue, OBJC_ASSOCIATION_RETAIN);
    }
    return queue;
}

static char *kPropertysKey;
- (void)setPropertys:(NSMutableDictionary *)propertys {
    objc_setAssociatedObject(self, &kPropertysKey, propertys, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableDictionary *)propertys {
    NSMutableDictionary *dic = objc_getAssociatedObject(self, &kPropertysKey);
    return dic;
}

static char *kColumeNamesKey;
- (void)setColumeNames:(NSMutableArray *)columeNames {
    objc_setAssociatedObject(self, &kColumeNamesKey, columeNames, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableArray *)columeNames {
    NSMutableArray *arr = objc_getAssociatedObject(self, &kColumeNamesKey);
    return arr;
}

static char *kColumeTypesKey;
- (void)setColumeTypes:(NSMutableArray *)columeTypes {
    objc_setAssociatedObject(self, &kColumeTypesKey, columeTypes, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableArray *)columeTypes {
    NSMutableArray *arr = objc_getAssociatedObject(self, &kColumeTypesKey);
    return arr;
}

@end
