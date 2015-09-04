//
//  TransactionManager.m
//  SalesforceSyncModule
//
//  Created by Gaeasys Admin on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TransactionInfoManager.h"
#import "DatabaseManager.h"

@implementation TransactionInfoManager


+ (void)initTable {
    DatabaseManager *database = [DatabaseManager getInstance];
    
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"TaskName"];
    [types addObject:@"TEXT PRIMARY KEY"];
    [columns addObject:@"LastSyncDate"];
    [types addObject:@"TEXT"];
    [database check:@"TransactionInfo" columns:columns types:types];
    [columns release];
    [types release];
    [database createIndex:@"TransactionInfo" columns:[NSArray arrayWithObject:@"TaskName"] unique:true];
}

+ (void)save:(NSDictionary *)item{
    DatabaseManager *database = [DatabaseManager getInstance];
    if ([[database select:@"TransactionInfo" fields:[NSArray arrayWithObject:@"TaskName"] column:@"TaskName" value:[item valueForKey:@"TaskName"] order:Nil ascending:YES] count] == 0) {
        [database insert:@"TransactionInfo" item:item];
    } else {
        [database update:@"TransactionInfo" item:item column:@"TaskName" value:[item valueForKey:@"TaskName"]];
    } 
}

+ (NSString *)readLastSyncDate:(NSString *)taskname {
    NSString *value = nil;
    NSArray *fields = [NSArray arrayWithObject:@"LastSyncDate"];
    NSArray *results = [[DatabaseManager getInstance] select:@"TransactionInfo" fields:fields column:@"TaskName" value:taskname order:Nil ascending:YES];
    if ([results count] > 0) {
        NSMutableDictionary *item = [results objectAtIndex:0];
        value = [item objectForKey:@"LastSyncDate"];
    }
    [results release];
    return value;
}

@end
