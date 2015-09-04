//
//  CustomHeader.m
//  CRMiOS
//
//  Created by raksmey yorn on 12/14/11.
//  Copyright (c) 2011 Fellow Consulting AG. All rights reserved.
//

#import "CustomHeader.h"


@implementation CustomHeader
@synthesize titleLabel = _titleLabel;
@synthesize color;
@synthesize icon;

-(id)initWithTitle:(NSString *)title{
    if ((self = [super init])) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.titleLabel = [[[UILabel alloc] init] autorelease];
        _titleLabel.textAlignment = UITextAlignmentLeft;
        _titleLabel.opaque = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text=title;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _titleLabel.shadowOffset = CGSizeMake(0, -1);
        [self addSubview:_titleLabel];
        self.color = [UIColor colorWithRed:105.0f/255.0f green:179.0f/255.0f blue:216.0f/255.0f alpha:1.0];
    }
    return self;
}


-(void) layoutSubviews {
    
    _coloredBoxRect = CGRectMake(0, 
                                 0, 
                                 self.bounds.size.width, 
                                 self.bounds.size.height);
    
    CGSize fontSize = [_titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:16.0]];
    CGRect titleRect=CGRectMake(10, _coloredBoxRect.size.height - (fontSize.height+6), fontSize.width, fontSize.height+5);
    _titleLabel.frame=titleRect;
 
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

    
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGColorRef lightColor = color.CGColor;
    CGColorRef shadowColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5].CGColor;   
    // Draw title box
    CGRect titlebox=_titleLabel.frame;
    titlebox.origin.x= titlebox.origin.x-5;
    titlebox.size.width= titlebox.size.width + 10;
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 3), 3.0, shadowColor);
    CGContextSetFillColorWithColor(context, lightColor);
    CGContextFillRect(context, titlebox);
    CGContextRestoreGState(context);
    
    //draw line
    CGRect lineRect= CGRectMake(_coloredBoxRect.origin.x, _coloredBoxRect.size.height - 3, _coloredBoxRect.size.width, 3);
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 2), 3.0, shadowColor);
    CGContextSetFillColorWithColor(context, lightColor);
    CGContextFillRect(context, lineRect);
    CGContextRestoreGState(context);
    
}



- (void)dealloc {
    [_titleLabel release];
    _titleLabel = nil;
    [color release];
    [super dealloc];
}


@end
