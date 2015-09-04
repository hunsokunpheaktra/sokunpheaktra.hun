//
//  ValuesCriteria.m
//
//  Created by Sy Pauv Phou on 6/3/11.
//  Copyright 2011 Gaeasys. All rights reserved.
//

#import "ValuesCriteria.h"


@implementation ValuesCriteria

@synthesize values;

- (id)initWithValues:(NSArray *)newValues {
    self = [super init];
    self.values = newValues;
    return self;
}

- (id)initWithString:(NSString *)value {
    self = [super init];
    if (value==nil) value = @"";
    self.values = [NSArray arrayWithObject:value];
    return self;
}

- (NSString *)getCriteria {
    if ([self.values count] == 1) {
        return @"= ?";
    } else {
        NSMutableString *ms = [[[NSMutableString alloc] initWithString:@"IN ("] autorelease];
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

+ (ValuesCriteria *)criteriaWithString:(NSString *)value {
    return [[[ValuesCriteria alloc] initWithString:value] autorelease];
}

+ (ValuesCriteria *)criteriaWithInt:(int)value {
    return [[ValuesCriteria alloc] initWithString:[NSString stringWithFormat:@"%i", value]];
}

- (void) dealloc
{
    [self.values release];
    [super dealloc];
}

@end
