//
//  LogManager.h
//
//  Created by Sy Pauv Phou on 4/27/11.
//

#import <Foundation/Foundation.h>
#import "DatabaseManager.h"
#import "LogItem.h"
#import "Item.h"

@interface LogManager : NSObject {
    
}

+ (void)initTable;
+ (void)initData;
+ (void)purge;
+ (void)error:(NSString *)log task:(int)task;
+ (void)warning:(NSString *)log task:(int)task withId:(NSString *)errorId entity:(NSString *)entity;
+ (void)info:(NSString *)log task:(int)task entity:(NSString *)entity;
+ (void)log:(NSString *)log type:(NSString *)type task:(int)task count:(int)count withId:(NSString *)errorId entity:(NSString *)entity;
+ (NSArray *)read;
+ (NSArray *)list;
+ (Item *)find:(NSDictionary *)criterias;

@end
