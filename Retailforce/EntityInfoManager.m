//
//  EntityInfoManager.m
//  SalesforceSyncModule
//
//  Created by Gaeasys Admin on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntityInfoManager.h"


@implementation EntityInfoManager


static NSMutableArray *columns;
static NSMutableArray *types;

+ (void)initColumns{
    if(columns == nil){
        columns = [[NSMutableArray alloc] initWithCapacity:1];
        types = [[NSMutableArray alloc] initWithCapacity:1];
        [columns addObject:@"local_id"];
        [types addObject:@"INTEGER PRIMARY KEY"];
        [columns addObject:@"name"];
        [types addObject:@"TEXT"];
        [columns addObject:@"label"];
        [types addObject:@"TEXT"];
        [columns addObject:@"labelPlural"];
        [types addObject:@"TEXT"];
        [columns addObject:@"deletable"];
        [types addObject:@"TEXT"];
        [columns addObject:@"createable"];
        [types addObject:@"TEXT"];
        [columns addObject:@"custom"];
        [types addObject:@"TEXT"];
        [columns addObject:@"updateable"]; 
        [types addObject:@"TEXT"];
        [columns addObject:@"keyPrefix"];
        [types addObject:@"TEXT"];
        [columns addObject:@"searchable"];
        [types addObject:@"TEXT"];
        [columns addObject:@"queryable"];
        [types addObject:@"TEXT"];
        [columns addObject:@"retrieveable"];
        [types addObject:@"TEXT"];
        [columns addObject:@"undeletable"];
        [types addObject:@"TEXT"];
        [columns addObject:@"triggerable"];
        [types addObject:@"TEXT"];
    }
}

+ (void)initTable {
    DatabaseManager *database = [DatabaseManager getInstance];
    [self initColumns];
    [database check:ENTITYINFO_ENTITY columns:columns types:types];
    [database createIndex:ENTITYINFO_ENTITY column:@"local_id" unique:true];
    [database createIndex:ENTITYINFO_ENTITY column:@"name" unique:true];
}

+ (void)insert:(Item *)item{
    NSMutableDictionary *fieldsIn = [item fields];
    for(NSString *field in [fieldsIn allKeys]){
        if([columns containsObject:field]) continue;
        [fieldsIn removeObjectForKey:field];
    }
    [[DatabaseManager getInstance] insert:ENTITYINFO_ENTITY item:fieldsIn];
    [fieldsIn release];
}

+ (Item *)find:(NSDictionary *)criterias {
    Item *item = nil;
    NSArray *items = [[DatabaseManager getInstance] select:ENTITYINFO_ENTITY fields:columns criterias:criterias order:Nil ascending:YES];
    if ([items count] > 0) {
        NSDictionary *itemFields = [items objectAtIndex:0];
        item = [[Item alloc] init:ENTITYINFO_ENTITY fields:itemFields];
    }
    [items release];
    return item;
}

+ (NSArray *)list:(NSDictionary *)criterias {
    
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *records = [[DatabaseManager getInstance] select:ENTITYINFO_ENTITY fields:columns criterias:criterias order:nil ascending:true];
    for (NSDictionary *record in records) {
        Item *tmpItem = [[Item alloc] init:ENTITYINFO_ENTITY fields:record];
        [list addObject:tmpItem];
        [tmpItem release];
    }
    [records release];
    return list;
}

@end
