//
//  JJDBManager.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/17.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "JJDBManager.h"
#import "JJFMDB.h"

@interface JJDBManager ()

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

#pragma mark - Public Methods

- (void)insertToDB:(JJDog *)model callback:(DBSuccessBlock)block {
    if (!model) {
        return ;
    }
    
    [model insertToDB:^(BOOL isSuccess) {
        if (isSuccess) {
            NSLog(@"insertToDB isSuccess");
        }
        else {
            NSLog(@"insertToDB failed");
        }
        
    }];
    
}


- (void)deleteToDB:(JJDog *)model callback:(DBSuccessBlock)block {
    [model deleteToDB:^(BOOL isSuccess) {
        if (isSuccess) {
            NSLog(@"deleteToDB isSuccess");
        }
        else {
            NSLog(@"deleteToDB failed");
        }
    }];
}

- (void)searchCallback:(DBSearchResults)block{
    [JJDog searchAll:^(NSArray *results) {
        if (block) {
            block(results);
        }
    }];
}


@end
