//
//  SettingManager.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 10/29/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "SettingManager.h"
#import "DatabaseManager.h"

static NSMutableArray *columns;

@implementation SettingManager

+ (void)insert:(Item *)item{
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    [[DatabaseManager getInstance] insert:item.entity item:tmp];
    [tmp release];
}
+ (void)update:(Item *)item{
    
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    if ([tmp objectForKey:@"local_id"] != nil) {
        [[DatabaseManager getInstance] update:item.entity item:tmp column:@"local_id" value:[tmp objectForKey:@"local_id"]];
    }
    [tmp release];
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
    
    NSArray *results = [[DatabaseManager getInstance] select:entity fields:columns column:@"local_id" value:@"1" order:nil ascending:NO];
    
    Item *item = nil;
    if ([results count] > 0) {
        NSDictionary *itemFields = [results objectAtIndex:0];
        item = [[Item alloc] init:entity fields:itemFields];
    }
    
    [results release];
    
    return item;
}

+ (int)getCount{
    int count = [[[DatabaseManager getInstance] select:@"Setting" fields:[NSArray arrayWithObject:@"local_id"] criterias:nil order:nil ascending:YES ] count];
    return count;
}

+ (void)initTable{
    
    DatabaseManager *database = [DatabaseManager getInstance];
    
    columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    
    [columns addObject:@"local_id"];
    [types addObject:@"INTEGER PRIMARY KEY"];
    [columns addObject:@"language"];
    [types addObject:@"TEXT"];
    [columns addObject:@"lastInstallDate"];
    [types addObject:@"TEXT"];
    [columns addObject:@"isPurchase"];
    [types addObject:@"TEXT"];
    [columns addObject:@"pushService"];
    [types addObject:@"TEXT"];
    [columns addObject:@"wlanSync"];
    [types addObject:@"TEXT"];
    [columns addObject:@"cloudSync"];
    [types addObject:@"TEXT"];
    [columns addObject:@"isLocalStorage"];
    [types addObject:@"TEXT"];
    [columns addObject:@"isManual"];
    [types addObject:@"TEXT"];
    [columns addObject:@"defaultReminderSetting"];
    [types addObject:@"TEXT"];
    [columns addObject:@"updateAtStart"];
    [types addObject:@"TEXT"];
    [columns addObject:@"user_email"];
    [types addObject:@"TEXT"];
    
    [database check:@"Setting" columns:columns types:types];
    [database createIndex:@"Setting" column:@"local_id" unique:true];
    
    [types release];
    
}

+ (Item*)newSettingItem{
    
    NSMutableArray *allFields = [NSMutableArray arrayWithArray:columns];
    [allFields removeObjectAtIndex:0];
    
    NSArray *allValues = [NSArray arrayWithObjects:@"English",@"",@"no",@"",@"no",@"no",@"no",@"no",@"1 WEEKS",@"yes",@"", nil];
    
    NSMutableDictionary *fields = [NSMutableDictionary dictionaryWithObjects:allValues forKeys:allFields];
    return [[Item alloc] init:@"Setting" fields:fields];
    
}

@end
