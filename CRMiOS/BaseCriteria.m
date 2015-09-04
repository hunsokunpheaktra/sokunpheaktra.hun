//
//  BaseCriteria.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "BaseCriteria.h"


@implementation BaseCriteria

@synthesize column;

- (id)initWithColumn:(NSString *)newColumn {
    self = [super init];
    self.column = newColumn;
    return self;
}

@end
