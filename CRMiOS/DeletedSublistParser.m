//
//  DeletedSublistParser.m
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/28/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "DeletedSublistParser.h"

@implementation DeletedSublistParser

@synthesize entity;
@synthesize currentItem;
@synthesize item;
@synthesize sublist;


- (id)initWithEntity:(NSString *)newEntity sublist:(NSString *)newSublist item:(SublistItem *)newItem {
    self = [super init];
    self.entity = newEntity;
    self.item = newItem;
    self.sublist = newSublist;
    self.currentItem = [[NSMutableDictionary alloc] initWithCapacity:1];
    self.lastPage = NO;
    return self;
}

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    if (level==7 && [tag isEqualToString:self.sublist]) {
        [self oneMoreItem];
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithCapacity:1];
        [tmp setObject:[item.fields objectForKey:@"gadget_id"] forKey:@"gadget_id"];
        SublistItem *tmpItem = [[SublistItem alloc] init:self.entity sublist:self.sublist fields:tmp];
        [SublistManager remove:tmpItem];
        [tmpItem release];
        [tmp release];
        [self.currentItem removeAllObjects];
    }
    if (level==8) {
        [self.currentItem setObject:value forKey:tag];
    }
}

- (void) dealloc
{
    [self.currentItem release];
    [super dealloc];
}

@end
