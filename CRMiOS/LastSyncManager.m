//
//  LastSyncManager.m
//  CRMiOS
//
//  Created by Arnaud Marguerat on 9/25/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "LastSyncManager.h"

@implementation LastSyncManager

+ (void)initTable {
    Database *database = [Database getInstance];
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"entity"];
    [types addObject:@"TEXT PRIMARY KEY"];
    [columns addObject:@"syncdate"];
    [types addObject:@"TEXT"];
    [database check:@"LastSync" columns:columns types:types];
    [columns release];
    [types release];
    
}

+ (void)initData {

}

+ (void)save:(NSString *)entity date:(NSString *)date {
    Database *database = [Database getInstance];
    NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:1];
    [item setValue:date forKey:@"syncdate"];
    if ([[database select:@"LastSync" fields:[NSArray arrayWithObject:@"syncdate"] column:@"entity" value:entity order:Nil ascending:YES] count] == 0) {
        [item setValue:entity forKey:@"entity"];
        [database insert:@"LastSync" item:item];
    } else {
        [database update:@"LastSync" item:item column:@"entity" value:entity];
    }
    [item release];
}

+ (NSString *)read:(NSString *)entity {

    NSString *date = nil;
    NSArray *fields = [NSArray arrayWithObject:@"syncdate"];
    NSArray *results = [[Database getInstance] select:@"LastSync" fields:fields column:@"entity" value:entity order:Nil ascending:YES];
    if ([results count] > 0) {
        NSMutableDictionary *item = [results objectAtIndex:0];
        date = [item objectForKey:@"syncdate"];
    }
    [results release];

    return date;
}

+ (void)clear {
    [[Database getInstance] remove:@"LastSync" criterias:nil];
}

@end
