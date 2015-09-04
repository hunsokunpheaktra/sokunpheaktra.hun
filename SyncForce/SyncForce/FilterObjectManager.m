//
//  FilterObjectManager.m
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterObjectManager.h"
#import "DatabaseManager.h"
#import "ValuesCriteria.h"
#import "InfoFactory.h"

@implementation FilterObjectManager

+ (void)insert:(Item *)item modifiedLocally:(BOOL)modifiedLocally{
    [[DatabaseManager getInstance] insert:item.entity item:item.fields];
}
+ (void)update:(Item *)item modifiedLocally:(BOOL)modifiedLocally{
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    Item *itmp =[FilterObjectManager find:item.entity];
    if ([tmp objectForKey:@"local_id"] != Nil) {
        [[DatabaseManager getInstance] update:item.entity item:tmp column:@"local_id" value:[tmp objectForKey:@"local_id"]];
    } else {
        [[DatabaseManager getInstance] update:item.entity item:tmp column:@"value" value:[tmp objectForKey:@"value"]];
    }
    [tmp release];
    [itmp release];

}
+ (void)remove:(NSString*)entity{
    
    for(Item *item in [FilterObjectManager list:entity]){//@"FilterObject"
        [[DatabaseManager getInstance] remove:item.entity column:@"objectName" value:[item.fields valueForKey:@"objectName"]];
    }

}

+ (NSArray *)list:(NSString*)entity{
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:1];
    
    NSMutableArray *fields = [[NSMutableArray alloc] initWithCapacity:1];
    [fields addObject:@"local_id"];
    [fields addObject:@"objectName"];
    [fields addObject:@"fieldName"];
    [fields addObject:@"fieldLabel"];
    [fields addObject:@"operator"];
    [fields addObject:@"value"];
    
    NSMutableDictionary *criteria = [[NSMutableDictionary alloc] initWithCapacity:1];
    [criteria setValue:[[ValuesCriteria alloc] initWithString:entity] forKey:@"objectName"];
    
    NSArray *records = [[DatabaseManager getInstance] select:@"FilterObject" fields:fields criterias:criteria order:nil ascending:true];
    
    for (NSDictionary *record in records) {
        Item *tmpItem = [[Item alloc] init:@"FilterObject" fields:record];
        [list addObject:tmpItem];
        [tmpItem release];
    }
    
    return list;
   

}
+ (Item *)find:(NSString *)entity{
    Item *item = nil;
    NSMutableArray *fields = [[NSMutableArray alloc] initWithArray:[[InfoFactory getInfo:entity] getAllFields]];
    [fields addObject:@"local_id"];
    [fields addObject:@"objectName"];
    [fields addObject:@"fieldName"];
    [fields addObject:@"fieldLabel"];
    [fields addObject:@"operator"];
    [fields addObject:@"value"];
    NSArray *items = [[DatabaseManager getInstance] select:@"FilterObject" fields:fields criterias:nil order:Nil ascending:YES];
    if ([items count] > 0) {
        NSDictionary *itemFields = [items objectAtIndex:0];
        item = [[Item alloc] init:entity fields:itemFields];
    }
    [items release];
    [fields release];
    return item;

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
    [columns addObject:@"fieldName"];
    [types addObject:@"TEXT"];
    [columns addObject:@"fieldLabel"];
    [types addObject:@"TEXT"];
    [columns addObject:@"type"];
    [types addObject:@"TEXT"];
    [columns addObject:@"operator"];
    [types addObject:@"TEXT"];
    [columns addObject:@"value"];
    [types addObject:@"TEXT"];
    [database check:@"FilterObject" columns:columns types:types];
    [columns release];
    [types release];
    //[database createIndex:@"FilterObject" columns:[NSArray arrayWithObject:@"FilterObject"] unique:true];
}

@end
