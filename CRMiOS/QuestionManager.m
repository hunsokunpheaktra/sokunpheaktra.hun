//
//  QuestionManager.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/21/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "QuestionManager.h"
#import "Database.h"

@implementation QuestionManager

+ (void)initTables {
    //Question (*AssessmentName, *Order, Question, Weight)
    Database *database = [Database getInstance];
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"AssessmentName"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Order1"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Question"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Weight"];
    [types addObject:@"TEXT"];
    [database check:@"Question" columns:columns types:types];
    [columns release];
    [types release];
    [database createIndex:@"Question" column:@"Question" unique:YES];
    [database createIndex:@"Question" column:@"AssessmentName" unique:NO];
    NSMutableArray *indexColumns;
    indexColumns = [NSMutableArray arrayWithObjects:@"Question",@"AssessmentName", Nil];
    [database createIndex:@"Question" columns:indexColumns unique:true];
}

+ (void)insert:(NSDictionary *)newQuestion{
    Database *database = [Database getInstance];
    [database insert:@"Question" item:newQuestion];
}

@end
