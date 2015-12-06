//
//  ViewController.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "ViewController.h"
#import "JJDBManager.h"
#import "JJFMDB.h"

@interface ViewController ()

@property (nonatomic, strong) JJDog *dog1;
@property (nonatomic, strong) JJDog *dog2;
@property (nonatomic, strong) JJDog *dog3;

@property (nonatomic, strong) NSArray *dogsArr;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)clickInsertBtn:(id)sender;
- (IBAction)clickDeleteBtn:(id)sender;
- (IBAction)clickReadBtn:(id)sender;
- (IBAction)clickShowImage:(id)sender;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dog1 = [[JJDog alloc] init];
    self.dog1.name = @"dog1";
    
    self.dog2 = [[JJDog alloc] init];
    self.dog2.name = @"dog2";
    
    self.dog3 = [[JJDog alloc] init];
    self.dog3.name = @"dog3";
    
    
}




- (IBAction)clickInsertBtn:(id)sender {
#if 1
    [[JJDBManager shareManager] insertToDB:self.dog1 callback:^(BOOL isSuccess) {
    }];
    
    [[JJDBManager shareManager] insertToDB:self.dog2 callback:^(BOOL isSuccess) {
    }];
    
    [[JJDBManager shareManager] insertToDB:self.dog3 callback:^(BOOL isSuccess) {
    }];
    
    JJDog *dog4 = [[JJDog alloc] init];
    dog4.name = @"dog4";
    [[JJDBManager shareManager] insertToDB:dog4 callback:^(BOOL isSuccess) {
    }];
#endif
    
#if 1
    JJCat *cat = [[JJCat alloc] init];
    cat.name = @"cat1";
    
    [cat insertToDB:^(BOOL isSuccess) {
        if (isSuccess) {
            NSLog(@"cat insertToDB isSuccess");
        }
        else {
            NSLog(@"cat insertToDB failed");
        }
    }];
#endif
}

- (IBAction)clickDeleteBtn:(id)sender {
    [[JJDBManager shareManager] deleteToDB:self.dog1 callback:^(BOOL isSuccess) {
    }];
}

- (IBAction)clickReadBtn:(id)sender {
    [[JJDBManager shareManager] searchCallback:^(NSArray *modelArr) {
        self.dogsArr = modelArr;
        for (JJDog *m in self.dogsArr) {
            NSLog(@"%@,%@", m.name, [[NSString alloc] initWithData:m.data encoding:NSUTF8StringEncoding]);
        }
    }];
}

- (IBAction)clickShowImage:(id)sender {
    JJDog *dog = [self.dogsArr firstObject];
    self.imageView.image = dog.image;
}

@end
