//
//  AssessmentManager.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/21/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "AssessmentManager.h"
#import "Database.h"

@implementation AssessmentManager

+ (void)initTables {
    //Assessment (*Name, Description)
    Database *database = [Database getInstance];
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"Name"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Description"];
    [types addObject:@"TEXT"];
    //(*Name, Description)
    [database check:@"Assessment" columns:columns types:types];
    [columns release];
    [types release];
    [database createIndex:@"Assessment" column:@"Name" unique:YES];
}

+ (void)insert:(NSDictionary *)newAssessment {
    Database *database = [Database getInstance];
    [database insert:@"Assessment" item:newAssessment];
}


@end
