//
//  CheckCollectionViewCell.h
//  TakePhotos
//
//  Created by 李伟超 on 15/4/28.
//  Copyright (c) 2015年 LWC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckCollectionViewCell : UICollectionViewCell

@property (nonatomic, retain) UIImageView   *imageView;
@property (nonatomic, retain) UIButton      *selectButton;
@property (nonatomic, assign) BOOL          isSelected;
@property (nonatomic, assign) BOOL          hiddenSelectButton;

@end
