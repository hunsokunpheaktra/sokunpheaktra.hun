//
//  AnswerManager.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/21/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "AnswerManager.h"
#import "Database.h"
@implementation AnswerManager

+ (void)initTables {
    //Answer (*AssessmentName, *QuestionOrder, *Order, Answer, Score)
    Database *database = [Database getInstance];
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"AssessmentName"];
    [types addObject:@"TEXT"];
    [columns addObject:@"QuestionOrder"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Order1"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Answer"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Score"];
    [types addObject:@"TEXT"];
    [database check:@"Answer" columns:columns types:types];
    [columns release];
    [types release];
    
    NSMutableArray *indexColumns;
    indexColumns = [NSMutableArray arrayWithObjects:@"Answer",@"QuestionOrder",@"AssessmentName", Nil];
    [database createIndex:@"Answer" columns:indexColumns unique:true];
}

+ (void)insert:(NSDictionary *)newAnswer {
    Database *database = [Database getInstance];
    [database insert:@"Answer" item:newAnswer];
}

@end
