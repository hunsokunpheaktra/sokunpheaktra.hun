//
//  IndustryManager.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/27/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "IndustryManager.h"


@implementation IndustryManager





+ (void)initTable {
    Database *database = [Database getInstance];
    
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"Code"];
    [types addObject:@"TEXT"];
    [columns addObject:@"LanguageCode"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Title"];
    [types addObject:@"TEXT"];
    
    [database check:@"Industry" columns:columns types:types];
    
    NSMutableArray *indexColumns;
    // unicity 
    indexColumns = [NSMutableArray arrayWithObjects:@"Code", @"LanguageCode", nil];
    [database createIndex:@"Industry" columns:indexColumns unique:true];
    
}

+ (void)initData {
    
}


+ (void)insert:(NSDictionary *)industry {
    Database *database = [Database getInstance];
    [database insert:@"Industry" item:industry];
}

+ (void)purge {
    Database *database = [Database getInstance];
    [database remove:@"Industry" criterias:nil];
}

+ (NSArray *)read:(NSString *)languageCode filter:(NSString *)filter {
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"LanguageCode" value:languageCode]];
    if (filter != nil && filter.length > 0) {
        [criterias addObject:[[LikeCriteria alloc] initWithColumn:@"Title" value:filter]];
    }
    NSArray *fields = [NSArray arrayWithObjects:@"Title", nil];
    return [[Database getInstance] select:@"Industry" fields:fields criterias:criterias order:@"Title" ascending:YES];
}

@end
