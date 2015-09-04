//
//  LikeCriteria.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "LikeCriteria.h"


@implementation LikeCriteria

@synthesize value;

- (id)initWithColumn:(NSString *)newColumn value:(NSString *)newValue {
    self = [super initWithColumn:newColumn];
    self.value = newValue;
    if ([self.column isEqualToString:@"search"] || [self.column isEqualToString:@"search2"]) {
        self.value = [newValue uppercaseString];
    } else {
        self.value = newValue;
    }
    return self;
}

- (NSString *)getCriteria {
    return [NSString stringWithFormat:@"%@ LIKE ?", self.column];
}

- (NSArray *)getValues {
    return [NSArray arrayWithObject:[NSString stringWithFormat:@"%@%%", self.value]];
}

@end
