//
//  CellBackground.h
//  CRMiOS
//
//  Created by Sy Pauv on 11/25/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor);
CGRect rectFor1PxStroke(CGRect rect);
void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color);
void drawGlossAndGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor);

@interface CustomCellBackground : UIView {

}


@end
