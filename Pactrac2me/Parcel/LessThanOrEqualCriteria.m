//
//  LessThanOrEqualCriteria.m
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LessThanOrEqualCriteria.h"

@implementation LessThanOrEqualCriteria

- (id)initWithValue:(NSString *)newValue{
    
    self = [super init];
    
    value = newValue;
    
    return self;
}

- (NSString *)getCriteria {
    return @"<= ?";
}

- (NSArray *)getValues {
    return [NSArray arrayWithObject:value];
}



@end
