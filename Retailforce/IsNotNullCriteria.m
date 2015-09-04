//
//  IsNotNullCriteria.m
//
//  Created by Sy Pauv Phou on 6/3/11.
//  Copyright 2011 Gaeasys. All rights reserved.
//

#import "IsNotNullCriteria.h"


@implementation IsNotNullCriteria

- (NSString *)getCriteria {
    return @"IS NOT NULL";
}

- (NSArray *)getValues {
    return Nil;
}

@end
