//
//  LogManager.m
//
//  Created by Sy Pauv Phou on 4/27/11.
//

#import "LogManager.h"

@implementation LogManager

+ (void)initTable {
    DatabaseManager *database = [DatabaseManager getInstance];
    
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
    [[DatabaseManager getInstance] remove:@"Synclog" criterias:Nil];
}

+ (void)error:(NSString *)log task:(int)task {
    [self log:log type:@"Error" task:task count:0 withId:nil entity:nil];
}

+ (void)warning:(NSString *)log task:(int)task withId:(NSString *)errorId entity:(NSString *)entity{
    [self log:log type:@"Warning" task:task count:0 withId:errorId entity:entity];
}

+ (void)info:(NSString *)log task:(int)task entity:(NSString *)entity{
    [self log:log type:@"Info" task:task count:0 withId:nil entity:entity];
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
        [item setObject:entity forKey:@"entity"];
    }

    [[DatabaseManager getInstance] insert:@"Synclog" item:item];
    [item release];
    [dateFormat release];
    
}


+ (NSArray *)read {
    DatabaseManager *database = [DatabaseManager getInstance];
    NSArray *countResult = [database selectSql:@"SELECT MAX(num) count FROM Synclog" params:Nil fields:[NSArray arrayWithObject:@"count"]];
    int count = [[[countResult objectAtIndex:0] objectForKey:@"count"] intValue];
    return [database selectSql:[NSString stringWithFormat:@"SELECT date, type, log,Id,entity task FROM Synclog WHERE num >= %d", count - 100] params:nil fields:[NSArray arrayWithObjects:@"date", @"type", @"log", @"task",@"Id",@"entity", nil]];
}

+ (NSArray *)list {
    NSMutableArray *logList = [[NSMutableArray alloc] initWithCapacity:1];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    DatabaseManager *database = [DatabaseManager getInstance];
    NSArray *tmpList = [database selectSql:@"SELECT date, type, log, task, count, Id, entity FROM Synclog ORDER BY num" params:nil fields:[NSArray arrayWithObjects:@"date", @"type", @"log", @"task", @"count",@"Id",@"entity", nil]];
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
        if ([logItem.type isEqualToString:@"Success"]) {
            for (LogItem *logItem2 in logList) {
                if ([logItem.task isEqualToString:logItem2.task]) {
                    found = YES;
                    logItem2.type = @"Success";
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

+ (Item *)find:(NSDictionary *)criterias {
    Item *item = nil;
    NSMutableArray *fields = [[NSMutableArray alloc] initWithObjects:@"count",@"entity",@"log", nil];
    NSArray *items = [[DatabaseManager getInstance] select:@"Synclog" fields:fields criterias:criterias order:Nil ascending:YES];
    if ([items count] > 0) {
        NSDictionary *itemFields = [items objectAtIndex:0];
        item = [[Item alloc] init:@"Synclog" fields:itemFields];
    }
    [items release];
    [fields release];
    return item;
}

@end
