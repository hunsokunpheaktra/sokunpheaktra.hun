//
//  Section.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "Section.h"


@implementation Section

@synthesize fields;
@synthesize name;

- (id)initWithName:(NSString *)newName {
    self = [super init];
    self.name = newName;
    self.fields = [[NSMutableArray alloc] initWithCapacity:1];
    self.isGrouping = NO;
    return self;
}

- (void) dealloc
{
    [self.fields release];
    [super dealloc];
}

@end
