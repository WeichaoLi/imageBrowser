//
//  CheckCollectionViewCell.m
//  TakePhotos
//
//  Created by 李伟超 on 15/4/28.
//  Copyright (c) 2015年 LWC. All rights reserved.
//

#import "CheckCollectionViewCell.h"

@implementation CheckCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
        
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setFrame:CGRectMake(CGRectGetWidth(self.bounds) - 40, 5, 35, 35)];
        [_selectButton setImage:[UIImage imageNamed:@"ImageSelectedOff"] forState:UIControlStateNormal];
        [_selectButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:_selectButton aboveSubview:_imageView];
    }
    return self;
}

- (void)setHiddenSelectButton:(BOOL)hiddenSelectButton {
    [_selectButton setHidden:hiddenSelectButton];
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (_isSelected) {
        [_selectButton setImage:[UIImage imageNamed:@"ImageSelectedOn"] forState:UIControlStateNormal];
    }else {
        [_selectButton setImage:[UIImage imageNamed:@"ImageSelectedOff"] forState:UIControlStateNormal];
    }
}

- (void)click:(id)sender {
    self.isSelected = !_isSelected;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [[UIColor clearColor] setFill];
    UIRectFill(rect);
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
