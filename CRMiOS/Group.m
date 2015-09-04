//
//  Group.m
//  Orientation
//
//  Created by Sy Pauv Phou on 3/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "Group.h"


@implementation Group

@synthesize name;
@synthesize shortName;
@synthesize items;

- (id)init {
    self = [super init];
    self.items = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    return self;
}


- (void) dealloc
{
    [self.items release];
    [super dealloc];
}

@end
