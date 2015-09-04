//
//  CommentViewController.m
//  CRMiOS
//
//  Created by Arnaud on 04/03/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "LongTextViewController.h"

@implementation LongTextViewController

@synthesize text;

- (id)initWithText:(NSString *)newText title:(NSString *)newTitle {
    self = [super init];
    self.text = newText;
    self.title = newTitle;
    return self;
}

- (void)loadView {
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [textView setFont:[UIFont systemFontOfSize:16]];
    [textView setText:self.text];
    [textView setEditable:NO];
    [self setView:textView];
}

@end
