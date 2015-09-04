//
//  CellBackground.m
//  CRMiOS
//
//  Created by Sy Pauv on 11/25/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "CellBackground.h"

CGRect rectFor1PxStroke(CGRect rect) {
    return CGRectMake(rect.origin.x + 0.5, rect.origin.y + 0.5, rect.size.width - 1, rect.size.height - 1);
}

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = [NSArray arrayWithObjects:(id)startColor, (id)endColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
}

void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color) {
    
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
    CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);        
    
}

void drawGlossAndGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor) {
    
    drawLinearGradient(context, rect, startColor, endColor);
    
    CGColorRef glossColor1 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.35].CGColor;
    CGColorRef glossColor2 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1].CGColor;
    
    CGRect topHalf = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/2);
    
    drawLinearGradient(context, topHalf, glossColor1, glossColor2);
    
}

@implementation CustomCellBackground


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef whiteColor = [UIColor colorWithRed:1.0 green:1.0 blue:15.0 alpha:1.0].CGColor; 
    CGColorRef lightGrayColor = [UIColor colorWithRed:239.0/255.0 green:247.0/255.0 blue:250.0/255.0 alpha:1.0].CGColor;
    
    CGRect paperRect = self.bounds;
    // Fill with gradient
    drawLinearGradient(context, paperRect, whiteColor, lightGrayColor);
   
    // Add white 1 px stroke
    CGRect strokeRect = paperRect;
    strokeRect.size.height -= 1;
    strokeRect = rectFor1PxStroke(strokeRect);
    
    CGContextSetStrokeColorWithColor(context, whiteColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokeRect(context, strokeRect);
    
}

- (void)dealloc {
    [super dealloc];
}


@end

