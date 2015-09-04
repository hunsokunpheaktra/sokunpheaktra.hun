//
//  CustomRecordTypeManager.m
//  CRMiOS
//
//  Created by Sy Pauv on 6/14/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "CustomRecordTypeManager.h"

// cache for custom record types
static NSMutableDictionary *cache;

@implementation CustomRecordTypeManager

+ (void)initTable {

    Database *database = [Database getInstance];

    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    
    [columns addObject:@"Name"];
    [types addObject:@"TEXT"];
    [columns addObject:@"LanguageCode"];
    [types addObject:@"TEXT"];
    [columns addObject:@"SingularName"];
    [types addObject:@"INTEGER"];
    [columns addObject:@"PluralName"];
    [types addObject:@"INTEGER"];
    [columns addObject:@"ShortName"];
    [types addObject:@"INTEGER"];
    [database check:@"CustomRecordType" columns:columns types:types];
    [database createIndex:@"CustomRecordType" columns:[NSArray arrayWithObjects:@"Name", @"LanguageCode",nil] unique:true];
    [columns release];
    [types release];
}

+ (void)initData {
    cache = [[NSMutableDictionary alloc] initWithCapacity:1];
}

+ (void)insert:(NSDictionary *)record {
    [cache removeAllObjects];
    Database *database = [Database getInstance];
    [database insert:@"CustomRecordType" item:record];
    
}


+ (NSString *)read:(NSString *)entity languageCode:(NSString *)languageCode plural:(BOOL)plural {
    NSString *key = [NSString stringWithFormat:@"%@/%@/%@", entity, languageCode, plural ? @"YES" : @"NO"];
    NSString *result = [cache objectForKey:key];
    if (result != nil) {
        if (result == (id)[NSNull null]) {
            return nil;
        }
        return result;
    }
    Database *database = [Database getInstance];
    NSArray *fields = [NSArray arrayWithObjects:@"PluralName", @"SingularName", nil];
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"LanguageCode" value:languageCode]];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"Name" value:entity]];
    NSArray *results = [database select:@"CustomRecordType" fields:fields criterias:criterias order:nil ascending:YES];
    if ([results count] == 0) {
        [cache setObject:[NSNull null] forKey:key];
        return nil;
    }
    result = [[results objectAtIndex:0] objectForKey:plural ? @"PluralName" : @"SingularName"];
    [cache setObject:result forKey:key];
    return result;
}


@end
