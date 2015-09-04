//
//  ConfigFilter.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 10/6/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ConfigFilter.h"


@implementation ConfigFilter

@synthesize criteria, name, optional;

- (id)initWithName:(NSString *)newName {
    self = [super init];
    self.name = newName;
    self.optional = NO;
    return self;
}

@end
