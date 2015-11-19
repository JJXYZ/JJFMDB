//
//  JJDBManager.h
//  JJFMDBDemo
//
//  Created by Jay on 15/11/17.
//  Copyright © 2015年 JayJJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JJDogDBModel.h"

typedef void (^DBSuccessBlock)(BOOL isSuccess);
typedef void (^DBSearchResults)(NSArray *modelArr);

@interface JJDBManager : NSObject

+ (JJDBManager *)shareManager;

/**
 *  插入数据
 *
 *  @param model
 */
- (void)insertToDB:(JJDogDBModel *)model callback:(DBSuccessBlock)block;

/**
 *  删除数据
 *
 *  @param model
 */
- (void)deleteToDB:(JJDogDBModel *)model callback:(DBSuccessBlock)block;

/**
 *  查询数据
 *
 *  @param block
 */
- (void)searchCallback:(DBSearchResults)block;

@end
