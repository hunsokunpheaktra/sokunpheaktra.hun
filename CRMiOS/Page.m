//
//  Page.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "Page.h"


@implementation Page

@synthesize name;
@synthesize sections;

- (id)initWithName:(NSString *)newName {
    self = [super init];
    self.name = newName;
    self.sections = [[NSMutableArray alloc] initWithCapacity:1];
    return self;
}

- (void) dealloc
{
    [self.sections release];
    [super dealloc];
}

@end
