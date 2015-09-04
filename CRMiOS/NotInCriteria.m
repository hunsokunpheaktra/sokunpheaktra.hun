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

- (id)initWithColumn:(NSString *)newColumn values:(NSArray *)newValues {
    self = [super initWithColumn:newColumn];
    self.values = newValues;
    return self;
}


- (NSString *)getCriteria {
    if ([self.values count] == 1) {
        return [NSString stringWithFormat:@"(%@ IS NULL OR %@ != ?)", self.column, self.column];
    } else {
        NSMutableString *ms = [[[NSMutableString alloc] initWithString:@"("] autorelease];
        [ms appendString:self.column];
        [ms appendString:@" IS NULL OR "];
        [ms appendString:self.column];
        [ms appendString:@" NOT IN ("];
        for (int i = 0; i < [self.values count]; i++) {
            if (i > 0) {
                [ms appendString:@", "];
            }
            [ms appendString:@"?"];
        }
        [ms appendString:@"))"];
        return ms;
    }
}

- (NSArray *)getValues {
    return values;
}



- (void) dealloc
{
    [self.values release];
    [super dealloc];
}


@end
