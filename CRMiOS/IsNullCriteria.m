//
//  IsNullCriteria.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "IsNullCriteria.h"


@implementation IsNullCriteria

- (id)initWithColumn:(NSString *)newColumn {
    self = [super initWithColumn:newColumn];
    return self;
}

- (NSString *)getCriteria {
    return [NSString stringWithFormat:@"%@ IS NULL", self.column];
}

- (NSArray *)getValues {
    return Nil;
}

@end
