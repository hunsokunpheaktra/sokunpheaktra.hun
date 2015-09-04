//
//  CustomTextField.m
//  Pactrac2me
//
//  Created by Hun Sokunpheaktra on 8/5/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (void)drawPlaceholderInRect:(CGRect)rect {
    CGContextRef curRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(curRef, [[UIColor whiteColor] CGColor]);
    [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
}
@end
