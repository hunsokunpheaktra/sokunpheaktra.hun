//
//  NotInCriteria.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 10/5/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "NotInCriteria.h"


@implementation NotInCriteria


@synthesize values;

- (id)initWithValue:(NSString *)newValue{
    self = [super init];
    self.values = [NSArray arrayWithObject:newValue];
    return self;
}


- (NSString *)getCriteria {
    if ([self.values count] == 1) {
        return @"!= ?";;
    } else {
        NSMutableString *ms = [[[NSMutableString alloc] initWithString:@"NOT IN ("] autorelease];
        for (int i = 0; i < [self.values count]; i++) {
            if (i > 0) {
                [ms appendString:@", "];
            }
            [ms appendString:@"?"];
        }
        [ms appendString:@")"];
        return ms;
    }
}

- (NSArray *)getValues {
    return values;
}

- (void) dealloc
{
    [super dealloc];
    [values release];
}


@end
