//
//  DetailLayoutSectionsInfoManager.m
//  SyncForce
//
//  Created by Gaeasys Admin on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailLayoutSectionsInfoManager.h"

@implementation DetailLayoutSectionsInfoManager
static NSMutableArray *columns;
static NSMutableArray *types;

+ (void)initColumns{
    if(columns == nil){
        columns = [[NSMutableArray alloc] initWithCapacity:1];
        types = [[NSMutableArray alloc] initWithCapacity:1];
        [columns addObject:@"local_id"];
        [types addObject:@"INTEGER PRIMARY KEY"];
        [columns addObject:@"entity"];
        [types addObject:@"TEXT"];
        [columns addObject:@"Id"];
        [types addObject:@"TEXT"];
        [columns addObject:@"useCollapsibleSection"];
        [types addObject:@"TEXT"];
        [columns addObject:@"useHeading"];
        [types addObject:@"TEXT"];
        [columns addObject:@"heading"];
        [types addObject:@"TEXT"];
        [columns addObject:@"columns"];
        [types addObject:@"TEXT"];
        [columns addObject:@"rows"];
        [types addObject:@"TEXT"];
        [columns addObject:@"numItems"];
        [types addObject:@"TEXT"];
        [columns addObject:@"editable"];
        [types addObject:@"TEXT"];
        [columns addObject:@"placeholder"];
        [types addObject:@"TEXT"];
        [columns addObject:@"required"];
        [types addObject:@"TEXT"];
        [columns addObject:@"label"];
        [types addObject:@"TEXT"];
        [columns addObject:@"type"];
        [types addObject:@"TEXT"];
        [columns addObject:@"value"];
        [types addObject:@"TEXT"];
        [columns addObject:@"tabOrder"];
        [types addObject:@"INTEGER"];
        [columns addObject:@"displayLines"];
        [types addObject:@"TEXT"];
    }
}

+ (void)initTable {
    DatabaseManager *database = [DatabaseManager getInstance];
    [self initColumns];
    [database check:DETAILLAYOUTSECTIONSINFO_ENTITY columns:columns types:types];
    [database createIndex:DETAILLAYOUTSECTIONSINFO_ENTITY column:@"local_id" unique:true];
    [database createIndex:DETAILLAYOUTSECTIONSINFO_ENTITY columns:[NSArray arrayWithObjects:@"entity",@"Id", nil] unique:false];
}

+ (void)insert:(Item *)item{
    NSMutableDictionary *fieldsIn = [item fields];
    for(NSString *field in [fieldsIn allKeys]){
        if([columns containsObject:field]) continue;
        [fieldsIn removeObjectForKey:field];
    }
    [[DatabaseManager getInstance] insert:DETAILLAYOUTSECTIONSINFO_ENTITY item:fieldsIn];
    [fieldsIn release];
}

+ (void)update:(Item *)item{
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    [[DatabaseManager getInstance] update:item.entity item:tmp column:@"local_id" value:[item.fields valueForKey:@"local_id"]];
}

+ (Item *)find:(NSDictionary *)criterias {
    Item *item = nil;
    NSArray *items = [[DatabaseManager getInstance] select:DETAILLAYOUTSECTIONSINFO_ENTITY fields:columns criterias:criterias order:Nil ascending:YES];
    if ([items count] > 0) {
        NSDictionary *itemFields = [items objectAtIndex:0];
        item = [[Item alloc] init:DETAILLAYOUTSECTIONSINFO_ENTITY fields:itemFields];
    }
    [items release];
    return item;
}

+ (NSArray *)list:(NSDictionary *)criterias {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *records = [[DatabaseManager getInstance] select:DETAILLAYOUTSECTIONSINFO_ENTITY fields:columns criterias:criterias order:@"tabOrder" ascending:true];
    for (NSDictionary *record in records) { 
        Item *tmpItem = [[Item alloc] init:DETAILLAYOUTSECTIONSINFO_ENTITY fields:record];
        [list addObject:tmpItem];
        [tmpItem release];
    }
    [records release];
    return list;
}

@end