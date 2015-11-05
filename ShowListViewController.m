//
//  ShowListViewController.m
//  TakePhotos
//
//  Created by 李伟超 on 15/4/28.
//  Copyright (c) 2015年 LWC. All rights reserved.
//

#import "ShowListViewController.h"
#import "CheckCollectionViewCell.h"
#import "ImageServices.h"
#import "ImageBrowser.h"
#import "ImageLoader.h"

#import "SDWebImage/UIImageView+WebCache.h"

@implementation ShowListViewController {
    ImageLoader *imageloader;
}

- (id)initWithShowType:(ShowType)showtype {
    self = [super init];
    if (self) {
        _showtype = showtype;
    }
    return self;
}

- (void)adjustByType {
    if (!_showtype) {
        _showtype = 1;
    }
    switch (_showtype) {
        case 1:{
            _showToolBar = NO;
        }
            break;
        case 2:
            break;
        case 3:{
            _showToolBar = NO;
        }
            break;
            
        default:
            break;
    }
}

- (void)loadView {
    [super loadView];

    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(presentToFore) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 5, 40, 30)];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = doneButton;
    
    if (_showToolBar && _toolBar == nil) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
        [_toolBar setBarStyle:UIBarStyleDefault];
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [_toolBar setBackgroundColor:[UIColor whiteColor]];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"完成" forState:UIControlStateNormal];
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
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(100, 100);
    flowLayout.minimumLineSpacing = 5;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 0, 5);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGRect frame = self.view.bounds;
    if (_showToolBar) {
        frame.size.height -= _toolBar.frame.size.height;
    }
    _myCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    _myCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _myCollectionView.delegate = self;
    _myCollectionView.dataSource = self;
    _myCollectionView.backgroundColor = [UIColor clearColor];
    _myCollectionView.bounces = YES;
    [_myCollectionView registerClass:[CheckCollectionViewCell class] forCellWithReuseIdentifier:@"imageCell"];
    [_myCollectionView showsVerticalScrollIndicator];
    [_myCollectionView setScrollEnabled:YES];
    
    if (_showToolBar) {
        [self.view insertSubview:_myCollectionView belowSubview:_toolBar];
    }else {
        [self.view addSubview:_myCollectionView];
    }
}

- (void)presentToFore {
    [self.navigationController dismissModalViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self adjustByType];
    
    imageloader = [[ImageLoader alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    NSArray *contentNames = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[[ImageServices getPathDirectory] stringByAppendingString:@"/small"] error:nil];
//    _imageArray = contentNames;
    [_myCollectionView reloadData];
}

- (void)setImageArray:(NSMutableArray *)imageArray {
    _imageArray = imageArray;
}

- (void)setImageOrigin:(ImageOrigin)imageOrigin {
    switch (imageOrigin) {
        case ImageOriginLocal:
            
            break;
            
        default:
            break;
    }
}

- (void)done:(id)sender {
    NSLog(@"00");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CheckCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/small/%@", _rootPath,_imageArray[indexPath.row]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [imageloader displayImage:filePath inImageView:cell.imageView];
    }else {
        [cell.imageView setImageWithURL:[NSURL URLWithString:_imageArray[indexPath.row]] placeholderImage:[UIImage imageNamed:@"cell_default"]];
    }
    
    cell.hiddenSelectButton = YES;                                                            
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (_showtype) {
        case 1:{
            if (_delegate && [_delegate respondsToSelector:@selector(didSelectInViewController:WithImage:)]) {
                UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",_rootPath, _imageArray[indexPath.row]]];
                [_delegate didSelectInViewController:self WithImage:image];
            }
        }
            break;
            
        case 2:
            
            break;
            
        case 3:{
            ImageBrowser *browser = [[ImageBrowser alloc] init];
            browser.localRootPath = _rootPath;
            browser.zoomArray = _imageArray;
            browser.currentIndex = indexPath.row;
            [browser setRemoveImage:^(NSString *url, NSUInteger index) {
                debug_NSLog(@"remove:%@",url);
                [self.delegate removeWithUrl:url];
                [self.imageArray removeObjectAtIndex:index];
            }];
            [self.navigationController pushViewController:browser animated:YES];
        }
            break;
            
        default:
            break;
    }
}

@end
