//
//  CustomUIBarButtonItem.m
//  Pactrac2me
//
//  Created by Hun Sokunpheaktra on 8/7/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "CustomUIBarButtonItem.h"
#import "AppDelegate.h"

@implementation CustomUIBarButtonItem

-(id)initWithText:(NSString *)title target:(id)target action:(SEL)action{
    
    float h = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 32 : 44;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"barbutton-bg.png"] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 70, h-10);
    button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    self = [super initWithCustomView:button];
    
    return self;
    
}

@end
