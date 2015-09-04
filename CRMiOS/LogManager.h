//
//  LogManager.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/27/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"
#import "LogItem.h"


@interface LogManager : NSObject {
    
}

+ (void)initTable;
+ (void)initData;
+ (void)purge;
+ (void)error:(NSString *)log task:(int)task;
+ (void)warning:(NSString *)log task:(int)task withId:(NSString *)errorId entity:(NSString *)entity;
+ (void)info:(NSString *)log task:(int)task;
+ (void)log:(NSString *)log type:(NSString *)type task:(int)task count:(int)count withId:(NSString *)errorId entity:(NSString *)entity;
+ (NSArray *)read;
+ (NSArray *)list;
+ (void)success:(NSString *)log task:(int)task count:(int)count;

@end
