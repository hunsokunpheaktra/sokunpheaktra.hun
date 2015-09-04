//
//  SalesStageManager.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "SalesStageManager.h"


@implementation SalesStageManager

+ (void)initTable {
    NSLog(@"salesStage init");
    Database *database = [Database getInstance];
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"Id"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Name"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Order1"];
    [types addObject:@"TEXT"];
    [columns addObject:@"SalesProcessId"];
    [types addObject:@"TEXT"];
    [columns addObject:@"SalesCategoryName"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Probability"];
    [types addObject:@"TEXT"];
    [columns addObject: @"Default1"];
    [types addObject: @"TEXT"];

    
    [database check:@"SalesStage" columns:columns types:types];
    [columns release];
    [types release];
    // name index
    NSMutableArray *indexColumns;
    indexColumns = [NSMutableArray arrayWithObjects:@"Id", Nil];
    [database createIndex:@"SalesStage" columns:indexColumns unique:true];
    
}

+ (void)initData{
}

+ (void)insert:(NSDictionary *)newSalesStage {

    Database *database = [Database getInstance];
    [database insert:@"SalesStage" item:newSalesStage];    
}

+ (void)purge {
    Database *database = [Database getInstance];
    [database remove:@"SalesStage" criterias:nil];
}

+ (NSArray *)read:(NSString *)type {
    NSArray *fields = [NSArray arrayWithObjects:@"Id", @"Name", @"Probability", nil];
    NSString *salesProcessId = nil;
    if (type != nil) {
        salesProcessId = [SalesProcessManager read:(NSString *)type];
    }
    if (salesProcessId == nil) {
        salesProcessId = [CurrentUserManager getSalesProcessId];
    }
    
    NSArray *criterias;
    if (salesProcessId == nil || [salesProcessId length] == 0) {
        criterias = [NSArray arrayWithObject:[ValuesCriteria criteriaWithColumn:@"Default1" value:@"Y"]];    
    } else {
        criterias = [NSArray arrayWithObject:[ValuesCriteria criteriaWithColumn:@"SalesProcessId" value:salesProcessId]];
    }
    
    NSArray *result = [[Database getInstance] select:@"SalesStage" fields:fields criterias:criterias order:@"Order1" ascending:YES];
    return result;
}


@end
