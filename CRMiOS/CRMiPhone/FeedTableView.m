//
//  FeedTableView.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/30/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "FeedTableView.h"


@implementation FeedTableView


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    // hides the keyboard when the user touches the screen
    if (touch.phase == UITouchPhaseBegan) {
        [self.superview endEditing:YES];
//        for (UIView *view in [[self superview] subviews]) {
//            if ([view isFirstResponder]) {
//                [view resignFirstResponder];
//                break;
//            }   
//        }
//        for (UIView *cellView in [self subviews]) {
//            for (UIView *contentView in [cellView subviews]) {
//                for (UIView *view in [contentView subviews]) {
//                    if ([view isFirstResponder]) {
//                        [view resignFirstResponder];
//                        break;
//                    }
//                }
//            }
//        }
    }
}
    
@end
