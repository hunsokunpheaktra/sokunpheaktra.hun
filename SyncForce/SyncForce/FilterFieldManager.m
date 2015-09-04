//
//  FilterFieldManager.m
//  SyncForce
//
//  Created by Gaeasys on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FilterFieldManager.h"
#import "DatabaseManager.h"
#import "ValuesCriteria.h"
#import "InfoFactory.h"


@implementation FilterFieldManager

static NSMutableArray *cols;

+ (void)insert:(Item *)item{
    [[DatabaseManager getInstance] insert:item.entity item:item.fields];
}

+ (void)remove:(NSString*)entity{
    
    NSMutableDictionary *localCriteria = [[NSMutableDictionary alloc] init];
    [localCriteria setValue:[[[ValuesCriteria alloc] initWithString:entity] autorelease] forKey:@"objectName"];
    
    for(Item *item in [FilterFieldManager list:localCriteria]){
        [[DatabaseManager getInstance] remove:item.entity column:@"objectName" value:[item.fields valueForKey:@"objectName"]];
    }
    
}

+ (Item *)find:(NSDictionary *)criterias {
    Item *item = nil;
    NSArray *items = [[DatabaseManager getInstance] select:@"FilterField" fields:cols criterias:criterias order:Nil ascending:YES];
    if ([items count] > 0) {
        NSDictionary *itemFields = [items objectAtIndex:0];
        item = [[Item alloc] init:@"FilterField" fields:itemFields];
    }
    [items release];
    return item;
}

+ (NSArray *)list:(NSDictionary *)criterias {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *records = [[DatabaseManager getInstance] select:@"FilterField" fields:cols criterias:criterias order:nil ascending:true];
    for (NSDictionary *record in records) {
        Item *tmpItem = [[Item alloc] init:@"FilterField" fields:record];
        [list addObject:tmpItem];
        [tmpItem release];
    }
    [records release];
    return list;
}


+ (void)initData{
    
}
+ (void)initTable{
    DatabaseManager *database = [DatabaseManager getInstance];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    cols = [[NSMutableArray alloc] initWithCapacity:1];
    
    [cols addObject:@"objectName"];
    [types addObject:@"TEXT"];
    [cols addObject:@"fieldName"];
    [types addObject:@"TEXT"];
    [cols addObject:@"fieldLabel"];
    [types addObject:@"TEXT"];
    [database check:@"FilterField" columns:cols types:types];
    [types release];
   // [database createIndex:@"FilterField" columns:[NSArray arrayWithObject:@"FilterField"] unique:true];
}


@end
