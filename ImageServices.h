//
//  ImageServices.h
//  TakePhotos
//
//  Created by 李伟超 on 15/4/24.
//  Copyright (c) 2015年 LWC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageServices : NSObject

+ (NSString *)postRequestWithURL: (NSString *)url
                      postParems: (NSMutableDictionary *)postParems
                     picFilePath: (NSString *)picFilePath
                     picFileName: (NSString *)picFileName;

+ (UIImage *)imageWithImage:(UIImage *)image NewSize:(CGSize)newSize;

+ (UIImage *)compressImageWith:(UIImage *)image;

+ (NSString *)getPathDirectory;

@end
