//
//  ImageLoader.h
//
//  Created by Kirill Shashkov on 12/2/11.
//  Copyright (c) 2011 IntexSoft LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageLoader : NSObject {
    NSCache *imagesCache;
    
     dispatch_queue_t loadingQueue;
}

- (void)displayImage:(NSString *)imagePath inImageView:(UIImageView *)imageView;
- (void)displayImage:(NSString *)imagePath inSize:(CGSize)size contentMode:(UIViewContentMode)contentMode callbackTarget:(id)target callbackSelector:(SEL)selector;

@end
