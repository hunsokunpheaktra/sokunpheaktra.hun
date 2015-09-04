//
//  CascadingPicklistManager.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/30/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "CascadingPicklistManager.h"

@implementation CascadingPicklistManager

+ (void)initTable {
    
    Database *database = [Database getInstance];
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"ObjectName"];
    [types addObject:@"TEXT"];
    [columns addObject:@"ParentPicklist"];
    [types addObject:@"TEXT"];
    [columns addObject:@"RelatedPicklist"];
    [types addObject:@"TEXT"];
    [columns addObject:@"ParentValue"];
    [types addObject:@"TEXT"];
    [columns addObject:@"RelatedValue"];
    [types addObject:@"TEXT"];
    [database check:@"Cascading" columns:columns types:types];
    
    NSMutableArray *indexColumns;
    // unicity 
    indexColumns = [NSMutableArray arrayWithObjects:@"ObjectName", @"ParentPicklist", @"RelatedPicklist", @"ParentValue",@"RelatedValue", Nil];
    [database createIndex:@"Cascading" columns:indexColumns unique:true];

    // name index
    indexColumns = [NSMutableArray arrayWithObjects:@"ObjectName", @"ParentPicklist",@"RelatedPicklist", Nil];
    [database createIndex:@"Cascading" columns:indexColumns unique:false];
    
}

+ (void)initData {

    
}

+ (void)insert:(NSDictionary *)picklist {
    NSLog(@"Save cascading!");
    Database *database = [Database getInstance];
    [database insert:@"cascading" item:picklist];
}

+ (void)purge {
    Database *database = [Database getInstance];
    [database remove:@"Cascading" criterias:nil];
}


+ (NSDictionary *)getChildren:(NSString *)entity field:(NSString *)field value:(NSString *)value {
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:3];
    field = [field stringByReplacingOccurrencesOfString:@"CustomPickList" withString:@"ZPick_"];
    field = [PicklistManager fixCode:field entity:entity];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"ObjectName" value:entity]];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"ParentPicklist" value:field]];
    if (value != nil && [value length] > 0) {
        [criterias addObject:[ValuesCriteria criteriaWithColumn:@"ParentValue" value:value]];
    }
    Database *database = [Database getInstance];
    NSArray *cascading = [database select:@"Cascading" fields:[NSArray arrayWithObjects:@"RelatedPicklist", @"RelatedValue", nil] criterias:criterias order:nil ascending:YES];
    [criterias release];  
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:1];
    for (NSDictionary *casc in cascading) {
        NSString *related = [casc objectForKey:@"RelatedPicklist"];
        related = [related stringByReplacingOccurrencesOfString:@"ZPick_" withString:@"CustomPickList"];
        NSMutableArray *values = [dict objectForKey:related];
        if (values == nil) {
            values = [[NSMutableArray alloc] initWithCapacity:1];
            [dict setValue:values forKey:related];
        }
        if (value != nil && [value length] > 0) {
            [values addObject:[casc objectForKey:@"RelatedValue"]];
        }
    }
    [cascading release];
    return dict;
}

+ (NSArray *)readAllowedValues:(NSString *)field item:(Item *)item {
    NSMutableArray *results = nil; // nil = allow all values
    if (item != nil) {
        NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:3];
        field = [field stringByReplacingOccurrencesOfString:@"CustomPickList" withString:@"ZPick_"];
        [criterias addObject:[ValuesCriteria criteriaWithColumn:@"ObjectName" value:item.entity]];
        [criterias addObject:[ValuesCriteria criteriaWithColumn:@"RelatedPicklist" value:field]];
        Database *database = [Database getInstance];
        NSArray *cascading = [database select:@"Cascading" fields:[NSArray arrayWithObjects:@"ParentPicklist", @"ParentValue", @"RelatedValue", nil] criterias:criterias order:nil ascending:YES];
        [criterias release];     
        if ([cascading count] > 0) {
            results = [[NSMutableArray alloc] initWithCapacity:1];
            NSString *parentField = [[cascading objectAtIndex:0] objectForKey:@"ParentPicklist"];
            parentField = [parentField stringByReplacingOccurrencesOfString:@"ZPick_" withString:@"CustomPickList"];
            NSString *parentValue = nil;
            NSString *displayValue = nil;
            // trick for handling bugged field names, we call the fixCode method
            for (NSString *code in item.fields) {
                NSString *fixedCode = [PicklistManager fixCode:code entity:item.entity];
                if ([parentField isEqualToString:fixedCode] || [parentField isEqualToString:code]) {
                    parentValue = [item.fields objectForKey:code];
                    displayValue = [PicklistManager getPicklistDisplay:item.entity field:parentField value:parentValue];
                    break;
                }
            }
            if (parentValue != nil) {
                for (NSDictionary *casc in cascading) {
                    if ([[casc objectForKey:@"ParentValue"] isEqualToString:displayValue]) {
                        [results addObject:[casc objectForKey:@"RelatedValue"]];
                    }
                }
            }
            // no results : all is allowed.
            if ([results count] == 0) {
                return nil;
            }
        } else {
            return nil;
        }
        [cascading release];
    }

    return results; 
}

@end
