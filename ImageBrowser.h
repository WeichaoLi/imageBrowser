//
//  ImageBrowser.h
//  TakePhotos
//
//  Created by 李伟超 on 15/5/6.
//  Copyright (c) 2015年 LWC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RemoveImage)(NSString *url, NSUInteger index);

@interface ImageBrowser : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>{
    NSMutableArray *_visiablePages; //可见的图片
    BOOL _isHidden;
    CGPoint currentOffset;
}

@property (nonatomic, copy)   NSArray *zoomArray;
@property (nonatomic, retain) NSString *localRootPath;
@property (nonatomic, retain) UIScrollView *scrollview;
@property (nonatomic, retain) UIToolbar *toolBar;
@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, copy) RemoveImage removeImage;

@end
