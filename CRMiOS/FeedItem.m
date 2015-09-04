//
//  FeedItem.m
//  CRMiOS
//
//  Created by Sy Pauv on 11/23/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "FeedItem.h"


@implementation FeedItem

@synthesize data, istmpItem;

-(id)init {
    self = [super init];
    self.istmpItem = [NSNumber numberWithBool:NO];
    self.data = [[NSMutableDictionary alloc] initWithCapacity:1];
    return self;
}

- (NSString *)getComment {
    return [self.data objectForKey:@"comment"];
}

- (NSString *)getUserId {
    return [self.data objectForKey:@"userid"];
}

- (NSString *)getParentId {
    return [self.data objectForKey:@"parentid"];
}

- (NSString *)getFullName {
    
    NSString *name = [self.data objectForKey:@"fullname"];
    if (name == nil || [[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        name = @"No Name";
    }
    return name;//;[self.data objectForKey:@"fullname"];
}

- (NSString *)getEntity {
    return [self.data objectForKey:@"entity"];
}

- (NSString *)getRecordId {
    return [self.data objectForKey:@"recordid"];
}

- (NSString *)getRecordName {
    return [self.data objectForKey:@"recordname"];
}

- (NSString *)getId {
    return [self.data objectForKey:@"gid"];
}


- (NSArray *)getChild {
    NSMutableArray *tmplistChild = [[NSMutableArray alloc]initWithCapacity:1];
    if ([[self getParentId] isEqualToString:@""]) {
        for (FeedItem *item in [FeedManager getFeed]) {
            if ([[item getParentId] isEqualToString:[self getId]]) {
                [tmplistChild addObject:item];
            }
        }
    }
    return tmplistChild;
}

- (NSDate *)getCreatedDate {
    NSString *stringdate = [self.data objectForKey:@"createddate"];
    if ([stringdate length] > 10) {
        stringdate = [stringdate substringWithRange:NSMakeRange(0,10)];
    }
    return [NSDate dateWithTimeIntervalSince1970:[stringdate intValue]];
}

- (NSString *)getCreatedDateFormatted {
    //convert timestamp to data
    NSDate *date = [self getCreatedDate];
    NSDateFormatter *datetimeFormat = [[NSDateFormatter alloc] init];
    [datetimeFormat setDateStyle:NSDateFormatterMediumStyle];
    [datetimeFormat setTimeStyle:NSDateFormatterMediumStyle];
    NSString *formatedDate = [datetimeFormat stringFromDate:date];
    [datetimeFormat release];
    return formatedDate;
    
} 

@end