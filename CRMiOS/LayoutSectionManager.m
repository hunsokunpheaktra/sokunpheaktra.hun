//
//  LayoutSectionManager.m
//  CRMiOS
//
//  Created by Sy Pauv on 6/20/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "LayoutSectionManager.h"


@implementation LayoutSectionManager

+ (void)initTable {
    
    Database *database = [Database getInstance];
    
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"subtype"];
    [types addObject:@"INTEGER"];
    [columns addObject:@"page"];
    [types addObject:@"INTEGER"];
    [columns addObject:@"section"];
    [types addObject:@"INTEGER"];
    [columns addObject:@"name"];
    [types addObject:@"TEXT"];
    [columns addObject:@"isGrouping"];
    [types addObject:@"TEXT"];
    
    [database check:@"LayoutSection" columns:columns types:types dontwant:[NSArray arrayWithObject:@"entity"]];
    
    [database createIndex:@"LayoutSection" columns:[NSArray arrayWithObjects:@"subtype", @"page", @"section", nil] unique:true];
    
}

+ (void)initData{ 
}

+ (void)save:(NSString *)subtype page:(int)page section:(int)section name:(NSString *)name isGrouping:(BOOL)isgrouping{
    NSMutableDictionary *newSection = [[NSMutableDictionary alloc]initWithCapacity:1];
    [newSection setValue:[NSString stringWithFormat:@"%@", subtype] forKey:@"subtype"];
    [newSection setValue:[NSString stringWithFormat:@"%i", page] forKey:@"page"];
    [newSection setValue:[NSString stringWithFormat:@"%i", section] forKey:@"section"];
    [newSection setValue:name forKey:@"name"];
    [newSection setValue:isgrouping ? @"1":@"0" forKey:@"isGrouping"];
    
    [[Database getInstance] insert:@"LayoutSection" item:newSection];
    
}

+ (NSArray *)read:(NSString *)subtype page:(int)page {
    
    NSArray *fields = [NSArray arrayWithObjects:@"name", @"section",@"isGrouping", nil];
    NSArray *fields2 = [NSArray arrayWithObjects:@"field", nil];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"subtype" value:subtype]];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"page" integer:page]];
    NSArray *tmpSections = [[Database getInstance] select:@"LayoutSection" fields:fields criterias:criterias order:@"section" ascending:YES];
    
    for (NSMutableDictionary *item in tmpSections) {
        Section *section = [[Section alloc] initWithName:[item objectForKey:@"name"]];
        section.isGrouping = [[item objectForKey:@"isGrouping"] isEqualToString:@"1"];
        NSMutableArray *criterias2 = [[NSMutableArray alloc] initWithCapacity:1];
        [criterias2 addObject:[ValuesCriteria criteriaWithColumn:@"subtype" value:subtype] ];
        [criterias2 addObject:[ValuesCriteria criteriaWithColumn:@"page" integer:page]];
        [criterias2 addObject:[ValuesCriteria criteriaWithColumn:@"section" value:[item objectForKey:@"section"]]];
        NSArray *tmpFields = [[Database getInstance] select:@"LayoutField" fields:fields2 criterias:criterias2 order:@"row" ascending:YES];
        for (NSMutableDictionary *item2 in tmpFields) {
            [section.fields addObject:[item2 objectForKey:@"field"]]; 
        }
        [criterias2 release];
        [tmpFields release];
        [result addObject:section];
        [section release];
    }
    //[fields release];
    [tmpSections release];
    return result;
}

@end
