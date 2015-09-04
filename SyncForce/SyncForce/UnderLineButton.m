//
//  UnderLineButton.m
//  CRMiOS
//
//  Created by Sy Pauv on 12/5/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "UnderLineButton.h"


@implementation UnderLineButton

+ (UnderLineButton*) underlinedButton {
    UnderLineButton* button = [[UnderLineButton alloc] init];
    return [button autorelease];
}

- (void) drawRect:(CGRect)rect {
    CGRect textRect = self.titleLabel.frame;
    
    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender + 2;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    // set to same colour as text
    CGContextSetStrokeColorWithColor(c, self.titleLabel.textColor.CGColor);
    
    CGContextMoveToPoint(c, textRect.origin.x, textRect.origin.y + textRect.size.height + descender);
    
    CGContextAddLineToPoint(c, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender);
    
    CGContextClosePath(c);
    
    CGContextDrawPath(c, kCGPathStroke);
    
}
@end
