//
//  ImageCache.m
//  MGOV
//
//  Created by 李伟超 on 15/11/4.
//  Copyright © 2015年 LWC. All rights reserved.
//

#import "ImageCache.h"
#import <CommonCrypto/CommonCrypto.h>

static NSString * const DataCacheException = @"DataCacheException";

//缓存时间
const NSTimeInterval kDefaultTime    =   20*60*60;

@interface ImageCache ()

@property (nonatomic, readonly) NSOperationQueue *examineQueue;
#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
#else
@property (nonatomic, assign) dispatch_semaphore_t semaphore;
#endif

@end

@implementation ImageCache

- (instancetype)init {
    if (self = [super init]) {
        _examineQueue = [[NSOperationQueue alloc] init];
        [_examineQueue setMaxConcurrentOperationCount:1];
        
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)dealloc {
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_semaphore);
#endif
}

- (void)examineExpire {
    [_examineQueue cancelAllOperations];
    [_examineQueue addOperationWithBlock:^{
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        
        static NSString *DataCacheFilePathKey = @"DataCacheFilePathKey";
        
        NSMutableArray *attributesArray = [@[] mutableCopy];
        for (NSString *filePath in [self validFilePathsUnderPath:self.rootPath]) {
            NSMutableDictionary *attributes = [[self attributesForFilePath:filePath] mutableCopy];
            [attributes setObject:filePath forKey:DataCacheFilePathKey];
            [attributesArray addObject:attributes];
        }
        //移除过期缓存
        [attributesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self isExpireByDate:[obj objectForKey:NSFileModificationDate]]) {
                NSString *filePath = [[obj objectForKey:DataCacheFilePathKey] stringByDeletingLastPathComponent];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager fileExistsAtPath:filePath isDirectory:NULL]) {
                    NSError *error = nil;
//                    NSLog(@"remove filePath: %@", filePath);
                    if (![fileManager removeItemAtPath:filePath error:&error]) {
                        [NSException raise:NSInvalidArgumentException format:@"%@", error];
                    }
                }
            }
        }];
        dispatch_semaphore_signal(_semaphore);
    }];
}

- (NSString *)rootPath {
    if (_rootPath) {
        return _rootPath;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    _rootPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
    return _rootPath;
}

- (id)objectForKey:(id <NSCoding>)key {
    if (![self hasObjectForKey:key]) {
        return nil;
    }
    if ([self isExpireForKey:key]) {
        //已过期
        [self removeObjectForKey:key];
        return nil;
    }
    
    NSString *path = [self filePathForKey:key];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (BOOL)isExpireForKey:(id<NSCoding>)key {
    NSString *path = [self filePathForKey:key];
    NSMutableDictionary *attributes = [[self attributesForFilePath:path] mutableCopy];
    NSDate *date = [attributes objectForKey:NSFileModificationDate];
    return [self isExpireByDate:date];
}

- (BOOL)isExpireByDate:(NSDate *)date {
    NSTimeInterval foreDate = [date timeIntervalSince1970];
    NSTimeInterval currentDate = [[NSDate date] timeIntervalSince1970];
    if (foreDate + kDefaultTime < currentDate) {
//        NSLog(@"===已过期");
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)hasObjectForKey:(id<NSCoding>)key {
    NSString *path = [self filePathForKey:key];
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL];
}

- (void)setObject:(id <NSCoding>)object forKey:(id <NSCoding>)key {
    NSString *path = [self filePathForKey:key];
//    NSLog(@"add filepath: %@", path);
    NSString *directoryPath = [path stringByDeletingLastPathComponent];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directoryPath isDirectory:NULL]) {
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            [NSException raise:DataCacheException format:@"%@", error];
        }
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    [data writeToFile:path atomically:YES];
    [self examineExpire];
}

- (void)removeObjectForKey:(id <NSCoding>)key {
    NSString *filePath = [self filePathForKey:key];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath isDirectory:NULL]) {
        NSError *error = nil;
        if (![fileManager removeItemAtPath:filePath error:&error]) {
            [NSException raise:NSInvalidArgumentException format:@"%@", error];
        }
    }
    
    NSString *directoryPath = [filePath stringByDeletingLastPathComponent];
    [self removeDirectoryIfEmpty:directoryPath];
}

- (NSString *)filePathForKey:(id<NSCoding>)key {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:key];
    if ([data length] == 0) {
        return nil;
    }
    
    unsigned char result[16];
    CC_MD5([data bytes], [data length], result);
    NSString *cacheKey = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                          result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
                          result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
    
    NSString *prefix = [cacheKey substringToIndex:2];
    NSString *directoryPath = [self.rootPath stringByAppendingPathComponent:prefix];
    return [directoryPath stringByAppendingPathComponent:cacheKey];
}

- (NSArray *)validFilePathsUnderPath:(NSString *)parentPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *paths = [@[] mutableCopy];
    for (NSString *subpath in [fileManager subpathsAtPath:parentPath]) {
        NSString *path = [parentPath stringByAppendingPathComponent:subpath];
        [paths addObject:path];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSString *path = (NSString *)evaluatedObject;
        BOOL isHidden = [[path lastPathComponent] hasPrefix:@"."];
        BOOL isDirectory;
        BOOL exists = [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
        return !isHidden && !isDirectory && exists;
    }];
    
    return [paths filteredArrayUsingPredicate:predicate];
}

- (NSDictionary *)attributesForFilePath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSMutableDictionary *attributes = [[fileManager attributesOfItemAtPath:filePath error:&error] mutableCopy];
    if (error) {
        [NSException raise:DataCacheException format:@"%@", error];
    }
    return attributes;
}

#pragma mark - remove

- (void)removeDirectoryIfEmpty:(NSString *)directoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directoryPath]) {
        return;
    }
    
    if (![[self validFilePathsUnderPath:directoryPath] count]) {
        NSError *error = nil;
        if (![fileManager removeItemAtPath:directoryPath error:&error]) {
            [NSException raise:DataCacheException format:@"%@", error];
        }
    }
}

@end
