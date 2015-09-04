//
//  GreaterThanCriteria.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 10/5/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "BetweenCriteria.h"


@implementation BetweenCriteria

@synthesize start, end;

- (id)initWithColumn:(NSString *)newColumn start:(NSString *)newStart end:(NSString *)newEnd {
    self = [super initWithColumn:newColumn];
    self.start = newStart;
    self.end = newEnd;
    return self;
}

- (NSString *)getCriteria {
    return [NSString stringWithFormat:@"%@ BETWEEN ? AND ?", self.column];
}

- (NSArray *)getValues {
    NSString *tmpStart = [EvaluateTools evaluate:self.start item:nil];
    NSString *tmpEnd = [EvaluateTools evaluate:self.end item:nil];
    return [NSArray arrayWithObjects:tmpStart, tmpEnd, nil];
}

@end
