//
//  KeyFieldInfoManager.m
//  SyncForce
//
//  Created by Gaeasys on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KeyFieldInfoManager.h"
#import "DatabaseManager.h"
#import "ValuesCriteria.h"
#import "InfoFactory.h"

@implementation KeyFieldInfoManager

static NSMutableArray *cols;

+ (void)insert:(Item *)item{
    [[DatabaseManager getInstance] insert:item.entity item:item.fields];
}

+ (void)remove:(NSString*)entity{
    
    NSMutableDictionary *localCriteria = [[NSMutableDictionary alloc] init];
    [localCriteria setValue:[[[ValuesCriteria alloc] initWithString:entity] autorelease] forKey:@"objectName"];
    
    for(Item *item in [KeyFieldInfoManager list:localCriteria]){
        [[DatabaseManager getInstance] remove:item.entity column:@"objectName" value:[item.fields valueForKey:@"objectName"]];
    }
    
}

+ (Item *)find:(NSDictionary *)criterias {
    Item *item = nil;
    NSArray *items = [[DatabaseManager getInstance] select:@"KeyFields" fields:cols criterias:criterias order:Nil ascending:YES];
    if ([items count] > 0) {
        NSDictionary *itemFields = [items objectAtIndex:0];
        item = [[Item alloc] init:@"KeyFields" fields:itemFields];
    }
    [items release];
    return item;
}

+ (NSArray *)list:(NSDictionary *)criterias {
    
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *records = [[DatabaseManager getInstance] select:@"KeyFields" fields:cols criterias:criterias order:nil ascending:true];
    
    for (NSDictionary *record in records) {
        Item *tmpItem = [[Item alloc] init:@"KeyFields" fields:record];
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
    [cols addObject:@"fieldType"];
    [types addObject:@"TEXT"];
    [database check:@"KeyFields" columns:cols types:types];
    [types release];
  //  [database createIndex:@"KeyFields" columns:[NSArray arrayWithObject:@"KeyFields"] unique:true];
}


@end

