//
//  SublistItem.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "SublistItem.h"


@implementation SublistItem

@synthesize sublist;

- (id)init:(NSString *)newEntity sublist:(NSString *)newSublist fields:(NSDictionary *)newFields {
    self = [super init:newEntity fields:newFields];
    self.sublist = newSublist;
    return self;
}

// return NO if non updatable sublists
- (BOOL)updatable {
    if ([self.entity isEqualToString:@"Activity"] && ([self.sublist isEqualToString:@"Contact"] || [self.sublist isEqualToString:@"User"])) {
        return NO;
    }
    return YES;
}

- (NSString *)unicityKey {
    if ([self.entity isEqualToString:@"Activity"] && [self.sublist isEqualToString:@"User"]) {
        return @"UserId";
    }
    return @"Id";
}

@end
