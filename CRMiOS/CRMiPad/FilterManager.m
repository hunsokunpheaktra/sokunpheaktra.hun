//
//  FilterManager.m
//  CRMiPad
//
//  Created by Sy Pauv Phou on 3/31/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "FilterManager.h"


@implementation FilterManager

static NSMutableDictionary *filters;

+ (NSString *)getFilter:(NSString *)subtype {
    if (filters == nil) {
        filters = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return [filters objectForKey:subtype];
}

+ (NSArray *)getCriterias:(NSString *)subtype {
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtype];
    NSString *code = [FilterManager getFilter:subtype];
    
    if ([code isEqualToString:@"%IMPORTANT%"]) {
        [criterias addObject:[[IsNotNullCriteria alloc] initWithColumn:@"important"]];
        return criterias;
    }
    
    if ([code isEqualToString:@"%FAVORITE%"]) {
        [criterias addObject:[[ValuesCriteria alloc] initWithColumn:@"favorite" value:@"1"]];
        return criterias;
    }
    
    for (ConfigFilter *filter in [sinfo getFilters:NO]) {
        if ([filter.name isEqualToString:code]) {
            [criterias addObject:filter.criteria];
        }
    }
    return criterias;
}


+ (void)setFilter:(NSString *)subtype code:(NSString *)code {
    if (filters == nil) {
        filters = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    [filters setObject:code forKey:subtype];
}






@end
