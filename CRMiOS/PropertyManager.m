//
//  PropertyManager.m
//  CRMiPad
//
//  Created by Sy Pauv Phou on 4/7/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "PropertyManager.h"

// cache for property
static NSMutableDictionary *cache;

@implementation PropertyManager

+ (void)save:(NSString *)property value:(NSString *)value {
    
    if ([cache objectForKey:property]!=nil) {
        [cache removeObjectForKey:property];
    }
    Database *database = [Database getInstance];
    NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:1];
    [item setValue:value forKey:@"value"];
    if ([[database select:@"Property" fields:[NSArray arrayWithObject:@"property"] column:@"property" value:property order:Nil ascending:YES] count] == 0) {
        [item setValue:property forKey:@"property"];
        [database insert:@"Property" item:item];
    } else {
        [database update:@"Property" item:item column:@"property" value:property];
    }
    [item release];
}

+ (NSString *)read:(NSString *)property {
    //if cache not yet created
    if (cache == nil) {
        cache = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    // is the value in the cache ?
    if ([cache objectForKey:property]!=nil) {
        return [cache objectForKey:property];
    }
    NSString *value = nil;
    NSArray *fields = [NSArray arrayWithObject:@"value"];
    NSArray *results = [[Database getInstance] select:@"Property" fields:fields column:@"property" value:property order:Nil ascending:YES];
    if ([results count] > 0) {
        NSMutableDictionary *item = [results objectAtIndex:0];
        value = [item objectForKey:@"value"];
    }
    [results release];
    //insert cache
    if ([cache objectForKey:property]==nil && value!=nil) {
        [cache setObject:value forKey:property];
    }
    return value;
}


+ (void)initTable {
    Database *database = [Database getInstance];
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"property"];
    [types addObject:@"TEXT PRIMARY KEY"];
    [columns addObject:@"value"];
    [types addObject:@"TEXT"];
    [database check:@"Property" columns:columns types:types];
    [columns release];
    [types release];
    [database createIndex:@"Property" columns:[NSArray arrayWithObject:@"property"] unique:true];

}

+ (void)initData {
    cache = [[NSMutableDictionary alloc] initWithCapacity:1];
    if ([PropertyManager read:@"URL"] == Nil) {
        [PropertyManager save:@"URL" value:@"https://secure-ausomxdsa.crmondemand.com"];
        [PropertyManager save:@"Login" value:@""];
        [PropertyManager save:@"Password" value:@""];
    }
    for (NSString *entity in [Configuration getEntities]) {
        if ([PropertyManager read:[NSString stringWithFormat:@"sync%@", entity]]==nil) {
            [PropertyManager save:[NSString stringWithFormat:@"sync%@", entity] value:@"true"];
        }
        if ([PropertyManager read:[NSString stringWithFormat:@"ownerFilter%@", entity]]==nil) {
            [PropertyManager save:[NSString stringWithFormat:@"ownerFilter%@", entity] value:@"Personal"];
        }
        if ([PropertyManager read:[NSString stringWithFormat:@"dateFilter%@", entity]]==nil) {
            [PropertyManager save:[NSString stringWithFormat:@"dateFilter%@", entity] value:@"All"];
        }
    }
    //save metadata change
    if ([PropertyManager read:@"LOVLastUpdated"]==nil) {
        [PropertyManager save:@"LOVLastUpdated" value:@""];
    }
    if ([PropertyManager read:@"syncPicklist"]==nil) {
        [PropertyManager save:@"syncPicklist" value:@"YES"];
    }
    
    //Start up sync
    if ([PropertyManager read:@"SyncAtStartup"]==nil) {
        [PropertyManager save:@"SyncAtStartup" value:@"0"];
    }
    
    //check full sync

    if([PropertyManager read:@"xmlName"]==nil){
        [PropertyManager save:@"xmlName" value:@"ipad"];
    }
    
    //Pharma Enable
    
    if([PropertyManager read:@"PharmaEnabled"]==nil){
        [PropertyManager save:@"PharmaEnabled" value:@"0"];
    }

    // Contact sort
    if([PropertyManager read:@"SortingContact"]==nil) {
        [PropertyManager save:@"SortingContact" value:@"LastName"];
    }
}

/*
** convert SyncAtStartup String to DateTime
** created date 21/05/2013
*/
+ (NSTimeInterval)getAutoSyncTime{

    
    NSString *autoSync = [self read:@"SyncAtStartup"];
    NSTimeInterval timeInterval = [autoSync intValue] * 60;
    return timeInterval;
    
}

@end
