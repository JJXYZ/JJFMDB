//
//  JJDBManager.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/17.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "JJDBManager.h"
#import "JJDatabaseQueue.h"
#import "JJBaseDBOperate+Methods.h"
#import "JJSandBox.h"

@interface JJDBManager ()

/** 数据库的Operate */
@property (nonatomic, strong) JJDogDBOperate *dogDBOperate;

@end

@implementation JJDBManager

#pragma mark - Lifecycle

+ (JJDBManager *)shareManager {
    __strong static JJDBManager *manager = nil;
    @synchronized(self){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [[JJDBManager alloc] init];
        });
    }
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
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

#pragma mark - Public Methods

- (void)insertToDB:(JJDogDBModel *)model callback:(DBSuccessBlock)block {
    if (!model) {
        return ;
    }
    
    [self.dogDBOperate insertToDB:model callback:^(BOOL isSuccess) {
        if (isSuccess) {
            NSLog(@"插入数据成功");
        }
        else {
            NSLog(@"插入数据失败!!!!");
        }
        if (block){
            block(isSuccess);
        }
    }];
}

- (void)deleteToDB:(JJDogDBModel *)model callback:(DBSuccessBlock)block {
    [self.dogDBOperate deleteToDB:model callback:^(BOOL isSuccess) {
        if (isSuccess) {
            NSLog(@"删除数据成功");
        }
        else {
            NSLog(@"删除数据失败!!!!");
        }
        if (block){
            block(isSuccess);
        }
    }];
}

- (void)searchCallback:(DBSearchResults)block{
    [self.dogDBOperate searchAll:^(NSArray *modelArr) {
        if (block) {
            block(modelArr);
        }
    }];
}


#pragma mark - Property

- (JJDogDBOperate *)dogDBOperate {
    if (_dogDBOperate) {
        return _dogDBOperate;
    }
#if 0
    JJDatabaseQueue *queue = [[JJDatabaseQueue alloc] initWithPath:[self getDataBasePath]];
    _dogDBOperate = [[JJDogDBOperate alloc] initWithDBQueue:queue];
#else
    _dogDBOperate = [[JJDogDBOperate alloc] init];
#endif
    return _dogDBOperate;
}
@end
