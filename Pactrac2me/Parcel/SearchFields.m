//
//  SearchFields.m
//  Parcel
//
//  Created by Gaeasys on 12/14/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "SearchFields.h"

@implementation SearchFields



+ (void)save:(NSString *)value {
    
    DatabaseManager *database = [DatabaseManager getInstance];
    NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:1];
    [item setValue:value forKey:@"fieldName"];
    [database insert:@"SearchFields" item:item];
    
    [item release];
}

+ (NSArray *)read {
    NSMutableArray *values = nil;
    NSArray *fields = [NSArray arrayWithObject:@"fieldName"];
    NSArray *results = [[DatabaseManager getInstance] select:@"SearchFields" fields:fields criterias:nil order:nil ascending:YES];
    
    if ([results count] > 0) {
        values = [NSMutableArray arrayWithCapacity:1];
        for (NSMutableDictionary *item in results) {
            [values addObject:[item objectForKey:@"fieldName"]];
        }
    }
    
    [results release];
    
    return values;
}


+ (void)initTable {
    DatabaseManager *database = [DatabaseManager getInstance];
    
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"fieldName"];
    [types addObject:@"TEXT PRIMARY KEY"];
    [database check:@"SearchFields" columns:columns types:types];
    [columns release];
    [types release];
    [database createIndex:@"SearchFields" columns:[NSArray arrayWithObject:@"fieldName"] unique:true];
    
}

+ (void)initDatas {

//    [SearchFields save:@"user_email"];
    [SearchFields save:@"receiver"];
    [SearchFields save:@"forwarder"];
    [SearchFields save:@"note"];
    [SearchFields save:@"description"];
    [SearchFields save:@"trackingNo"];
    [SearchFields save:@"shippingDate"];
    [SearchFields save:@"reminderDate"];
    
}



@end
