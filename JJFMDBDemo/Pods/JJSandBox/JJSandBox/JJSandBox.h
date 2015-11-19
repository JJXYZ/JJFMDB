//
//  JJSandBox.h
//  JJSandBoxDemo
//
//  Created by Jay on 15/11/11.
//  Copyright © 2015年 JJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JJSandBox : NSObject

#pragma mark - Path

/** 获取程序的Home目录路径 */
+ (NSString *)getHomeDirectoryPath;

/** 获取document目录路径 */
+ (NSString *)getDocumentPath;

/** 获取Cache目录路径 */
+ (NSString *)getCachePath;

/** 获取Library目录路径 */
+ (NSString *)getLibraryPath;

/** 获取Tmp目录路径 */
+ (NSString *)getTempPath;

#pragma mark- 文件操作

/** 创建目录文件夹 */
+ (NSString *)createList:(NSString *)list listName:(NSString *)name;

/** 写入NSArray文件 */
+ (BOOL)writeFileArray:(NSArray *)array specifiedFile:(NSString *)path;

/** 写入NSDictionary文件 */
+ (BOOL)writeFileDictionary:(NSMutableDictionary *)dic specifiedFile:(NSString *)path;

/** 是否存在该文件 */
+ (BOOL)isFileExists:(NSString *)filepath;

/** 删除指定文件 */
+ (void)deleteFile:(NSString *)filepath;

/** 删除 document/dir 目录下所有文件 */
+ (void)deleteAllForDocumentsDir:(NSString *)dir;

/** 删除 document/dir 目录下有preName前缀的文件 */
+ (void)deletefileForDocumentsDir:(NSString *)dir preName:(NSString *)preName;

/** 获取目录列表里所有的文件名 */
+ (NSArray *)getSubpathsAtPath:(NSString *)path;

#pragma mark- 获取文件的数据

+ (NSData *)getDataForResource:(NSString *)name inDir:(NSString *)dir;
+ (NSData *)getDataForDocuments:(NSString *)name inDir:(NSString *)dir;
+ (NSData *)getDataForPath:(NSString *)path;

#pragma mark- 获取文件路径

+ (NSString *)getPathForCaches:(NSString *)filename;
+ (NSString *)getPathForCaches:(NSString *)filename inDir:(NSString *)dir;

+ (NSString *)getPathForDocuments:(NSString *)filename;
+ (NSString *)getPathForDocuments:(NSString *)filename inDir:(NSString *)dir;

+ (NSString *)getPathForResource:(NSString *)name;
+ (NSString *)getPathForResource:(NSString *)name inDir:(NSString *)dir;

@end
