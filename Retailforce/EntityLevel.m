//
//  EntityLevel.m
//  RetailForce
//
//  Created by Gaeasys on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EntityLevel.h"
#import "DatabaseManager.h"
#import "Item.h"

@implementation EntityLevel


+ (void)initTable {
    DatabaseManager *database = [DatabaseManager getInstance];
    
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"EntityName"];
    [types addObject:@"TEXT PRIMARY KEY"];
    [columns addObject:@"Level"];
    [types addObject:@"TEXT"];
    [database check:@"EntityLevel" columns:columns types:types];
    [columns release];
    [types release];
    [database createIndex:@"EntityLevel" columns:[NSArray arrayWithObject:@"EntityName"] unique:true];
}

+ (void)save:(NSDictionary *)item{
    DatabaseManager *database = [DatabaseManager getInstance];
    
    if ([[database select:@"EntityLevel" fields:[NSArray arrayWithObject:@"EntityName"] column:@"EntityName" value:[item valueForKey:@"EntityName"] order:Nil ascending:YES] count] == 0) {
        [database insert:@"EntityLevel" item:item];
    } else {
        [database update:@"EntityLevel" item:item column:@"EntityName" value:[item valueForKey:@"EntityName"]];
    } 
}

+ (NSString *)readLevel:(NSString *)entityname {
    NSString *value = nil;
    NSArray *fields = [NSArray arrayWithObject:@"Level"];
    NSArray *results = [[DatabaseManager getInstance] select:@"EntityLevel" fields:fields column:@"EntityName" value:entityname order:Nil ascending:YES];
    if ([results count] > 0) {
        NSMutableDictionary *item = [results objectAtIndex:0];
        value = [item objectForKey:@"Level"];
    }
    [results release];
    return value;
}

+ (NSArray*)readEntities {
    NSArray *fields = [NSArray arrayWithObjects:@"EntityName",@"Level",nil];
    NSArray * results = [[DatabaseManager getInstance] select:@"EntityLevel"  fields:fields criterias:nil order:nil ascending:YES];
    
    return results;
}


@end
