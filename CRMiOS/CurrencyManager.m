//
//  CurrencyManager.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "CurrencyManager.h"


@implementation CurrencyManager

+ (void)initTable {
    Database *database = [Database getInstance];
    
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"Name"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Code"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Symbol"];
    [types addObject:@"TEXT"];
    [columns addObject:@"IssuingCountry"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Active"];
    [types addObject:@"TEXT"];
    
    [database check:@"Currency" columns:columns types:types];
    
    NSMutableArray *indexColumns;
    // unicity 
    indexColumns = [NSMutableArray arrayWithObject:@"Code"];
    [database createIndex:@"Currency" columns:indexColumns unique:true];
    
}

+ (void)initData {
    
}

+ (void)insert:(NSDictionary *)currency {
    Database *database = [Database getInstance];
    [database insert:@"Currency" item:currency];
}

+ (BOOL)exists:(NSDictionary *)currency {
    Database *database = [Database getInstance];
    NSArray *filter = [NSArray arrayWithObject:[ValuesCriteria criteriaWithColumn:@"Code" value:[currency objectForKey:@"Code"]]];
    NSArray *list = [database select:@"Currency" fields:[NSArray arrayWithObject:@"Code"] criterias:filter order:Nil ascending:YES];
    BOOL ret = [list count] > 0;
    [list release];
    return ret;
}

+ (NSArray *)read:(NSString *)filter {
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    if (filter != nil && filter.length > 0) {
        [criterias addObject:[[LikeCriteria alloc] initWithColumn:@"Name" value:filter]];
    }
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"Active" value:@"Y"]];
    NSArray *fields = [NSArray arrayWithObjects:@"Name", @"Code", @"issuingCountry", Nil];
    return [[Database getInstance] select:@"Currency" fields:fields criterias:criterias order:@"Code" ascending:YES];
}


@end
