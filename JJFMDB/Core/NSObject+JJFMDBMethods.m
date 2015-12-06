//
//  NSObject+JJFMDBMethods.m
//  JJFMDBDemo
//
//  Created by Jay on 15/12/5.
//  Copyright © 2015年 JJ. All rights reserved.
//


#import "NSObject+JJFMDBMethods.h"

/** system */
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

/** pods */
#import "FMDB.h"
#import "JJSandBox.h"

/** Core */
#import "JJFMDBDefine.h"
#import "JJDatabaseQueue.h"
#import "NSObject+JJFMDBProtocol.h"
#import "NSObject+JJFMDBObject.h"

/** Helper */
#import "NSDate+JJFMDB.h"
#import "NSString+JJFMDB.h"
#import "NSObject+JJFMDBPropertys.h"
#import "JJFMDBProperty.h"


@implementation NSObject (JJFMDBMethods)

#pragma mark - Init

+ (void)startToDB {
    [self loadProtypes];
    [self createTable];
}


#pragma mark - Private Methods

/** 加载JJProperty数组 */
+ (void)loadProtypes {
    self.propertys = [self properties];
}

#pragma mark - Methods

/**
 *  根据bindingModel的类型,把数据库的值转换过来
 *
 *  @param bindingModel 继承JJBaseDBModel
 *  @param set          FMResultSet
 *  @param columeName   属性的Name
 *  @param columeType   属性的类型
 */
+ (void)setValueWithModel:(id)model set:(FMResultSet *)set columeName:(NSString *)columeName columeType:(NSString *)columeType {

    if ([columeType isEqualToString:@"NSString"]) {
        [model setValue:[set stringForColumn:columeName] forKey:columeName];
    }
    else if ([columeType isEqualToString:@"int"] ||
             [columeType isEqualToString:@"long"] ||
             [columeType isEqualToString:@"long long"]) {
        [model setValue:[NSNumber numberWithLongLong:[set longLongIntForColumn:columeName]] forKey:columeName];
    }
    else if ([columeType isEqualToString:@"BOOL"] ||
             [columeType isEqualToString:@"bool"]) {
        [model setValue:[NSNumber numberWithBool:[set boolForColumn:columeName]] forKey:columeName];
    }
    else if ([columeType isEqualToString:@"char"]) {
        [model setValue:[NSNumber numberWithInt:[set intForColumn:columeName]] forKey:columeName];
    }
    else if ([columeType isEqualToString:@"float"] ||
             [columeType isEqualToString:@"double"]) {
        [model setValue:[NSNumber numberWithDouble:[set doubleForColumn:columeName]] forKey:columeName];
    }
    else if ([columeType isEqualToString:@"NSNumber"]) {
        [model setValue:[NSNumber numberWithLongLong:[set stringForColumn:columeName].longLongValue] forKey:columeName];
    }
    else if ([columeType isEqualToString:@"UIImage"]) {
        NSString* filename = [set stringForColumn:columeName];
        if ([JJSandBox isFileExists:[JJSandBox getPathForDocuments:filename inDir:@"dbImages"]]) {
            UIImage *img = [UIImage imageWithContentsOfFile:[JJSandBox getPathForDocuments:filename inDir:@"dbImages"]];
            [model setValue:img forKey:columeName];
        }
    }
    else if ([columeType isEqualToString:@"NSDate"]) {
        NSString* datestr = [set stringForColumn:columeName];
        [model setValue:[NSDate dateWithString:datestr] forKey:columeName];
    }
    else if ([columeType isEqualToString:@"NSData"]) {
        NSString *filename = [set stringForColumn:columeName];
        if ([JJSandBox isFileExists:[JJSandBox getPathForDocuments:filename inDir:@"dbData"]]) {
            NSData* data = [NSData dataWithContentsOfFile:[JJSandBox getPathForDocuments:filename inDir:@"dbData"]];
            [model setValue:data forKey:columeName];
        }
    }
}

/**
 *  数据库value存文件对应的名字使用(UIImage, NSData, NSDate)
 *
 *  @param value 文件的名字
 */
+ (void)valueForFileName:(id)value
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
 *  根据modle,返回创建表SQL,例:@"name TEXT,age INTEGER,height BIGINT"
 *
 *  @return NSString
 */
+ (NSString *)appendTableSQL {
    NSMutableString *tableSQL = [NSMutableString string];
    for (int i=0; i<self.propertys.count; i++) {
        JJFMDBProperty *property = [self.propertys objectAtIndex:i];
        [tableSQL appendFormat:@"%@ %@", property.name, property.dbType];
        if (self.propertys.count != i+1) {
            [tableSQL appendString:@","];
        }
    }
    return tableSQL;
}


/**
 *  字典转SQL的where语句,
 *
 *  @param dic    where字典条件,例:@{@"name":@"Jay", @"age":@18}
 *  @param values 数组:@[@"Jay",@18]
 *
 *  @return where语句,例:@" name = ? AND age = ? OR height = ?"
 */
+ (NSString *)dictionaryToSQLWhereDic:(NSDictionary *)dic andValues:(NSMutableArray *)values {
    NSMutableString *whereKey = [NSMutableString stringWithCapacity:0];
    if (dic && dic.count) {
        NSArray *keys = dic.allKeys;
        for (int i=0; i< keys.count;i++) {
            
            NSString *key = [keys objectAtIndex:i];
            id va = [dic objectForKey:key];
            
            if ([va isKindOfClass:[NSArray class]]) {
                //当NSDictionary的value是NSArray类型时,使用or当中间值
                NSArray* vlist = va;
                for (int j=0; j<vlist.count; j++) {
                    id subvalue = [vlist objectAtIndex:j];
                    if (whereKey.length > 0) {
                        if (j > 0) {
                            [whereKey appendFormat:@"OR %@=? ",key];
                        }
                        else {
                            [whereKey appendFormat:@"AND %@=? ",key];
                        }
                    }
                    else {
                        [whereKey appendFormat:@"%@=? ",key];
                    }
                    [values addObject:subvalue];
                }
            }
            else {
                if (whereKey.length > 0) {
                    [whereKey appendFormat:@"AND %@=? ",key];
                }
                else {
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
 *  @param SQL     SQL
 *  @param orderby orderby
 *  @param offset  offset
 *  @param count   count
 */
+ (void)SQLString:(NSMutableString *)SQL AddOder:(NSString *)orderby offset:(int)offset count:(int)count
{
    if (!SQL || !count) {
        return ;
    }
    
    if (orderby != nil && ![orderby isEmptyWithTrim]) {
        [SQL appendFormat:@"ORDER BY %@ ",orderby];
    }
    [SQL appendFormat:@"LIMIT %d OFFSET %d ",count, offset];
}

/**
 *  通过model创建setKey和setValues
 *
 *  @param setKey    SQL语句中的"SET %@"这个%@,例:@"name=?,age=?"
 *  @param setValues 要更新的值,例:@[@"Jay", @18]
 *  @param model        model
 */
+ (void)createSetKey:(NSMutableString *)setKey andSetValues:(NSMutableArray *)setValues withModel:(NSObject *)model {
    
    for (int i=0; i<self.propertys.count; i++) {
        JJFMDBProperty *property = [self.propertys objectAtIndex:i];
        [setKey appendFormat:@"%@=?,", property.name];
        id value = [model valueForKey:property.name];
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
+ (void)createSetKey:(NSMutableString *)setKey andSetValues:(NSMutableArray *)setValues withupdateKeyDic:(NSDictionary *)setDic {
    
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
+ (void)createInsertKey:(NSMutableString *)insertKey insertValuesStr:(NSMutableString *)insertValuesStr insertValues:(NSMutableArray *)insertValues model:(NSObject *)model {
    
    for (int i=0; i<self.propertys.count; i++) {
        JJFMDBProperty *property = [self.propertys objectAtIndex:i];
        [insertKey appendFormat:@"%@,", property.name];
        [insertValuesStr appendString:@"?,"];
        id value = [model valueForKey:property.name];
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
+ (void)createTable
{
    if ([self.jj_tableName isEmptyWithTrim]) {
        NSLog(@"TableName is None!");
        return;
    }
    
    [self.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        NSString *createTableSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,%@)",self.jj_tableName,[self appendTableSQL]];
        [db executeUpdate:createTableSQL];
    }];
}


+ (void)tableAddColumn:(NSString *)column type:(NSString *)type results:(JJFMDBSuccess)block {
    [self.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        
        NSString *updateTableSQL = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@",self.jj_tableName, column, type];
        
        BOOL execute = [db executeUpdate:updateTableSQL];
        
        if (block) {
            block(execute);
        }
    }];
}

//SQLite不支持删除列
+ (void)tableDropColumn:(NSString *)column results:(JJFMDBSuccess)block {
    [self.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        
        NSString *updateTableSQL = [NSString stringWithFormat:@"ALTER TABLE %@ DROP COLUMN %@",self.jj_tableName, column];
        
        BOOL execute = [db executeUpdate:updateTableSQL];
        
        if (block) {
            block(execute);
        }
    }];
}


/**
 *  查询数据库内的表名
 *  select * from sqlite_master where type='table' order by name
 */
+ (void)readTableNames:(JJFMDBResults)block {
    
}



+ (void)readTableColumns:(JJFMDBResults)block {
    [self.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        
        NSMutableString *searchSQL = [NSMutableString stringWithFormat:@"PRAGMA TABLE_INFO(%@)", self.jj_tableName];
        
        FMResultSet *set =[db executeQuery:searchSQL];
        
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

+ (void)executeResult:(FMResultSet *)set block:(JJFMDBResults)block {
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    while ([set next]) {
        NSObject *model = [[self alloc] init];
        model.rowid = [set intForColumnIndex:0];
        for (int i=0; i<self.propertys.count; i++) {
            JJFMDBProperty *property = [self.propertys objectAtIndex:i];
            [self setValueWithModel:model set:set columeName:property.name columeType:property.orignType];
        }
        [array addObject:model];
    }
    [set close];
    
    if (block) {
        block(array);
    }
}

+ (void)searchCount:(JJFMDBCount)block
{
    [self.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        
        NSMutableString *searchSQL = [NSMutableString stringWithFormat:@"SELECT count(*) FROM %@", self.jj_tableName];
        FMResultSet *set =[db executeQuery:searchSQL];
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
+ (void)searchAll:(JJFMDBResults)block {
    [self searchWhere:nil orderBy:nil offset:0 count:0 results:block];
}

+ (void)searchCount:(int)count results:(JJFMDBResults)block {
    [self searchWhere:nil orderBy:nil offset:0 count:count results:block];
}

+ (void)searchOrderBy:(NSString *)orderBy count:(int)count results:(JJFMDBResults)block {
    [self searchWhere:nil orderBy:orderBy offset:0 count:count results:block];
}


+ (void)searchAllWhere:(NSString *)where results:(JJFMDBResults)block {
    [self searchWhere:where orderBy:nil offset:0 count:0 results:block];
}

#pragma mark Search Page
+ (void)searchPageNum:(int)pageNum results:(JJFMDBResults)block
{
    [self searchWhere:nil orderBy:nil offset:(pageNum * DB_SEARCH_COUNT) count:DB_SEARCH_COUNT results:block];
}

+ (void)searchOrderBy:(NSString *)orderBy pageNum:(int)pageNum results:(JJFMDBResults)block
{
    [self searchWhere:nil orderBy:orderBy offset:(pageNum * DB_SEARCH_COUNT) count:DB_SEARCH_COUNT results:block];
}

#pragma mark Search 自定义Where

+ (void)searchWhere:(NSString *)where pageNum:(int)pageNum results:(JJFMDBResults)block
{
    [self searchWhere:where orderBy:nil offset:(pageNum * DB_SEARCH_COUNT) count:DB_SEARCH_COUNT results:block];
}


+ (void)searchWhere:(NSString *)where orderBy:(NSString *)orderBy pageNum:(int)pageNum results:(JJFMDBResults)block
{
    [self searchWhere:where orderBy:orderBy offset:(pageNum * DB_SEARCH_COUNT) count:DB_SEARCH_COUNT results:block];
}

+ (void)searchWhere:(NSString *)where orderBy:(NSString *)orderBy count:(int)count results:(JJFMDBResults)block
{
    [self searchWhere:where orderBy:orderBy offset:0 count:count results:block];
}


+ (void)searchWhere:(NSString *)where orderBy:(NSString *)orderBy offset:(int)offset count:(int)count results:(JJFMDBResults)block
{
    [self.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        
        NSMutableString *searchSQL = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ", self.jj_tableName];
        if (where != nil && ![where isEmptyWithTrim]) {
            [searchSQL appendFormat:@"WHERE %@ ",where];
        }
        [self SQLString:searchSQL AddOder:orderBy offset:offset count:count];
        FMResultSet *set =[db executeQuery:searchSQL];
        
        [self executeResult:set block:block];
    }];
}
#pragma mark Search key-value模式传入
+ (void)searchWhereDic:(NSDictionary *)whereDic pageNum:(int)pageNum results:(JJFMDBResults)block;
{
    [self searchWhereDic:whereDic orderBy:nil offset:(pageNum * DB_SEARCH_COUNT) count:DB_SEARCH_COUNT results:block];
}

+ (void)searchWhereDic:(NSDictionary *)whereDic orderBy:(NSString *)orderBy pageNum:(int)pageNum results:(JJFMDBResults)block;
{
    [self searchWhereDic:whereDic orderBy:orderBy offset:(pageNum * DB_SEARCH_COUNT) count:DB_SEARCH_COUNT results:block];
}

+ (void)searchWhereDic:(NSDictionary *)whereDic orderBy:(NSString *)orderby offset:(int)offset count:(int)count results:(JJFMDBResults)block;
{
    [self.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ", self.jj_tableName];
        
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:0];
        
        if (whereDic !=nil && whereDic.count>0)
        {
            NSString *whereKey = [self dictionaryToSQLWhereDic:whereDic andValues:values];
            [query appendFormat:@"WHERE %@ ",whereKey];
        }
        [self SQLString:query AddOder:orderby offset:offset count:count];
        FMResultSet *set =[db executeQuery:query withArgumentsInArray:values];
        
        [self executeResult:set block:block];
    }];
}

#pragma mark - Insert

- (void)executeInsertToDB:(FMDatabase *)db result:(JJFMDBSuccess)block
{
    //    NSLog(@"=========================");
    //    NSLog(@"开始插入数据");
    NSMutableString *insertKey = [NSMutableString stringWithCapacity:0];
    NSMutableString *insertValuesStr = [NSMutableString stringWithCapacity:0];
    NSMutableArray *insertValues = [NSMutableArray arrayWithCapacity:0];
    
    [self.class createInsertKey:insertKey insertValuesStr:insertValuesStr insertValues:insertValues model:self];
    
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@)", self.class.jj_tableName, insertKey, insertValuesStr];
    BOOL execute = [db executeUpdate:insertSQL withArgumentsInArray:insertValues];
    self.rowid = db.lastInsertRowId;
    
    if (block) {
        block(execute);
    }
    
    if (execute == NO) {
        NSLog(@"database insert fail %@",NSStringFromClass(self.class));
    }
}

#pragma mark Insert model

- (void)insertToDB:(JJFMDBSuccess)block {
    
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeInsertToDB:db result:block];
    }];
}

- (void)insertUpdateToDB:(JJFMDBSuccess)block {
    
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        BOOL isExists = [self executeIsExistsToDB:db result:nil];
        if (isExists) {
            [self executeUpdateToDB:db result:block];
        }
        else {
            [self executeInsertToDB:db result:block];
        }
        
    }];
}

#pragma mark Insert 自定义Where

- (void)insertUpdateToDB:(NSString *)where result:(JJFMDBSuccess)block {
    
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        BOOL isExists = [self executeIsExistsToDB:where db:db result:nil];
        if (isExists) {
            [self executeUpdateToDB:db where:where result:block];
        }
        else {
            [self executeInsertToDB:db result:block];
        }
    }];
}

- (void)insertUpdateToDB:(NSString *)updateKey where:(NSString *)where result:(JJFMDBSuccess)block {
    
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        BOOL isExists = [self executeIsExistsToDB:where db:db result:nil];
        if (isExists) {
            [self.class executeUpdateToDB:updateKey db:db where:where result:block];
        }
        else {
            [self executeInsertToDB:db result:block];
        }
    }];
}

#pragma mark Insert key-value

- (void)insertUpdateToDBDic:(NSDictionary *)whereDic result:(JJFMDBSuccess)block {
    
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        BOOL isExists = [self executeIsExistsToDBDic:whereDic db:db result:block];
        if (isExists) {
            [self executeUpdateToDB:db whereDic:whereDic result:block];
        }
        else {
            [self executeInsertToDB:db result:block];
        }
    }];
}

- (void)insertUpdateToDBDic:(NSDictionary *)updateKeyDic whereDic:(NSDictionary *)whereDic result:(JJFMDBSuccess)block {
    
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        BOOL isExists = [self executeIsExistsToDBDic:whereDic db:db result:block];
        if (isExists) {
            [self.class executeUpdateToDB:db updateKeyDic:updateKeyDic whereDic:whereDic result:block];
        }
        else {
            [self executeInsertToDB:db result:block];
        }
    }];
}

#pragma mark - Update

- (void)executeUpdateToDB:(FMDatabase *)db result:(JJFMDBSuccess)block
{
    [self executeUpdateToDB:db where:nil result:block];
}

- (void)executeUpdateToDB:(FMDatabase *)db where:(NSString *)where result:(JJFMDBSuccess)block
{
    NSMutableString *updateKey = [NSMutableString stringWithCapacity:0];
    NSMutableArray *updateValues = [NSMutableArray arrayWithCapacity:0];
    
    //创建updateKey 和 UpdateValues
    [self.class createSetKey:updateKey andSetValues:updateValues withModel:self];
    
    NSString *updateSQL = nil;
    if (where) {
        updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@", self.class.jj_tableName, updateKey, where];
    }
    else {
        //通过rowid来更新数据
        if (self.rowid > 0) {
            updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE rowid=%lld",self.class.jj_tableName, updateKey, self.rowid];
        }
        else {
            if (!self.primaryKey) {
                if (block) {
                    block(NO);
                }
                return ;
            }
            
            //通过primarykey来更新数据
            updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@=?",self.class.jj_tableName, updateKey, self.primaryKey];
            
            [updateValues addObject:[self valueForKey:self.primaryKey]];
        }
    }
    
    BOOL execute = [db executeUpdate:updateSQL withArgumentsInArray:updateValues];
    
    if (block) {
        block(execute);
    }
}


+ (void)executeUpdateToDB:(NSString *)updateKey db:(FMDatabase *)db where:(NSString *)where result:(JJFMDBSuccess)block
{
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@", self.class.jj_tableName, updateKey, where];
    
    BOOL execute = [db executeUpdate:updateSQL];
    
    if (block) {
        block(execute);
    }
}


- (void)executeUpdateToDB:(FMDatabase *)db whereDic:(NSDictionary *)whereDic result:(JJFMDBSuccess)block {
    NSMutableString *setKey = [NSMutableString stringWithCapacity:0];
    NSMutableArray *setValues = [NSMutableArray arrayWithCapacity:0];
    
    /** 创建updateKey 和 UpdateValues */
    [self.class createSetKey:setKey andSetValues:setValues withModel:self];
    
    NSString *updateSQL = [NSString string];
    
    if (whereDic && whereDic.count) {
        /** whereDic对应的值继续放在updateValues里面,只要?和value对应 */
        NSString *where = [self.class dictionaryToSQLWhereDic:whereDic andValues:setValues];
        updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",self.class.jj_tableName, setKey, where];
    }
    
    BOOL execute = [db executeUpdate:updateSQL withArgumentsInArray:setValues];
    
    if (block) {
        block(execute);
    }
}

+ (void)executeUpdateToDB:(FMDatabase *)db updateKeyDic:(NSDictionary *)updateKeyDic whereDic:(NSDictionary *)whereDic result:(JJFMDBSuccess)block {
    
    NSMutableString *setKey = [NSMutableString stringWithCapacity:0];
    NSMutableArray *setValues = [NSMutableArray arrayWithCapacity:0];
    
    /** 创建updateKey 和 UpdateValues */
    [self.class createSetKey:setKey andSetValues:setValues withupdateKeyDic:updateKeyDic];
    
    NSString *updateSQL = [NSString string];
    
    if (whereDic && whereDic.count) {
        /** whereDic对应的值继续放在updateValues里面,只要?和value对应 */
        NSString *where = [self.class dictionaryToSQLWhereDic:whereDic andValues:setValues];
        updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",self.class.jj_tableName, setKey, where];
    }
    
    BOOL execute = [db executeUpdate:updateSQL withArgumentsInArray:setValues];
    
    if (block) {
        block(execute);
    }
}


#pragma mark Update model

- (void)updateToDB:(JJFMDBSuccess)block
{
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeUpdateToDB:db result:block];
    }];
}

#pragma mark Update 自定义Where

- (void)updateToDB:(NSString *)where result:(JJFMDBSuccess)block {
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeUpdateToDB:db where:where result:block];
    }];
}

+ (void)updateToDB:(NSString *)updateKey where:(NSString *)where result:(JJFMDBSuccess)block {
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeUpdateToDB:updateKey db:db where:where result:block];
    }];
}



#pragma mark Update key-value

- (void)updateToDBDic:(NSDictionary *)whereDic result:(JJFMDBSuccess)block {
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeUpdateToDB:db whereDic:whereDic result:block];
    }];
}

+ (void)updateToDBDic:(NSDictionary *)updateKeyDic whereDic:(NSDictionary *)whereDic result:(JJFMDBSuccess)block
{
    [self.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeUpdateToDB:db updateKeyDic:updateKeyDic whereDic:whereDic result:block];
    }];
}


#pragma mark - Delete

- (void)deleteToDB:(JJFMDBSuccess)block {
    
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        NSString *deleteSQL = nil;
        BOOL result = NO;
        if (self.rowid > 0) {
            deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE rowid=%lld", self.class.jj_tableName, self.rowid];
            result = [db executeUpdate:deleteSQL];
        }
        else {
            if (!self.primaryKey) {
                if (block) {
                    block(result);
                }
                return ;
            }
            deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@=?", self.class.jj_tableName, self.primaryKey];
            result = [db executeUpdate:deleteSQL, [self valueForKey:self.primaryKey]];
        }
        
        if (block) {
            block(result);
        }
    }];
}

- (void)deleteToDB:(NSString *)where result:(JJFMDBSuccess)block {
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", self.class.jj_tableName, where];
        BOOL result = [db executeUpdate:deleteSQL];
        if (block) {
            block(result);
        }
    }];
}


- (void)deleteToDBDic:(NSDictionary *)whereDic result:(JJFMDBSuccess)block {
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:0];
        
        NSString *whereKey = [self.class dictionaryToSQLWhereDic:whereDic andValues:values];
        NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",self.class.jj_tableName,whereKey];
        
        BOOL result = [db executeUpdate:deleteSQL withArgumentsInArray:values];
        
        if (block) {
            block(result);
        }
    }];
}

- (void)clearTable:(JJFMDBSuccess)block {
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        NSString *delete = [NSString stringWithFormat:@"DELETE FROM %@",self.class.jj_tableName];
        BOOL result = [db executeUpdate:delete];
        
        if (block) {
            block(result);
        }
    }];
}

#pragma mark - isExist

- (BOOL)executeIsExistsToDB:(FMDatabase *)db result:(JJFMDBSuccess)block
{
    if (!self.primaryKey) {
        if (block) {
            block(NO);
        }
        return NO;
    }
    
    NSString *where = [NSString stringWithFormat:@"%@='%@'", self.primaryKey,[self valueForKey:self.primaryKey]];
    
    BOOL isExists = [self executeIsExistsToDB:where db:db result:block];
    
    return isExists;
}

- (BOOL)executeIsExistsToDB:(NSString *)where db:(FMDatabase *)db result:(JJFMDBSuccess)block {
    
    NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",self.class.jj_tableName,where];
    FMResultSet *resultSet = [db executeQuery:querySQL];
    
    //结果有多少个
    //int resultNum =  [resultSet intForColumnIndex:0];
    
    BOOL isExists = [resultSet next];
    
    [resultSet close];
    
    if (block) {
        block(isExists);
    }
    
    return isExists;
}

- (BOOL)executeIsExistsToDBDic:(NSDictionary *)whereDic db:(FMDatabase *)db result:(JJFMDBSuccess)block {
    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:0];
    NSString *whereKey = [self.class dictionaryToSQLWhereDic:whereDic andValues:values];
    
    NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",self.class.jj_tableName, whereKey];
    FMResultSet *resultSet = [db executeQuery:querySQL withArgumentsInArray:values];
    
    BOOL isExists = [resultSet next];
    
    [resultSet close];
    
    if (block) {
        block(isExists);
    }
    
    return isExists;
}


- (void)isExistsToDB:(JJFMDBSuccess)block {
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeIsExistsToDB:db result:block];
    }];
}

- (void)isExistsToDB:(NSString *)where result:(JJFMDBSuccess)block {
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeIsExistsToDB:where db:db result:block];
    }];
}


- (void)isExistsToDBDic:(NSDictionary *)whereDic result:(JJFMDBSuccess)block {
    [self.class.dbQueue inDatabaseAsync:^(FMDatabase *db) {
        [self executeIsExistsToDBDic:whereDic db:db result:block];
    }];
}

#pragma mark - Property

static char *kJJFMDBPropertysKey;
+ (void)setPropertys:(NSMutableArray *)propertys {
    objc_setAssociatedObject(self, &kJJFMDBPropertysKey, propertys, OBJC_ASSOCIATION_RETAIN);
}

+ (NSMutableArray *)propertys {
    return objc_getAssociatedObject(self, &kJJFMDBPropertysKey);
}

@end
