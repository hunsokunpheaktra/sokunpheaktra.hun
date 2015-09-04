//
//  LayoutPageManager.m
//  CRMiOS
//
//  Created by Sy Pauv on 6/20/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "LayoutPageManager.h"


@implementation LayoutPageManager

+ (void)initTable {

    Database *database = [Database getInstance];
    
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"subtype"];
    [types addObject:@"TEXT"];    
    [columns addObject:@"page"];
    [types addObject:@"INTEGER"];
    [columns addObject:@"name"];
    [types addObject:@"TEXT"];
    [database check:@"LayoutPage" columns:columns types:types dontwant:[NSArray arrayWithObject:@"entity"]];
    
    [database createIndex:@"LayoutPage" columns:[NSArray arrayWithObjects:@"subtype", @"page", nil] unique:true];
}

+ (void)initData{ 
}

+ (void)save:(NSString *)subtype page:(int)page name:(NSString *)name{
    
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    [item setObject:[NSString stringWithFormat:@"%@", subtype] forKey:@"subtype"];
    [item setObject:[NSString stringWithFormat:@"%i", page] forKey:@"page"];
    if (name != nil) {
        [item setObject:name forKey:@"name"];
    }
    
    [[Database getInstance] insert:@"LayoutPage" item:item];
    [item release];
    
}

+ (NSArray *)read:(NSString *)subtype {
    
    NSMutableArray *fields = [NSArray arrayWithObject:@"name"];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"subtype" value:subtype]];    
    NSArray *tmp = [[Database getInstance] select:@"LayoutPage" fields:fields criterias:criterias order:nil ascending:YES];
    for (NSMutableDictionary *item in tmp) {
        NSString *name = [item objectForKey:@"name"];
        [result addObject:(name == nil ? @"" : name)];
    }
    return result;
}

+ (BOOL)hasData {
    
    NSMutableArray *fields = [NSArray arrayWithObject:@"name"];
    BOOL result = NO;
    NSArray *tmp = [[Database getInstance] select:@"LayoutPage" fields:fields criterias:nil order:nil ascending:YES];
    result = [tmp count] > 0;
    [tmp release];
    return result;
}

@end
