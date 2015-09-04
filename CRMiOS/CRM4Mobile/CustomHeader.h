//
//  CustomHeader.h
//  CRMiOS
//
//  Created by raksmey yorn on 12/14/11.
//  Copyright (c) 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomHeader : UIView {
    UILabel *_titleLabel;
    UIImageView *icon;
    UIColor *color;
    CGRect _coloredBoxRect;

}

-(id)initWithTitle:(NSString *)title;
@property (retain) UIImageView *icon;
@property (retain) UILabel *titleLabel;
@property (retain) UIColor *color;

@end