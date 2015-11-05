//
//  LWCImageZoomView.h
//  ReviewImage
//
//  Created by 李伟超 on 15/4/27.
//  Copyright (c) 2015年 LWC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ImageOrientation) {
    ImageOrientationPortrait = UIInterfaceOrientationPortrait,
    ImageOrientationLandScapeLeft = UIInterfaceOrientationLandscapeLeft,
    ImageOrientationLandScapeRight = UIInterfaceOrientationLandscapeRight,
    ImageOrientationPortraitUpsideDown = UIInterfaceOrientationPortraitUpsideDown,
};

@protocol TapZoomingViewDelegate <NSObject>

- (void)HandleTap:(UITapGestureRecognizer *)gesture;

@end

@interface ImageZoomView : UIView<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *ImageURL;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) ImageOrientation imageOrientation;
@property (nonatomic, assign) id<TapZoomingViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame WithImage:(UIImage *)image;
- (id)initWithFrame:(CGRect)frame WithURL:(NSURL *)url;

- (void)imageDidChange;

@end
