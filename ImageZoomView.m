//
//  LWCImageZoomView.m
//  ReviewImage
//
//  Created by 李伟超 on 15/4/27.
//  Copyright (c) 2015年 LWC. All rights reserved.
//

#import "ImageZoomView.h"
#import "ImageCache.h"

//#define __IPHONE_SYSTEM_VERSION [[UIDevice currentDevice] systemVersion].floatValue

@interface ImageZoomView()

@property (nonatomic, readwrite, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;

@end

@implementation ImageZoomView {
    UIImage *currentImage;
    NSURL *currentURL;
    
    ImageCache *dataCache;
}

- (id)initWithFrame:(CGRect)frame WithImage:(UIImage *)image {
    if (self = [self initWithFrame:frame]) {
        currentImage = image;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame WithURL:(NSURL *)url {
    if (self = [self initWithFrame:frame]) {
        currentURL = url;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Drawing code
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    /****************************scrollview***************************/
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.decelerationRate = 0.1f;
        _scrollView.delegate = self;
        
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
//        _containerView.backgroundColor = [UIColor redColor];
        [_scrollView addSubview:_containerView];
        
        [self addSubview:_scrollView];
    }
    
    
    /****************************手势***************************/
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    [_scrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    [_scrollView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    /****************************初始化***************************/
    
    _imageOrientation = ImageOrientationPortrait;
    
#warning 这里需要修改
    [self imageDidChange];
    [NSThread detachNewThreadSelector:@selector(loadImage) toTarget:self withObject:nil];
}

- (id)getDataWithURL:(NSURL *)url {
    NSData *data = [NSData dataWithContentsOfFile:url.absoluteString];;
    if (!data) {
        if (!dataCache) {
            dataCache = [[ImageCache alloc] init];
        }
        data = [dataCache objectForKey:url.absoluteString];
        if (!data) {
            data = [NSData dataWithContentsOfURL:url];
            [dataCache setObject:data forKey:url.absoluteString];
        }
    }
    return data;
}

- (void)loadImage {
    @autoreleasepool {
        NSData *data = nil;
        if (currentURL) {
            data = [self getDataWithURL:currentURL];
        }
        UIImage *image = [UIImage imageWithData:data];
        if (currentImage) {
            image = currentImage;
        }
        
        self.imageView = [[UIImageView alloc] initWithImage:image];
        [self imageDidChange];
    }
}

- (void)dealloc {
    _scrollView = nil;
    _containerView = nil;
    _imageView = nil;
}

#pragma mark- Properties

- (void)setImageOrientation:(ImageOrientation)imageOrientation {
    _imageOrientation = imageOrientation;
}

- (void)setImageView:(UIImageView *)imageView {
    if(imageView != _imageView){
//        [_imageView removeObserver:self forKeyPath:@"image"];
        [_imageView removeFromSuperview];
        
        _imageView = imageView;
        _imageView.frame = _imageView.bounds;
        
//        [_imageView addObserver:self forKeyPath:@"image" options:0 context:nil];
        
        [_containerView addSubview:_imageView];
        
        _scrollView.zoomScale = 1;
        _scrollView.contentOffset = CGPointZero;
        _containerView.bounds = _imageView.bounds;
        
        [self resetZoomScale];
        _scrollView.zoomScale  = _scrollView.minimumZoomScale;
        [self scrollViewDidZoom:_scrollView];
    }
}

#pragma mark - 当图片改变:例如旋转

- (void)imageDidChange {
    
    CGSize size = (self.imageView.image) ? self.imageView.image.size : self.bounds.size;
    CGFloat ratio;
    
    if (_imageOrientation == ImageOrientationPortrait || _imageOrientation == ImageOrientationPortraitUpsideDown) { //判断图片是不是正的
        ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
    }else {
        ratio = MIN(_scrollView.frame.size.width / size.height, _scrollView.frame.size.height / size.width);
    }
    
    CGFloat W = ratio * size.width;
    CGFloat H = ratio * size.height;
    self.imageView.frame = CGRectMake(0, 0, W, H);
    
    _scrollView.zoomScale = 1;
    _scrollView.contentOffset = CGPointZero;
    _containerView.bounds = _imageView.bounds;
    
    [self resetZoomScale];
    _scrollView.zoomScale  = _scrollView.minimumZoomScale;
    [self scrollViewDidZoom:_scrollView];
    
    _imageView.frame = _containerView.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    _scrollView.bounds = self.bounds;
}

#pragma mark- Scrollview delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat Ws = _scrollView.frame.size.width - _scrollView.contentInset.left - _scrollView.contentInset.right;
    CGFloat Hs = _scrollView.frame.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
    CGFloat W = _containerView.frame.size.width;
    CGFloat H = _containerView.frame.size.height;
    
    CGRect rct = _containerView.frame;
    rct.origin.x = MAX((Ws-W)/2, 0);
    rct.origin.y = MAX((Hs-H)/2, 0);
    _containerView.frame = rct;
    
    if (scrollView.zoomScale >= scrollView.maximumZoomScale) {

    }
}

- (void)resetZoomScale {
    CGFloat Rw = _scrollView.frame.size.width / self.imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / self.imageView.frame.size.height;
    
    CGFloat scale = 1;
    
    if (_imageOrientation == ImageOrientationPortrait || _imageOrientation == ImageOrientationPortraitUpsideDown) {
        Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
        Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    }else {
        Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.height));
        Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.width));
    }
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
}

#pragma mark - Tap gesture

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    
    if (_delegate && [_delegate respondsToSelector:@selector(HandleTap:)]) {
        [_delegate HandleTap:gesture];
    }

}

- (void)didDoubleTap:(UITapGestureRecognizer*)gesture {
    CGPoint touchPoint = [gesture locationInView:_containerView];
    if (_scrollView.zoomScale != _scrollView.minimumZoomScale) {
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    }else {
        [_scrollView zoomToRect:[self getRectWithScale:_scrollView.maximumZoomScale andCenter:touchPoint] animated:YES];
    }
}

- (CGRect)getRectWithScale:(float)scale andCenter:(CGPoint)center{
    CGRect newRect;
    newRect.size.width = _scrollView.frame.size.width/scale;
    newRect.size.height = _scrollView.frame.size.height/scale;
    newRect.origin.x = center.x - newRect.size.width/2;
    newRect.origin.y = center.y - newRect.size.height/2;
    return newRect;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self imageDidChange];
    
}


@end
