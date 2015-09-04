//
//  PicklistInfoManager.m
//  SyncForce
//
//  Created by Gaeasys Admin on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PicklistInfoManager.h"
#import "DatabaseManager.h"

@implementation PicklistInfoManager


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
        [columns addObject:@"fieldname"];
        [types addObject:@"TEXT"];
        [columns addObject:@"fieldlabel"];
        [types addObject:@"TEXT"];
        [columns addObject:@"value"];
        [types addObject:@"TEXT"];
        [columns addObject:@"label"];
        [types addObject:@"TEXT"];
        [columns addObject:@"fieldorder"];
        [types addObject:@"INTEGER"];
        [columns addObject:@"active"];
        [types addObject:@"TEXT"];
        [columns addObject:@"defaultValue"];
        [types addObject:@"TEXT"];
        [columns addObject:@"validFor"];
        [types addObject:@"TEXT"];
        [columns addObject:@"dependentPicklist"];
        [types addObject:@"TEXT"];
        [columns addObject:@"controllerName"];
        [types addObject:@"TEXT"];
    }
}

+ (void)initTable {
    DatabaseManager *database = [DatabaseManager getInstance];
    [self initColumns];
    [database check:PICKLISTINFO_ENTITY columns:columns types:types];
    [database createIndex:PICKLISTINFO_ENTITY column:@"local_id" unique:true];
}

+ (void)insert:(Item *)item{
    NSMutableDictionary *fieldsIn = [item fields];
    for(NSString *field in [fieldsIn allKeys]){
        if([columns containsObject:field]) continue;
        [fieldsIn removeObjectForKey:field];
    }
    [[DatabaseManager getInstance] insert:PICKLISTINFO_ENTITY item:fieldsIn];
    [fieldsIn release];
}

+ (Item *)find:(NSDictionary *)criterias {
    Item *item = nil;
    NSArray *items = [[DatabaseManager getInstance] select:PICKLISTINFO_ENTITY fields:columns criterias:criterias order:Nil ascending:YES];
    if ([items count] > 0) {
        NSDictionary *itemFields = [items objectAtIndex:0];
        item = [[Item alloc] init:PICKLISTINFO_ENTITY fields:itemFields];
    }
    [items release];
    return item;
}

+ (NSArray *)list:(NSDictionary *)criterias {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *records = [[DatabaseManager getInstance] select:PICKLISTINFO_ENTITY fields:columns criterias:criterias order:nil ascending:true];
    for (NSDictionary *record in records) {
        Item *tmpItem = [[Item alloc] init:PICKLISTINFO_ENTITY fields:record];
        [list addObject:tmpItem];
        [tmpItem release];
    }
    [records release];
    return list;
}

@end
