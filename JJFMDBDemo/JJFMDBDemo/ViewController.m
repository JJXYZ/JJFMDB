//
//  ViewController.m
//  JJFMDBDemo
//
//  Created by Jay on 15/11/16.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "ViewController.h"
#import "JJDBManager.h"

@interface ViewController ()

@property (nonatomic, strong) JJDogDBModel *dog1;
@property (nonatomic, strong) JJDogDBModel *dog2;
@property (nonatomic, strong) JJDogDBModel *dog3;

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
    
    self.dog1 = [[JJDogDBModel alloc] init];
    self.dog1.name = @"dog1";
    
    self.dog2 = [[JJDogDBModel alloc] init];
    self.dog2.name = @"dog2";
    
    self.dog3 = [[JJDogDBModel alloc] init];
    self.dog3.name = @"dog3";
    
    
}




- (IBAction)clickInsertBtn:(id)sender {
    [[JJDBManager shareManager] insertToDB:self.dog1 callback:^(BOOL isSuccess) {
    }];
    
    [[JJDBManager shareManager] insertToDB:self.dog2 callback:^(BOOL isSuccess) {
    }];
    
    [[JJDBManager shareManager] insertToDB:self.dog3 callback:^(BOOL isSuccess) {
    }];
}

- (IBAction)clickDeleteBtn:(id)sender {
    [[JJDBManager shareManager] deleteToDB:self.dog1 callback:^(BOOL isSuccess) {
    }];
}

- (IBAction)clickReadBtn:(id)sender {
    [[JJDBManager shareManager] searchCallback:^(NSArray *modelArr) {
        self.dogsArr = modelArr;
        for (JJDogDBModel *m in self.dogsArr) {
            NSLog(@"%@,%@", m.name, [[NSString alloc] initWithData:m.data encoding:NSUTF8StringEncoding]);
        }
    }];
}

- (IBAction)clickShowImage:(id)sender {
    JJDogDBModel *dog = [self.dogsArr firstObject];
    self.imageView.image = dog.image;
}

@end
