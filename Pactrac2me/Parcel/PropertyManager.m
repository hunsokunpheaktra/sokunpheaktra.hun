//
//  PropertyManager.m
//  Pactrac2me
//
//  Created by Hun Sokunpheaktra on 4/8/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "PropertyManager.h"
#import "DatabaseManager.h"

@implementation PropertyManager

+ (void)save:(NSString *)property value:(NSString *)value {
    DatabaseManager *database = [DatabaseManager getInstance];
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
    NSString *value = nil;
    NSArray *fields = [NSArray arrayWithObject:@"value"];
    NSArray *results = [[DatabaseManager getInstance] select:@"Property" fields:fields column:@"property" value:property order:Nil ascending:YES];
    if ([results count] > 0) {
        NSMutableDictionary *item = [results objectAtIndex:0];
        value = [item objectForKey:@"value"];
    }
    [results release];
    return value;
}


+ (void)initTable {
    DatabaseManager *database = [DatabaseManager getInstance];
    
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
+ (void)initDatas{
    //save last sync user
    if ([PropertyManager read:@"LastSyncUser"]==nil) {
        [PropertyManager save:@"LastSyncUser" value:@""];
    }
}

@end
