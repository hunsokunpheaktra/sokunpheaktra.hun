//
//  LogManager.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/27/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "LogManager.h"


@implementation LogManager

+ (void)initTable {
    Database *database = [Database getInstance];
    
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"num"];
    [types addObject:@"INTEGER PRIMARY KEY AUTOINCREMENT"];
    [columns addObject:@"task"];
    [types addObject:@"INTEGER"];
    [columns addObject:@"date"];
    [types addObject:@"TEXT"];
    [columns addObject:@"type"];
    [types addObject:@"TEXT"];
    [columns addObject:@"log"];
    [types addObject:@"TEXT"];
    [columns addObject:@"count"];
    [types addObject:@"INTEGER"];
    [columns addObject:@"Id"];
    [types addObject:@"TEXT"];
    [columns addObject:@"entity"];
    [types addObject:@"TEXT"];

    [database check:@"Synclog" columns:columns types:types];
    [columns release];
    [types release];
}

+ (void)initData {
    
}

+ (void)purge {
    [[Database getInstance] remove:@"Synclog" criterias:Nil];
}

+ (void)error:(NSString *)log task:(int)task {
    [self log:log type:@"ERROR" task:task count:0 withId:nil entity:nil];
}

+ (void)warning:(NSString *)log task:(int)task withId:(NSString *)errorId entity:(NSString *)entity{
    [self log:log type:@"WARNING" task:task count:0 withId:errorId entity:entity];
}

+ (void)info:(NSString *)log task:(int)task {
    [self log:log type:@"INFO" task:task count:0 withId:nil entity:nil];
}

+ (void)success:(NSString *)log task:(int)task count:(int)count {
    [self log:log type:@"SUCCESS" task:task count:count withId:nil entity:nil];
}


+ (void)log:(NSString *)log type:(NSString *)type task:(int)task count:(int)count withId:(NSString *)errorId entity:(NSString *)entity{
    NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:1];
    [item setObject:log forKey:@"log"];
    [item setObject:[NSNumber numberWithInt:task] forKey:@"task"];
    [item setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    [item setObject:dateString forKey:@"date"];
    [item setObject:type forKey:@"type"];
    
    if (errorId != nil && entity != nil) {
        [item setObject:errorId forKey:@"Id"];
        [item setObject:entity forKey:@"Entity"];
    }

    [[Database getInstance] insert:@"Synclog" item:item];
    [item release];
    [dateFormat release];
    
}


+ (NSArray *)read {
    Database *database = [Database getInstance];
    NSArray *countResult = [database selectSql:@"SELECT MAX(num) count FROM Synclog" params:Nil fields:[NSArray arrayWithObject:@"count"]];
    int count = [[[countResult objectAtIndex:0] objectForKey:@"count"] intValue];
    return [database selectSql:[NSString stringWithFormat:@"SELECT date, type, log,Id,entity task FROM Synclog WHERE num >= %d", count - 100] params:nil fields:[NSArray arrayWithObjects:@"date", @"type", @"log", @"task",@"Id",@"entity", nil]];
}

+ (NSArray *)list {
    NSMutableArray *logList = [[NSMutableArray alloc] initWithCapacity:1];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    Database *database = [Database getInstance];
    NSArray *tmpList = [database selectSql:@"SELECT date, type, log, task, count, Id, entity FROM Synclog ORDER BY task, date" params:nil fields:[NSArray arrayWithObjects:@"date", @"type", @"log", @"task", @"count", @"Id", @"entity", nil]];
    for (NSDictionary *tmpItem in tmpList) {
        LogItem *logItem = [[LogItem alloc] init];
        logItem.message = [tmpItem objectForKey:@"log"];
        logItem.date = [dateFormat dateFromString:[tmpItem objectForKey:@"date"]];
        logItem.type = [tmpItem objectForKey:@"type"];
        logItem.task = [tmpItem objectForKey:@"task"];
        logItem.count = [tmpItem objectForKey:@"count"];
        logItem.errorId = [tmpItem objectForKey:@"Id"];
        logItem.entity = [tmpItem objectForKey:@"entity"];
        BOOL found = NO;
        if ([logItem.type isEqualToString:@"SUCCESS"]) {
            for (LogItem *logItem2 in logList) {
                if ([logItem.task isEqualToString:logItem2.task]) {
                    found = YES;
                    logItem2.type = @"SUCCESS";
                    logItem2.count = logItem.count;
                    break;
                }
            }
        }
        if (!found) {
            [logList addObject:logItem];
        } 
        [logItem release];
    }
    [tmpList release];
    [dateFormat release];
    return logList;
}

@end
