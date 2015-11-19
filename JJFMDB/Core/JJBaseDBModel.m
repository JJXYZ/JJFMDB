//
//  JJBaseDBModel.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "JJBaseDBModel.h"
#import "JJBaseDBOperate.h"

@implementation JJBaseDBModel

+ (Class)getBindingOperateClass
{
    return [JJBaseDBOperate class];
}


@end
