//
//  ShowListViewController.h
//  TakePhotos
//
//  Created by 李伟超 on 15/4/28.
//  Copyright (c) 2015年 LWC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ShowType) {
    selectOne = 1,
    selectMultiple = 2,
    checkAll = 3,
};

typedef NS_ENUM(NSUInteger, ImageOrigin) {
    ImageOriginLocal = 1,
    ImageOriginOnline = 2,
};

@protocol ShowListCallBackDelegate <NSObject>

- (void)removeWithUrl:(NSString *)url;

@optional

- (void)didSelectInViewController:(UIViewController *)viewController WithImage:(UIImage *)image;

@end

@interface ShowListViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign) id<ShowListCallBackDelegate> delegate;
@property (nonatomic, retain) UICollectionView *myCollectionView;
@property (nonatomic, assign) ShowType showtype;
@property (nonatomic, assign) ImageOrigin imageOrigin;
@property (nonatomic, retain) NSString *rootPath;
@property (nonatomic, copy)   NSMutableArray *imageArray;
@property (nonatomic, retain) UIToolbar *toolBar;
@property (nonatomic) BOOL showToolBar;

- (id)initWithShowType:(ShowType)showtype;

@end
