//
//  CRTableViewCell.h
//  CRMultiRowSelector
//
//  Created by Christian Roman Mendoza on 6/17/12.
//  Copyright (c) 2012 chroman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, readonly, strong) UIImageView *imageView;
@property (nonatomic, readonly, strong) UIImage *renderedMark;

@end