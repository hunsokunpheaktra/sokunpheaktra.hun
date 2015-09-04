//
//  FilterManager.m
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EntityManager.h"
#import "FilterManager.h"

@implementation FilterManager

+ (void)insert:(Item *)item modifiedLocally:(BOOL)modifiedLocally{
    
    [[DatabaseManager getInstance] insert:item.entity item:item.fields];
    
}
+ (void)update:(Item *)item modifiedLocally:(BOOL)modifiedLocally{
    
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    if ([tmp valueForKey:@"local_id"] != Nil) {
        [[DatabaseManager getInstance] update:item.entity item:tmp column:@"local_id" value:[tmp objectForKey:@"local_id"]];
    } else {
        [[DatabaseManager getInstance] update:item.entity item:tmp column:@"value" value:[tmp objectForKey:@"value"]];
    }
    [tmp release];
    
}

+ (Item *)find:(NSString *)entity{
    Item *item = nil;
    NSMutableDictionary *criteria = [[NSMutableDictionary alloc] initWithCapacity:1];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:entity] autorelease] forKey:@"objectName"];
    NSMutableArray *fields = [[NSMutableArray alloc] initWithCapacity:1];
    [fields addObject:@"local_id"];
    [fields addObject:@"objectName"];
    [fields addObject:@"label"];
    [fields addObject:@"value"];
    [fields addObject:@"lastSyn"];
    NSArray *items = [[DatabaseManager getInstance] select:@"Filter" fields:fields criterias:criteria order:Nil ascending:YES];
    if ([items count] > 0) {
        NSDictionary *itemFields = [items objectAtIndex:0];
        item = [[Item alloc] init:@"Filter" fields:itemFields];
    }
    [items release];
    [fields release];
    return item;
}

+ (void)remove:(Item *)item{
    
}

+ (NSArray *)list:(NSMutableDictionary*)criteria{
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:1];
    
    NSMutableArray *fields = [[NSMutableArray alloc] initWithCapacity:1];
    [fields addObject:@"local_id"];
    [fields addObject:@"objectName"];
    [fields addObject:@"label"];
    [fields addObject:@"value"];
    [fields addObject:@"lastSyn"];
    
    NSArray *records = [[DatabaseManager getInstance] select:@"Filter" fields:fields criterias:criteria order:nil ascending:true];
    
    for (NSDictionary *record in records) {
        Item *tmpItem = [[Item alloc] init:@"Filter" fields:record];
        [list addObject:tmpItem];
        [tmpItem release];
    }
    
    [fields release];  // Latest Release
    [records release]; // Latest Release
    
    return list;
    
}

+ (void)initData{
    
}
+ (void)initTable{
    
    DatabaseManager *database = [DatabaseManager getInstance];
    
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"local_id"];
    [types addObject:@"TEXT PRIMARY KEY"];
    [columns addObject:@"objectName"];
    [types addObject:@"TEXT"];
    [columns addObject:@"label"];
    [types addObject:@"TEXT"];
    [columns addObject:@"value"];
    [types addObject:@"TEXT"];
    [columns addObject:@"lastSyn"];
    [types addObject:@"TEXT"];
    [database check:@"Filter" columns:columns types:types];
    [columns release];
    [types release];
    //[database createIndex:@"Filter" columns:[NSArray arrayWithObject:@"Filter"] unique:true];
    
}

@end
