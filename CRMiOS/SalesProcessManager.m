//
//  SalesProcessManager.m
//  CRMiOS
//
//  Created by Arnaud on 12/20/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "SalesProcessManager.h"

@implementation SalesProcessManager


+ (void)initTable {
    Database *database = [Database getInstance];
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"Id"];
    [types addObject:@"TEXT"];
    [columns addObject: @"OpportunityType"];
    [types addObject: @"TEXT"];
    
    
    [database check:@"SalesProcess" columns:columns types:types];
    // name index
    NSMutableArray *indexColumns;
    indexColumns = [NSMutableArray arrayWithObjects:@"Id", @"OpportunityType", Nil];
    [database createIndex:@"SalesProcess" columns:indexColumns unique:true];
    
}

+ (void)initData{
}

+ (void)insert:(NSDictionary *)newSalesProcess {
    Database *database = [Database getInstance];
    [database insert:@"SalesProcess" item:newSalesProcess];
}

+ (void)purge {
    Database *database = [Database getInstance];
    [database remove:@"SalesProcess" criterias:nil];
}

+ (NSString *)read:(NSString *)type {
    NSArray *fields = [NSArray arrayWithObjects:@"Id", @"OpportunityType", nil];
    NSArray *criterias = [NSArray arrayWithObject:[ValuesCriteria criteriaWithColumn:@"OpportunityType" value:type]];
    NSArray *result = [[Database getInstance] select:@"SalesProcess" fields:fields criterias:criterias order:nil ascending:NO];
    NSString *processId = nil;
    if (result.count > 0) {
        processId = [[result objectAtIndex:0] objectForKey:@"Id"];
    }
    [result release];
    return processId;
}



@end
