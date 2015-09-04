//
//  BasicPreviewItem.m
//  Pactrac2me
//
//  Created by Hun Sokunpheaktra on 3/1/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "BasicPreviewItem.h"

@implementation BasicPreviewItem

@synthesize previewItemURL, previewItemTitle;

-(void)dealloc
{
    self.previewItemURL = nil;
    self.previewItemTitle = nil;
    [super dealloc];
}

@end
