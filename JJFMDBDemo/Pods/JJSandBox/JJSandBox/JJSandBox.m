//
//  JJSandBox.m
//  JJSandBoxDemo
//
//  Created by Jay on 15/11/11.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import "JJSandBox.h"

@implementation JJSandBox

#pragma mark - Path

+ (NSString *)getHomeDirectoryPath {
    return NSHomeDirectory();
}

+ (NSString *)getDocumentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

+ (NSString *)getCachePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

+ (NSString *)getLibraryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

+ (NSString *)getTempPath {
    return NSTemporaryDirectory();
}

+ (NSString *)getDirectoryForDocuments:(NSString *)dir {
    NSError *error = nil;
    NSString *path = [[self getDocumentPath] stringByAppendingPathComponent:dir];
    if(![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"create dir error: %@",error.debugDescription);
    }
    return path;
}

+ (NSString *)getDirectoryForCaches:(NSString *)dir {
    NSError *error;
    NSString *path = [[self getCachePath] stringByAppendingPathComponent:dir];
    
    if(![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"create dir error: %@", error.debugDescription);
    }
    return path;
}

#pragma mark - 文件操作

+ (NSString *)createList:(NSString *)list listName:(NSString *)name {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileDirectory = [list stringByAppendingPathComponent:name];
    if ([self isFileExists:name]) {
        NSLog(@"exist,%@", name);
    }
    else {
        [fileManager createDirectoryAtPath:fileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fileDirectory;
}

+ (BOOL)writeFileArray:(NSArray *)array specifiedFile:(NSString *)path {
    return [array writeToFile:path atomically:YES];
}

+ (BOOL)writeFileDictionary:(NSMutableDictionary *)dic specifiedFile:(NSString *)path {
    return [dic writeToFile:path atomically:YES];
}

+ (BOOL)isFileExists:(NSString *)filepath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filepath];
}

+ (void)deleteFile:(NSString *)filepath {
    if([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
    }
}

+ (NSArray *)getSubpathsAtPath:(NSString *)path {
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSArray *file = [fileManage subpathsAtPath:path];
    return file;
}

+ (void)deleteAllForDocumentsDir:(NSString *)dir {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:[self getDirectoryForDocuments:dir] error:nil];
    for (NSString *filename in fileList) {
        [fileManager removeItemAtPath:[self getPathForDocuments:filename inDir:dir] error:nil];
    }
}

+ (void)deletefileForDocumentsDir:(NSString *)dir preName:(NSString *)preName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:[self getDirectoryForDocuments:dir] error:nil];
    for (NSString *filename in fileList) {
        if ([filename hasPrefix:preName]) {
            [fileManager removeItemAtPath:[self getPathForDocuments:filename inDir:dir] error:nil];
        }
    }
}


#pragma mark - 获取文件的数据

+ (NSData *)getDataForPath:(NSString *)path {
    return [[NSFileManager defaultManager] contentsAtPath:path];
}

+ (NSData *)getDataForResource:(NSString *)name inDir:(NSString *)dir {
    return [self getDataForPath:[self getPathForResource:name inDir:dir]];
}

+ (NSData *)getDataForDocuments:(NSString *)name inDir:(NSString *)dir {
    return [self getDataForPath:[self getPathForDocuments:name inDir:dir]];
}



#pragma mark - 获取文件路径

+ (NSString *)getPathForResource:(NSString *)name {
    return [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:name];
}

+ (NSString *)getPathForResource:(NSString *)name inDir:(NSString *)dir {
    return [[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:dir] stringByAppendingPathComponent:name];
}

+ (NSString *)getPathForDocuments:(NSString *)filename {
    return [[self getDocumentPath] stringByAppendingPathComponent:filename];
}

+ (NSString *)getPathForDocuments:(NSString *)filename inDir:(NSString *)dir {
    return [[self getDirectoryForDocuments:dir] stringByAppendingPathComponent:filename];
}

+ (NSString *)getPathForCaches:(NSString *)filename {
    return [[self getCachePath] stringByAppendingPathComponent:filename];
}

+ (NSString *)getPathForCaches:(NSString *)filename inDir:(NSString *)dir {
    return [[self getDirectoryForCaches:dir] stringByAppendingPathComponent:filename];
}

@end
