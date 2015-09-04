//
//  UserManager.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 11/21/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "UserManager.h"
#import "DatabaseManager.h"
#import "Reachability.h"

#import "NSObject+SBJson.h"

@implementation UserManager

static NSMutableArray *columns;

+ (NSDictionary*)list:(NSDictionary*)criterias{
    
    NSArray *records = [[DatabaseManager getInstance] select:@"User" fields:columns criterias:criterias order:nil ascending:true];
    
    
    NSMutableDictionary *listRecords = [[NSMutableDictionary alloc] initWithCapacity:1];
    for (NSDictionary *record in records) {
        Item *tmpItem = [[Item alloc] init:@"User" fields:record];
        [listRecords setObject:tmpItem forKey:[tmpItem.fields objectForKey:@"email"]];
        [tmpItem release];
    }
    
    return listRecords;
    
}


+(NSArray*) find: (NSDictionary*)criterias{
    
    
    NSArray *records = [[DatabaseManager getInstance] select:@"User" fields:columns criterias:criterias order:nil ascending:true];
    
    NSMutableArray* listFound = [[NSMutableArray alloc] init];
    for (NSDictionary *record in records) {
        [listFound addObject:[[Item alloc] init:@"User" fields:record]];
    }
    
    return listFound;
}

+ (Item *)find:(NSString *)entity column:(NSString *)column value:(NSString *)value{
    
    NSArray *results = [[DatabaseManager getInstance] select:entity fields:columns column:column value:value order:nil ascending:NO];
    
    Item *item = nil;
    if ([results count] > 0) {
        NSDictionary *itemFields = [results objectAtIndex:0];
        item = [[Item alloc] init:entity fields:itemFields];
    }
    [results release];
    
    return item;
    
}

+ (Item *)find:(NSString *)entity criterias:(NSDictionary *)criterias{
    
    NSArray *results = [[DatabaseManager getInstance] select:entity fields:columns criterias:criterias order:nil ascending:YES];
    
    Item *item = nil;
    if ([results count] > 0) {
        NSDictionary *itemFields = [results objectAtIndex:0];
        item = [[Item alloc] init:entity fields:itemFields];
    }
    [results release];
    
    return item;
    
}

+ (void)insert:(Item *)item{
    
    Item *newItem = [[Item alloc] init:@"User" fields:item.fields];
    [[DatabaseManager getInstance] insert:newItem.entity item:newItem.fields];
    [newItem release];
    
}

+ (void)update:(Item *)item{
    
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    if ([tmp objectForKey:@"local_id"] != Nil) {
        [[DatabaseManager getInstance] update:item.entity item:tmp column:@"local_id" value:[tmp objectForKey:@"local_id"]];
    } else {
        [[DatabaseManager getInstance] update:item.entity item:tmp column:@"id" value:[tmp objectForKey:@"id"]];
    }
    [tmp release];
}

+ (void)initTable{
    
    DatabaseManager *database = [DatabaseManager getInstance];
    
    columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    
    [columns addObject:@"local_id"];
    [types addObject:@"INTEGER PRIMARY KEY"];
    [columns addObject:@"id"];
    [types addObject:@"TEXT"];
    [columns addObject:@"first_name"];
    [types addObject:@"TEXT"];
    [columns addObject:@"last_name"];
    [types addObject:@"TEXT"];
    [columns addObject:@"modified"];
    [types addObject:@"TEXT"];
    [columns addObject:@"email"];
    [types addObject:@"TEXT"];
    [columns addObject:@"password"];
    [types addObject:@"TEXT"];
    [columns addObject:@"loginCount"];
    [types addObject:@"TEXT"];
    [columns addObject:@"lastLogin"];
    [types addObject:@"TEXT"];
    
    [database check:@"User" columns:columns types:types];
    [database createIndex:@"User" column:@"id" unique:true];
    
    [types release];
    
}

@end
