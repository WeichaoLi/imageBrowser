//
//  ImageCache.h
//  MGOV
//
//  Created by 李伟超 on 15/11/4.
//  Copyright © 2015年 LWC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject {
    NSString *_rootPath;
}

@property (nonatomic, readonly) NSString *rootPath;

- (NSString *)filePathForKey:(id <NSCoding>)key;
- (BOOL)hasObjectForKey:(id<NSCoding>)key;
- (id)objectForKey:(id <NSCoding>)key;

- (void)setObject:(id <NSCoding>)object forKey:(id <NSCoding>)key;
- (void)removeObjectForKey:(id <NSCoding>)key;

//- (void)removeOldObjects; // will be called automatically when currentSize > limitOfSize.
//- (void)removeObjectsByAccessedDate:(NSDate *)accessedDate;
//- (void)removeObjectsUsingBlock:(BOOL (^)(NSString *filePath))block;

@end
