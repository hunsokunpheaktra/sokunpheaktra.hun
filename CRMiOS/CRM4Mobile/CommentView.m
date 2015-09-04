//
//  CommentView.m
//  CRMiOS
//
//  Created by Sy Pauv on 11/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "CommentView.h"


@implementation CommentView
@synthesize titleLabel,lightColor,imageView,commont,createDate;

-(id)initWithFrame:(CGRect)frame{
    
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        self.titleLabel = [[[UILabel alloc] init] autorelease];
        titleLabel.textAlignment = UITextAlignmentLeft;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        titleLabel.textColor = [UIColor colorWithRed:0.1 green:0.3 blue:0.5 alpha:1.0];
        [self addSubview:titleLabel];
        
        self.commont = [[[UILabel alloc] init] autorelease];
        commont.textAlignment = UITextAlignmentLeft;
        commont.backgroundColor = [UIColor clearColor];
        commont.font = [UIFont systemFontOfSize:14.0];
        commont.textColor = [UIColor blackColor];
        commont.numberOfLines=40;
        [self addSubview:commont];
        
        self.imageView = [[[UIImageView alloc]init]autorelease];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        
        self.createDate = [[[UILabel alloc]init] autorelease] ;
        createDate.textAlignment = UITextAlignmentLeft;
        createDate.opaque = NO;
        createDate.backgroundColor = [UIColor clearColor];
        createDate.font = [UIFont systemFontOfSize:16.0];
        createDate.textColor = [UIColor grayColor];
        createDate.numberOfLines=40;
        [self addSubview:createDate];

        self.lightColor = [UIColor colorWithRed:239.0/255.0 green:247.0/255.0 blue:250.0/255.0 alpha:1.0];
        
    }
    return self;

}
-(void) layoutSubviews {
    
    CGFloat coloredBoxMargin = 6.0;
    CGFloat coloredBoxHeight = self.bounds.size.height-20;
    _coloredBoxRect = CGRectMake(coloredBoxMargin, 
                                 coloredBoxMargin, 
                                 self.bounds.size.width-coloredBoxMargin*2, 
                                 coloredBoxHeight);
    
    CGFloat paperMargin = 9.0;
    _paperRect = CGRectMake(paperMargin, 
                            CGRectGetMaxY(_coloredBoxRect), 
                            self.bounds.size.width-paperMargin*2, 
                            self.bounds.size.height-CGRectGetMaxY(_coloredBoxRect));

    titleLabel.frame = CGRectMake(80, 5, 150, 30);
    commont.frame = CGRectMake(80, 30, _coloredBoxRect.size.width-80, _coloredBoxRect.size.height-30);
    [imageView setFrame:CGRectMake(20, 20, 45, 45)];
    
    self.createDate.frame=CGRectMake(220, 5,300, 30);
    
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGColorRef shadowColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5].CGColor;   

    // Draw shadow
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 2), 5.0, shadowColor);
    CGContextSetFillColorWithColor(context, lightColor.CGColor);
    CGContextFillRect(context, _coloredBoxRect);
    CGContextRestoreGState(context);
}

- (void)dealloc
{
    [super dealloc];
}

@end
