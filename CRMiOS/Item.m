//
//  Item.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/6/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "Item.h"


@implementation Item

@synthesize entity;
@synthesize fields;

- (id)init:(NSString *)newEntity fields:(NSDictionary *)newFields {
    self = [super init];
    self.entity = newEntity;
    self.fields = [NSMutableDictionary dictionaryWithDictionary:newFields];
    return self;
}

- (void) dealloc
{
    [self.fields release];
    [super dealloc];
}


@end
