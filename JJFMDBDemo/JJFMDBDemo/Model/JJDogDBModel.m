//
//  JJDogDBModel.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/17.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "JJDogDBModel.h"

@implementation JJDogDBOperate

/** 注意:这里返回的是DBModel类名 */
+ (Class)getBindingModelClass {
    return [JJDogDBModel class];
}

/** 表名 */
+ (const NSString *)getTableName {
    return @"dog_table";
}

@end

@implementation JJDogDBModel

#pragma mark - Lifecycle

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    //do nothing
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"dog";
        _number = @20;
        _integer = 18;
        _c = 'm';
        _i = 520;
        _s = 2;
        _ll = 20121224;
        _f = 10.99;
        _cgFloat = 3.1415;
        _b = YES;
        _data = [@"Hello Dog" dataUsingEncoding:NSUTF8StringEncoding];
        _image = [UIImage imageNamed:@"image"];
    }
    return self;
}

#pragma mark - Private Methods

+ (Class)getBindingOperateClass
{
    return [JJDogDBOperate class];
}

@end
