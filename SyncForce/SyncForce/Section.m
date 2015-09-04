//
//  Section.m
//  SyncForce
//
//  Created by Gaeasys Admin on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Section.h"


@implementation Section

@synthesize fields;
@synthesize name;
@synthesize isGrouping;

- (id)initWithName:(NSString *)newName {
    self = [super init];
    self.name = newName;
    self.fields = [[NSMutableArray alloc] initWithCapacity:1];
    self.isGrouping=[NSNumber numberWithBool:NO];
    return self;
}

- (void) dealloc
{
    [self.fields release];
    [super dealloc];
}

@end
