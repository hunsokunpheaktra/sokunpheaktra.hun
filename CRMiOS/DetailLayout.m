//
//  Layout.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "DetailLayout.h"


@implementation DetailLayout

@synthesize pages;


- (id)init {
    self = [super init];
    self.pages = [[NSMutableArray alloc] initWithCapacity:1];
    return self;
}

- (void) dealloc
{
    [self.pages release];
    [super dealloc];
}

@end
