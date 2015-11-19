//
//  JJDogDBModel.h
//  JJFMDBDemo
//
//  Created by Jay on 15/11/17.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "JJBaseDBModel.h"
#import "JJBaseDBOperate.h"
#import <UIKit/UIKit.h>

@interface JJDogDBOperate : JJBaseDBOperate

@end

@interface JJDogDBModel : JJBaseDBModel

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSNumber *number;

@property (nonatomic, assign) NSInteger integer;

@property (nonatomic, assign) char c;

@property (nonatomic, assign) int i;

@property (nonatomic, assign) short s;

@property (nonatomic, assign) long long ll;

@property (nonatomic, assign) float f;

@property (nonatomic, assign) CGFloat cgFloat;

@property (nonatomic, assign) BOOL b;

@property (nonatomic, strong) NSData *data;

@property (nonatomic, strong) UIImage *image;


@end
