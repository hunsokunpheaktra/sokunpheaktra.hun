//
//  ValuesCriteria.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ValuesCriteria.h"


@implementation ValuesCriteria

@synthesize values;

- (id)initWithColumn:(NSString *)newColumn values:(NSArray *)newValues {
    self = [super initWithColumn:newColumn];
    self.values = newValues;
    return self;
}

- (id)initWithColumn:(NSString *)newColumn value:(NSString *)value {
    self = [super initWithColumn:newColumn];
    if (value == nil) value = @"";
    self.values = [NSArray arrayWithObject:value];
    return self;
}

- (NSString *)getCriteria {
    if ([self.values count] == 1) {
        return [NSString stringWithFormat:@"%@ = ?", self.column];
    } else {
        NSMutableString *ms = [[[NSMutableString alloc] initWithString:self.column] autorelease];
        [ms appendString:@" IN ("];
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

+ (ValuesCriteria *)criteriaWithColumn:(NSString *)column value:(NSString *)value {
    return [[[ValuesCriteria alloc] initWithColumn:column value:value] autorelease];
}

+ (ValuesCriteria *)criteriaWithColumn:(NSString *)column integer:(int)value {
    return [[ValuesCriteria alloc] initWithColumn:column value:[NSString stringWithFormat:@"%i", value]];
}

- (void) dealloc
{
    [self.values release];
    [super dealloc];
}

@end
