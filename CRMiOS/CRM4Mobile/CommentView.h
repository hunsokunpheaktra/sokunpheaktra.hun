//
//  CommentView.h
//  CRMiOS
//
//  Created by Sy Pauv on 11/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellBackground.h"
#import "BigDetailViewController.h"


@interface CommentView : UIView {
    
    UILabel *titleLabel;
    UIColor *_lightColor;
    CGRect _coloredBoxRect;
    CGRect _paperRect;
    UILabel *comment;
    UILabel *createDate;
    UIImageView *imageView;
    
}
@property (retain) UILabel *createDate;
@property (retain) UILabel *commont;
@property (retain) UIColor *lightColor;
@property (retain) UILabel *titleLabel;
@property (retain) UIImageView *imageView;


@end
