//
//  OrCriteria.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/16/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "OrCriteria.h"


@implementation OrCriteria

@synthesize criteria1, criteria2;


- (id)initWithCriteria1:(NSObject <Criteria> *)newCriteria1 criteria2:(NSObject <Criteria> *)newCriteria2 {
    self = [super init];
    self.criteria1 = newCriteria1;
    self.criteria2 = newCriteria2;
    return self;
}

- (NSString *)getCriteria {
    return [NSString stringWithFormat:@"(%@ OR %@)", [self.criteria1 getCriteria], [self.criteria2 getCriteria]];
}

- (NSArray *)getValues {
    NSMutableArray *values = [NSMutableArray arrayWithArray:[self.criteria1 getValues]];
    [values addObjectsFromArray:[self.criteria2 getValues]];
    return values;
}

- (NSString *)column {
    return nil;
}

@end
