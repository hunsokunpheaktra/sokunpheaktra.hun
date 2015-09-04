//
//  LikeCriteria.m
//
//  Created by Sy Pauv Phou on 6/3/11.
//  Copyright 2011 Gaeasys. All rights reserved.
//

#import "LikeCriteria.h"


@implementation LikeCriteria

@synthesize value;

- (id)initWithValue:(NSString *)newValue {
    self = [super init];
    self.value = newValue;
    return self;
}

- (NSString *)getCriteria {
    return @"LIKE ?";
}

- (NSArray *)getValues {
    return [NSArray arrayWithObject:[NSString stringWithFormat:@"%@%%", value]];
}

@end
