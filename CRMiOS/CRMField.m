//
//  CRMField.m
//  Orientation
//
//  Created by Sy Pauv Phou on 3/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "CRMField.h"
#import "Configuration.h"


@implementation CRMField


@synthesize code;
@synthesize displayName;
@synthesize type;

- initWithCode:(NSString *)newCode displayName:(NSString *)newDisplayName type:(NSString *)newType entity:(NSString *)entity {
    self = [super init];
    self.code = newCode;
    self.displayName = newDisplayName;
    self.type = newType;
    return self;
}


- (void) dealloc
{
    [self.displayName release];
    [self.type release];
    [self.code release];
    [super dealloc];
}

@end
