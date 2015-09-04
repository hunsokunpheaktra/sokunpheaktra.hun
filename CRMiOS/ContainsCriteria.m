//
//  ContainsCriteria.m
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/21/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "ContainsCriteria.h"

@implementation ContainsCriteria

@synthesize value;

- (id)initWithColumn:(NSString *)newColumn value:(NSString *)newValue {
    self = [super initWithColumn:newColumn];
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
    return [NSArray arrayWithObject:[NSString stringWithFormat:@"%%%@%%", self.value]];
}

@end
