//
//  ImageBrowser.m
//  TakePhotos
//
//  Created by 李伟超 on 15/5/6.
//  Copyright (c) 2015年 LWC. All rights reserved.
//

#import "ImageBrowser.h"
#import "ImageZoomView.h"
//#import "ImageServices.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define PADDING    10

@interface ImageBrowser()<TapZoomingViewDelegate>

@end

@implementation ImageBrowser {
    // Appearance
    BOOL _previousNavBarHidden;
}

- (id)init {
    if (self = [super init]) {
#ifdef __IPHONE_7_0
        self.navigationController.navigationBar.translucent = NO;
        self.extendedLayoutIncludesOpaqueBars = YES;
        //        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        if (SYSTEM_VERSION_LESS_THAN(@"7")) self.wantsFullScreenLayout = YES;
#endif
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return _isHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)loadView {
    [super loadView];
    
    CGRect frame = self.view.bounds;
    frame.origin.x -= PADDING;
    frame.size.width += 2*PADDING;
    _scrollview = [[UIScrollView alloc] initWithFrame:frame];
    [_scrollview setContentSize:CGSizeMake(_zoomArray.count * frame.size.width, 0)];
    _scrollview.backgroundColor = [UIColor blackColor];
    _scrollview.showsHorizontalScrollIndicator = NO;
    _scrollview.showsVerticalScrollIndicator = NO;
    _scrollview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _scrollview.decelerationRate = 0.1f;
    _scrollview.delegate = self;
    _scrollview.pagingEnabled = YES;
    [self.view addSubview:_scrollview];
    
    if (_toolBar == nil) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [_toolBar setBackgroundColor:[UIColor whiteColor]];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(deleteImage) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"删除" forState:UIControlStateNormal];
        [btn setFrame:CGRectMake(10, 5, 50, 30)];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [btn setBackgroundColor:[UIColor colorWithRed:0/255.0 green:127/255.0 blue:245/255.0 alpha:1.0f]];
        [btn.layer setCornerRadius:3.0f];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        
        NSArray *Items = @[flexibleSpace,doneButton];
        [_toolBar setItems:Items animated:YES];
        _toolBar.tintColor = [UIColor whiteColor];
        
        [self.view addSubview:_toolBar];
    }
    
    [self performLayout];
}

- (void)performLayout {
    
    for (int i = -2; i <= 2; i++) {
        NSInteger index = _currentIndex  + i;
        if (index < 0)
            continue;
        if (index >= _zoomArray.count)
            break;
        
        @autoreleasepool {
            CGRect frame = self.view.frame;
            frame.origin.x = index * CGRectGetWidth(_scrollview.frame)+ PADDING;
            //            LWCImageZoomView *zoomingview = nil;
            //            if ([_zoomArray[i] isMemberOfClass:[NSURL class]]) {
            //                zoomingview = [[LWCImageZoomView alloc] initWithFrame:frame WithURL:_zoomArray[i]];
            //            }else if ([_zoomArray[i] isMemberOfClass:[UIImage class]]) {
            //                zoomingview = [[LWCImageZoomView alloc] initWithFrame:frame WithImage:_zoomArray[i]];
            //            }else {
            //                zoomingview = [[LWCImageZoomView alloc] initWithFrame:frame WithURL:[NSURL URLWithString:_zoomArray[i]]];
            //            }
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",_localRootPath, _zoomArray[index]];
            NSURL *url = nil;
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                 url = [NSURL URLWithString:filePath];
            }else {
                url = [NSURL URLWithString:_zoomArray[index]];
            }
            ImageZoomView *zoomingview = [[ImageZoomView alloc] initWithFrame:frame
                                                                            WithURL:url];
            zoomingview.delegate = self;
            zoomingview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

            if (!_visiablePages) {
                _visiablePages = [NSMutableArray arrayWithCapacity:5];
            }
            [_visiablePages addObject:zoomingview];
            
            [_scrollview addSubview:zoomingview];
        }
    }
    currentOffset = CGPointMake(_currentIndex*CGRectGetWidth(_scrollview.frame), 0);
    [_scrollview setContentOffset:currentOffset];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.view.backgroundColor = [UIColor blackColor];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_isHidden) {
        [self HandleTap:nil];
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)dealloc {
    _scrollview = nil;
    _zoomArray = nil;
    _toolBar = nil;
}

- (void)addZoomViewAtIndex:(NSUInteger)index {
    CGRect frame = self.view.frame;
    frame.origin.x = index * CGRectGetWidth(_scrollview.frame)+ PADDING;
    //            LWCImageZoomView *zoomingview = nil;
    //            if ([_zoomArray[i] isMemberOfClass:[NSURL class]]) {
    //                zoomingview = [[LWCImageZoomView alloc] initWithFrame:frame WithURL:_zoomArray[i]];
    //            }else if ([_zoomArray[i] isMemberOfClass:[UIImage class]]) {
    //                zoomingview = [[LWCImageZoomView alloc] initWithFrame:frame WithImage:_zoomArray[i]];
    //            }else {
    //                zoomingview = [[LWCImageZoomView alloc] initWithFrame:frame WithURL:[NSURL URLWithString:_zoomArray[i]]];
    //            }
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",_localRootPath, _zoomArray[index]];
    NSURL *url = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        url = [NSURL URLWithString:filePath];
    }else {
        url = [NSURL URLWithString:_zoomArray[index]];
    }
    ImageZoomView *zoomingview = [[ImageZoomView alloc] initWithFrame:frame
                                                                    WithURL:url];
    zoomingview.delegate = self;
    zoomingview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    if (!_visiablePages) {
        _visiablePages = [NSMutableArray arrayWithCapacity:5];
    }
    if (index > _currentIndex) {
        [_visiablePages addObject:zoomingview];
    }else {
        [_visiablePages insertObject:zoomingview atIndex:0];
    }    
    
    [_scrollview addSubview:zoomingview];
}

- (void)removeZoomViewAtIndex:(NSUInteger)index {
    ImageZoomView *zoomView = [_visiablePages objectAtIndex:index];
    [zoomView removeFromSuperview];
    [_visiablePages removeObject:zoomView];
}

- (void)deleteImage {
    if (_removeImage) {
        _removeImage(_zoomArray[_currentIndex], _currentIndex);
        [self.navigationController popViewControllerAnimated:YES];
    }
//    NSString *fileName = _zoomArray[_currentIndex];
//    NSString *filePath = [NSString stringWithFormat:@"%@/%@",_localRootPath, fileName];
//    NSError *error = nil;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if ([fileManager removeItemAtPath:filePath error:&error]) {
//        filePath = [NSString stringWithFormat:@"%@/small/%@",_localRootPath, fileName];
//        if ([fileManager removeItemAtPath:filePath error:&error]) {
//            [self.navigationController popViewControllerAnimated:NO];
//        }
//    }else {
//        NSLog(@"%@",error);
//    }
}

#pragma mark - Tap gesture

- (void)HandleTap:(UITapGestureRecognizer*)gesture {
    _isHidden = !_isHidden;
    [self prefersStatusBarHidden];
    [self setNeedsStatusBarAppearanceUpdate];
    [UIView animateWithDuration:0.2 animations:^{
        [self toggleHideNavigationBar:_isHidden];
    }];
    [self.navigationController setNavigationBarHidden:_isHidden animated:YES];
}

- (void)toggleHideNavigationBar:(BOOL)isHidden {
    CGRect frame = CGRectZero;
    if (isHidden) {
        frame = _toolBar.frame;
        frame.origin.y += frame.size.height;
        _toolBar.frame = frame;
    }else {
        frame = _toolBar.frame;
        frame.origin.y -= frame.size.height;
        _toolBar.frame = frame;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _previousNavBarHidden = YES;
    if (_isHidden) {
        [self HandleTap:nil];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!_isHidden && _previousNavBarHidden) {
        [self HandleTap:nil];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    /*
    NSUInteger CRindex = scrollView.contentOffset.x/scrollView.bounds.size.width;
    @autoreleasepool {
        if (CRindex > _currentIndex) {
            if (CRindex < _zoomArray.count - 2) {
                [self addZoomViewAtIndex:CRindex+2];
            }
            if (CRindex > 2) {
                [self removeZoomViewAtIndex:0];
            }
        }else if(CRindex < _currentIndex) {
            if (_currentIndex > 2) {
                [self addZoomViewAtIndex:CRindex-2];
            }
            if (_currentIndex < _zoomArray.count - 2) {
                [self removeZoomViewAtIndex:_visiablePages.count -1];
            }
        }
    }
    _currentIndex = CRindex;
     */
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSUInteger CRindex = scrollView.contentOffset.x/scrollView.bounds.size.width;
    @autoreleasepool {
        if (CRindex > _currentIndex) {
            if (CRindex < _zoomArray.count - 2) {
                [self addZoomViewAtIndex:CRindex+2];
            }
            if (CRindex > 2) {
                [self removeZoomViewAtIndex:0];
            }
        }else if(CRindex < _currentIndex) {
            if (_currentIndex > 2) {
                [self addZoomViewAtIndex:CRindex-2];
            }
            if (_currentIndex < _zoomArray.count - 2) {
                [self removeZoomViewAtIndex:_visiablePages.count -1];
            }
        }
    }
    _currentIndex = CRindex;
//    NSUInteger CRindex = scrollView.contentOffset.x/scrollView.bounds.size.width;
//    if (CRindex > _currentIndex) {
//        LWCImageZoomView *zoomView = nil;
//        if (CRindex > 2) {
////            [self removeZoomViewAtIndex:0];
//            zoomView = [_visiablePages objectAtIndex:0];
//            [zoomView removeFromSuperview];
//            [_visiablePages removeObjectAtIndex:0];
//        }
//        if (CRindex < _zoomArray.count - 2) {
//            CGRect frame = self.view.frame;
//            frame.origin.x = (CRindex+2) * CGRectGetWidth(_scrollview.frame)+ PADDING;
//            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[ImageServices getPathDirectory], _zoomArray[CRindex+2]]];
//            if (!zoomView) {
//                zoomView = [[LWCImageZoomView alloc] initWithFrame:frame WithURL:url];
//                zoomView.delegate = self;
//                zoomView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//            }else {
//                zoomView = [zoomView initWithFrame:frame WithURL:url];
//            }
//            [_visiablePages addObject:zoomView];
//            [_scrollview addSubview:zoomView];
//        }
//    }else if(CRindex < _currentIndex) {
//        if (_currentIndex > 2) {
//            [self addZoomViewAtIndex:CRindex-2];
//        }
//        if (_currentIndex < _zoomArray.count - 2) {
//            [self removeZoomViewAtIndex:_visiablePages.count -1];
//        }
//    }
//    _currentIndex = CRindex;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [_scrollview setContentSize:CGSizeMake(_zoomArray.count * _scrollview.bounds.size.width, 0)];
    [_scrollview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i = 0; i < _zoomArray.count; i++) {
        CGRect frame = _scrollview.bounds;
        frame.origin.x = i*frame.size.width;
        frame.size = CGSizeMake(frame.size.width, frame.size.height);
        ImageZoomView *zoomingview = [[ImageZoomView alloc] initWithFrame:frame];
        [_scrollview addSubview:zoomingview];
    }
    //    for (LWCImageZoomView *zoomview in _scrollview.subviews) {
    //        zoomview.imageOrientation = (ImageOrientation)toInterfaceOrientation;
    //        [zoomview imageDidChange];
    //    }
}

@end
