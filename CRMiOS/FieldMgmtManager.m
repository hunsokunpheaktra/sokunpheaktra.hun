//
//  FieldMgmtManager.m
//  CRMiOS
//
//  Created by Arnaud on 1/11/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "FieldMgmtManager.h"

@implementation FieldMgmtManager

+ (void)initTable {
    Database *database = [Database getInstance];
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"ObjectName"];
    [types addObject:@"TEXT"];
    [columns addObject:@"GenericIntegrationTag"];
    [types addObject:@"TEXT"];
    [columns addObject:@"DefaultValue"];
    [types addObject:@"TEXT"];
    
    [database check:@"FieldMgmt" columns:columns types:types];
    [columns release];
    [types release];
    
    // name index
    NSArray *indexColumns = [NSMutableArray arrayWithObjects:@"ObjectName", @"GenericIntegrationTag", nil];
    [database createIndex:@"FieldMgmt" columns:indexColumns unique:true];
    
}

+ (void)initData {
}

+ (void)insert:(NSDictionary *)values {
    Database *database = [Database getInstance];
    [database insert:@"FieldMgmt" item:values];
}

+ (void)purge {
    Database *database = [Database getInstance];
    [database remove:@"FieldMgmt" criterias:nil];
}

+ (BOOL)isFormula:(NSString *)entity field:(NSString *)field {
    Database *database = [Database getInstance];
    NSArray *criterias = [NSArray arrayWithObjects:
        [ValuesCriteria criteriaWithColumn:@"ObjectName" value:entity],
        [ValuesCriteria criteriaWithColumn:@"GenericIntegrationTag" value:field], nil];
            
    NSArray *items = [database select:@"FieldMgmt" fields:[NSArray arrayWithObject:@"DefaultValue"] criterias:criterias order:nil ascending:YES];
    BOOL ret = NO;
    if ([items count] > 0) {
        NSDictionary *item = [items objectAtIndex:0];
        if ([[item objectForKey:@"DefaultValue"] length] > 0) {
            ret = YES;
        }
    }
    [items release];
    return ret;
    
}

+ (NSArray *)list:(NSString *)entity {
    Database *database = [Database getInstance];
    return [database select:@"FieldMgmt" fields:[NSArray arrayWithObjects:@"GenericIntegrationTag", @"DefaultValue", nil] column:@"ObjectName" value:entity order:nil ascending:YES];
}

@end
